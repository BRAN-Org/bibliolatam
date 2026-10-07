test_that("query_vufind_api fails informatively on empty or invalid inputs", {
  expect_error(
    download_bdtd(""),
    "string de busca nao vazia"
  )
  expect_error(
    download_bdtd("test", limit = -1),
    "inteiro positivo"
  )
  expect_error(
    download_oasisbr(""),
    "string de busca nao vazia"
  )
  expect_error(
    download_oasisbr("test", limit = 0),
    "inteiro positivo"
  )
})

test_that("parse_vufind_records handles edge cases", {
  records <- list(
    list(
      title = "Tese de Inteligencia Artificial",
      authors = list(
        primary = list("SILVA, Joao Neto" = list())
      ),
      publicationDates = list("2022"),
      institutions = list("USP"),
      formats = list("doctoralThesis"),
      summary = list("Resumo teste sobre IA"),
      subjects = list("IA", "Machine Learning"),
      languages = list("por"),
      urls = list(list(url = "https://teses.usp.br/123"))
    )
  )

  df_parsed <- bibliolatam:::parse_vufind_records(records, dbsource = "bdtd")
  expect_equal(nrow(df_parsed), 1L)
  expect_equal(df_parsed$DT, "THESIS")
  expect_equal(df_parsed$PY, "2022")
  expect_equal(df_parsed$AU, "SILVA NETO J")
  expect_equal(df_parsed$LA, "PORTUGUESE")
  expect_equal(df_parsed$UT, "https://teses.usp.br/123")
  expect_equal(df_parsed$SO, "USP")

  # Test Oasisbr multi-typology
  records_oasis <- list(
    list(
      title = "Artigo Cientifico em Revista",
      authors = list(primary = list("Gama, Gabriel" = list())),
      publicationDates = list("2021"),
      formats = list("article"),
      urls = list("https://ojs.revista.org/1")
    )
  )
  df_oasis <- bibliolatam:::parse_vufind_records(records_oasis, dbsource = "oasisbr")
  expect_equal(df_oasis$DT, "ARTICLE")
  expect_equal(df_oasis$SO, "OASISBR/IBICT")
})
