#' Parse export files from BDTD / Oasisbr (IBICT)
#'
#' Reads and standardizes tabular exports (CSV, TSV) from the Biblioteca Digital
#' Brasileira de Teses e Dissertações (BDTD) or Oasisbr portal (IBICT).
#'
#' @param file Path to the CSV or TSV file exported from BDTD/Oasisbr.
#' @param convert Logical. If TRUE, directly wraps output with `as_bibliometrix()`. Default is TRUE.
#' @return A data frame formatted with standard bibliometric tags.
#' @export
read_bdtd <- function(file, convert = TRUE) {
  if (!is.character(file) || length(file) != 1L || !file.exists(file)) {
    stop("Arquivo nao encontrado ou caminho invalido.", call. = FALSE)
  }

  # detecta separador olhando a primeira linha nao vazia
  primeira_linha <- readLines(file, n = 5L, encoding = "UTF-8", warn = FALSE)
  primeira_linha <- primeira_linha[nzchar(trimws(primeira_linha))][1]
  if (is.na(primeira_linha) || !nzchar(primeira_linha)) {
    stop("Arquivo vazio.", call. = FALSE)
  }

  sep <- if (grepl(";", primeira_linha)) {
    ";"
  } else if (grepl("\t", primeira_linha)) {
    "\t"
  } else {
    ","
  }

  # le tentando UTF-8 primeiro, se falhar tenta Latin1
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
    stop("Nenhum registro encontrado no arquivo da BDTD/Oasisbr.", call. = FALSE)
  }

  # normaliza nomes de colunas para caixa baixa e sem acentos
  cnames_raw <- names(raw_df)
  cnames_clean <- tolower(iconv(cnames_raw, to = "ASCII//TRANSLIT"))
  cnames_clean <- gsub("[^a-z0-9]", "", cnames_clean)

  # dicionario de sinonimos do portal BDTD / Oasisbr / VuFind
  mapa_tags <- list(
    TI = c("titulo", "title"),
    AU = c("autores", "autor", "authors", "author"),
    RP = c("orientadores", "orientador", "advisors", "advisor"),
    INST = c("instituicao", "institution", "universidade", "university"),
    PROG = c("programa", "program", "programadeposgraduacao", "departamento"),
    PY = c("ano", "year", "anodedefesa", "datadedefesa", "data"),
    DT = c("tipo", "type", "tipodedocumento", "grau", "degree"),
    DE = c("assuntos", "assunto", "palavraschave", "keywords", "subjects", "subject"),
    AB = c("resumo", "abstract"),
    LA = c("idioma", "language", "lang"),
    URI = c("uri", "url", "link", "handle", "recordurl"),
    DI = c("doi")
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
  if (!"TI" %in% names(out) || !"AU" %in% names(out)) {
    stop("Nao foi possivel identificar as colunas obrigatorias (Titulo, Autores) da BDTD/Oasisbr.", call. = FALSE)
  }

  # constroi SO (Source) a partir de Instituicao e Programa se SO nao existir
  if (!"SO" %in% names(out)) {
    has_inst <- "INST" %in% names(out)
    has_prog <- "PROG" %in% names(out)

    if (has_inst && has_prog) {
      so_vals <- paste0(out$INST, ifelse(nzchar(out$PROG), paste0(". ", out$PROG), ""))
      out$SO <- toupper(trimws(so_vals))
    } else if (has_inst) {
      out$SO <- toupper(trimws(out$INST))
    } else if (has_prog) {
      out$SO <- toupper(trimws(out$PROG))
    } else {
      out$SO <- "BDTD/IBICT"
    }
  }

  # limpa colunas auxiliares INST e PROG
  out$INST <- NULL
  out$PROG <- NULL

  # ano de publicacao/defesa: extrai 4 digitos
  if ("PY" %in% names(out)) {
    year_match <- regmatches(out$PY, regexpr("[12][0-9]{3}", out$PY))
    out$PY <- ifelse(nzchar(year_match), year_match, out$PY)
  } else {
    out$PY <- NA_character_
  }

  # normaliza autores
  out$AU <- vapply(out$AU, normalize_authors, FUN.VALUE = character(1L), USE.NAMES = FALSE)

  # normaliza orientador (RP) se presente
  if ("RP" %in% names(out)) {
    out$RP <- vapply(out$RP, normalize_authors, FUN.VALUE = character(1L), USE.NAMES = FALSE)
  }

  # classifica tipo documental (DT)
  if ("DT" %in% names(out)) {
    out$DT <- toupper(out$DT)
    out$DT <- ifelse(
      grepl("DISSERTA|MESTRADO|MASTER", out$DT),
      "DISSERTATION",
      ifelse(grepl("TESE|DOUTORADO|PHD|DOCTOR", out$DT), "THESIS", "THESIS")
    )
  } else {
    out$DT <- "THESIS"
  }

  # padroniza idioma (LA)
  if ("LA" %in% names(out)) {
    la_raw <- tolower(trimws(out$LA))
    out$LA <- ifelse(
      la_raw %in% c("por", "pt", "portugues", "portuguese"), "PORTUGUESE",
      ifelse(
        la_raw %in% c("eng", "en", "ingles", "english"), "ENGLISH",
        ifelse(la_raw %in% c("spa", "es", "espanhol", "spanish"), "SPANISH", toupper(la_raw))
      )
    )
  }

  # limpa DOI se houver
  if ("DI" %in% names(out)) {
    out$DI <- gsub("^https?://(dx\\.)?doi\\.org/", "", out$DI, ignore.case = TRUE)
  }

  # se tem URI e nao tem UT, preenche UT como identificador unico
  if ("URI" %in% names(out) && (!"UT" %in% names(out) || all(is.na(out$UT)))) {
    out$UT <- out$URI
  }

  if (isTRUE(convert)) {
    out <- as_bibliometrix(out, dbsource = "bdtd")
  }

  out
}

#' @rdname read_bdtd
#' @export
read_oasisbr <- read_bdtd
