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
    # decodifica entidades xml comuns
    clean_txt <- gsub("&amp;", "&", clean_txt, fixed = TRUE)
    clean_txt <- gsub("&lt;", "<", clean_txt, fixed = TRUE)
    clean_txt <- gsub("&gt;", ">", clean_txt, fixed = TRUE)
    clean_txt <- gsub("&quot;", "\"", clean_txt, fixed = TRUE)
    clean_txt <- gsub("&apos;|&#39;", "'", clean_txt)
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
  # Extrai contrib contrib-type="author" ou qualquer contrib se nao houver author
  m_contrib <- gregexpr("<contrib\\b[^>]*contrib-type=[\"']author[\"'][^>]*>(.*?)</contrib>", front_text, perl = TRUE)
  contrib_matches <- regmatches(front_text, m_contrib)[[1]]
  if (length(contrib_matches) == 0L || (length(contrib_matches) == 1L && !nzchar(contrib_matches[1]))) {
    m_contrib <- gregexpr("<contrib\\b[^>]*>(.*?)</contrib>", front_text, perl = TRUE)
    contrib_matches <- regmatches(front_text, m_contrib)[[1]]
  }

  raw_authors <- character(0L)
  is_collab_vec <- logical(0L)

  if (length(contrib_matches) > 0) {
    for (cm in contrib_matches) {
      surname <- extract_first_tag(cm, "surname")
      given <- extract_first_tag(cm, "given-names")
      collab <- extract_first_tag(cm, "collab")
      suffix <- extract_first_tag(cm, "suffix")
      if (!is.na(suffix) && nzchar(suffix) && !is.na(surname)) {
        surname <- paste(surname, suffix)
      }
      if (!is.na(surname) && nzchar(surname)) {
        author_name <- if (!is.na(given) && nzchar(given)) paste(surname, given, sep = ", ") else surname
        raw_authors <- c(raw_authors, author_name)
        is_collab_vec <- c(is_collab_vec, FALSE)
      } else if (!is.na(collab) && nzchar(collab)) {
        raw_authors <- c(raw_authors, collab)
        is_collab_vec <- c(is_collab_vec, TRUE)
      }
    }
  }

  # Se ainda nao achou autores, checa collab direto em contrib-group
  if (length(raw_authors) == 0L) {
    m_cg <- regexec("<contrib-group\\b[^>]*>(.*?)</contrib-group>", front_text, perl = TRUE)
    reg_cg <- regmatches(front_text, m_cg)[[1]]
    if (length(reg_cg) >= 2) {
      cg_collab <- extract_first_tag(reg_cg[2], "collab")
      if (!is.na(cg_collab) && nzchar(cg_collab)) {
        raw_authors <- c(raw_authors, cg_collab)
        is_collab_vec <- c(is_collab_vec, TRUE)
      }
    }
  }

  au <- if (length(raw_authors) > 0) {
    norm_vec <- mapply(function(a, is_c) {
      if (is_c) {
        toupper(trimws(a))
      } else {
        normalize_authors(a)
      }
    }, raw_authors, is_collab_vec, USE.NAMES = FALSE)
    norm_vec <- norm_vec[!is.na(norm_vec) & nzchar(norm_vec)]
    if (length(norm_vec) > 0) paste(norm_vec, collapse = "; ") else NA_character_
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
    ref_author <- extract_first_tag(ref_text, "surname")
    ref_author <- if (!is.na(ref_author) && nzchar(ref_author)) toupper(ref_author) else ""

    # 2. Ano
    ref_year <- extract_first_tag(ref_text, "year")
    ref_year <- if (!is.na(ref_year) && nzchar(ref_year)) ref_year else ""

    # 3. Periodico / Fonte
    ref_source <- extract_first_tag(ref_text, "source")
    ref_source <- if (!is.na(ref_source) && nzchar(ref_source)) toupper(ref_source) else ""

    # 4. Volume
    ref_vol <- extract_first_tag(ref_text, "volume")
    ref_vol <- if (!is.na(ref_vol) && nzchar(ref_vol)) paste0("V", ref_vol) else ""

    # 5. Pagina
    ref_page <- extract_first_tag(ref_text, "fpage")
    ref_page <- if (!is.na(ref_page) && nzchar(ref_page)) paste0("P", ref_page) else ""

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
