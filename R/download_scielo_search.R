#' Search and download records from SciELO via Crossref API
#'
#' Queries the Crossref REST API filtered by the official SciELO DOI prefix (`10.1590`),
#' retrieving metadata records for peer-reviewed journal articles across SciELO collections
#' (Brazil, Colombia, Mexico, Chile, Argentina, etc.), and parses them into a standardized
#' `bibliometrixDB` data frame.
#'
#' @param query Character. Search terms or query expression (e.g. `"dengue vacina"`).
#' @param limit Integer. Maximum number of records to retrieve. Default is 50.
#' @param convert Logical. If `TRUE` (default), transforms the result into a canonical
#'   `bibliometrixDB` data frame using [as_bibliometrix()].
#' @param progress Logical. If `TRUE` (default), prints progress messages during pagination.
#' @param normalize_authors Logical. If `TRUE` (default), normalizes author names.
#' @param timeout Numeric. Maximum seconds before connection timeout. Default is 30.
#' @return A `data.frame` with class `c("bibliometrixDB", "data.frame")` containing SciELO records.
#' @export
download_scielo_search <- function(query,
                                   limit = 50L,
                                   convert = TRUE,
                                   progress = TRUE,
                                   normalize_authors = TRUE,
                                   timeout = 30) {
  if (!is.character(query) || length(query) != 1L || !nzchar(trimws(query))) {
    stop("O argumento 'query' deve ser uma string de busca nao vazia.", call. = FALSE)
  }

  limit <- as.integer(limit)
  if (is.na(limit) || limit <= 0L) {
    stop("O argumento 'limit' deve ser um inteiro positivo.", call. = FALSE)
  }

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("O pacote 'jsonlite' e necessario para consultas a API do Crossref/SciELO.", call. = FALSE)
  }

  old_timeout <- getOption("timeout")
  on.exit(options(timeout = old_timeout), add = TRUE)
  options(timeout = max(timeout, 10))

  base_url <- "https://api.crossref.org/works"
  page_size <- min(limit, 50L)
  accumulated_items <- list()
  offset <- 0L

  while (length(accumulated_items) < limit) {
    current_rows <- min(page_size, limit - length(accumulated_items))

    if (isTRUE(progress)) {
      message(sprintf("[SciELO API] Consultando registros %d a %d (buscando ate %d)...",
                      offset + 1L, offset + current_rows, limit))
    }

    req_url <- paste0(
      base_url,
      "?query=", utils::URLencode(query),
      "&filter=prefix:10.1590",
      "&rows=", as.integer(current_rows),
      "&offset=", as.integer(offset)
    )

    h <- c("User-Agent" = "bibliolatam/0.1.0 (mailto:suporte@bran.org)")

    conn <- tryCatch(
      url(req_url, open = "rb", headers = h),
      error = function(e) {
        stop(sprintf("Falha de conexao com o endpoint Crossref/SciELO: %s", e$message), call. = FALSE)
      }
    )

    raw_lines <- tryCatch(
      readLines(conn, warn = FALSE, encoding = "UTF-8"),
      error = function(e) {
        close(conn)
        stop(sprintf("Erro ao ler resposta da API SciELO/Crossref: %s", e$message), call. = FALSE)
      }
    )
    close(conn)

    raw_txt <- paste(raw_lines, collapse = "\n")
    if (!nzchar(raw_txt) || !grepl("^\\{", trimws(raw_txt))) {
      stop("Resposta invalida recebida da API SciELO/Crossref (formato nao-JSON).", call. = FALSE)
    }

    parsed <- tryCatch(
      jsonlite::fromJSON(raw_txt, simplifyVector = FALSE),
      error = function(e) {
        stop(sprintf("Falha ao interpretar JSON da API SciELO/Crossref: %s", e$message), call. = FALSE)
      }
    )

    if (!identical(parsed$status, "ok") || is.null(parsed$message$items)) {
      break
    }

    batch <- parsed$message$items
    if (length(batch) == 0L) {
      break
    }

    accumulated_items <- c(accumulated_items, batch)

    total_results <- as.integer(parsed$message[["total-results"]])
    if (!is.na(total_results) && length(accumulated_items) >= total_results) {
      break
    }

    offset <- offset + length(batch)
  }

  if (length(accumulated_items) == 0L) {
    warning("Nenhum registro encontrado no SciELO para a consulta fornecida.", call. = FALSE)
    return(data.frame())
  }

  df <- parse_crossref_scielo_items(accumulated_items, normalize_authors_flag = normalize_authors)

  if (isTRUE(convert)) {
    df <- as_bibliometrix(df, dbsource = "scielo")
  }

  df
}

#' Internal helper to parse Crossref SciELO items into a data frame
#'
#' @param items List of work items returned by Crossref API.
#' @param normalize_authors_flag Logical.
#' @return A data.frame formatted for bibliometrix.
#' @noRd
parse_crossref_scielo_items <- function(items, normalize_authors_flag = TRUE) {
  if (length(items) == 0L) {
    return(data.frame())
  }

  n <- length(items)
  titles <- character(n)
  authors <- character(n)
  sources <- character(n)
  years <- character(n)
  abstracts <- character(n)
  keywords <- character(n)
  doctypes <- character(n)
  languages <- character(n)
  identifiers <- character(n)
  dois <- character(n)
  volumes <- character(n)
  pages <- character(n)

  for (i in seq_len(n)) {
    it <- items[[i]]

    # Titulo (TI)
    ti <- if (!is.null(it$title) && length(it$title) > 0L) {
      paste(unlist(it$title), collapse = " ")
    } else {
      NA_character_
    }
    titles[i] <- if (nzchar(trimws(ti))) trimws(ti) else NA_character_

    # Autores (AU)
    au_vec <- character(0L)
    if (!is.null(it$author) && length(it$author) > 0L) {
      for (a in it$author) {
        if (!is.null(a$family) && nzchar(trimws(a$family))) {
          if (!is.null(a$given) && nzchar(trimws(a$given))) {
            au_vec <- c(au_vec, paste0(trimws(a$family), ", ", trimws(a$given)))
          } else {
            au_vec <- c(au_vec, trimws(a$family))
          }
        } else if (!is.null(a$name) && nzchar(trimws(a$name))) {
          au_vec <- c(au_vec, trimws(a$name))
        }
      }
    }

    if (length(au_vec) > 0L) {
      au_str <- paste(au_vec, collapse = "; ")
      if (isTRUE(normalize_authors_flag)) {
        au_str <- normalize_authors(au_str)
      }
      authors[i] <- au_str
    } else {
      authors[i] <- "ANONYMOUS"
    }

    # Ano (PY)
    py_val <- NA_character_
    issued_dates <- it$issued[["date-parts"]]
    pub_online <- it[["published-online"]][["date-parts"]]
    pub_print <- it[["published-print"]][["date-parts"]]
    created_dates <- it$created[["date-parts"]]

    date_src <- if (!is.null(issued_dates) && length(issued_dates) > 0L) {
      issued_dates[[1]]
    } else if (!is.null(pub_print) && length(pub_print) > 0L) {
      pub_print[[1]]
    } else if (!is.null(pub_online) && length(pub_online) > 0L) {
      pub_online[[1]]
    } else if (!is.null(created_dates) && length(created_dates) > 0L) {
      created_dates[[1]]
    } else {
      NULL
    }

    if (!is.null(date_src) && length(date_src) > 0L) {
      y_cand <- as.character(date_src[[1]])
      if (grepl("^[12][0-9]{3}$", y_cand)) {
        py_val <- y_cand
      }
    }
    years[i] <- py_val

    # Fonte / Periodico (SO)
    so_val <- NA_character_
    if (!is.null(it[["container-title"]]) && length(it[["container-title"]]) > 0L) {
      so_val <- toupper(trimws(it[["container-title"]][[1]]))
    } else if (!is.null(it[["short-container-title"]]) && length(it[["short-container-title"]]) > 0L) {
      so_val <- toupper(trimws(it[["short-container-title"]][[1]]))
    }
    if (is.na(so_val) || !nzchar(so_val)) {
      so_val <- "SCIELO"
    }
    sources[i] <- so_val

    # Resumo (AB)
    ab_val <- NA_character_
    if (!is.null(it$abstract) && nzchar(trimws(it$abstract))) {
      clean_ab <- gsub("<[^>]+>", " ", it$abstract)
      clean_ab <- gsub("\\s+", " ", clean_ab)
      ab_val <- trimws(clean_ab)
    }
    abstracts[i] <- ab_val

    # Palavras-chave / Assuntos (DE)
    de_val <- NA_character_
    if (!is.null(it$subject) && length(it$subject) > 0L) {
      subj_items <- unlist(it$subject)
      subj_items <- subj_items[nzchar(trimws(subj_items))]
      if (length(subj_items) > 0L) {
        de_val <- toupper(paste(unique(trimws(subj_items)), collapse = "; "))
      }
    }
    keywords[i] <- de_val

    # Tipo Documental (DT)
    type_raw <- if (!is.null(it$type)) tolower(trimws(it$type)) else ""
    dt_val <- if (grepl("journal-article|article", type_raw)) {
      "ARTICLE"
    } else if (grepl("book-chapter", type_raw)) {
      "BOOK_CHAPTER"
    } else if (grepl("book", type_raw)) {
      "BOOK"
    } else if (grepl("proceedings|conference", type_raw)) {
      "CONFERENCE"
    } else {
      "ARTICLE"
    }
    doctypes[i] <- dt_val

    # Idioma (LA)
    la_val <- "PORTUGUESE"
    if (!is.null(it$language) && nzchar(trimws(it$language))) {
      l_raw <- tolower(trimws(it$language))
      la_val <- if (l_raw %in% c("pt", "por", "portuguese", "portugues")) {
        "PORTUGUESE"
      } else if (l_raw %in% c("es", "spa", "spanish", "espanhol")) {
        "SPANISH"
      } else if (l_raw %in% c("en", "eng", "english", "ingles")) {
        "ENGLISH"
      } else {
        toupper(l_raw)
      }
    }
    languages[i] <- la_val

    # DOI (DI) e Identificador (UT)
    doi_val <- if (!is.null(it$DOI) && nzchar(trimws(it$DOI))) trimws(it$DOI) else NA_character_
    dois[i] <- doi_val
    identifiers[i] <- if (!is.na(doi_val)) paste0("https://doi.org/", doi_val) else NA_character_

    # Volume (VL) e Paginas (BP/EP)
    volumes[i] <- if (!is.null(it$volume)) as.character(it$volume) else NA_character_
    pages[i] <- if (!is.null(it$page)) as.character(it$page) else NA_character_
  }

  df <- data.frame(
    TI = titles,
    AU = authors,
    SO = sources,
    PY = years,
    AB = abstracts,
    DE = keywords,
    DT = doctypes,
    LA = languages,
    UT = identifiers,
    DI = dois,
    VL = volumes,
    BP = pages,
    stringsAsFactors = FALSE
  )

  df
}
