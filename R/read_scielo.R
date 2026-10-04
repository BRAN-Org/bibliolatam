#' Parse export files from SciELO
#'
#' Reads and standardizes tabular CSV export files downloaded from the SciELO portal (search.scielo.org).
#'
#' @param file Path to the SciELO CSV export file.
#' @param convert Logical. If TRUE, directly wraps output with `as_bibliometrix(..., dbsource = "scielo")`. Default is TRUE.
#' @return A data frame formatted with standard bibliometric tags.
#' @export
read_scielo <- function(file, convert = TRUE) {
  if (!is.character(file) || length(file) != 1L || !file.exists(file)) {
    stop("Arquivo nao encontrado ou caminho invalido.", call. = FALSE)
  }

  primeira_linha <- readLines(file, n = 2L, encoding = "UTF-8", warn = FALSE)
  primeira_linha <- primeira_linha[nzchar(trimws(primeira_linha))][1]
  if (is.na(primeira_linha) || !nzchar(primeira_linha)) {
    stop("Arquivo vazio.", call. = FALSE)
  }

  # detecta delimitador comum
  sep <- if (grepl(";", primeira_linha)) ";" else if (grepl("\t", primeira_linha)) "\t" else ","

  # le tentando utf-8 com fallback pra latin1
  raw_df <- tryCatch(
    utils::read.csv(
      file,
      sep = sep,
      stringsAsFactors = FALSE,
      encoding = "UTF-8",
      check.names = FALSE
    ),
    error = function(e) {
      utils::read.csv(
        file,
        sep = sep,
        stringsAsFactors = FALSE,
        fileEncoding = "Latin1",
        check.names = FALSE
      )
    }
  )

  if (nrow(raw_df) == 0L) {
    stop("Nenhum registro encontrado no arquivo do SciELO.", call. = FALSE)
  }

  # higieniza nomes de colunas
  cnames_raw <- names(raw_df)
  cnames_clean <- tolower(iconv(cnames_raw, to = "ASCII//TRANSLIT"))
  cnames_clean <- gsub("[^a-z0-9]", "", cnames_clean)

  # dicionario de sinonimos pt / es / en do portal scielo
  mapa_tags <- list(
    TI = c("title", "titulo"),
    AU = c("authors", "autores", "author", "autor"),
    SO = c("journal", "revista", "periodico", "source"),
    PY = c("year", "ano", "publicationyear", "anopublicacao"),
    AB = c("abstract", "resumo", "resumen"),
    DE = c("keywords", "palavraschave", "palabrasclave", "palavraschaves"),
    DI = c("doi"),
    VL = c("volume", "vol"),
    IS = c("number", "issue", "numero", "fasciculo"),
    BP = c("pages", "paginas", "page", "pagina"),
    SN = c("issn")
  )

  res_list <- list()
  for (tag in names(mapa_tags)) {
    pos <- which(cnames_clean %in% mapa_tags[[tag]])
    if (length(pos) > 0) {
      val <- raw_df[[pos[1]]]
      res_list[[tag]] <- trimws(as.character(val))
    }
  }

  out <- as.data.frame(res_list, stringsAsFactors = FALSE)

  # valida colunas essenciais
  req_cols <- c("AU", "TI", "SO", "PY")
  missing_req <- setdiff(req_cols, names(out))
  if (length(missing_req) > 0) {
    stop(
      sprintf("Nao foi possivel mapear colunas obrigatorias do SciELO: %s", paste(missing_req, collapse = ", ")),
      call. = FALSE
    )
  }

  # normaliza autores no padrao wos/bibliometrix
  out$AU <- vapply(out$AU, normalize_authors, FUN.VALUE = character(1L), USE.NAMES = FALSE)

  # sanitiza prefixo doi
  if ("DI" %in% names(out)) {
    out$DI <- gsub("^https?://(dx\\.)?doi\\.org/", "", out$DI, ignore.case = TRUE)
  }

  out$DT <- "ARTICLE"

  if (isTRUE(convert)) {
    out <- as_bibliometrix(out, dbsource = "scielo")
  }

  out
}
