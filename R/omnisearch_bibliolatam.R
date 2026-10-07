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
#' @param deduplicate Logical. If `TRUE` (default), runs [merge_bibliolatam()] on the combined results
#'   to resolve duplicate DOIs and fuzzy titles, and fuse metadata tags.
#' @param progress Logical. If `TRUE` (default), prints progress status for each database queried.
#' @param timeout Numeric. Maximum seconds allowed per API request. Default is 30.
#' @return A `data.frame` with class `c("bibliometrixDB", "data.frame")` containing merged and harmonized records.
#' @export
omnisearch_bibliolatam <- function(query,
                                   sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
                                   limit_per_source = 50L,
                                   deduplicate = TRUE,
                                   progress = TRUE,
                                   timeout = 30) {
  if (!is.character(query) || length(query) != 1L || !nzchar(trimws(query))) {
    stop("O argumento 'query' deve ser uma string de busca nao vazia.", call. = FALSE)
  }

  limit_per_source <- as.integer(limit_per_source)
  if (is.na(limit_per_source) || limit_per_source <= 0L) {
    stop("O argumento 'limit_per_source' deve ser um inteiro positivo.", call. = FALSE)
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
            convert = TRUE,
            progress = progress,
            timeout = timeout
          ),
          "bdtd" = download_bdtd(
            query = query,
            limit = limit_per_source,
            convert = TRUE,
            progress = progress
          ),
          "oasisbr" = download_oasisbr(
            query = query,
            limit = limit_per_source,
            convert = TRUE,
            progress = progress
          ),
          "lareferencia" = download_lareferencia(
            query = query,
            limit = limit_per_source,
            convert = TRUE,
            progress = progress
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
    res_single <- results_list[[1L]]
    class(res_single) <- unique(c("bibliometrixDB", class(res_single)))
    attr(res_single, "dbsource") <- "omnisearch"
    return(res_single)
  }

  # Multiplas fontes
  if (isTRUE(deduplicate)) {
    if (isTRUE(progress)) {
      message(sprintf("[Omnisearch] Executando deduplicacao e fusao de metadados em %d fontes...",
                      length(results_list)))
    }
    merged_df <- Reduce(function(acc, item) {
      merge_bibliolatam(acc, item, match_by = c("doi", "title"))
    }, results_list)
    class(merged_df) <- unique(c("bibliometrixDB", class(merged_df)))
    attr(merged_df, "dbsource") <- "omnisearch"
    return(merged_df)
  }

  # Caso deduplicate = FALSE: empilha datasets harmonizando colunas
  all_cols <- unique(unlist(lapply(results_list, names)))
  aligned_list <- lapply(results_list, function(d) {
    missing_cols <- setdiff(all_cols, names(d))
    for (mc in missing_cols) {
      d[[mc]] <- NA_character_
    }
    d[, all_cols, drop = FALSE]
  })
  combined_df <- do.call(rbind, aligned_list)
  class(combined_df) <- unique(c("bibliometrixDB", class(combined_df)))
  attr(combined_df, "dbsource") <- "omnisearch"
  combined_df
}
