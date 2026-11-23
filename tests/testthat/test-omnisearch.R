test_that("omnisearch_bibliolatam validates input arguments correctly", {
  expect_error(omnisearch_bibliolatam(""), "deve ser uma string de busca nao vazia")
  expect_error(omnisearch_bibliolatam(c("a", "b")), "deve ser uma string de busca nao vazia")
  expect_error(omnisearch_bibliolatam(123), "deve ser uma string de busca nao vazia")
  expect_error(omnisearch_bibliolatam("dengue", limit_per_source = 0), "deve ser um inteiro positivo")
  expect_error(omnisearch_bibliolatam("dengue", sources = "invalid_db"), "Nenhuma fonte valida especificada")
  expect_error(omnisearch_bibliolatam("dengue", similarity_threshold = 0), "similarity_threshold")
  expect_error(omnisearch_bibliolatam("dengue", similarity_threshold = 1.5), "similarity_threshold")
  expect_error(omnisearch_bibliolatam("dengue", similarity_threshold = "high"), "similarity_threshold")
})

test_that("omnisearch_bibliolatam handles single source and empty fallbacks cleanly", {
  skip_on_cran()

  # Test single source
  df_single <- tryCatch(
    omnisearch_bibliolatam("dengue", sources = "scielo", limit_per_source = 2L, progress = FALSE),
    error = function(e) {
      skip(paste("API SciELO offline:", e$message))
    }
  )

  if (nrow(df_single) > 0L) {
    expect_s3_class(df_single, "bibliometrixDB")
    expect_true(nrow(df_single) <= 2L)
    expect_true("TI" %in% names(df_single))
  }
})

test_that("omnisearch_bibliolatam merges and deduplicates multi-source datasets", {
  df1 <- data.frame(
    TI = c("Estudo do Dengue no Brasil", "Tratamento de Zika"),
    AU = c("SILVA J", "SANTOS M"),
    SO = c("REV SAUDE PUBLICA", "REV MED"),
    PY = c(2020, 2021),
    DI = c("10.1590/test.1", "10.1590/test.2"),
    AB = c("Resumo completo", NA),
    DB = c("SCIELO", "SCIELO"),
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    TI = c("Estudo do Dengue no Brasil", "Outro trabalho"),
    AU = c("SILVA J", "OLIVEIRA P"),
    SO = c("BDTD/IBICT", "BDTD/IBICT"),
    PY = c(2020, 2019),
    DI = c("10.1590/test.1", NA),
    AB = c(NA, "Resumo tese"),
    DB = c("BDTD", "BDTD"),
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "bdtd")

  merged <- merge_bibliolatam(df1, df2, match_by = c("doi", "title"))
  expect_s3_class(merged, "bibliometrixDB")
  expect_equal(nrow(merged), 3L)
  # Duplicate record 10.1590/test.1 should have abstract preserved from df1
  match_rec <- merged[!is.na(merged$DI) & merged$DI == "10.1590/test.1", ]
  expect_equal(nrow(match_rec), 1L)
  expect_equal(match_rec$AB, "Resumo completo")
  expect_true(grepl("scielo", match_rec$DB, ignore.case = TRUE) && grepl("bdtd", match_rec$DB, ignore.case = TRUE))
})

test_that("omnisearch_bibliolatam forwards advanced parameters to downloaders and merger", {
  captured_scielo <- list()
  captured_bdtd <- list()
  captured_merge <- list()

  mock_scielo <- as_bibliometrix(
    data.frame(
      TI = "Artigo Teste SciELO",
      AU = "GAMA G",
      SO = "REV TEST",
      PY = 2022,
      DI = "10.4067/test1",
      AB = "Resumo completo do artigo.",
      DT = "ARTICLE",
      LA = "SPANISH",
      stringsAsFactors = FALSE
    ),
    dbsource = "scielo"
  )

  mock_bdtd <- as_bibliometrix(
    data.frame(
      TI = "Tese Teste BDTD",
      AU = "SILVA J",
      SO = "USP",
      PY = 2023,
      DI = NA_character_,
      AB = NA_character_,
      DT = "THESIS",
      LA = "PORTUGUESE",
      stringsAsFactors = FALSE
    ),
    dbsource = "bdtd"
  )

  testthat::with_mocked_bindings(
    download_scielo_search = function(query, limit, years, enrich_references, convert, progress, normalize_authors, timeout, collections, ...) {
      captured_scielo <<- list(
        years = years,
        enrich_references = enrich_references,
        normalize_authors = normalize_authors,
        timeout = timeout,
        collections = collections
      )
      mock_scielo
    },
    download_bdtd = function(query, limit, years, convert, progress, normalize_authors, timeout, ...) {
      captured_bdtd <<- list(
        years = years,
        normalize_authors = normalize_authors,
        timeout = timeout
      )
      mock_bdtd
    },
    merge_bibliolatam = function(df1, df2, match_by, similarity_threshold, ...) {
      captured_merge <<- list(
        match_by = match_by,
        similarity_threshold = similarity_threshold
      )
      rbind(df1, df2)
    },
    .package = "bibliolatam",
    {
      res <- omnisearch_bibliolatam(
        "teste",
        sources = c("scielo", "bdtd"),
        limit_per_source = 5L,
        years = c(2021, 2024),
        enrich_references = TRUE,
        deduplicate = TRUE,
        progress = FALSE,
        timeout = 45,
        match_by = "doi",
        similarity_threshold = 0.94,
        normalize_authors = FALSE,
        scielo_collections = c("cl", "es")
      )

      expect_equal(captured_scielo$years, c(2021, 2024))
      expect_true(captured_scielo$enrich_references)
      expect_false(captured_scielo$normalize_authors)
      expect_equal(captured_scielo$timeout, 45)
      expect_equal(captured_scielo$collections, c("cl", "es"))

      expect_equal(captured_bdtd$years, c(2021, 2024))
      expect_false(captured_bdtd$normalize_authors)
      expect_equal(captured_bdtd$timeout, 45)

      expect_equal(captured_merge$match_by, "doi")
      expect_equal(captured_merge$similarity_threshold, 0.94)
      expect_equal(nrow(res), 2L)
    }
  )
})

test_that("omnisearch_bibliolatam applies post-retrieval quality filters accurately", {
  mock_df <- as_bibliometrix(
    data.frame(
      TI = c("Artigo Espanhol Com DOI", "Tese Portugues Sem DOI", "Artigo Ingles Sem Resumo"),
      AU = c("PEREZ M", "SILVA J", "SMITH K"),
      SO = c("REV A", "USP", "REV B"),
      PY = c(2022, 2023, 2024),
      DI = c("10.4067/a1", NA_character_, "10.1590/a3"),
      AB = c("Resumen completo.", "Resumo da tese.", NA_character_),
      DT = c("ARTICLE", "THESIS", "ARTICLE"),
      LA = c("SPANISH", "PORTUGUESE", "ENGLISH"),
      stringsAsFactors = FALSE
    ),
    dbsource = "scielo"
  )

  testthat::with_mocked_bindings(
    download_scielo_search = function(...) mock_df,
    .package = "bibliolatam",
    {
      # Filter by doc_types
      r_art <- omnisearch_bibliolatam("q", sources = "scielo", doc_types = "ARTICLE", progress = FALSE)
      expect_equal(nrow(r_art), 2L)
      expect_true(all(r_art$DT == "ARTICLE"))

      # Filter by languages
      r_es <- omnisearch_bibliolatam("q", sources = "scielo", languages = "SPANISH", progress = FALSE)
      expect_equal(nrow(r_es), 1L)
      expect_equal(r_es$LA[1], "SPANISH")

      # Filter require_doi
      r_doi <- omnisearch_bibliolatam("q", sources = "scielo", require_doi = TRUE, progress = FALSE)
      expect_equal(nrow(r_doi), 2L)
      expect_false(any(is.na(r_doi$DI)))

      # Filter require_abstract
      r_ab <- omnisearch_bibliolatam("q", sources = "scielo", require_abstract = TRUE, progress = FALSE)
      expect_equal(nrow(r_ab), 2L)
      expect_false(any(is.na(r_ab$AB)))

      # Combined strict filters (DOI + Abstract + ARTICLE)
      r_strict <- omnisearch_bibliolatam(
        "q",
        sources = "scielo",
        doc_types = "ARTICLE",
        require_doi = TRUE,
        require_abstract = TRUE,
        progress = FALSE
      )
      expect_equal(nrow(r_strict), 1L)
      expect_equal(r_strict$TI[1], "Artigo Espanhol Com DOI")
      expect_s3_class(r_strict, "bibliometrixDB")

      # Contradictory filter yields 0-row bibliometrixDB cleanly
      r_zero <- omnisearch_bibliolatam(
        "q",
        sources = "scielo",
        doc_types = "THESIS",
        require_doi = TRUE,
        progress = FALSE
      )
      expect_equal(nrow(r_zero), 0L)
      expect_s3_class(r_zero, "bibliometrixDB")
    }
  )
})
