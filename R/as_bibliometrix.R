#' Convert raw parsed data to a bibliometrix-compatible object
#'
#' @param df A data frame containing parsed bibliographic records.
#' @param dbsource Character string identifying the regional source (e.g. "spell", "scielo", "bdtd").
#' @return A data frame with class `c("bibliometrixDB", "data.frame")` ready for bibliometrix.
#' @export
as_bibliometrix <- function(df, dbsource = c("spell", "scielo", "bdtd", "oasisbr", "redalyc", "lareferencia", "omnisearch")) {
  if (!is.data.frame(df)) {
    stop("df precisa ser um data.frame/tibble.", call. = FALSE)
  }

  if (nrow(df) == 0L) {
    stop("df esta vazio, nada pra converter.", call. = FALSE)
  }

  dbsource <- match.arg(dbsource)

  # campos minimos que toda base tem que ter pra nao bugar no summary/analise
  req_cols <- c("AU", "TI", "SO", "PY")
  missing_req <- setdiff(req_cols, names(df))
  if (length(missing_req) > 0) {
    stop(
      sprintf("Faltam colunas essenciais no dataset: %s", paste(missing_req, collapse = ", ")),
      call. = FALSE
    )
  }

  # tags padrao wos/scopus que o bibliometrix espera no convert2df
  std_tags <- c(
    "AU", "TI", "SO", "PY", "DE", "ID", "AB", "C1", "RP",
    "CR", "TC", "DI", "DT", "SN", "LA", "UT", "DB"
  )

  # se nao veio na base de origem, preenche NA sem inventar dado
  for (tag in std_tags) {
    if (!tag %in% names(df)) {
      df[[tag]] <- NA_character_
    }
  }

  # bibliometrix quebra em plot/rede se PY ou TC vierem como character
  df$PY <- suppressWarnings(as.numeric(df$PY))
  df$TC <- suppressWarnings(as.numeric(df$TC))
  df$TC[is.na(df$TC)] <- 0

  # garante que colunas de texto nao fiquem como factor
  char_tags <- c("AU", "TI", "SO", "DE", "ID", "AB", "C1", "RP", "CR", "DI", "DT", "SN", "LA", "UT")
  for (tag in char_tags) {
    if (tag %in% names(df) && is.factor(df[[tag]])) {
      df[[tag]] <- as.character(df[[tag]])
    }
  }

  # gera SR (Standard Reference) se ausente ou vazio, obrigatorio para cocMatrix e redes
  if (!"SR" %in% names(df) || all(is.na(df$SR))) {
    first_author <- gsub(";.*$", "", df$AU)
    first_author <- trimws(first_author)
    first_author[is.na(first_author) | !nzchar(first_author)] <- "ANONYMOUS"

    py_val <- if ("PY" %in% names(df)) df$PY else ""
    py_val[is.na(py_val)] <- ""

    so_val <- if ("SO" %in% names(df)) trimws(df$SO) else ""
    so_val[is.na(so_val)] <- ""

    vl_val <- if ("VL" %in% names(df)) paste0("V", trimws(df$VL)) else ""
    vl_val[is.na(df$VL) | !nzchar(df$VL)] <- ""

    bp_val <- if ("BP" %in% names(df)) paste0("P", trimws(df$BP)) else ""
    bp_val[is.na(df$BP) | !nzchar(df$BP)] <- ""

    di_val <- if ("DI" %in% names(df)) paste0("DOI ", trimws(df$DI)) else ""
    di_val[is.na(df$DI) | !nzchar(df$DI)] <- ""

    sr_vec <- character(nrow(df))
    for (i in seq_len(nrow(df))) {
      parts <- c(first_author[i], py_val[i], so_val[i], vl_val[i], bp_val[i], di_val[i])
      parts <- parts[nzchar(parts)]
      sr_vec[i] <- paste(parts, collapse = ", ")
    }
    df$SR <- make.unique(toupper(sr_vec), sep = "-")
  }

  if (!"SR_FULL" %in% names(df) || all(is.na(df$SR_FULL))) {
    df$SR_FULL <- df$SR
  }
  if (!"JI" %in% names(df) || all(is.na(df$JI))) {
    df$JI <- df$SO
  }
  if (!"J9" %in% names(df) || all(is.na(df$J9))) {
    df$J9 <- substr(toupper(df$SO), 1, 29)
  }

  # se ID (Keywords Plus) nao veio na base regional, espelha DE (Author Keywords) para compatibilidade com bibliometrix
  if ("DE" %in% names(df) && (all(is.na(df$ID)) || !any(nzchar(df$ID[!is.na(df$ID)])))) {
    df$ID <- df$DE
  }

  # preenche dbsource
  df$DB <- dbsource

  # contrato canonico
  class(df) <- unique(c("bibliometrixDB", class(df)))
  attr(df, "dbsource") <- dbsource

  df
}
