test_that("read_scielo_jats reads single XML file and populates canonical tags", {
  xml_path <- system.file("extdata", "scielo_sample.xml", package = "bibliolatam")
  if (!nzchar(xml_path)) {
    xml_path <- "../../inst/extdata/scielo_sample.xml"
  }

  df <- read_scielo_jats(xml_path, convert = TRUE)

  expect_s3_class(df, "bibliometrixDB")
  expect_equal(attr(df, "dbsource"), "scielo")
  expect_equal(nrow(df), 1L)

  # Valida tags obrigatorias
  expect_true(all(c("AU", "TI", "SO", "PY") %in% names(df)))
  expect_equal(df$PY[1], 2014)
  expect_equal(df$SO[1], "Revista de Saude Publica")
  expect_match(df$TI[1], "HIV/AIDS knowledge", fixed = TRUE)

  # Valida normalizacao de autor
  expect_equal(df$AU[1], "GOMES RR; BATISTA FILHO JR")

  # Valida identificadores e metadados adicionais
  expect_equal(df$DI[1], "10.1590/S0034-8910.2014048004911")
  expect_equal(df$SN[1], "0034-8910")
  expect_equal(df$VL[1], "48")
  expect_equal(df$IS[1], "2")
  expect_equal(df$BP[1], "206")
  expect_equal(df$EP[1], "215")
  expect_match(df$DE[1], "HIV INFECTIONS; HEALTH KNOWLEDGE", fixed = TRUE)
  expect_match(df$C1[1], "Universidade Federal de Minas Gerais", fixed = TRUE)

  # Valida Cited References (CR)
  expect_false(is.na(df$CR[1]))
  expect_match(df$CR[1], "AARO, 2011, HEALTH EDUC RES, V26, P212, DOI: 10.1093/her/cyq086", fixed = TRUE)
  expect_match(df$CR[1], "ADAM, 2009, J ACQUIR IMMUNE DEFIC SYNDR, V52, P143, DOI: 10.1097/QAI.0b013e3181baf111", fixed = TRUE)
  expect_match(df$CR[1], "BRASIL. Ministerio da Saude. Boletim Epidemiologico HIV/Aids", fixed = TRUE)
})

test_that("read_scielo_jats works with directory of XML files", {
  dir_path <- system.file("extdata", "scielo_jats_dir", package = "bibliolatam")
  if (!nzchar(dir_path)) {
    dir_path <- "../../inst/extdata/scielo_jats_dir"
  }

  df <- read_scielo_jats(dir_path, convert = TRUE)
  expect_s3_class(df, "bibliometrixDB")
  expect_equal(nrow(df), 2L)
  expect_equal(length(unique(df$DI)), 2L)
})

test_that("read_scielo_jats works with zip bundle of XML files", {
  zip_path <- system.file("extdata", "scielo_jats_bundle.zip", package = "bibliolatam")
  if (!nzchar(zip_path)) {
    zip_path <- "../../inst/extdata/scielo_jats_bundle.zip"
  }

  df <- read_scielo_jats(zip_path, convert = TRUE)
  expect_s3_class(df, "bibliometrixDB")
  expect_equal(nrow(df), 2L)
  expect_equal(length(unique(df$DI)), 2L)
})

test_that("read_scielo_jats respects convert = FALSE flag", {
  xml_path <- system.file("extdata", "scielo_sample.xml", package = "bibliolatam")
  if (!nzchar(xml_path)) {
    xml_path <- "../../inst/extdata/scielo_sample.xml"
  }

  raw_df <- read_scielo_jats(xml_path, convert = FALSE)
  expect_false("bibliometrixDB" %in% class(raw_df))
  expect_s3_class(raw_df, "data.frame")
  expect_equal(nrow(raw_df), 1L)
})

test_that("read_scielo_jats raises informative errors on invalid input", {
  expect_error(read_scielo_jats("arquivo_inexistente.xml"), "Arquivo ou diretorio nao encontrado")
  expect_error(read_scielo_jats(123), "Arquivo ou diretorio nao encontrado")
  expect_error(read_scielo_jats(c("a.xml", "b.xml")), "Arquivo ou diretorio nao encontrado")

  # Arquivo nao XML nem zip
  tmp_txt <- tempfile(fileext = ".txt")
  writeLines("hello", tmp_txt)
  expect_error(read_scielo_jats(tmp_txt), "Formato nao suportado")
  unlink(tmp_txt)

  # Diretorio vazio sem XMLs
  tmp_empty_dir <- tempfile(pattern = "empty_dir_")
  dir.create(tmp_empty_dir)
  expect_error(read_scielo_jats(tmp_empty_dir), "Nenhum arquivo XML encontrado")
  unlink(tmp_empty_dir, recursive = TRUE)
})
