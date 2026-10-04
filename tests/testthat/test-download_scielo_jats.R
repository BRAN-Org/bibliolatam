skip_if_no_internet <- function() {
  testthat::skip_on_cran()
  testthat::skip_on_ci()
  can_connect <- tryCatch({
    h <- curlGetHeaders("https://www.google.com")
    !is.null(h) && length(h) > 0L
  }, error = function(e) FALSE)
  if (!isTRUE(can_connect)) {
    testthat::skip("Sem conexao com a internet")
  }
}

test_that("download_scielo_jats rejects invalid input arguments", {
  expect_error(download_scielo_jats(character(0)), "precisa ser um vetor de caracteres nao vazio")
  expect_error(download_scielo_jats(123), "precisa ser um vetor de caracteres nao vazio")
  expect_error(download_scielo_jats(NULL), "precisa ser um vetor de caracteres nao vazio")
  expect_error(download_scielo_jats(c("", "   ")), "Nenhum identificador valido fornecido")
})

test_that("is_valid_scielo_xml validates file size and JATS article tag", {
  xml_path <- system.file("extdata", "scielo_sample.xml", package = "bibliolatam")
  if (!nzchar(xml_path)) {
    xml_path <- "../../inst/extdata/scielo_sample.xml"
  }

  expect_true(is_valid_scielo_xml(xml_path))
  expect_false(is_valid_scielo_xml("nonexistent_file.xml"))

  tmp_fake <- tempfile(fileext = ".xml")
  writeLines(c("<html>", "<body>Error 404 Not Found</body>", "</html>"), tmp_fake)
  on.exit(unlink(tmp_fake), add = TRUE)
  expect_false(is_valid_scielo_xml(tmp_fake))
})

test_that("resolve_scielo_xml_url formats URLs correctly", {
  skip_if_no_internet()

  url_doi <- resolve_scielo_xml_url("10.1590/S0034-8910.2014048004911")
  expect_type(url_doi, "character")
  expect_match(url_doi, "format=xml")

  url_direct <- resolve_scielo_xml_url("https://www.scielo.br/j/rsp/a/TZzbxXk9WvsFCKrPYtgZ3jd/?lang=en")
  expect_type(url_direct, "character")
  expect_match(url_direct, "format=xml")
})

test_that("download_scielo_jats handles non-existent or invalid DOI cleanly", {
  skip_if_no_internet()

  expect_error(
    suppressWarnings(
      download_scielo_jats("10.1590/invalid_doi_that_does_not_exist_99999", progress = FALSE, timeout = 10)
    ),
    "Nenhum arquivo XML valido foi baixado"
  )
})

test_that("download_scielo_jats downloads and parses real SciELO JATS XML", {
  skip_if_no_internet()

  doi <- "10.1590/S0034-8910.2014048004911"
  td <- tempfile("test_scielo_dl_")

  df <- download_scielo_jats(doi, dest_dir = td, parse = TRUE, progress = FALSE, timeout = 25)
  on.exit(unlink(td, recursive = TRUE), add = TRUE)

  expect_s3_class(df, "bibliometrixDB")
  expect_equal(nrow(df), 1L)
  expect_equal(df$DI[1], doi)
  expect_equal(df$PY[1], 2014)
  expect_match(df$SO[1], "Revista de Sa[uú]de P[uú]blica")
  expect_match(df$AU[1], "GOMES RR")
  expect_false(is.na(df$CR[1]))
})

test_that("download_scielo_jats works with parse = FALSE returning file path", {
  skip_if_no_internet()

  doi <- "10.1590/S0034-8910.2014048004911"
  td <- tempfile("test_scielo_raw_")

  files <- download_scielo_jats(doi, dest_dir = td, parse = FALSE, progress = FALSE, timeout = 25)
  on.exit(unlink(td, recursive = TRUE), add = TRUE)

  expect_type(files, "character")
  expect_equal(length(files), 1L)
  expect_true(file.exists(files[1]))
  expect_true(is_valid_scielo_xml(files[1]))
})
