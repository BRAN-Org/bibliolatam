#' Parse SciELO JATS XML articles and cited references
#'
#' Reads one or multiple SciELO articles in NLM/JATS XML format (`.xml`, directory, or `.zip`).
#' Extracts core metadata tags (`AU`, `TI`, `SO`, `PY`, `AB`, `DE`, `DI`, `SN`, `VL`, `IS`, `BP`, `EP`, `C1`)
#' and reconstructs the canonical Cited References (`CR`) tag from `<ref-list>` for cocitation
#' and bibliographic coupling workflows in `bibliometrix`.
#'
#' @param path Path to a `.xml` file, a directory of XML files, or a `.zip` archive containing XML files.
#' @param convert Logical. If TRUE, directly wraps output with `as_bibliometrix(..., dbsource = "scielo")`. Default is TRUE.
#' @return A data frame formatted with standard bibliometric tags including `CR`.
#' @export
read_scielo_jats <- function(path, convert = TRUE) {
  if (!is.character(path) || length(path) != 1L || !file.exists(path)) {
    stop("Arquivo ou diretorio nao encontrado ou caminho invalido.", call. = FALSE)
  }

  temp_dir <- NULL
  on.exit({
    if (!is.null(temp_dir) && dir.exists(temp_dir)) {
      unlink(temp_dir, recursive = TRUE)
    }
  }, add = TRUE)

  xml_files <- character(0L)

  if (dir.exists(path)) {
    xml_files <- list.files(path, pattern = "\\.xml$", full.names = TRUE, ignore.case = TRUE)
  } else if (grepl("\\.zip$", path, ignore.case = TRUE)) {
    temp_dir <- tempfile(pattern = "scielo_jats_")
    dir.create(temp_dir)
    utils::unzip(path, exdir = temp_dir)
    xml_files <- list.files(temp_dir, pattern = "\\.xml$", full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
  } else if (grepl("\\.xml$", path, ignore.case = TRUE)) {
    xml_files <- path
  } else {
    stop("Formato nao suportado. Forneca um arquivo .xml, um diretorio ou um arquivo .zip.", call. = FALSE)
  }

  if (length(xml_files) == 0L) {
    stop("Nenhum arquivo XML encontrado no caminho especificado.", call. = FALSE)
  }

  records <- lapply(xml_files, parse_single_scielo_jats)
  records <- records[!vapply(records, is.null, logical(1L))]

  if (length(records) == 0L) {
    stop("Nao foi possivel extrair registros validos dos arquivos XML.", call. = FALSE)
  }

  # combina lista de records em data frame
  all_cols <- unique(unlist(lapply(records, names)))
  df_list <- lapply(all_cols, function(col) {
    vapply(records, function(r) {
      val <- r[[col]]
      if (is.null(val) || length(val) == 0L || is.na(val)) NA_character_ else as.character(val)
    }, FUN.VALUE = character(1L))
  })
  names(df_list) <- all_cols
  out <- as.data.frame(df_list, stringsAsFactors = FALSE)

  # valida colunas essenciais
  req_cols <- c("AU", "TI", "SO", "PY")
  missing_req <- setdiff(req_cols, names(out))
  if (length(missing_req) > 0) {
    stop(
      sprintf("Nao foi possivel mapear colunas obrigatorias do SciELO JATS: %s", paste(missing_req, collapse = ", ")),
      call. = FALSE
    )
  }

  out$DT <- "ARTICLE"

  if (isTRUE(convert)) {
    out <- as_bibliometrix(out, dbsource = "scielo")
  }

  out
}

# Helper interno para extrair nós via regex resiliente sem dependência externa pesada
extract_first_tag <- function(text, tag_name) {
  pattern <- sprintf("<%s\\b[^>]*>(.*?)</%s>", tag_name, tag_name)
  m <- regexec(pattern, text, perl = TRUE)
  reg <- regmatches(text, m)[[1]]
  if (length(reg) >= 2) {
    clean_txt <- gsub("<[^>]+>", "", reg[2])
    trimws(clean_txt)
  } else {
    NA_character_
  }
}

parse_single_scielo_jats <- function(file) {
  raw_lines <- readLines(file, encoding = "UTF-8", warn = FALSE)
  if (length(raw_lines) == 0L) return(null_or_empty_scielo())
  xml_text <- paste(raw_lines, collapse = " ")

  if (!grepl("<article\\b", xml_text, ignore.case = TRUE)) {
    return(null_or_empty_scielo())
  }
  # Isola nó front para metadados do artigo
  m_front <- regexec("<front\\b[^>]*>(.*?)</front>", xml_text, perl = TRUE)
  reg_front <- regmatches(xml_text, m_front)[[1]]
  front_text <- if (length(reg_front) >= 2) reg_front[2] else xml_text

  # 1. Titulo (TI)
  ti <- extract_first_tag(front_text, "article-title")
  if (is.na(ti) || !nzchar(ti)) {
    ti <- extract_first_tag(front_text, "trans-title")
  }

  # 2. Periodico (SO)
  so <- extract_first_tag(front_text, "journal-title")
  if (is.na(so) || !nzchar(so)) {
    so <- extract_first_tag(front_text, "abbrev-journal-title")
  }

  # 3. Ano (PY)
  # Busca dentro de pub-date
  m_pub <- regexec("<pub-date\\b[^>]*>(.*?)</pub-date>", front_text, perl = TRUE)
  reg_pub <- regmatches(front_text, m_pub)[[1]]
  py <- NA_character_
  if (length(reg_pub) >= 2) {
    py <- extract_first_tag(reg_pub[2], "year")
  }
  if (is.na(py) || !nzchar(py)) {
    py <- extract_first_tag(front_text, "year")
  }

  # 4. Autores (AU)
  # Extrai contrib contrib-type="author"
  m_contrib <- gregexpr("<contrib\\b[^>]*contrib-type=[\"']author[\"'][^>]*>(.*?)</contrib>", front_text, perl = TRUE)
  contrib_matches <- regmatches(front_text, m_contrib)[[1]]
  raw_authors <- character(0L)

  if (length(contrib_matches) > 0) {
    for (cm in contrib_matches) {
      surname <- extract_first_tag(cm, "surname")
      given <- extract_first_tag(cm, "given-names")
      if (!is.na(surname) && nzchar(surname)) {
        author_name <- if (!is.na(given) && nzchar(given)) paste(surname, given, sep = ", ") else surname
        raw_authors <- c(raw_authors, author_name)
      }
    }
  }

  au <- if (length(raw_authors) > 0) {
    normalize_authors(paste(raw_authors, collapse = "; "))
  } else {
    NA_character_
  }

  # 5. Resumo (AB)
  ab <- extract_first_tag(front_text, "abstract")

  # 6. Palavras-chave (DE)
  m_kwd <- gregexpr("<kwd\\b[^>]*>(.*?)</kwd>", front_text, perl = TRUE)
  kwd_matches <- regmatches(front_text, m_kwd)[[1]]
  de <- if (length(kwd_matches) > 0) {
    kw_vec <- vapply(kwd_matches, function(k) {
      gsub("<[^>]+>", "", k)
    }, FUN.VALUE = character(1L), USE.NAMES = FALSE)
    kw_vec <- trimws(kw_vec)
    kw_vec <- kw_vec[nzchar(kw_vec)]
    if (length(kw_vec) > 0) paste(toupper(kw_vec), collapse = "; ") else NA_character_
  } else {
    NA_character_
  }

  # 7. DOI (DI)
  m_doi <- regexec("<article-id\\b[^>]*pub-id-type=[\"']doi[\"'][^>]*>(.*?)</article-id>", front_text, perl = TRUE)
  reg_doi <- regmatches(front_text, m_doi)[[1]]
  di <- if (length(reg_doi) >= 2) trimws(gsub("<[^>]+>", "", reg_doi[2])) else NA_character_
  if (!is.na(di)) {
    di <- gsub("^https?://(dx\\.)?doi\\.org/", "", di, ignore.case = TRUE)
  }

  # 8. ISSN (SN)
  sn <- extract_first_tag(front_text, "issn")

  # 9. Volume, Fasciculo, Paginas (VL, IS, BP, EP)
  vl <- extract_first_tag(front_text, "volume")
  is <- extract_first_tag(front_text, "issue")
  bp <- extract_first_tag(front_text, "fpage")
  ep <- extract_first_tag(front_text, "lpage")

  # 10. Afiliações (C1)
  m_aff <- gregexpr("<aff\\b[^>]*>(.*?)</aff>", front_text, perl = TRUE)
  aff_matches <- regmatches(front_text, m_aff)[[1]]
  c1 <- if (length(aff_matches) > 0) {
    aff_vec <- vapply(aff_matches, function(a) {
      org <- extract_first_tag(a, "institution")
      country <- extract_first_tag(a, "country")
      parts <- c(org, country)
      parts <- parts[!is.na(parts) & nzchar(parts)]
      if (length(parts) > 0) paste(parts, collapse = ", ") else trimws(gsub("<[^>]+>", " ", a))
    }, FUN.VALUE = character(1L), USE.NAMES = FALSE)
    aff_vec <- trimws(aff_vec)
    aff_vec <- aff_vec[nzchar(aff_vec)]
    if (length(aff_vec) > 0) paste(aff_vec, collapse = "; ") else NA_character_
  } else {
    NA_character_
  }

  # 11. Cited References (CR)
  m_ref <- gregexpr("<ref\\b[^>]*>(.*?)</ref>", xml_text, perl = TRUE)
  ref_matches <- regmatches(xml_text, m_ref)[[1]]
  cr_list <- character(0L)

  if (length(ref_matches) > 0) {
    for (rm in ref_matches) {
      cr_item <- parse_scielo_reference(rm)
      if (!is.na(cr_item) && nzchar(cr_item)) {
        cr_list <- c(cr_list, cr_item)
      }
    }
  }

  cr <- if (length(cr_list) > 0) paste(cr_list, collapse = "; ") else NA_character_

  list(
    TI = ti,
    AU = au,
    SO = so,
    PY = py,
    AB = ab,
    DE = de,
    DI = di,
    SN = sn,
    VL = vl,
    IS = is,
    BP = bp,
    EP = ep,
    C1 = c1,
    CR = cr
  )
}

null_or_empty_scielo <- function() {
  NULL
}

parse_scielo_reference <- function(ref_text) {
  # Verifica se tem element-citation
  if (grepl("<element-citation\\b", ref_text, ignore.case = TRUE)) {
    # 1. Autor primeiro
    m_author <- regexec("<surname\\b[^>]*>(.*?)</surname>", ref_text, perl = TRUE)
    reg_author <- regmatches(ref_text, m_author)[[1]]
    ref_author <- if (length(reg_author) >= 2) toupper(trimws(gsub("<[^>]+>", "", reg_author[2]))) else ""

    # 2. Ano
    m_year <- regexec("<year\\b[^>]*>(.*?)</year>", ref_text, perl = TRUE)
    reg_year <- regmatches(ref_text, m_year)[[1]]
    ref_year <- if (length(reg_year) >= 2) trimws(gsub("<[^>]+>", "", reg_year[2])) else ""

    # 3. Periodico / Fonte
    m_source <- regexec("<source\\b[^>]*>(.*?)</source>", ref_text, perl = TRUE)
    reg_source <- regmatches(ref_text, m_source)[[1]]
    ref_source <- if (length(reg_source) >= 2) toupper(trimws(gsub("<[^>]+>", "", reg_source[2]))) else ""

    # 4. Volume
    m_vol <- regexec("<volume\\b[^>]*>(.*?)</volume>", ref_text, perl = TRUE)
    reg_vol <- regmatches(ref_text, m_vol)[[1]]
    ref_vol <- if (length(reg_vol) >= 2) paste0("V", trimws(gsub("<[^>]+>", "", reg_vol[2]))) else ""

    # 5. Pagina
    m_page <- regexec("<fpage\\b[^>]*>(.*?)</fpage>", ref_text, perl = TRUE)
    reg_page <- regmatches(ref_text, m_page)[[1]]
    ref_page <- if (length(reg_page) >= 2) paste0("P", trimws(gsub("<[^>]+>", "", reg_page[2]))) else ""

    # 6. DOI
    m_rdoi <- regexec("<pub-id\\b[^>]*pub-id-type=[\"']doi[\"'][^>]*>(.*?)</pub-id>", ref_text, perl = TRUE)
    reg_rdoi <- regmatches(ref_text, m_rdoi)[[1]]
    ref_doi <- if (length(reg_rdoi) >= 2) paste0("DOI: ", trimws(gsub("<[^>]+>", "", reg_rdoi[2]))) else ""

    parts <- c(ref_author, ref_year, ref_source, ref_vol, ref_page, ref_doi)
    parts <- parts[nzchar(parts)]
    if (length(parts) > 0) return(paste(parts, collapse = ", "))
  }

  # Fallback para mixed-citation
  if (grepl("<mixed-citation\\b", ref_text, ignore.case = TRUE)) {
    raw_mixed <- extract_first_tag(ref_text, "mixed-citation")
    if (!is.na(raw_mixed) && nzchar(raw_mixed)) {
      clean_mixed <- gsub("\\s+", " ", raw_mixed)
      clean_mixed <- gsub("^[0-9.]+\\s*", "", clean_mixed)
      return(trimws(clean_mixed))
    }
  }

  NA_character_
}
