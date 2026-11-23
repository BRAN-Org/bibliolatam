#' Unified Latin American Scientific Omnisearch
#'
#' Queries multiple Latin American bibliographic repositories (SciELO via Crossref API,
#' BDTD, Oasisbr, and LA Referencia via VuFind API), parses and harmonizes their metadata
#' into canonical `bibliometrixDB` format, and performs automated cross-database deduplication
#' and metadata fusion using [merge_bibliolatam()].
#'
#' @param query Character. Unified search terms or query expression (e.g. `"inteligencia artificial"`).
#' @param sources Character vector. Databases to query. Defaults to `c("scielo", "bdtd", "oasisbr", "lareferencia")`.
#'   Supported choices: `"scielo"`, `"bdtd"`, `"oasisbr"`, `"lareferencia"`.
#' @param limit_per_source Integer. Maximum records to retrieve per database. Default is 50.
#' @param years Numeric/Integer vector. Year range e.g. `c(2020, 2024)` or single year `2022`. Default is `NULL`.
#' @param enrich_references Logical. If `TRUE`, retrieves full JATS XML for SciELO records
#'   and enriches the `CR` (Cited References) field. Default is `FALSE`.
#' @param deduplicate Logical. If `TRUE` (default), runs [merge_bibliolatam()] on the combined results
#'   to resolve duplicate DOIs and fuzzy titles, and fuse metadata tags.
#' @param progress Logical. If `TRUE` (default), prints progress status for each database queried.
#' @param timeout Numeric. Maximum seconds allowed per API request. Default is 30.
#' @param match_by Character vector. Matching criteria passed to [merge_bibliolatam()]:
#'   `"doi"` and/or `"title"`. Defaults to `c("doi", "title")`.
#' @param similarity_threshold Numeric between 0 and 1. Minimum normalized string similarity
#'   passed to [merge_bibliolatam()] for fuzzy title matching. Default is 0.90.
#' @param normalize_authors Logical. If `TRUE` (default), normalizes Luso-Hispanic author names
#'   across all queried repositories via [normalize_authors()].
#' @param scielo_collections Character vector. SciELO national collections passed to
#'   [download_scielo_search()] (`"br"`, `"cl"`, `"es"`, `"cr"`, `"pe"`, `"uy"`, or `"all"`).
#'   Defaults to all six collections.
#' @param doc_types Character vector or `NULL`. Optional post-retrieval filter on Document Type (`DT`),
#'   e.g. `c("ARTICLE", "THESIS", "DISSERTATION")`. Default is `NULL` (keep all types).
#' @param languages Character vector or `NULL`. Optional post-retrieval filter on Language (`LA`),
#'   e.g. `c("PORTUGUESE", "SPANISH", "ENGLISH")`. Default is `NULL` (keep all languages).
#' @param require_doi Logical. If `TRUE`, retains only records carrying a non-empty `DI` field. Default is `FALSE`.
#' @param require_abstract Logical. If `TRUE`, retains only records carrying a non-empty `AB` field. Default is `FALSE`.
#' @return A data frame with class \code{c("bibliometrixDB", "data.frame")} containing the
#'   deduplicated and harmonized bibliographic records aggregated across the queried Latin American databases.
#' @export
#' @examples
#' \donttest{
#' tryCatch({
#'   df <- omnisearch_bibliolatam("energia solar", limit_per_source = 2L, progress = FALSE)
#'   head(df[, c("AU", "TI", "PY", "DB")])
#' }, error = function(e) message("Service temporarily unavailable."))
#' }
omnisearch_bibliolatam <- function(query,
                                   sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
                                   limit_per_source = 50L,
                                   years = NULL,
                                   enrich_references = FALSE,
                                   deduplicate = TRUE,
                                   progress = TRUE,
                                   timeout = 30,
                                   match_by = c("doi", "title"),
                                   similarity_threshold = 0.90,
                                   normalize_authors = TRUE,
                                   scielo_collections = c("br", "cl", "es", "cr", "pe", "uy"),
                                   doc_types = NULL,
                                   languages = NULL,
                                   require_doi = FALSE,
                                   require_abstract = FALSE) {
  if (!is.character(query) || length(query) != 1L || !nzchar(trimws(query))) {
    stop("O argumento 'query' deve ser uma string de busca nao vazia.", call. = FALSE)
  }

  limit_per_source <- as.integer(limit_per_source)
  if (is.na(limit_per_source) || limit_per_source <= 0L) {
    stop("O argumento 'limit_per_source' deve ser um inteiro positivo.", call. = FALSE)
  }

  if (!is.numeric(similarity_threshold) || length(similarity_threshold) != 1L ||
      is.na(similarity_threshold) || similarity_threshold <= 0 || similarity_threshold > 1) {
    stop("O argumento 'similarity_threshold' deve ser um numero entre 0 e 1.", call. = FALSE)
  }

  valid_match <- intersect(tolower(as.character(match_by)), c("doi", "title"))
  if (length(valid_match) == 0L) {
    valid_match <- c("doi", "title")
  }

  valid_sources <- c("scielo", "bdtd", "oasisbr", "lareferencia")
  matched_sources <- intersect(tolower(sources), valid_sources)
  if (length(matched_sources) == 0L) {
    stop(sprintf("Nenhuma fonte valida especificada. Escolha entre: %s",
                 paste(valid_sources, collapse = ", ")), call. = FALSE)
  }

  results_list <- list()

  for (src in matched_sources) {
    if (isTRUE(progress)) {
      message(sprintf("[Omnisearch] Consultando fonte: %s...", toupper(src)))
    }

    df_src <- tryCatch(
      {
        switch(
          src,
          "scielo" = download_scielo_search(
            query = query,
            limit = limit_per_source,
            years = years,
            enrich_references = enrich_references,
            convert = TRUE,
            progress = progress,
            normalize_authors = normalize_authors,
            timeout = timeout,
            collections = scielo_collections
          ),
          "bdtd" = download_bdtd(
            query = query,
            limit = limit_per_source,
            years = years,
            convert = TRUE,
            progress = progress,
            normalize_authors = normalize_authors,
            timeout = timeout
          ),
          "oasisbr" = download_oasisbr(
            query = query,
            limit = limit_per_source,
            years = years,
            convert = TRUE,
            progress = progress,
            normalize_authors = normalize_authors,
            timeout = timeout
          ),
          "lareferencia" = download_lareferencia(
            query = query,
            limit = limit_per_source,
            years = years,
            convert = TRUE,
            progress = progress,
            normalize_authors = normalize_authors,
            timeout = timeout
          )
        )
      },
      error = function(e) {
        warning(sprintf("[Omnisearch] Falha ao consultar %s: %s", toupper(src), e$message), call. = FALSE)
        data.frame()
      }
    )

    if (is.data.frame(df_src) && nrow(df_src) > 0L) {
      results_list[[src]] <- df_src
      if (isTRUE(progress)) {
        message(sprintf("[Omnisearch] %s retornou %d registros.", toupper(src), nrow(df_src)))
      }
    } else if (isTRUE(progress)) {
      message(sprintf("[Omnisearch] %s nao retornou registros.", toupper(src)))
    }
  }

  if (length(results_list) == 0L) {
    warning("Nenhum registro recuperado em nenhuma das fontes consultadas.", call. = FALSE)
    empty_df <- data.frame(
      TI = character(0L),
      AU = character(0L),
      SO = character(0L),
      PY = numeric(0L),
      DB = character(0L),
      stringsAsFactors = FALSE
    )
    class(empty_df) <- c("bibliometrixDB", "data.frame")
    attr(empty_df, "dbsource") <- "omnisearch"
    return(empty_df)
  }

  if (length(results_list) == 1L) {
    out_df <- results_list[[1L]]
  } else if (isTRUE(deduplicate)) {
    if (isTRUE(progress)) {
      message(sprintf("[Omnisearch] Executando deduplicacao e fusao de metadados em %d fontes...",
                      length(results_list)))
    }
    out_df <- Reduce(function(acc, item) {
      merge_bibliolatam(
        acc,
        item,
        match_by = valid_match,
        similarity_threshold = similarity_threshold
      )
    }, results_list)
  } else {
    # Caso deduplicate = FALSE: empilha datasets harmonizando colunas
    all_cols <- unique(unlist(lapply(results_list, names)))
    aligned_list <- lapply(results_list, function(d) {
      missing_cols <- setdiff(all_cols, names(d))
      for (mc in missing_cols) {
        d[[mc]] <- NA_character_
      }
      d[, all_cols, drop = FALSE]
    })
    out_df <- do.call(rbind, aligned_list)
  }

  # Filtros opcionais de qualidade do corpus (pos-coleta)
  out_df <- apply_omnisearch_quality_filters(
    df = out_df,
    doc_types = doc_types,
    languages = languages,
    require_doi = require_doi,
    require_abstract = require_abstract
  )

  class(out_df) <- unique(c("bibliometrixDB", class(out_df)))
  attr(out_df, "dbsource") <- "omnisearch"
  out_df
}

#' Apply optional post-retrieval quality filters to Omnisearch output
#'
#' @param df Data frame returned by Omnisearch aggregation.
#' @param doc_types Optional character vector of allowed `DT` values.
#' @param languages Optional character vector of allowed `LA` values.
#' @param require_doi Logical. Require non-empty `DI`.
#' @param require_abstract Logical. Require non-empty `AB`.
#' @return Filtered data frame.
#' @noRd
apply_omnisearch_quality_filters <- function(df,
                                             doc_types = NULL,
                                             languages = NULL,
                                             require_doi = FALSE,
                                             require_abstract = FALSE) {
  if (!is.data.frame(df) || nrow(df) == 0L) {
    return(df)
  }

  if (!is.null(doc_types) && length(doc_types) > 0L && "DT" %in% names(df)) {
    allowed_dt <- toupper(trimws(as.character(doc_types)))
    allowed_dt <- allowed_dt[nzchar(allowed_dt) & allowed_dt != "ALL"]
    if (length(allowed_dt) > 0L) {
      df_dt <- toupper(trimws(as.character(df$DT)))
      df <- df[!is.na(df_dt) & df_dt %in% allowed_dt, , drop = FALSE]
    }
  }

  if (!is.null(languages) && length(languages) > 0L && "LA" %in% names(df) && nrow(df) > 0L) {
    allowed_la <- toupper(trimws(as.character(languages)))
    allowed_la <- allowed_la[nzchar(allowed_la) & allowed_la != "ALL"]
    if (length(allowed_la) > 0L) {
      df_la <- toupper(trimws(as.character(df$LA)))
      df <- df[!is.na(df_la) & df_la %in% allowed_la, , drop = FALSE]
    }
  }

  if (isTRUE(require_doi) && nrow(df) > 0L) {
    if ("DI" %in% names(df)) {
      di_vals <- trimws(as.character(df$DI))
      df <- df[!is.na(di_vals) & nzchar(di_vals) & toupper(di_vals) != "NA", , drop = FALSE]
    } else {
      df <- df[0L, , drop = FALSE]
    }
  }

  if (isTRUE(require_abstract) && nrow(df) > 0L) {
    if ("AB" %in% names(df)) {
      ab_vals <- trimws(as.character(df$AB))
      df <- df[!is.na(ab_vals) & nzchar(ab_vals) & toupper(ab_vals) != "NA", , drop = FALSE]
    } else {
      df <- df[0L, , drop = FALSE]
    }
  }

  rownames(df) <- NULL
  df
}
