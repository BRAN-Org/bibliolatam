#' Parse export files from SPELL / ANPAD
#'
#' @param file Path to the CSV file exported from SPELL.
#' @param convert Logical. If TRUE, directly wraps output with `as_bibliometrix()`. Default is TRUE.
#' @return A data frame formatted with standard bibliometric tags.
#' @export
read_spell <- function(file, convert = TRUE) {
  if (!is.character(file) || length(file) != 1L || !file.exists(file)) {
    stop("Arquivo nao encontrado ou caminho invalido.", call. = FALSE)
  }

  # detecta separador olhando a primeira linha nao vazia
  primeira_linha <- readLines(file, n = 2L, encoding = "UTF-8", warn = FALSE)
  primeira_linha <- primeira_linha[nzchar(trimws(primeira_linha))][1]
  if (is.na(primeira_linha) || !nzchar(primeira_linha)) {
    stop("Arquivo vazio.", call. = FALSE)
  }

  sep <- if (grepl(";", primeira_linha)) ";" else if (grepl("\t", primeira_linha)) "\t" else ","

  # le tentando utf-8 primeiro, se chiar tenta latin1
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
    stop("Nenhum registro encontrado no CSV do SPELL.", call. = FALSE)
  }

  # normaliza nomes de colunas pra caixa baixa e sem acento pra bater o match
  cnames_raw <- names(raw_df)
  cnames_clean <- tolower(iconv(cnames_raw, to = "ASCII//TRANSLIT"))
  cnames_clean <- gsub("[^a-z0-9]", "", cnames_clean)

  # dicionario de sinonimos do portal da anpad
  mapa_tags <- list(
    TI = c("titulo", "title"),
    AU = c("autores", "autoria", "authors", "author"),
    SO = c("periodico", "revista", "journal", "source", "publicacao"),
    PY = c("ano", "year", "anopublicacao"),
    AB = c("resumo", "abstract"),
    DE = c("palavraschave", "keywords", "palavraschaves"),
    DI = c("doi"),
    VL = c("volume", "vol"),
    IS = c("numero", "issue", "num"),
    BP = c("paginas", "pages", "pagina", "page")
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

  # valida se as colunas essenciais foram encontradas
  req_cols <- c("AU", "TI", "SO", "PY")
  missing_req <- setdiff(req_cols, names(out))
  if (length(missing_req) > 0) {
    stop(
      sprintf("Nao foi possivel mapear colunas obrigatorias do SPELL: %s", paste(missing_req, collapse = ", ")),
      call. = FALSE
    )
  }

  # padroniza autores no formato wos/bibliometrix (SOBRENOME INICIAIS)
  out$AU <- vapply(out$AU, normalize_spell_authors, FUN.VALUE = character(1L), USE.NAMES = FALSE)

  # limpa doi se veio com url junto
  if ("DI" %in% names(out)) {
    out$DI <- gsub("^https?://(dx\\.)?doi\\.org/", "", out$DI, ignore.case = TRUE)
  }

  # fixa tipo artigo se nao informado
  out$DT <- "ARTICLE"

  if (isTRUE(convert)) {
    out <- as_bibliometrix(out, dbsource = "spell")
  }

  out
}

# helper interno pra formatar autores estilo bibliometrix
normalize_spell_authors <- function(au_str) {
  if (is.na(au_str) || !nzchar(trimws(au_str))) {
    return(NA_character_)
  }

  # separa autores individuais (normalmente ';' no spell)
  raw_authors <- unlist(strsplit(au_str, ";", fixed = TRUE))
  norm_authors <- character(0L)

  for (a in raw_authors) {
    a <- trimws(a)
    if (!nzchar(a)) next

    if (grepl(",", a, fixed = TRUE)) {
      # formato: 'Sobrenome, Nome Outro'
      parts <- unlist(strsplit(a, ",", fixed = TRUE))
      sobrenome <- toupper(trimws(parts[1]))
      restante <- if (length(parts) > 1) trimws(parts[2]) else ""
      prenomes <- unlist(strsplit(restante, "\\s+"))
      iniciais <- paste0(substr(prenomes[nzchar(prenomes)], 1, 1), collapse = "")
      norm_a <- if (nzchar(iniciais)) paste(sobrenome, toupper(iniciais)) else sobrenome
    } else {
      # formato: 'Nome Outro Sobrenome'
      tokens <- unlist(strsplit(a, "\\s+"))
      if (length(tokens) == 1) {
        norm_a <- toupper(tokens)
      } else {
        sobrenome <- toupper(tokens[length(tokens)])
        prenomes <- tokens[-length(tokens)]
        iniciais <- paste0(substr(prenomes[nzchar(prenomes)], 1, 1), collapse = "")
        norm_a <- paste(sobrenome, toupper(iniciais))
      }
    }
    norm_authors <- c(norm_authors, norm_a)
  }

  if (length(norm_authors) == 0L) {
    return(NA_character_)
  }

  paste(norm_authors, collapse = "; ")
}
