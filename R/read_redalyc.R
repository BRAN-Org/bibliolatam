#' Parse BibTeX text entries
#'
#' @param lines Character vector of file lines.
#' @return A data frame with standard tags.
#' @noRd
parse_redalyc_bibtex <- function(lines) {
  text <- paste(lines, collapse = "\n")
  # Quebra por entradas @article, @book, etc.
  entry_splits <- strsplit(text, "\n@")[[1]]
  if (length(entry_splits) == 0L) return(data.frame())

  records <- list()
  for (e in entry_splits) {
    if (!grepl("\\{", e)) next
    header_rest <- strsplit(e, "\\{", perl = TRUE)[[1]]
    if (length(header_rest) < 2L) next

    doc_type <- toupper(trimws(gsub("^@", "", header_rest[1])))
    body <- paste(header_rest[-1], collapse = "{")

    # Extrai campos campo = {valor} ou campo = "valor"
    field_matches <- gregexpr("(?i)([a-z_-]+)\\s*=\\s*[{|\"](.*?)[}|\"]\\s*[,\\n]", body, perl = TRUE)
    matches <- regmatches(body, field_matches)[[1]]

    rec <- list(DT = if (grepl("ARTICLE", doc_type)) "ARTICLE" else doc_type)
    for (m in matches) {
      kv <- regmatches(m, regexec("(?i)([a-z_-]+)\\s*=\\s*[{|\"](.*?)[}|\"]", m, perl = TRUE))[[1]]
      if (length(kv) >= 3L) {
        key <- tolower(trimws(kv[2]))
        val <- trimws(kv[3])
        # limpa quebras e chaves internas
        val <- gsub("[{}]", "", val)
        val <- gsub("\\s+", " ", val)
        rec[[key]] <- val
      }
    }

    if (!is.null(rec$title) || !is.null(rec$author)) {
      records[[length(records) + 1L]] <- rec
    }
  }

  if (length(records) == 0L) return(data.frame())

  n <- length(records)
  out_ti <- character(n)
  out_au <- character(n)
  out_so <- character(n)
  out_py <- character(n)
  out_ab <- character(n)
  out_de <- character(n)
  out_di <- character(n)
  out_sn <- character(n)
  out_dt <- character(n)
  out_vl <- character(n)
  out_is <- character(n)
  out_bp <- character(n)
  out_ep <- character(n)

  for (i in seq_len(n)) {
    r <- records[[i]]
    out_ti[i] <- if (!is.null(r$title)) r$title else NA_character_
    out_au[i] <- if (!is.null(r$author)) gsub("\\s+and\\s+", "; ", r$author, ignore.case = TRUE) else "ANONYMOUS"
    out_so[i] <- if (!is.null(r$journal)) r$journal else if (!is.null(r$booktitle)) r$booktitle else "REDALYC"
    out_py[i] <- if (!is.null(r$year)) r$year else NA_character_
    out_ab[i] <- if (!is.null(r$abstract)) r$abstract else NA_character_
    out_de[i] <- if (!is.null(r$keywords)) r$keywords else NA_character_
    out_di[i] <- if (!is.null(r$doi)) r$doi else NA_character_
    out_sn[i] <- if (!is.null(r$issn)) r$issn else if (!is.null(r$isbn)) r$isbn else NA_character_
    out_dt[i] <- if (!is.null(r$DT)) r$DT else "ARTICLE"
    out_vl[i] <- if (!is.null(r$volume)) r$volume else NA_character_
    out_is[i] <- if (!is.null(r$number)) r$number else NA_character_
    out_bp[i] <- if (!is.null(r$pages)) gsub("-.*$", "", r$pages) else NA_character_
    out_ep[i] <- if (!is.null(r$pages)) gsub("^.*-", "", r$pages) else NA_character_
  }

  data.frame(
    TI = out_ti,
    AU = out_au,
    SO = out_so,
    PY = out_py,
    AB = out_ab,
    DE = out_de,
    DI = out_di,
    SN = out_sn,
    DT = out_dt,
    VL = out_vl,
    IS = out_is,
    BP = out_bp,
    EP = out_ep,
    stringsAsFactors = FALSE
  )
}

#' Parse RIS text entries
#'
#' @param lines Character vector of file lines.
#' @return A data frame with standard tags.
#' @noRd
parse_redalyc_ris <- function(lines) {
  records <- list()
  cur_rec <- list(AU = character(0L), KW = character(0L))

  for (l in lines) {
    line <- trimws(l)
    if (!nzchar(line)) next

    if (grepl("^ER\\s*-", line)) {
      if (length(cur_rec$AU) > 0L || !is.null(cur_rec$TI)) {
        records[[length(records) + 1L]] <- cur_rec
      }
      cur_rec <- list(AU = character(0L), KW = character(0L))
      next
    }

    m <- regexec("^([A-Z0-9]{2})\\s*-\\s*(.*)$", line)
    match <- regmatches(line, m)[[1]]
    if (length(match) == 3L) {
      tag <- match[2]
      val <- trimws(match[3])

      if (tag %in% c("AU", "A1")) {
        cur_rec$AU <- c(cur_rec$AU, val)
      } else if (tag %in% c("TI", "T1")) {
        cur_rec$TI <- val
      } else if (tag %in% c("JO", "JF", "T2", "JA")) {
        cur_rec$SO <- val
      } else if (tag %in% c("PY", "Y1")) {
        year_cand <- regmatches(val, regexpr("[12][0-9]{3}", val))
        cur_rec$PY <- if (length(year_cand) > 0L) year_cand else val
      } else if (tag %in% c("AB", "N2")) {
        cur_rec$AB <- val
      } else if (tag %in% c("KW")) {
        cur_rec$KW <- c(cur_rec$KW, val)
      } else if (tag %in% c("DO")) {
        cur_rec$DI <- val
      } else if (tag %in% c("SN")) {
        cur_rec$SN <- val
      } else if (tag %in% c("TY")) {
        cur_rec$DT <- if (grepl("JOUR", val)) "ARTICLE" else val
      } else if (tag %in% c("VL")) {
        cur_rec$VL <- val
      } else if (tag %in% c("IS")) {
        cur_rec$IS <- val
      } else if (tag %in% c("SP")) {
        cur_rec$BP <- val
      } else if (tag %in% c("EP")) {
        cur_rec$EP <- val
      }
    }
  }

  if (length(records) == 0L) return(data.frame())

  n <- length(records)
  out_ti <- character(n)
  out_au <- character(n)
  out_so <- character(n)
  out_py <- character(n)
  out_ab <- character(n)
  out_de <- character(n)
  out_di <- character(n)
  out_sn <- character(n)
  out_dt <- character(n)
  out_vl <- character(n)
  out_is <- character(n)
  out_bp <- character(n)
  out_ep <- character(n)

  for (i in seq_len(n)) {
    r <- records[[i]]
    out_ti[i] <- if (!is.null(r$TI)) r$TI else NA_character_
    out_au[i] <- if (length(r$AU) > 0L) paste(r$AU, collapse = "; ") else "ANONYMOUS"
    out_so[i] <- if (!is.null(r$SO)) r$SO else "REDALYC"
    out_py[i] <- if (!is.null(r$PY)) r$PY else NA_character_
    out_ab[i] <- if (!is.null(r$AB)) r$AB else NA_character_
    out_de[i] <- if (length(r$KW) > 0L) paste(r$KW, collapse = "; ") else NA_character_
    out_di[i] <- if (!is.null(r$DI)) r$DI else NA_character_
    out_sn[i] <- if (!is.null(r$SN)) r$SN else NA_character_
    out_dt[i] <- if (!is.null(r$DT)) r$DT else "ARTICLE"
    out_vl[i] <- if (!is.null(r$VL)) r$VL else NA_character_
    out_is[i] <- if (!is.null(r$IS)) r$IS else NA_character_
    out_bp[i] <- if (!is.null(r$BP)) r$BP else NA_character_
    out_ep[i] <- if (!is.null(r$EP)) r$EP else NA_character_
  }

  data.frame(
    TI = out_ti,
    AU = out_au,
    SO = out_so,
    PY = out_py,
    AB = out_ab,
    DE = out_de,
    DI = out_di,
    SN = out_sn,
    DT = out_dt,
    VL = out_vl,
    IS = out_is,
    BP = out_bp,
    EP = out_ep,
    stringsAsFactors = FALSE
  )
}

#' Parse Redalyc and AmeliCA bibliographic export files
#'
#' Reads and standardizes bibliographic files exported from Redalyc and AmeliCA
#' supporting BibTeX (`.bib`), RIS (`.ris`), and tabular CSV/TSV formats.
#' Standardizes author names via [normalize_authors()], maps Hispanic compound surnames,
#' and returns a canonical `bibliometrixDB` object.
#'
#' @param file Character. Path to the `.bib`, `.ris`, or `.csv` export file.
#' @param convert Logical. If `TRUE` (default), directly converts to `bibliometrixDB` via [as_bibliometrix()].
#' @return A data frame formatted with canonical bibliometric tags.
#' @export
read_redalyc <- function(file, convert = TRUE) {
  if (!is.character(file) || length(file) != 1L || !file.exists(file)) {
    stop("Arquivo nao encontrado ou caminho invalido.", call. = FALSE)
  }

  raw_lines <- readLines(file, encoding = "UTF-8", warn = FALSE)
  non_empty <- raw_lines[nzchar(trimws(raw_lines))]
  if (length(non_empty) == 0L) {
    stop("Arquivo vazio.", call. = FALSE)
  }

  first_chunk <- paste(utils::head(non_empty, 10), collapse = "\n")

  # Detecta formato
  if (grepl("^\\s*@[a-zA-Z]+\\s*\\{", first_chunk) || grepl("\\.bib$", file, ignore.case = TRUE)) {
    raw_df <- parse_redalyc_bibtex(raw_lines)
  } else if (grepl("^[A-Z0-9]{2}\\s*-", first_chunk) || grepl("\\.ris$", file, ignore.case = TRUE)) {
    raw_df <- parse_redalyc_ris(raw_lines)
  } else {
    # Formato tabular CSV
    raw_df <- tryCatch(
      utils::read.csv(file, stringsAsFactors = FALSE, encoding = "UTF-8", check.names = FALSE),
      error = function(e) {
        utils::read.csv(file, sep = ";", stringsAsFactors = FALSE, encoding = "UTF-8", check.names = FALSE)
      }
    )
    # Mapeia colunas comuns
    cnames_clean <- tolower(iconv(names(raw_df), to = "ASCII//TRANSLIT"))
    cnames_clean <- gsub("[^a-z0-9]", "", cnames_clean)

    mapping <- list(
      TI = c("titulo", "title", "articulo"),
      AU = c("autores", "autor", "authors", "author"),
      SO = c("revista", "journal", "fuente", "source"),
      PY = c("ano", "year", "anio", "fecha"),
      AB = c("resumen", "abstract"),
      DE = c("palabrasclave", "keywords", "palabras"),
      DI = c("doi"),
      SN = c("issn", "isbn"),
      DT = c("tipo", "type")
    )
    res_list <- list()
    for (tag in names(mapping)) {
      pos <- which(cnames_clean %in% mapping[[tag]])
      if (length(pos) > 0L) {
        res_list[[tag]] <- as.character(raw_df[[pos[1]]])
      }
    }
    raw_df <- as.data.frame(res_list, stringsAsFactors = FALSE)
  }

  if (nrow(raw_df) == 0L) {
    stop("Nenhum registro bibliografico identificado no arquivo Redalyc.", call. = FALSE)
  }

  # Normaliza autores
  if ("AU" %in% names(raw_df)) {
    raw_df$AU <- vapply(raw_df$AU, normalize_authors, FUN.VALUE = character(1L), USE.NAMES = FALSE)
  }

  # Limpa DOI
  if ("DI" %in% names(raw_df)) {
    raw_df$DI <- clean_doi(raw_df$DI)
  }

  # Ano
  if ("PY" %in% names(raw_df)) {
    py_cand <- regmatches(raw_df$PY, regexpr("[12][0-9]{3}", raw_df$PY))
    raw_df$PY <- ifelse(nzchar(py_cand), py_cand, raw_df$PY)
  }

  if (isTRUE(convert)) {
    raw_df <- as_bibliometrix(raw_df, dbsource = "redalyc")
  }

  raw_df
}
