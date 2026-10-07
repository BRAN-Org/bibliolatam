#' Internal helper to query IBICT VuFind API
#'
#' @param base_url Character. API endpoint URL.
#' @param query Character. Search terms.
#' @param limit Integer. Number of records requested.
#' @param page Integer. Page number.
#' @param timeout Numeric. Seconds before timeout.
#' @return A list with parsed response or stops on error.
#' @noRd
query_vufind_api <- function(base_url, query, limit = 20L, page = 1L, timeout = 30) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("O pacote 'jsonlite' e necessario para consultas a API da BDTD/Oasisbr. Instale com install.packages('jsonlite').", call. = FALSE)
  }

  old_timeout <- getOption("timeout")
  on.exit(options(timeout = old_timeout), add = TRUE)
  options(timeout = max(timeout, 10))

  fields <- c(
    "field[]=title",
    "field[]=authors",
    "field[]=publicationDates",
    "field[]=institutions",
    "field[]=formats",
    "field[]=summary",
    "field[]=subjects",
    "field[]=urls",
    "field[]=id",
    "field[]=languages",
    "field[]=cleanDoi"
  )

  params <- paste(
    c(
      paste0("lookfor=", utils::URLencode(query)),
      paste0("limit=", as.integer(limit)),
      paste0("page=", as.integer(page)),
      fields
    ),
    collapse = "&"
  )

  req_url <- paste0(base_url, "?", params)

  conn <- tryCatch(
    url(req_url, open = "rb", headers = c("User-Agent" = "bibliolatam/0.1.0 (https://github.com/BRAN-Org/bibliolatam)")),
    error = function(e) {
      stop(sprintf("Falha de conexao com o endpoint IBICT (%s): %s", base_url, e$message), call. = FALSE)
    }
  )

  raw_lines <- tryCatch(
    readLines(conn, warn = FALSE, encoding = "UTF-8"),
    error = function(e) {
      close(conn)
      stop(sprintf("Erro ao ler resposta da API IBICT: %s", e$message), call. = FALSE)
    }
  )
  close(conn)

  raw_txt <- paste(raw_lines, collapse = "\n")
  # Limpa mensagens de log eventuais do PHP/VuFind antes do JSON
  clean_txt <- sub("^[^{]*(\\{.*)$", "\\1", raw_txt)

  if (!nzchar(clean_txt) || !grepl("^\\{", clean_txt)) {
    stop("Resposta invalida recebida do portal IBICT (formato nao-JSON).", call. = FALSE)
  }

  parsed <- tryCatch(
    jsonlite::fromJSON(clean_txt, simplifyVector = FALSE),
    error = function(e) {
      stop(sprintf("Falha ao interpretar resposta JSON do IBICT: %s", e$message), call. = FALSE)
    }
  )

  if (!identical(parsed$status, "OK")) {
    msg <- if (!is.null(parsed$status)) parsed$status else "Status desconhecido"
    stop(sprintf("A API IBICT retornou status de erro: %s", msg), call. = FALSE)
  }

  parsed
}

#' Internal helper to convert VuFind records list to bibliometrix-compatible data frame
#'
#' @param records List of records from VuFind API.
#' @param dbsource Character. Either "bdtd" or "oasisbr".
#' @param normalize_authors_flag Logical.
#' @return A data.frame formatted for bibliometrix.
#' @noRd
parse_vufind_records <- function(records, dbsource = c("bdtd", "oasisbr"), normalize_authors_flag = TRUE) {
  dbsource <- match.arg(dbsource)

  if (length(records) == 0L) {
    return(data.frame())
  }

  n <- length(records)
  titles <- character(n)
  authors <- character(n)
  advisors <- character(n)
  sources <- character(n)
  years <- character(n)
  abstracts <- character(n)
  keywords <- character(n)
  doctypes <- character(n)
  languages <- character(n)
  identifiers <- character(n)
  dois <- character(n)

  for (i in seq_len(n)) {
    r <- records[[i]]

    # Titulo (TI)
    ti <- if (!is.null(r$title)) as.character(r$title) else NA_character_
    titles[i] <- if (nzchar(ti)) ti else NA_character_

    # Autores (AU)
    au_vec <- character(0L)
    if (!is.null(r$authors)) {
      if (!is.null(r$authors$primary) && length(r$authors$primary) > 0L) {
        au_vec <- c(au_vec, names(r$authors$primary))
      }
      if (!is.null(r$authors$secondary) && length(r$authors$secondary) > 0L) {
        au_vec <- c(au_vec, names(r$authors$secondary))
      }
      if (!is.null(r$authors$corporate) && length(r$authors$corporate) > 0L) {
        au_vec <- c(au_vec, names(r$authors$corporate))
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
    if (!is.null(r$publicationDates) && length(r$publicationDates) > 0L) {
      py_cand <- paste(unlist(r$publicationDates), collapse = " ")
      m <- regmatches(py_cand, regexpr("[12][0-9]{3}", py_cand))
      if (length(m) > 0L && nzchar(m)) py_val <- m
    }
    years[i] <- py_val

    # Fonte / Instituicao (SO)
    inst_val <- NA_character_
    if (!is.null(r$institutions) && length(r$institutions) > 0L) {
      inst_val <- toupper(trimws(paste(unlist(r$institutions), collapse = "; ")))
    }
    if (is.na(inst_val) || !nzchar(inst_val)) {
      inst_val <- if (dbsource == "bdtd") "BDTD/IBICT" else "OASISBR/IBICT"
    }
    sources[i] <- inst_val

    # Resumo (AB)
    ab_val <- NA_character_
    if (!is.null(r$summary) && length(r$summary) > 0L) {
      ab_val <- paste(unlist(r$summary), collapse = "\n\n")
    }
    abstracts[i] <- ab_val

    # Palavras-chave / Assuntos (DE)
    de_val <- NA_character_
    if (!is.null(r$subjects) && length(r$subjects) > 0L) {
      de_items <- unlist(r$subjects)
      de_items <- de_items[nzchar(trimws(de_items))]
      if (length(de_items) > 0L) {
        de_val <- toupper(paste(unique(trimws(de_items)), collapse = "; "))
      }
    }
    keywords[i] <- de_val

    # Tipo Documental (DT)
    fmt_raw <- if (!is.null(r$formats) && length(r$formats) > 0L) {
      toupper(paste(unlist(r$formats), collapse = " "))
    } else {
      ""
    }

    if (dbsource == "bdtd") {
      doctypes[i] <- if (grepl("DISSERTA|MESTRADO|MASTER", fmt_raw)) {
        "DISSERTATION"
      } else {
        "THESIS"
      }
    } else {
      # Oasisbr: multi-tipologia
      if (grepl("DISSERTA|MESTRADO|MASTER", fmt_raw)) {
        doctypes[i] <- "DISSERTATION"
      } else if (grepl("TESE|DOUTORADO|DOCTOR|PHD", fmt_raw)) {
        doctypes[i] <- "THESIS"
      } else if (grepl("ARTICL|ARTIGO|PERIODIC", fmt_raw)) {
        doctypes[i] <- "ARTICLE"
      } else if (grepl("BOOK|LIVRO|CAPITULO|CHAPTER", fmt_raw)) {
        doctypes[i] <- "BOOK"
      } else if (grepl("CONFEREN|CONGRESS|ANAIS|EVENT", fmt_raw)) {
        doctypes[i] <- "CONFERENCE"
      } else {
        doctypes[i] <- "MISCELLANEOUS"
      }
    }

    # Idioma (LA)
    la_val <- "PORTUGUESE"
    if (!is.null(r$languages) && length(r$languages) > 0L) {
      l_raw <- tolower(trimws(r$languages[[1]]))
      la_val <- if (l_raw %in% c("por", "pt", "portugues", "portuguese")) {
        "PORTUGUESE"
      } else if (l_raw %in% c("eng", "en", "ingles", "english")) {
        "ENGLISH"
      } else if (l_raw %in% c("spa", "es", "espanhol", "spanish")) {
        "SPANISH"
      } else {
        toupper(l_raw)
      }
    }
    languages[i] <- la_val

    # Identificador / URL (UT)
    ut_val <- NA_character_
    if (!is.null(r$urls) && length(r$urls) > 0L) {
      u_first <- r$urls[[1]]
      if (is.list(u_first) && !is.null(u_first$url)) {
        ut_val <- as.character(u_first$url)
      } else if (is.character(u_first)) {
        ut_val <- u_first[1]
      }
    }
    if (is.na(ut_val) || !nzchar(ut_val)) {
      ut_val <- if (!is.null(r$id)) as.character(r$id) else NA_character_
    }
    identifiers[i] <- ut_val

    # DOI (DI)
    doi_val <- NA_character_
    if (!is.null(r$cleanDoi) && length(r$cleanDoi) > 0L) {
      doi_val <- as.character(r$cleanDoi[[1]])
    }
    dois[i] <- doi_val
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
    stringsAsFactors = FALSE
  )

  if (any(!is.na(dois) & nzchar(dois))) {
    df$DI <- dois
  }

  df
}

#' Search and download records from BDTD (IBICT)
#'
#' Queries the official REST API of the Biblioteca Digital Brasileira de Teses e
#' Dissertações (BDTD / IBICT), retrieves metadata records for doctoral theses and
#' master's dissertations, and parses them into a standardized `bibliometrixDB` data frame.
#'
#' @param query Character. Search terms or query expression (e.g. `"inteligencia artificial"`).
#' @param limit Integer. Maximum number of records to retrieve. Default is 50.
#' @param convert Logical. If `TRUE` (default), transforms the result into a canonical
#'   `bibliometrixDB` data frame using [as_bibliometrix()].
#' @param progress Logical. If `TRUE` (default), prints progress messages during pagination.
#' @param normalize_authors Logical. If `TRUE` (default), normalizes author names.
#' @return A `data.frame` with class `c("bibliometrixDB", "data.frame")` containing BDTD thesis and dissertation records.
#' @export
download_bdtd <- function(query,
                          limit = 50L,
                          convert = TRUE,
                          progress = TRUE,
                          normalize_authors = TRUE) {
  if (!is.character(query) || length(query) != 1L || !nzchar(trimws(query))) {
    stop("O argumento 'query' deve ser uma string de busca nao vazia.", call. = FALSE)
  }

  limit <- as.integer(limit)
  if (is.na(limit) || limit <= 0L) {
    stop("O argumento 'limit' deve ser um inteiro positivo.", call. = FALSE)
  }

  base_url <- "https://bdtd.ibict.br/vufind/api/v1/search"
  page_size <- min(limit, 50L)
  accumulated_records <- list()
  page <- 1L

  while (length(accumulated_records) < limit) {
    current_limit <- min(page_size, limit - length(accumulated_records))
    if (isTRUE(progress)) {
      message(sprintf("[BDTD API] Consultando pagina %d (buscando ate %d registros)...", page, limit))
    }

    resp <- query_vufind_api(base_url, query = query, limit = current_limit, page = page)

    batch <- resp$records
    if (length(batch) == 0L) {
      break
    }

    accumulated_records <- c(accumulated_records, batch)

    total_available <- as.integer(resp$resultCount)
    if (!is.na(total_available) && length(accumulated_records) >= total_available) {
      break
    }

    page <- page + 1L
  }

  if (length(accumulated_records) == 0L) {
    warning("Nenhum registro encontrado na BDTD para a consulta fornecida.", call. = FALSE)
    return(data.frame())
  }

  df <- parse_vufind_records(accumulated_records, dbsource = "bdtd", normalize_authors_flag = normalize_authors)

  if (isTRUE(convert)) {
    df <- as_bibliometrix(df, dbsource = "bdtd")
  }

  df
}

#' Search and download records from Oasisbr (IBICT)
#'
#' Queries the official REST API of the Portal Brasileiro de Acesso Aberto (Oasisbr / IBICT),
#' retrieves metadata records across scientific articles, theses, books, and conference papers,
#' and parses them into a standardized `bibliometrixDB` data frame.
#'
#' @param query Character. Search terms or query expression.
#' @param limit Integer. Maximum number of records to retrieve. Default is 50.
#' @param convert Logical. If `TRUE` (default), transforms the result into a canonical
#'   `bibliometrixDB` data frame using [as_bibliometrix()].
#' @param progress Logical. If `TRUE` (default), prints progress messages during pagination.
#' @param normalize_authors Logical. If `TRUE` (default), normalizes author names.
#' @return A `data.frame` with class `c("bibliometrixDB", "data.frame")` containing Oasisbr multidisciplinary records.
#' @export
download_oasisbr <- function(query,
                             limit = 50L,
                             convert = TRUE,
                             progress = TRUE,
                             normalize_authors = TRUE) {
  if (!is.character(query) || length(query) != 1L || !nzchar(trimws(query))) {
    stop("O argumento 'query' deve ser uma string de busca nao vazia.", call. = FALSE)
  }

  limit <- as.integer(limit)
  if (is.na(limit) || limit <= 0L) {
    stop("O argumento 'limit' deve ser um inteiro positivo.", call. = FALSE)
  }

  base_url <- "https://oasisbr.ibict.br/vufind/api/v1/search"
  page_size <- min(limit, 50L)
  accumulated_records <- list()
  page <- 1L

  while (length(accumulated_records) < limit) {
    current_limit <- min(page_size, limit - length(accumulated_records))
    if (isTRUE(progress)) {
      message(sprintf("[Oasisbr API] Consultando pagina %d (buscando ate %d registros)...", page, limit))
    }

    resp <- query_vufind_api(base_url, query = query, limit = current_limit, page = page)

    batch <- resp$records
    if (length(batch) == 0L) {
      break
    }

    accumulated_records <- c(accumulated_records, batch)

    total_available <- as.integer(resp$resultCount)
    if (!is.na(total_available) && length(accumulated_records) >= total_available) {
      break
    }

    page <- page + 1L
  }

  if (length(accumulated_records) == 0L) {
    warning("Nenhum registro encontrado no Oasisbr para a consulta fornecida.", call. = FALSE)
    return(data.frame())
  }

  df <- parse_vufind_records(accumulated_records, dbsource = "oasisbr", normalize_authors_flag = normalize_authors)

  if (isTRUE(convert)) {
    df <- as_bibliometrix(df, dbsource = "oasisbr")
  }

  df
}
