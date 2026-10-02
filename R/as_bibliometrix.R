#' Convert raw parsed data to a bibliometrix-compatible object
#'
#' @param df A data frame containing parsed bibliographic records.
#' @param dbsource Character string identifying the regional source (e.g. "spell", "scielo", "bdtd").
#' @return A data frame with class `c("bibliometrixDB", "data.frame")` ready for bibliometrix.
#' @export
as_bibliometrix <- function(df, dbsource = c("spell", "scielo", "bdtd", "redalyc", "lareferencia")) {
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

  # preenche dbsource
  df$DB <- dbsource

  # contrato canonico
  class(df) <- unique(c("bibliometrixDB", class(df)))
  attr(df, "dbsource") <- dbsource

  df
}
