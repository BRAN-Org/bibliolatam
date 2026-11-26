#' Clean and standardize DOI strings
#'
#' @param doi Character vector of DOIs.
#' @return Cleaned uppercase DOI string or NA.
#' @noRd
clean_doi <- function(doi) {
  if (is.null(doi)) return(character(0L))
  d <- trimws(as.character(doi))
  d <- gsub("^https?://(dx\\.)?doi\\.org/", "", d, ignore.case = TRUE)
  d <- gsub("^doi:\\s*", "", d, ignore.case = TRUE)
  d <- gsub("[./]$", "", d) # remove trailing dots/slashes
  d <- toupper(trimws(d))
  d[!nzchar(d) | d == "NA"] <- NA_character_
  d
}

#' Check if two cleaned DOIs differ only by safe separator spelling
#'
#' Narrow exception to the explicit DOI conflict veto, inspired by Kara et al. (2025)
#' (BibexPy). Allows pairs whose registrant prefix and separator-free alphanumeric
#' suffix core are identical, with differing separators limited to 1-to-1 substitutions
#' (`-`, `.`, `_`) or internal insertions/deletions not splitting two adjacent digits
#' (strictly rejecting volume/page partitioning shifts such as `5.350` vs `53.50`).
#'
#' @param d1 Character scalar (cleaned uppercase DOI).
#' @param d2 Character scalar (cleaned uppercase DOI).
#' @return Logical scalar.
#' @noRd
is_doi_separator_variant <- function(d1, d2) {
  if (is.na(d1) || is.na(d2) || !nzchar(d1) || !nzchar(d2) || identical(d1, d2)) {
    return(FALSE)
  }
  s1 <- regexpr("/", d1, fixed = TRUE)
  s2 <- regexpr("/", d2, fixed = TRUE)
  if (s1 < 2L || s2 < 2L) return(FALSE)

  pref1 <- substr(d1, 1L, s1 - 1L)
  pref2 <- substr(d2, 1L, s2 - 1L)
  if (!identical(pref1, pref2)) return(FALSE)

  suf1 <- substr(d1, s1 + 1L, nchar(d1))
  suf2 <- substr(d2, s2 + 1L, nchar(d2))
  if (!nzchar(suf1) || !nzchar(suf2)) return(FALSE)

  profile_suffix <- function(suf) {
    chars <- strsplit(suf, "", fixed = TRUE)[[1]]
    core <- character(0L)
    gaps <- list()
    for (ch in chars) {
      if (ch %in% c("-", ".", "_")) {
        k <- as.character(length(core))
        gaps[[k]] <- paste0(if (!is.null(gaps[[k]])) gaps[[k]] else "", ch)
      } else {
        core <- c(core, ch)
      }
    }
    list(core = core, gaps = gaps)
  }

  p1 <- profile_suffix(suf1)
  p2 <- profile_suffix(suf2)
  if (!identical(p1$core, p2$core)) return(FALSE)

  core_len <- length(p1$core)
  all_pos <- union(names(p1$gaps), names(p2$gaps))
  for (k in all_pos) {
    x <- if (!is.null(p1$gaps[[k]])) p1$gaps[[k]] else ""
    y <- if (!is.null(p2$gaps[[k]])) p2$gaps[[k]] else ""
    if (identical(x, y)) next
    if (nchar(x) == 1L && nchar(y) == 1L) next
    if (nchar(x) > 1L || nchar(y) > 1L) return(FALSE)
    pos <- as.integer(k)
    if (pos <= 0L || pos >= core_len) return(FALSE)
    if (grepl("^[0-9]$", p1$core[pos]) && grepl("^[0-9]$", p1$core[pos + 1L])) {
      return(FALSE)
    }
  }
  TRUE
}

#' Clean numeric bibliographic locator (volume VL or beginning page BP)
#'
#' @param x Character/numeric vector.
#' @return Standardized uppercase locator string or NA.
#' @noRd
clean_bib_locator <- function(x) {
  if (is.null(x)) return(character(0L))
  s <- trimws(as.character(x))
  s[is.na(x) | !nzchar(s) | toupper(s) == "NA"] <- NA_character_
  s <- gsub("^([Vv][Oo][Ll]?\\.?|[Pp]{1,2}\\.?)\\s*", "", s)
  s <- gsub("\\.0+$", "", s)
  s <- sub("\\s*[-\u2013\u2014].*$", "", s)
  s <- toupper(trimws(s))
  s[!nzchar(s) | s == "NA"] <- NA_character_
  s
}

#' Normalize title strings for fuzzy comparison
#'
#' @param titles Character vector of titles.
#' @return Normalized ASCII lowercase title strings.
#' @noRd
normalize_title_str <- function(titles) {
  if (is.null(titles)) return(character(0L))
  t <- tolower(trimws(as.character(titles)))
  # remove acentos
  t <- iconv(t, to = "ASCII//TRANSLIT")
  # remove pontuacao e espacos multiplos
  t <- gsub("[^a-z0-9]", " ", t)
  t <- gsub("\\s+", " ", t)
  t <- trimws(t)
  # harmoniza abreviacoes comuns de series em titulos
  t <- gsub("\\bvol\\b", "volume", t)
  t <- gsub("\\bpt\\b", "parte", t)
  t <- gsub("\\bsecc?\\b", "secao", t)
  trimws(t)
}

#' Extract normalized series/part token from normalized title
#'
#' @param norm_title Normalized lowercase ASCII title string.
#' @return A character string identifier (e.g. "part_1", "part_2") or NA.
#' @noRd
extract_part_token <- function(norm_title) {
  if (is.null(norm_title) || is.na(norm_title) || !nzchar(norm_title)) return(NA_character_)

  roman_map <- c(
    "i" = "1", "ii" = "2", "iii" = "3", "iv" = "4", "v" = "5",
    "vi" = "6", "vii" = "7", "viii" = "8", "ix" = "9", "x" = "10"
  )

  # 1. Verifica padroes com indicadores explicitos (PT, EN e ES: parte, volume/volumen, secao/seccion, fase, ensaio, tomo, entrega, capitulo)
  m <- regexec("\\b(parte|part|volumen|volume|vol|secao|seccion|section|fase|phase|ensaio|tomo|entrega|capitulo)\\s+([0-9]+|[ivxlcdm]+|[a-z])\\b", norm_title)
  reg_res <- regmatches(norm_title, m)[[1]]
  if (length(reg_res) >= 3L) {
    indicator <- tolower(reg_res[2])
    val <- tolower(reg_res[3])

    if (indicator %in% c("part", "parte")) indicator <- "part"
    if (indicator %in% c("volume", "volumen", "vol")) indicator <- "vol"
    if (indicator %in% c("section", "secao", "seccion")) indicator <- "sec"
    if (indicator %in% c("phase", "fase")) indicator <- "phase"

    if (val %in% names(roman_map)) {
      val <- roman_map[[val]]
    }
    return(paste0(indicator, "_", val))
  }

  # 2. Verifica numeral romano ou ordinal curto ao final do titulo (ex: "estudo i" vs "estudo ii")
  trailing_m <- regexec("\\s+(i|ii|iii|iv|v|vi|vii|viii|ix|x|[0-9]{1,2})$", norm_title)
  trailing_res <- regmatches(norm_title, trailing_m)[[1]]
  if (length(trailing_res) >= 2L) {
    val <- tolower(trailing_res[2])
    if (val %in% names(roman_map)) val <- roman_map[[val]]
    return(paste0("part_", val))
  }

  NA_character_
}

#' Extract clean uppercase author surnames from author string
#'
#' @param au_str Character scalar representing authors.
#' @return Character vector of distinct uppercase author surnames, or character(0).
#' @noRd
extract_author_surnames <- function(au_str) {
  if (is.null(au_str) || is.na(au_str) || !nzchar(trimws(au_str))) {
    return(character(0L))
  }
  raw_authors <- unlist(strsplit(as.character(au_str), ";", fixed = TRUE))
  surnames <- character(0L)

  sufixos <- c("junior", "jr", "filho", "neto", "sobrinho", "segundo", "terceiro")

  for (a in raw_authors) {
    a <- trimws(a)
    if (!nzchar(a)) next

    if (grepl(",", a, fixed = TRUE)) {
      comma_parts <- trimws(unlist(strsplit(a, ",", fixed = TRUE)))
      sn <- comma_parts[1]
      if (tolower(sn) %in% sufixos && length(comma_parts) >= 2L && nzchar(comma_parts[2])) {
        after_toks <- unlist(strsplit(comma_parts[2], "\\s+"))
        after_toks <- after_toks[nzchar(after_toks)]
        if (length(after_toks) > 0L) sn <- after_toks[length(after_toks)]
      }
    } else {
      tokens <- unlist(strsplit(a, "\\s+"))
      tokens <- tokens[nzchar(tokens)]
      if (length(tokens) == 0L) next
      if (length(tokens) == 1L) {
        sn <- tokens[1]
      } else {
        last_tok <- tolower(tokens[length(tokens)])
        if (last_tok %in% sufixos && length(tokens) >= 3L) {
          sn <- paste(tokens[length(tokens) - 1L], tokens[length(tokens)])
        } else if (grepl("^[A-Z]{1,4}$", tokens[length(tokens)]) && length(tokens) >= 2L) {
          # Formato WOS padrao: "SOBRENOME INICIAIS"
          sn <- paste(tokens[1L:(length(tokens) - 1L)], collapse = " ")
        } else {
          sn <- tokens[length(tokens)]
        }
      }
    }

    sn_norm <- tolower(trimws(sn))
    sn_norm <- iconv(sn_norm, to = "ASCII//TRANSLIT")
    sn_clean <- gsub("[^a-z]", "", sn_norm)
    non_distinctive <- c("anonymous", "anonimo", "desconhecido", "na", sufixos,
                         "san", "santa", "santo", "sao", "van", "von")
    if (nzchar(sn_clean) && !sn_clean %in% non_distinctive) {
      surnames <- c(surnames, toupper(sn_clean))
    }
    # Extrai tambem sub-tokens significativos de sobrenomes compostos (Achado #4)
    sn_words <- unlist(strsplit(sn_norm, "\\s+"))
    sn_words <- sn_words[!sn_words %in% c("da", "de", "do", "das", "dos", "del", "la", "las", "los", "y", "e",
                                          non_distinctive)]
    for (w in sn_words) {
      w_clean <- gsub("[^a-z]", "", w)
      if (nchar(w_clean) >= 3L && !w_clean %in% non_distinctive) {
        surnames <- c(surnames, toupper(w_clean))
      }
    }
  }
  unique(surnames)
}

#' Check if two sets of author surnames are compatible
#'
#' @param sn1 Character vector of surnames.
#' @param sn2 Character vector of surnames.
#' @return Logical TRUE if compatible, FALSE otherwise.
#' @noRd
surnames_compatible <- function(sn1, sn2) {
  if (length(sn1) == 0L || length(sn2) == 0L) return(FALSE)
  # Sobreposicao exata
  if (length(intersect(sn1, sn2)) > 0L) return(TRUE)
  # Tolerancia de 1 caractere de edicao para variacoes foneticas comuns (ex: Sousa vs Souza)
  for (s1 in sn1) {
    if (nchar(s1) < 4L) next
    dists <- utils::adist(s1, sn2)[1, ]
    if (any(dists <= 1L)) return(TRUE)
  }
  FALSE
}

#' Internal deduplication for a single bibliographic dataset
#'
#' @param df Data frame conforming to bibliometrixDB tags.
#' @param match_by Character vector specifying matching criteria: "doi" and/or "title".
#' @param similarity_threshold Numeric threshold for title matching.
#' @param verbose Logical flag.
#' @return Deduplicated data frame.
#' @noRd
deduplicate_internal <- function(df,
                                 match_by = c("doi", "title"),
                                 similarity_threshold = 0.90,
                                 verbose = FALSE) {
  if (nrow(df) <= 1L) {
    class(df) <- unique(c("bibliometrixDB", class(df)))
    return(df)
  }

  req_cols <- c("AU", "TI", "SO", "PY")
  missing_req <- setdiff(req_cols, names(df))
  if (length(missing_req) > 0L) {
    stop(sprintf("Data frame nao contem as colunas minimas necessarias: %s",
                 paste(missing_req, collapse = ", ")), call. = FALSE)
  }

  all_cols <- names(df)
  n <- nrow(df)

  dois <- if ("DI" %in% names(df)) clean_doi(df$DI) else rep(NA_character_, n)
  titles <- normalize_title_str(df$TI)
  titles_lens <- nchar(titles)
  parts <- vapply(titles, extract_part_token, character(1L), USE.NAMES = FALSE)
  au_surnames <- lapply(df$AU, extract_author_surnames)
  py <- suppressWarnings(as.numeric(df$PY))
  dt <- if ("DT" %in% names(df)) toupper(trimws(as.character(df$DT))) else rep(NA_character_, n)

  matched_pairs <- list()
  merged_rows <- logical(n)

  # 1. Matching por DOI exato
  if ("doi" %in% match_by) {
    for (i in seq_len(n - 1L)) {
      if (merged_rows[i]) next
      d1 <- dois[i]
      if (!is.na(d1) && nzchar(d1)) {
        pos <- which(!merged_rows & (seq_len(n) > i) & !is.na(dois) & dois == d1)
        for (j in pos) {
          matched_pairs[[length(matched_pairs) + 1L]] <- c(i, j)
          merged_rows[j] <- TRUE
        }
      }
    }
  }
  doi_matches_count <- length(matched_pairs)
  dois_core <- gsub("[-._]", "", dois)

  # 2. Matching por Titulo aproximado (filtros O(1) vetorizados ANTES de loops de autoria e adist)
  candidates_before_len <- 0L
  pruned_by_len <- 0L
  if ("title" %in% match_by) {
    for (i in seq_len(n - 1L)) {
      if (merged_rows[i]) next
      t1 <- titles[i]
      if (!nzchar(t1) || nchar(t1) < 15L) next
      t1_len <- titles_lens[i]

      cand_indices <- which(!merged_rows & (seq_len(n) > i))
      if (length(cand_indices) == 0L) break

      # 2.1 Conflito explicito de DOIs distintos (Achado #1, O(1) vetorizado; libera variantes seguras de separador)
      d1 <- dois[i]
      if (!is.na(d1) && nzchar(d1)) {
        cand_d2 <- dois[cand_indices]
        doi_conflict <- !is.na(cand_d2) & nzchar(cand_d2) & cand_d2 != d1
        if (any(doi_conflict)) {
          same_core <- which(doi_conflict & dois_core[cand_indices] == dois_core[i])
          for (cp in same_core) {
            if (is_doi_separator_variant(d1, cand_d2[cp])) doi_conflict[cp] <- FALSE
          }
        }
        cand_indices <- cand_indices[!doi_conflict]
      }
      if (length(cand_indices) == 0L) next

      # 2.2 Guardrail de Tipo Documental (DT) (Achado #3, O(1) vetorizado)
      t_doc1 <- dt[i]
      if (!is.na(t_doc1) && nzchar(t_doc1)) {
        is_thesis_1 <- t_doc1 %in% c("THESIS", "DISSERTATION")
        is_article_1 <- t_doc1 %in% c("ARTICLE", "JOURNAL ARTICLE", "JOURNAL")
        if (is_thesis_1 || is_article_1) {
          cand_dt2 <- dt[cand_indices]
          cand_is_thesis_2 <- cand_dt2 %in% c("THESIS", "DISSERTATION")
          cand_is_article_2 <- cand_dt2 %in% c("ARTICLE", "JOURNAL ARTICLE", "JOURNAL")
          dt_incompatible <- (is_thesis_1 & cand_is_article_2) | (is_article_1 & cand_is_thesis_2)
          cand_indices <- cand_indices[!dt_incompatible]
        }
      }
      if (length(cand_indices) == 0L) next

      # 2.3 Tolerancia de ano +- 1 (O(1) vetorizado)
      p1 <- py[i]
      if (!is.na(p1)) {
        cand_p2 <- py[cand_indices]
        valid_year <- is.na(cand_p2) | abs(cand_p2 - p1) <= 1
        cand_indices <- cand_indices[valid_year]
      }
      if (length(cand_indices) == 0L) next

      # 2.4 Guardrail de Series / Partes (O(1) vetorizado)
      part1 <- parts[i]
      if (length(cand_indices) > 0L) {
        cand_parts2 <- parts[cand_indices]
        both_have_diff_parts <- !is.na(part1) & !is.na(cand_parts2) & part1 != cand_parts2
        is_sequel_1 <- !is.na(part1) && grepl("_(2|3|4|5|6|7|8|9|10)$", part1)
        sequel_discrepancy_1 <- is_sequel_1 & is.na(cand_parts2)
        sequel_discrepancy_2 <- is.na(part1) & !is.na(cand_parts2) & grepl("_(2|3|4|5|6|7|8|9|10)$", cand_parts2)
        valid_parts <- !both_have_diff_parts & !sequel_discrepancy_1 & !sequel_discrepancy_2
        cand_indices <- cand_indices[valid_parts]
      }
      if (length(cand_indices) == 0L) next

      # 2.5 Length Bound Filter (O(1) vetorizado - poda ~90% antes de qualquer loop R ou adist)
      candidates_before_len <- candidates_before_len + length(cand_indices)
      if (similarity_threshold > 0) {
        min_len <- ceiling(t1_len * similarity_threshold)
        max_len <- floor(t1_len / similarity_threshold)
        cand_lens <- titles_lens[cand_indices]
        valid_len <- cand_lens >= min_len & cand_lens <= max_len
        pruned_by_len <- pruned_by_len + sum(!valid_len)
        cand_indices <- cand_indices[valid_len]
        if (length(cand_indices) == 0L) next
      }

      cand_titles <- titles[cand_indices]
      sn1 <- au_surnames[[i]]

      # 2.6 Exact match fast-path (O(1), checa autoria apenas nos candidatos de titulo identico)
      exact_match_pos <- which(cand_titles == t1)
      if (length(exact_match_pos) > 0L) {
        ex_cands <- cand_indices[exact_match_pos]
        if (length(sn1) > 0L) {
          ok_ex <- vapply(ex_cands, function(c_idx) {
            sn2 <- au_surnames[[c_idx]]
            length(sn2) == 0L || surnames_compatible(sn1, sn2)
          }, logical(1L))
          ex_cands <- ex_cands[ok_ex]
        }
        if (length(ex_cands) > 0L) {
          if (length(ex_cands) > 1L && length(sn1) > 0L) {
            has_au <- vapply(ex_cands, function(c_idx) length(au_surnames[[c_idx]]) > 0L, logical(1L))
            if (any(has_au)) ex_cands <- ex_cands[has_au]
          }
          target_j <- ex_cands[1L]
          matched_pairs[[length(matched_pairs) + 1L]] <- c(i, target_j)
          merged_rows[target_j] <- TRUE
          next
        }
        cand_indices <- cand_indices[-exact_match_pos]
        if (length(cand_indices) == 0L) next
        cand_titles <- titles[cand_indices]
      }

      # 2.7 Canopy filter se > 15 candidatos sobreviventes ao Length Bound
      if (length(cand_indices) > 15L) {
        sig_words <- unlist(regmatches(t1, gregexpr("[a-z0-9]{4,}", t1)))
        if (length(sig_words) > 0L) {
          shared_term <- logical(length(cand_indices))
          for (w in sig_words) {
            shared_term <- shared_term | grepl(w, cand_titles, fixed = TRUE)
          }
          cand_indices <- cand_indices[shared_term]
          if (length(cand_indices) == 0L) next
          cand_titles <- titles[cand_indices]
        }
      }

      # 2.8 Guardrail de Autoria (executado apenas sobre o subconjunto podado)
      if (length(sn1) > 0L && length(cand_indices) > 0L) {
        valid_authors <- logical(length(cand_indices))
        for (k in seq_along(cand_indices)) {
          c_idx <- cand_indices[k]
          sn2 <- au_surnames[[c_idx]]
          valid_authors[k] <- length(sn2) == 0L || surnames_compatible(sn1, sn2)
        }
        cand_indices <- cand_indices[valid_authors]
        if (length(cand_indices) == 0L) next
        cand_titles <- titles[cand_indices]
      }

      # 2.9 Levenshtein fuzzy matching
      dists <- utils::adist(t1, cand_titles)[1, ]
      max_lens <- pmax(t1_len, titles_lens[cand_indices])
      sims <- 1 - (dists / max_lens)

      best_idx <- which.max(sims)
      if (length(best_idx) > 0L) {
        max_sim <- sims[best_idx]
        c_idx <- cand_indices[best_idx]

        eff_thresh <- similarity_threshold
        if (length(sn1) == 0L || length(au_surnames[[c_idx]]) == 0L) {
          eff_thresh <- max(eff_thresh, 0.95)
        }

        if (max_sim >= eff_thresh) {
          matched_pairs[[length(matched_pairs) + 1L]] <- c(i, c_idx)
          merged_rows[c_idx] <- TRUE
        }
      }
    }
  }
  title_matches_count <- length(matched_pairs) - doi_matches_count

  # 3. Fallback estrutural (SO >= 0.90 + VL + BP + PY +- 1 + AU compativel) para edicoes traduzidas sem DOI
  # Inspirado em Kara et al. (2025) (BibexPy), preservando todos os guardrails de DOI/DT/Series/Autoria.
  structural_matches_count <- 0L
  if ("title" %in% match_by && all(c("SO", "VL", "BP") %in% names(df))) {
    so_norm <- normalize_title_str(df$SO)
    vl_clean <- clean_bib_locator(df$VL)
    bp_clean <- clean_bib_locator(df$BP)

    for (i in seq_len(n - 1L)) {
      if (merged_rows[i]) next
      if (is.na(vl_clean[i]) || is.na(bp_clean[i]) || nchar(so_norm[i]) < 5L) next
      sn1 <- au_surnames[[i]]
      if (length(sn1) == 0L) next

      cand_indices <- which(!merged_rows & (seq_len(n) > i) &
                              !is.na(vl_clean) & vl_clean == vl_clean[i] &
                              !is.na(bp_clean) & bp_clean == bp_clean[i] &
                              nchar(so_norm) >= 5L)
      if (length(cand_indices) == 0L) next

      d1 <- dois[i]
      if (!is.na(d1) && nzchar(d1)) {
        cand_d2 <- dois[cand_indices]
        doi_conflict <- !is.na(cand_d2) & nzchar(cand_d2) & cand_d2 != d1
        if (any(doi_conflict)) {
          same_core <- which(doi_conflict & dois_core[cand_indices] == dois_core[i])
          for (cp in same_core) {
            if (is_doi_separator_variant(d1, cand_d2[cp])) doi_conflict[cp] <- FALSE
          }
        }
        cand_indices <- cand_indices[!doi_conflict]
      }
      if (length(cand_indices) == 0L) next

      t_doc1 <- dt[i]
      if (!is.na(t_doc1) && nzchar(t_doc1)) {
        is_th1 <- t_doc1 %in% c("THESIS", "DISSERTATION")
        is_ar1 <- t_doc1 %in% c("ARTICLE", "JOURNAL ARTICLE", "JOURNAL")
        if (is_th1 || is_ar1) {
          cdt2 <- dt[cand_indices]
          dt_inc <- (is_th1 & cdt2 %in% c("ARTICLE", "JOURNAL ARTICLE", "JOURNAL")) |
                    (is_ar1 & cdt2 %in% c("THESIS", "DISSERTATION"))
          cand_indices <- cand_indices[!dt_inc]
        }
      }
      if (length(cand_indices) == 0L) next

      p1 <- py[i]
      if (!is.na(p1)) {
        cand_p2 <- py[cand_indices]
        cand_indices <- cand_indices[is.na(cand_p2) | abs(cand_p2 - p1) <= 1]
      }
      if (length(cand_indices) == 0L) next

      part1 <- parts[i]
      cand_parts2 <- parts[cand_indices]
      both_diff <- !is.na(part1) & !is.na(cand_parts2) & part1 != cand_parts2
      is_seq1 <- !is.na(part1) && grepl("_(2|3|4|5|6|7|8|9|10)$", part1)
      seq1 <- is_seq1 & is.na(cand_parts2)
      seq2 <- is.na(part1) & !is.na(cand_parts2) & grepl("_(2|3|4|5|6|7|8|9|10)$", cand_parts2)
      cand_indices <- cand_indices[!both_diff & !seq1 & !seq2]
      if (length(cand_indices) == 0L) next

      ok_au <- vapply(cand_indices, function(c_idx) {
        sn2 <- au_surnames[[c_idx]]
        length(sn2) > 0L && surnames_compatible(sn1, sn2)
      }, logical(1L))
      cand_indices <- cand_indices[ok_au]
      if (length(cand_indices) == 0L) next

      so_dists <- utils::adist(so_norm[i], so_norm[cand_indices])[1, ]
      so_sims <- 1 - (so_dists / pmax(nchar(so_norm[i]), nchar(so_norm[cand_indices])))
      best_so <- which.max(so_sims)
      if (length(best_so) > 0L && so_sims[best_so] >= 0.90) {
        target_j <- cand_indices[best_so]
        matched_pairs[[length(matched_pairs) + 1L]] <- c(i, target_j)
        merged_rows[target_j] <- TRUE
        structural_matches_count <- structural_matches_count + 1L
      }
    }
  }

  # Fusao dos pares duplicados internos
  out_df <- df
  for (pair in matched_pairs) {
    i <- pair[1]
    j <- pair[2]
    row1 <- out_df[i, , drop = FALSE]
    row2 <- out_df[j, , drop = FALSE]

    fused_row <- row1
    for (col in all_cols) {
      val1 <- row1[[col]][1]
      val2 <- row2[[col]][1]

      if (is.null(val1) || is.na(val1) || !nzchar(trimws(as.character(val1)))) {
        if (!is.null(val2) && !is.na(val2) && nzchar(trimws(as.character(val2)))) {
          fused_row[[col]][1] <- val2
        }
      } else if (col %in% c("CR", "DE")) {
        refs1 <- unlist(strsplit(as.character(val1), ";\\s*"))
        refs2 <- if (!is.na(val2)) unlist(strsplit(as.character(val2), ";\\s*")) else character(0L)
        all_refs <- unique(c(trimws(refs1), trimws(refs2)))
        all_refs <- all_refs[nzchar(all_refs)]
        if (length(all_refs) > 0L) {
          fused_row[[col]][1] <- paste(all_refs, collapse = "; ")
        }
      }
    }
    db1 <- if ("DB" %in% names(row1) && !is.na(row1$DB[1])) as.character(row1$DB[1]) else "DB1"
    db2 <- if ("DB" %in% names(row2) && !is.na(row2$DB[1])) as.character(row2$DB[1]) else "DB2"
    fused_row$DB[1] <- if (identical(db1, db2)) db1 else paste0(db1, "+", db2)

    out_df[i, ] <- fused_row
  }

  out <- out_df[!merged_rows, , drop = FALSE]

  # Regenera SR
  first_author <- gsub(";.*$", "", out$AU)
  first_author <- trimws(first_author)
  first_author[is.na(first_author) | !nzchar(first_author)] <- "ANONYMOUS"

  py_val <- if ("PY" %in% names(out)) out$PY else ""
  py_val[is.na(py_val)] <- ""

  so_val <- if ("SO" %in% names(out)) trimws(out$SO) else ""
  so_val[is.na(so_val)] <- ""

  vl_val <- if ("VL" %in% names(out)) paste0("V", trimws(out$VL)) else ""
  vl_val[is.na(out$VL) | !nzchar(out$VL)] <- ""

  bp_val <- if ("BP" %in% names(out)) paste0("P", trimws(out$BP)) else ""
  bp_val[is.na(out$BP) | !nzchar(out$BP)] <- ""

  sr_vec <- character(nrow(out))
  for (i in seq_len(nrow(out))) {
    parts_i <- c(first_author[i], py_val[i], so_val[i], vl_val[i], bp_val[i])
    parts_i <- parts_i[nzchar(parts_i)]
    sr_vec[i] <- paste(parts_i, collapse = ", ")
  }
  out$SR <- make.unique(toupper(sr_vec), sep = "-")
  out$SR_FULL <- out$SR

  orig_db <- attr(df, "dbsource")
  if (is.null(orig_db)) {
    orig_db <- if ("DB" %in% names(df) && nrow(df) > 0L && !is.na(df$DB[1])) as.character(df$DB[1]) else "deduplicated"
  }

  class(out) <- unique(c("bibliometrixDB", class(out)))
  attr(out, "dbsource") <- orig_db
  attr(out, "merge_stats") <- list(
    n1 = n,
    n2 = 0L,
    doi_duplicates = doi_matches_count,
    title_duplicates = title_matches_count,
    structural_duplicates = structural_matches_count,
    total_duplicates = length(matched_pairs),
    final_count = nrow(out),
    candidates_before_len = candidates_before_len,
    length_bound_pruned = pruned_by_len
  )

  if (verbose) {
    message(sprintf("[merge_bibliolatam] Intra-source deduplicacao: %d registros iniciais -> %d duplicatas fundidas -> %d finais",
                    n, length(matched_pairs), nrow(out)))
  }

  out
}

#' Merge and Deduplicate Regional Bibliographic Collections
#'
#' Merges two bibliographic datasets (e.g. SciELO, Oasisbr, SPELL, BDTD, or Redalyc) or performs
#' intra-source deduplication on a single dataset when `df2` is `NULL`. Identifies duplicates
#' through canonical DOI resolution and normalized title fuzzy matching, fusing complementary
#' metadata fields into a unified corpus.
#'
#' @param df1 A data frame with class `bibliometrixDB` or conforming to standard tags.
#' @param df2 An optional second data frame with class `bibliometrixDB` or conforming to standard tags.
#'   If `NULL` (default), performs intra-source deduplication on `df1`.
#' @param match_by Character vector specifying matching criteria: `"doi"` and/or `"title"`.
#'   Defaults to `c("doi", "title")`.
#' @param similarity_threshold Numeric between 0 and 1. Minimum normalized string similarity
#'   required for title matching. Default is 0.90.
#' @param verbose Logical. If `TRUE`, prints merge diagnostics. Default is FALSE.
#' @return A data frame with class \code{c("bibliometrixDB", "data.frame")} containing the deduplicated
#'   and merged bibliographic records with fused metadata tags.
#' @export
#' @examples
#' df1 <- data.frame(
#'   AU = "SILVA J", TI = "Open access in Brazil",
#'   SO = "Journal A", PY = 2022, DI = "10.1590/test1",
#'   stringsAsFactors = FALSE
#' )
#' df2 <- data.frame(
#'   AU = "SILVA J", TI = "Open access in Brazil",
#'   SO = "Journal A", PY = 2022, DI = "10.1590/test1",
#'   stringsAsFactors = FALSE
#' )
#' merged <- merge_bibliolatam(as_bibliometrix(df1, "scielo"), as_bibliometrix(df2, "bdtd"))
#' nrow(merged)
merge_bibliolatam <- function(df1,
                              df2 = NULL,
                              match_by = c("doi", "title"),
                              similarity_threshold = 0.90,
                              verbose = FALSE) {
  if (!is.null(df2) && (!is.data.frame(df1) || !is.data.frame(df2))) {
    stop("Ambos os objetos df1 e df2 precisam ser data frames.", call. = FALSE)
  }
  if (is.null(df2) && !is.data.frame(df1)) {
    stop("O objeto df1 precisa ser um data frame.", call. = FALSE)
  }

  if (is.null(df2)) {
    return(deduplicate_internal(df1, match_by = match_by,
                                similarity_threshold = similarity_threshold,
                                verbose = verbose))
  }

  if (nrow(df1) == 0L && nrow(df2) == 0L) {
    stop("Ambos os data frames estao vazios.", call. = FALSE)
  }
  if (nrow(df1) == 0L) return(df2)
  if (nrow(df2) == 0L) return(df1)

  # Garante que ambos possuem as tags minimas
  req_cols <- c("AU", "TI", "SO", "PY")
  for (df_name in c("df1", "df2")) {
    cur_df <- get(df_name)
    missing_req <- setdiff(req_cols, names(cur_df))
    if (length(missing_req) > 0) {
      stop(sprintf("Data frame %s nao contem as colunas minimas necessarias: %s", df_name, paste(missing_req, collapse = ", ")), call. = FALSE)
    }
  }

  # Harmoniza colunas presentes entre os dois datasets
  all_cols <- unique(c(names(df1), names(df2)))
  for (col in all_cols) {
    if (!col %in% names(df1)) df1[[col]] <- NA
    if (!col %in% names(df2)) df2[[col]] <- NA
  }
  df1 <- df1[, all_cols, drop = FALSE]
  df2 <- df2[, all_cols, drop = FALSE]

  n1 <- nrow(df1)
  n2 <- nrow(df2)

  # Prepara chaves de matching
  dois1 <- if ("DI" %in% names(df1)) clean_doi(df1$DI) else rep(NA_character_, n1)
  dois2 <- if ("DI" %in% names(df2)) clean_doi(df2$DI) else rep(NA_character_, n2)

  titles1 <- normalize_title_str(df1$TI)
  titles2 <- normalize_title_str(df2$TI)

  parts1 <- vapply(titles1, extract_part_token, character(1L), USE.NAMES = FALSE)
  parts2 <- vapply(titles2, extract_part_token, character(1L), USE.NAMES = FALSE)

  au_surnames1 <- lapply(df1$AU, extract_author_surnames)
  au_surnames2 <- lapply(df2$AU, extract_author_surnames)

  py1 <- suppressWarnings(as.numeric(df1$PY))
  py2 <- suppressWarnings(as.numeric(df2$PY))

  dt1 <- if ("DT" %in% names(df1)) toupper(trimws(as.character(df1$DT))) else rep(NA_character_, n1)
  dt2 <- if ("DT" %in% names(df2)) toupper(trimws(as.character(df2$DT))) else rep(NA_character_, n2)

  matched_pairs <- list() # cada entrada: c(i_in_df1, j_in_df2)
  matched_in_2 <- logical(n2)

  # 1. Matching por DOI exato
  if ("doi" %in% match_by) {
    for (i in seq_len(n1)) {
      d1 <- dois1[i]
      if (!is.na(d1) && nzchar(d1)) {
        pos <- which(!matched_in_2 & !is.na(dois2) & dois2 == d1)
        if (length(pos) > 0L) {
          j <- pos[1]
          matched_pairs[[length(matched_pairs) + 1L]] <- c(i, j)
          matched_in_2[j] <- TRUE
        }
      }
    }
  }

  doi_matches_count <- length(matched_pairs)
  dois1_core <- gsub("[-._]", "", dois1)
  dois2_core <- gsub("[-._]", "", dois2)

  # 2. Matching por Titulo aproximado (filtros O(1) vetorizados ANTES de loops de autoria e adist)
  candidates_before_len <- 0L
  pruned_by_len <- 0L
  total_cartesian_len_pruned <- 0L
  if ("title" %in% match_by) {
    unmatched_1 <- setdiff(seq_len(n1), vapply(matched_pairs, function(p) p[1], integer(1L)))
    titles1_lens <- nchar(titles1)
    titles2_lens <- nchar(titles2)

    if (similarity_threshold > 0 && length(unmatched_1) > 0L) {
      for (i_l in unmatched_1) {
        l1_i <- titles1_lens[i_l]
        if (l1_i >= 15L) {
          min_l_i <- ceiling(l1_i * similarity_threshold)
          max_l_i <- floor(l1_i / similarity_threshold)
          total_cartesian_len_pruned <- total_cartesian_len_pruned + sum(titles2_lens < min_l_i | titles2_lens > max_l_i)
        }
      }
    }

    for (i in unmatched_1) {
      t1 <- titles1[i]
      t1_len <- titles1_lens[i]
      if (!nzchar(t1) || t1_len < 15L) next # ignora titulos extremamente curtos para evitar falso positivo

      cand_indices <- which(!matched_in_2)
      if (length(cand_indices) == 0L) break

      # 2.1 Conflito explicito de DOIs distintos (Achado #1, O(1) vetorizado; libera variantes seguras de separador)
      d1 <- dois1[i]
      if (!is.na(d1) && nzchar(d1)) {
        cand_d2 <- dois2[cand_indices]
        doi_conflict <- !is.na(cand_d2) & nzchar(cand_d2) & cand_d2 != d1
        if (any(doi_conflict)) {
          same_core <- which(doi_conflict & dois2_core[cand_indices] == dois1_core[i])
          for (cp in same_core) {
            if (is_doi_separator_variant(d1, cand_d2[cp])) doi_conflict[cp] <- FALSE
          }
        }
        cand_indices <- cand_indices[!doi_conflict]
      }
      if (length(cand_indices) == 0L) next

      # 2.2 Guardrail de Tipo Documental (DT) (Achado #3, O(1) vetorizado)
      t_doc1 <- dt1[i]
      if (!is.na(t_doc1) && nzchar(t_doc1)) {
        is_thesis_1 <- t_doc1 %in% c("THESIS", "DISSERTATION")
        is_article_1 <- t_doc1 %in% c("ARTICLE", "JOURNAL ARTICLE", "JOURNAL")
        if (is_thesis_1 || is_article_1) {
          cand_dt2 <- dt2[cand_indices]
          cand_is_thesis_2 <- cand_dt2 %in% c("THESIS", "DISSERTATION")
          cand_is_article_2 <- cand_dt2 %in% c("ARTICLE", "JOURNAL ARTICLE", "JOURNAL")
          dt_incompatible <- (is_thesis_1 & cand_is_article_2) | (is_article_1 & cand_is_thesis_2)
          cand_indices <- cand_indices[!dt_incompatible]
        }
      }
      if (length(cand_indices) == 0L) next

      # 2.3 Filtra candidatos por aproximacao de ano se ambos tiverem PY (+- 1 ano, O(1) vetorizado)
      p1 <- py1[i]
      if (!is.na(p1)) {
        cand_p2 <- py2[cand_indices]
        valid_year <- is.na(cand_p2) | abs(cand_p2 - p1) <= 1
        cand_indices <- cand_indices[valid_year]
      }
      if (length(cand_indices) == 0L) next

      # 2.4 Guardrail de Series / Partes / Volumes (O(1) vetorizado)
      part1 <- parts1[i]
      if (length(cand_indices) > 0L) {
        cand_parts2 <- parts2[cand_indices]
        both_have_diff_parts <- !is.na(part1) & !is.na(cand_parts2) & part1 != cand_parts2
        is_sequel_1 <- !is.na(part1) && grepl("_(2|3|4|5|6|7|8|9|10)$", part1)
        sequel_discrepancy_1 <- is_sequel_1 & is.na(cand_parts2)
        sequel_discrepancy_2 <- is.na(part1) & !is.na(cand_parts2) & grepl("_(2|3|4|5|6|7|8|9|10)$", cand_parts2)

        valid_parts <- !both_have_diff_parts & !sequel_discrepancy_1 & !sequel_discrepancy_2
        cand_indices <- cand_indices[valid_parts]
      }
      if (length(cand_indices) == 0L) next

      # 2.5 Filtro Matematico de Extensao de String (Length Bound Filter, O(1) vetorizado)
      # Executado ANTES de loops de autoria e adist, podando ~90% dos candidatos em nanossegundos
      candidates_before_len <- candidates_before_len + length(cand_indices)
      if (similarity_threshold > 0) {
        min_len <- ceiling(t1_len * similarity_threshold)
        max_len <- floor(t1_len / similarity_threshold)
        cand_lens <- titles2_lens[cand_indices]
        valid_len <- cand_lens >= min_len & cand_lens <= max_len
        pruned_by_len <- pruned_by_len + sum(!valid_len)
        cand_indices <- cand_indices[valid_len]
        if (length(cand_indices) == 0L) next
      }

      cand_titles <- titles2[cand_indices]
      sn1 <- au_surnames1[[i]]

      # 2.6 Atalho de correspondencia exata de titulo (Exact Match Fast-Path, O(1))
      exact_match_pos <- which(cand_titles == t1)
      if (length(exact_match_pos) > 0L) {
        ex_cands <- cand_indices[exact_match_pos]
        if (length(sn1) > 0L) {
          ok_ex <- vapply(ex_cands, function(c_idx) {
            sn2 <- au_surnames2[[c_idx]]
            length(sn2) == 0L || surnames_compatible(sn1, sn2)
          }, logical(1L))
          ex_cands <- ex_cands[ok_ex]
        }
        if (length(ex_cands) > 0L) {
          if (length(ex_cands) > 1L && length(sn1) > 0L) {
            # Prioriza candidato com autor explicitamente compativel sobre candidato anonimo
            has_au <- vapply(ex_cands, function(c_idx) {
              length(au_surnames2[[c_idx]]) > 0L
            }, logical(1L))
            if (any(has_au)) {
              ex_cands <- ex_cands[has_au]
            }
          }
          target_j <- ex_cands[1L]
          matched_pairs[[length(matched_pairs) + 1L]] <- c(i, target_j)
          matched_in_2[target_j] <- TRUE
          next
        }
        cand_indices <- cand_indices[-exact_match_pos]
        if (length(cand_indices) == 0L) next
        cand_titles <- titles2[cand_indices]
      }

      # 2.7 Bloqueio por Palavras de Conteudo (Significant Content Word Canopy)
      if (length(cand_indices) > 15L) {
        sig_words <- unlist(regmatches(t1, gregexpr("[a-z0-9]{4,}", t1)))
        if (length(sig_words) > 0L) {
          shared_term <- logical(length(cand_indices))
          for (w in sig_words) {
            shared_term <- shared_term | grepl(w, cand_titles, fixed = TRUE)
          }
          cand_indices <- cand_indices[shared_term]
          if (length(cand_indices) == 0L) next
          cand_titles <- titles2[cand_indices]
        }
      }

      # 2.8 Guardrail de Autoria (Compatibilidade de Sobrenomes apenas nos sobreviventes)
      if (length(sn1) > 0L && length(cand_indices) > 0L) {
        valid_authors <- logical(length(cand_indices))
        for (k in seq_along(cand_indices)) {
          c_idx <- cand_indices[k]
          sn2 <- au_surnames2[[c_idx]]
          if (length(sn2) == 0L) {
            valid_authors[k] <- TRUE
          } else {
            valid_authors[k] <- surnames_compatible(sn1, sn2)
          }
        }
        cand_indices <- cand_indices[valid_authors]
        if (length(cand_indices) == 0L) next
        cand_titles <- titles2[cand_indices]
      }

      # 2.9 Distancia de Levenshtein Normalizada
      dists <- utils::adist(t1, cand_titles)[1, ]
      max_lens <- pmax(t1_len, titles2_lens[cand_indices])
      sims <- 1 - (dists / max_lens)

      best_idx <- which.max(sims)
      if (length(best_idx) > 0L) {
        max_sim <- sims[best_idx]
        c_idx <- cand_indices[best_idx]

        eff_thresh <- similarity_threshold
        if (length(sn1) == 0L || length(au_surnames2[[c_idx]]) == 0L) {
          eff_thresh <- max(eff_thresh, 0.95)
        }

        if (max_sim >= eff_thresh) {
          matched_pairs[[length(matched_pairs) + 1L]] <- c(i, c_idx)
          matched_in_2[c_idx] <- TRUE
        }
      }
    }
  }

  title_matches_count <- length(matched_pairs) - doi_matches_count

  # 3. Fallback estrutural (SO >= 0.90 + VL + BP + PY +- 1 + AU compativel) para edicoes traduzidas sem DOI
  # Inspirado em Kara et al. (2025) (BibexPy), preservando todos os guardrails de DOI/DT/Series/Autoria.
  structural_matches_count <- 0L
  if ("title" %in% match_by && all(c("SO", "VL", "BP") %in% names(df1)) && all(c("SO", "VL", "BP") %in% names(df2))) {
    unmatched_1_s <- setdiff(seq_len(n1), vapply(matched_pairs, function(p) p[1], integer(1L)))
    if (length(unmatched_1_s) > 0L && any(!matched_in_2)) {
      so1_norm <- normalize_title_str(df1$SO)
      so2_norm <- normalize_title_str(df2$SO)
      vl1_clean <- clean_bib_locator(df1$VL)
      vl2_clean <- clean_bib_locator(df2$VL)
      bp1_clean <- clean_bib_locator(df1$BP)
      bp2_clean <- clean_bib_locator(df2$BP)

      for (i in unmatched_1_s) {
        if (is.na(vl1_clean[i]) || is.na(bp1_clean[i]) || nchar(so1_norm[i]) < 5L) next
        sn1 <- au_surnames1[[i]]
        if (length(sn1) == 0L) next

        cand_indices <- which(!matched_in_2 &
                                !is.na(vl2_clean) & vl2_clean == vl1_clean[i] &
                                !is.na(bp2_clean) & bp2_clean == bp1_clean[i] &
                                nchar(so2_norm) >= 5L)
        if (length(cand_indices) == 0L) next

        d1 <- dois1[i]
        if (!is.na(d1) && nzchar(d1)) {
          cand_d2 <- dois2[cand_indices]
          doi_conflict <- !is.na(cand_d2) & nzchar(cand_d2) & cand_d2 != d1
          if (any(doi_conflict)) {
            same_core <- which(doi_conflict & dois2_core[cand_indices] == dois1_core[i])
            for (cp in same_core) {
              if (is_doi_separator_variant(d1, cand_d2[cp])) doi_conflict[cp] <- FALSE
            }
          }
          cand_indices <- cand_indices[!doi_conflict]
        }
        if (length(cand_indices) == 0L) next

        t_doc1 <- dt1[i]
        if (!is.na(t_doc1) && nzchar(t_doc1)) {
          is_th1 <- t_doc1 %in% c("THESIS", "DISSERTATION")
          is_ar1 <- t_doc1 %in% c("ARTICLE", "JOURNAL ARTICLE", "JOURNAL")
          if (is_th1 || is_ar1) {
            cdt2 <- dt2[cand_indices]
            dt_inc <- (is_th1 & cdt2 %in% c("ARTICLE", "JOURNAL ARTICLE", "JOURNAL")) |
                      (is_ar1 & cdt2 %in% c("THESIS", "DISSERTATION"))
            cand_indices <- cand_indices[!dt_inc]
          }
        }
        if (length(cand_indices) == 0L) next

        p1 <- py1[i]
        if (!is.na(p1)) {
          cand_p2 <- py2[cand_indices]
          cand_indices <- cand_indices[is.na(cand_p2) | abs(cand_p2 - p1) <= 1]
        }
        if (length(cand_indices) == 0L) next

        part1 <- parts1[i]
        cand_parts2 <- parts2[cand_indices]
        both_diff <- !is.na(part1) & !is.na(cand_parts2) & part1 != cand_parts2
        is_seq1 <- !is.na(part1) && grepl("_(2|3|4|5|6|7|8|9|10)$", part1)
        seq1 <- is_seq1 & is.na(cand_parts2)
        seq2 <- is.na(part1) & !is.na(cand_parts2) & grepl("_(2|3|4|5|6|7|8|9|10)$", cand_parts2)
        cand_indices <- cand_indices[!both_diff & !seq1 & !seq2]
        if (length(cand_indices) == 0L) next

        ok_au <- vapply(cand_indices, function(c_idx) {
          sn2 <- au_surnames2[[c_idx]]
          length(sn2) > 0L && surnames_compatible(sn1, sn2)
        }, logical(1L))
        cand_indices <- cand_indices[ok_au]
        if (length(cand_indices) == 0L) next

        so_dists <- utils::adist(so1_norm[i], so2_norm[cand_indices])[1, ]
        so_sims <- 1 - (so_dists / pmax(nchar(so1_norm[i]), nchar(so2_norm[cand_indices])))
        best_so <- which.max(so_sims)
        if (length(best_so) > 0L && so_sims[best_so] >= 0.90) {
          target_j <- cand_indices[best_so]
          matched_pairs[[length(matched_pairs) + 1L]] <- c(i, target_j)
          matched_in_2[target_j] <- TRUE
          structural_matches_count <- structural_matches_count + 1L
        }
      }
    }
  }


  if (isTRUE(verbose)) {
    message(sprintf("[Merge Bibliolatam] Registros Colecao 1: %d | Colecao 2: %d", n1, n2))
    message(sprintf("[Merge Bibliolatam] Pares duplicados encontrados por DOI: %d", doi_matches_count))
    message(sprintf("[Merge Bibliolatam] Pares duplicados encontrados por Titulo: %d", title_matches_count))
    message(sprintf("[Merge Bibliolatam] Total duplicados: %d", length(matched_pairs)))
  }

  # Fusao dos pares duplicados
  merged_rows_df1 <- df1
  for (pair in matched_pairs) {
    i <- pair[1]
    j <- pair[2]
    row1 <- df1[i, , drop = FALSE]
    row2 <- df2[j, , drop = FALSE]

    fused_row <- row1
    for (col in all_cols) {
      val1 <- row1[[col]][1]
      val2 <- row2[[col]][1]

      # Se val1 for NA ou vazio e val2 tiver informacao, adota val2
      if (is.null(val1) || is.na(val1) || !nzchar(trimws(as.character(val1)))) {
        if (!is.null(val2) && !is.na(val2) && nzchar(trimws(as.character(val2)))) {
          fused_row[[col]][1] <- val2
        }
      } else if (col %in% c("CR", "DE")) {
        # Se ambos tem Cited References (CR) ou Keywords (DE), combina e deduplica
        refs1 <- unlist(strsplit(as.character(val1), ";\\s*"))
        refs2 <- if (!is.na(val2)) unlist(strsplit(as.character(val2), ";\\s*")) else character(0L)
        all_refs <- unique(c(trimws(refs1), trimws(refs2)))
        all_refs <- all_refs[nzchar(all_refs)]
        if (length(all_refs) > 0L) {
          fused_row[[col]][1] <- paste(all_refs, collapse = "; ")
        }
      }
    }
    # Marca origem combinada
    db1 <- if ("DB" %in% names(row1) && !is.na(row1$DB[1])) as.character(row1$DB[1]) else "DB1"
    db2 <- if ("DB" %in% names(row2) && !is.na(row2$DB[1])) as.character(row2$DB[1]) else "DB2"
    fused_row$DB[1] <- if (identical(db1, db2)) db1 else paste0(db1, "+", db2)

    merged_rows_df1[i, ] <- fused_row
  }

  # Adiciona registros unicos de df2 que nao deram match em df1
  unmatched_df2 <- df2[!matched_in_2, , drop = FALSE]

  out <- rbind(merged_rows_df1, unmatched_df2)

  # Regenera identificador de registro padrao SR para garantir unicidade
  first_author <- gsub(";.*$", "", out$AU)
  first_author <- trimws(first_author)
  first_author[is.na(first_author) | !nzchar(first_author)] <- "ANONYMOUS"

  py_val <- if ("PY" %in% names(out)) out$PY else ""
  py_val[is.na(py_val)] <- ""

  so_val <- if ("SO" %in% names(out)) trimws(out$SO) else ""
  so_val[is.na(so_val)] <- ""

  vl_val <- if ("VL" %in% names(out)) paste0("V", trimws(out$VL)) else ""
  vl_val[is.na(out$VL) | !nzchar(out$VL)] <- ""

  bp_val <- if ("BP" %in% names(out)) paste0("P", trimws(out$BP)) else ""
  bp_val[is.na(out$BP) | !nzchar(out$BP)] <- ""

  sr_vec <- character(nrow(out))
  for (i in seq_len(nrow(out))) {
    parts <- c(first_author[i], py_val[i], so_val[i], vl_val[i], bp_val[i])
    parts <- parts[nzchar(parts)]
    sr_vec[i] <- paste(parts, collapse = ", ")
  }
  out$SR <- make.unique(toupper(sr_vec), sep = "-")
  out$SR_FULL <- out$SR

  class(out) <- unique(c("bibliometrixDB", class(out)))
  attr(out, "dbsource") <- "merged"
  attr(out, "merge_stats") <- list(
    n1 = n1,
    n2 = n2,
    doi_duplicates = doi_matches_count,
    title_duplicates = title_matches_count,
    structural_duplicates = structural_matches_count,
    total_duplicates = length(matched_pairs),
    final_count = nrow(out),
    candidates_before_len = candidates_before_len,
    length_bound_pruned = pruned_by_len,
    cartesian_length_bound_pruned = total_cartesian_len_pruned
  )

  out
}
