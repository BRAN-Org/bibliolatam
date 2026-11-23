test_that("download_scielo_search validates input arguments correctly", {
  expect_error(download_scielo_search(""), "deve ser uma string de busca nao vazia")
  expect_error(download_scielo_search(c("a", "b")), "deve ser uma string de busca nao vazia")
  expect_error(download_scielo_search(123), "deve ser uma string de busca nao vazia")
  expect_error(download_scielo_search("dengue", limit = 0), "deve ser um inteiro positivo")
  expect_error(download_scielo_search("dengue", limit = -5), "deve ser um inteiro positivo")
  expect_error(download_scielo_search("dengue", collections = character(0L)), "colecao ou prefixo DOI valido")
  expect_error(download_scielo_search("dengue", collections = "invalid_country"), "Nenhuma colecao SciELO valida")
})

test_that("resolve_scielo_prefixes maps all six national SciELO collections and raw prefixes", {
  all_px <- bibliolatam:::resolve_scielo_prefixes()
  expect_equal(
    all_px,
    c("10.1590", "10.4067", "10.4321", "10.15517", "10.17843", "10.26461")
  )
  expect_equal(bibliolatam:::resolve_scielo_prefixes("all"), all_px)
  expect_equal(bibliolatam:::resolve_scielo_prefixes(c("CL", "es")), c("10.4067", "10.4321"))
  expect_equal(bibliolatam:::resolve_scielo_prefixes(c("cr", "pe", "uy")), c("10.15517", "10.17843", "10.26461"))
  expect_equal(bibliolatam:::resolve_scielo_prefixes(c("br", "10.1590", "10.99999")), c("10.1590", "10.99999"))
  expect_error(bibliolatam:::resolve_scielo_prefixes(NULL), "colecao ou prefixo DOI valido")
  expect_error(bibliolatam:::resolve_scielo_prefixes(""), "colecao ou prefixo DOI valido")
  expect_error(bibliolatam:::resolve_scielo_prefixes("xx"), "Nenhuma colecao SciELO valida")
})

test_that("parse_crossref_scielo_items handles empty or malformed items cleanly", {
  res_empty <- bibliolatam:::parse_crossref_scielo_items(list())
  expect_true(is.data.frame(res_empty))
  expect_equal(nrow(res_empty), 0L)

  mock_item <- list(
    title = list("Aportes al estudio del dengue"),
    author = list(
      list(family = "Gomez", given = "Maria"),
      list(family = "Silva", given = "Jose Filho")
    ),
    `container-title` = list("Revista de Saude Publica"),
    issued = list(`date-parts` = list(list(2021L, 5L))),
    DOI = "10.1590/s0034-89102021000100001",
    abstract = "<jats:p>Estudo epidemiologico relevante.</jats:p>",
    subject = list("Dengue", "Epidemiologia"),
    type = "journal-article",
    language = "pt"
  )

  df_mock <- bibliolatam:::parse_crossref_scielo_items(list(mock_item))
  expect_equal(nrow(df_mock), 1L)
  expect_equal(df_mock$TI[1], "Aportes al estudio del dengue")
  expect_true(grepl("GOMEZ M", df_mock$AU[1]) || grepl("SILVA J FILHO", df_mock$AU[1]))
  expect_equal(df_mock$SO[1], "REVISTA DE SAUDE PUBLICA")
  expect_equal(df_mock$PY[1], "2021")
  expect_equal(df_mock$DI[1], "10.1590/s0034-89102021000100001")
  expect_equal(df_mock$AB[1], "Estudo epidemiologico relevante.")
  expect_true(grepl("DENGUE", df_mock$DE[1]))
  expect_equal(df_mock$DT[1], "ARTICLE")
  expect_equal(df_mock$LA[1], "PORTUGUESE")
})

test_that("download_scielo_search retrieves live data from Crossref API", {
  skip_on_cran()

  df <- tryCatch(
    download_scielo_search("dengue", limit = 3L, progress = FALSE),
    error = function(e) {
      skip(paste("API SciELO/Crossref offline:", e$message))
    }
  )

  if (nrow(df) > 0L) {
    expect_s3_class(df, "bibliometrixDB")
    expect_true(nrow(df) <= 3L)
    expect_true("TI" %in% names(df))
    expect_true("AU" %in% names(df))
    expect_true("PY" %in% names(df))
    expect_true("SO" %in% names(df))
    expect_equal(unique(df$DB), "scielo")
  }
})

test_that("download_scielo_search constructs Crossref year and multi-country prefix filters properly", {
  mock_called_url <- NULL
  testthat::with_mocked_bindings(
    url = function(description, ...) {
      mock_called_url <<- description
      textConnection('{"status":"ok","message":{"total-results":0,"items":[]}}')
    },
    .package = "base",
    {
      # Default multi-country prefixes + year range
      suppressWarnings(download_scielo_search("dengue", limit = 5L, years = c(2021, 2024), progress = FALSE))
      expect_true(grepl("prefix:10.1590,prefix:10.4067,prefix:10.4321,prefix:10.15517,prefix:10.17843,prefix:10.26461", mock_called_url, fixed = TRUE))
      expect_true(grepl("from-pub-date:2021,until-pub-date:2024", mock_called_url, fixed = TRUE))

      # Single country (Chile) + single year
      suppressWarnings(download_scielo_search("dengue", limit = 5L, years = 2022, collections = "cl", progress = FALSE))
      expect_true(grepl("filter=prefix:10.4067,from-pub-date:2022,until-pub-date:2022", mock_called_url, fixed = TRUE))

      # Spain and Peru subset + no year filter
      suppressWarnings(download_scielo_search("dengue", limit = 5L, years = NULL, collections = c("es", "pe"), progress = FALSE))
      expect_true(grepl("filter=prefix:10.4321,prefix:10.17843&", mock_called_url, fixed = TRUE))
      expect_false(grepl("from-pub-date", mock_called_url))
    }
  )
})

test_that("download_scielo_search integrates enrich_references logic", {
  mock_item <- list(
    title = list("Artigo Dengue"),
    author = list(list(family = "Silva", given = "J")),
    `container-title` = list("Revista Saude"),
    issued = list(`date-parts` = list(list(2022L))),
    DOI = "10.1590/test-cr-enrich",
    type = "journal-article"
  )
  mock_json <- sprintf('{"status":"ok","message":{"total-results":1,"items":[%s]}}',
                       jsonlite::toJSON(mock_item, auto_unbox = TRUE))

  mock_jats_df <- data.frame(
    DI = "10.1590/test-cr-enrich",
    CR = "SILVA J, 2010, REV MED, V1, P10",
    stringsAsFactors = FALSE
  )

  testthat::with_mocked_bindings(
    url = function(description, ...) {
      textConnection(mock_json)
    },
    .package = "base",
    {
      testthat::with_mocked_bindings(
        download_scielo_jats = function(...) {
          mock_jats_df
        },
        .package = "bibliolatam",
        {
          res <- download_scielo_search("dengue", limit = 1L, enrich_references = TRUE, progress = FALSE)
          expect_true("CR" %in% names(res))
          expect_equal(res$CR[1], "SILVA J, 2010, REV MED, V1, P10")
        }
      )
    }
  )
})
