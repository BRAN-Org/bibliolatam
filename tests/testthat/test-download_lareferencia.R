test_that("download_lareferencia validates input arguments correctly", {
  expect_error(download_lareferencia(""), "deve ser uma string de busca nao vazia")
  expect_error(download_lareferencia(c("a", "b")), "deve ser uma string de busca nao vazia")
  expect_error(download_lareferencia(123), "deve ser uma string de busca nao vazia")
  expect_error(download_lareferencia("dengue", limit = 0), "deve ser um inteiro positivo")
  expect_error(download_lareferencia("dengue", limit = -10), "deve ser um inteiro positivo")
})

test_that("parse_vufind_records handles lareferencia dbsource correctly", {
  mock_record <- list(
    title = "Analisis del dengue en America Latina",
    authors = list(
      primary = list("Perez, Juan" = list(role = list("author"))),
      secondary = list()
    ),
    institutions = list("Universidad de Buenos Aires"),
    publicationDates = list("2020"),
    formats = list("Article"),
    summary = list("Estudio integral sobre dengue."),
    subjects = list(list("Dengue"), list("Salud")),
    languages = list("spa"),
    urls = list("https://repositorio.uba.ar/handle/1234"),
    cleanDoi = list("10.1234/lareferencia.test"),
    country = "Argentina"
  )

  df_parsed <- bibliolatam:::parse_vufind_records(list(mock_record), dbsource = "lareferencia")
  expect_equal(nrow(df_parsed), 1L)
  expect_equal(df_parsed$TI[1], "Analisis del dengue en America Latina")
  expect_equal(df_parsed$PY[1], "2020")
  expect_equal(df_parsed$DT[1], "ARTICLE")
  expect_equal(df_parsed$LA[1], "SPANISH")
  expect_equal(df_parsed$DI[1], "10.1234/lareferencia.test")
})

test_that("download_lareferencia retrieves live data from LA Referencia API", {
  skip_on_cran()

  df <- tryCatch(
    download_lareferencia("dengue", limit = 3L, progress = FALSE),
    error = function(e) {
      skip(paste("API LA Referencia offline:", e$message))
    }
  )

  if (nrow(df) > 0L) {
    expect_s3_class(df, "bibliometrixDB")
    expect_true(nrow(df) <= 3L)
    expect_true("TI" %in% names(df))
    expect_true("AU" %in% names(df))
    expect_true("PY" %in% names(df))
    expect_true("SO" %in% names(df))
    expect_equal(unique(df$DB), "lareferencia")
  }
})
