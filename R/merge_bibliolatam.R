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
  trimws(t)
}

#' Merge and Deduplicate Regional Bibliographic Collections
#'
#' Merges two bibliographic datasets (e.g. SciELO, Oasisbr, SPELL, BDTD, or Redalyc),
#' identifies cross-database duplicates through canonical DOI resolution and normalized
#' title fuzzy matching, and fuses complementary metadata fields into a unified corpus.
#'
#' @param df1 A data frame with class `bibliometrixDB` or conforming to standard tags.
#' @param df2 A data frame with class `bibliometrixDB` or conforming to standard tags.
#' @param match_by Character vector specifying matching criteria: `"doi"` and/or `"title"`.
#'   Defaults to `c("doi", "title")`.
#' @param similarity_threshold Numeric between 0 and 1. Minimum normalized string similarity
#'   required for title matching. Default is 0.90.
#' @param verbose Logical. If `TRUE`, prints merge diagnostics. Default is FALSE.
#' @return A `data.frame` with class `c("bibliometrixDB", "data.frame")` containing the deduplicated
#'   and merged collection.
#' @export
merge_bibliolatam <- function(df1,
                              df2,
                              match_by = c("doi", "title"),
                              similarity_threshold = 0.90,
                              verbose = FALSE) {
  if (!is.data.frame(df1) || !is.data.frame(df2)) {
    stop("Ambos os objetos df1 e df2 precisam ser data frames.", call. = FALSE)
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

  py1 <- suppressWarnings(as.numeric(df1$PY))
  py2 <- suppressWarnings(as.numeric(df2$PY))

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

  # 2. Matching por Titulo aproximado (com tolerancia de ano +- 1)
  if ("title" %in% match_by) {
    unmatched_1 <- setdiff(seq_len(n1), vapply(matched_pairs, function(p) p[1], integer(1L)))

    for (i in unmatched_1) {
      t1 <- titles1[i]
      if (!nzchar(t1) || nchar(t1) < 15) next # ignora titulos extremamente curtos para evitar falso positivo

      cand_indices <- which(!matched_in_2)
      if (length(cand_indices) == 0L) break

      # Filtra candidatos por aproximacao de ano se ambos tiverem PY
      p1 <- py1[i]
      if (!is.na(p1)) {
        cand_p2 <- py2[cand_indices]
        valid_year <- is.na(cand_p2) | abs(cand_p2 - p1) <= 1
        cand_indices <- cand_indices[valid_year]
      }

      if (length(cand_indices) == 0L) next

      cand_titles <- titles2[cand_indices]
      # Usa adist do base R
      dists <- utils::adist(t1, cand_titles, ignore.case = TRUE)[1, ]
      max_len <- pmax(nchar(t1), nchar(cand_titles))
      sims <- 1 - (dists / max_len)

      best_match_pos <- which(sims >= similarity_threshold)
      if (length(best_match_pos) > 0L) {
        # pega a maior similaridade
        best_idx <- best_match_pos[which.max(sims[best_match_pos])]
        target_j <- cand_indices[best_idx]

        matched_pairs[[length(matched_pairs) + 1L]] <- c(i, target_j)
        matched_in_2[target_j] <- TRUE
      }
    }
  }

  title_matches_count <- length(matched_pairs) - doi_matches_count

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
      } else if (col == "CR") {
        # Se ambos tem Cited References (CR), combina e deduplica
        refs1 <- unlist(strsplit(as.character(val1), ";\\s*"))
        refs2 <- if (!is.na(val2)) unlist(strsplit(as.character(val2), ";\\s*")) else character(0L)
        all_refs <- unique(c(trimws(refs1), trimws(refs2)))
        all_refs <- all_refs[nzchar(all_refs)]
        if (length(all_refs) > 0L) {
          fused_row$CR[1] <- paste(all_refs, collapse = "; ")
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
    total_duplicates = length(matched_pairs),
    final_count = nrow(out)
  )

  out
}
