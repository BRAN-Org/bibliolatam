#' Download SciELO JATS XML articles by DOI or PID
#'
#' Retrieves full-text NLM/JATS XML documents directly from official SciELO
#' endpoints using standard DOIs, classic PIDs (`S...`), or SciELO article URLs.
#' Follows HTTP redirections using base R networking, validates XML payload integrity,
#' and optionally parses the downloaded files directly into a `bibliometrixDB` data frame.
#'
#' @param ids Character vector of DOIs (e.g. `"10.1590/S0034-8910.2014048004911"`),
#'   SciELO PIDs, or article URLs.
#' @param dest_dir Character. Directory where `.xml` files will be saved.
#'   Defaults to a temporary directory created via [tempfile()].
#' @param parse Logical. If `TRUE` (default), calls [read_scielo_jats()] on the
#'   downloaded files and returns a parsed bibliometric data frame. If `FALSE`,
#'   returns a character vector of downloaded file paths.
#' @param convert Logical. Passed to [read_scielo_jats()] when `parse = TRUE`.
#'   Default is `TRUE`.
#' @param progress Logical. If `TRUE` (default), prints progress messages during
#'   retrieval.
#' @param timeout Numeric. Maximum seconds allowed per article download. Default is 25.
#' @return If `parse = TRUE`, a `data.frame` with class `c("bibliometrixDB", "data.frame")`.
#'   If `parse = FALSE`, a character vector of local file paths to the downloaded XMLs.
#' @export
download_scielo_jats <- function(ids,
                                 dest_dir = tempfile(pattern = "scielo_jats_"),
                                 parse = TRUE,
                                 convert = TRUE,
                                 progress = TRUE,
                                 timeout = 25) {
  if (!is.character(ids) || length(ids) == 0L) {
    stop("O argumento 'ids' precisa ser um vetor de caracteres nao vazio.", call. = FALSE)
  }

  ids <- trimws(ids)
  ids <- ids[nzchar(ids)]

  if (length(ids) == 0L) {
    stop("Nenhum identificador valido fornecido.", call. = FALSE)
  }

  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
  }

  old_timeout <- getOption("timeout")
  on.exit(options(timeout = old_timeout), add = TRUE)
  options(timeout = max(timeout, 10))

  successful_files <- character(0L)
  total <- length(ids)

  for (i in seq_along(ids)) {
    id <- ids[i]
    safe_name <- gsub("[^A-Za-z0-9_-]", "_", id)
    target_file <- file.path(dest_dir, paste0(safe_name, ".xml"))

    xml_url <- resolve_scielo_xml_url(id)

    if (is.null(xml_url) || !nzchar(xml_url)) {
      warning(sprintf("[%d/%d] Nao foi possivel resolver URL para %s", i, total, id), call. = FALSE)
      next
    }

    dl_ok <- FALSE
    for (attempt in 1:2) {
      dl_ok <- tryCatch({
        utils::download.file(
          url = xml_url,
          destfile = target_file,
          quiet = TRUE,
          headers = c("User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) bibliolatam/0.1")
        )
        file.exists(target_file) && is_valid_scielo_xml(target_file)
      }, error = function(e) {
        FALSE
      })
      if (dl_ok) break
      Sys.sleep(0.4)
    }

    if (!dl_ok || !file.exists(target_file)) {
      if (file.exists(target_file)) unlink(target_file)
      warning(sprintf("[%d/%d] Falha no download de %s", i, total, id), call. = FALSE)
      next
    }

    successful_files <- c(successful_files, target_file)

    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] %s -> OK (%s)", i, total, id, basename(target_file)))
    }
  }

  if (length(successful_files) == 0L) {
    stop("Nenhum arquivo XML valido foi baixado.", call. = FALSE)
  }

  if (isTRUE(parse)) {
    read_scielo_jats(dest_dir, convert = convert)
  } else {
    successful_files
  }
}

get_headers_with_retry <- function(url, retries = 3L) {
  h <- NULL
  for (attempt in seq_len(retries)) {
    h <- tryCatch(
      curlGetHeaders(url, redirect = TRUE),
      error = function(e) NULL
    )
    if (!is.null(h) && length(h) > 0L) {
      status <- attr(h, "status")
      if (is.null(status) || status < 500) {
        return(h)
      }
    }
    Sys.sleep(0.4)
  }
  h
}

resolve_scielo_xml_url <- function(id) {
  id <- trimws(id)
  id_clean <- gsub("^https?://(dx\\.)?doi\\.org/", "", id, ignore.case = TRUE)

  # Determina URL inicial para seguir redirecionamento
  start_url <- if (grepl("^10\\.", id_clean)) {
    paste0("https://doi.org/", id_clean)
  } else if (grepl("^https?://", id, ignore.case = TRUE)) {
    id
  } else if (grepl("^S[0-9]{4}-[0-9]{4}", id_clean, ignore.case = TRUE)) {
    paste0("https://www.scielo.br/scielo.php?script=sci_arttext&pid=", id_clean)
  } else {
    paste0("https://doi.org/", id_clean)
  }

  headers <- get_headers_with_retry(start_url)

  if (is.null(headers) || length(headers) == 0L) {
    return(NULL)
  }

  status <- attr(headers, "status")
  if (!is.null(status) && status >= 400) {
    return(NULL)
  }

  # Extrai cabecalhos location de redirecionamentos
  locs <- grep("location:", headers, ignore.case = TRUE, value = TRUE)

  landing_url <- if (length(locs) > 0L) {
    last_loc <- trimws(sub("^location:[[:space:]]*", "", locs[length(locs)], ignore.case = TRUE))
    last_loc <- sub("[\r\n]+$", "", last_loc)
    if (startsWith(last_loc, "/")) {
      paste0("https://www.scielo.br", last_loc)
    } else {
      last_loc
    }
  } else {
    if (grepl("^https?://(dx\\.)?doi\\.org/", start_url, ignore.case = TRUE)) {
      return(NULL)
    }
    start_url
  }

  # Se a landing URL ja tem format=xml, retorna direto
  if (grepl("format=xml", landing_url, ignore.case = TRUE)) {
    return(landing_url)
  }

  sep <- if (grepl("\\?", landing_url)) "&" else "?"
  paste0(landing_url, sep, "format=xml")
}

is_valid_scielo_xml <- function(file_path) {
  if (!file.exists(file_path) || file.info(file_path)$size < 200) {
    return(FALSE)
  }

  header_lines <- readLines(file_path, n = 20, encoding = "UTF-8", warn = FALSE)
  header_text <- paste(header_lines, collapse = " ")

  grepl("<article\\b", header_text, ignore.case = TRUE)
}
