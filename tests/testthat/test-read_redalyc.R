test_that("read_redalyc parses BibTeX export format", {
  bib_text <- c(
    "@article{garcia2021,",
    "  title = {Innovacion y desarrollo tecnologico en America Latina},",
    "  author = {Garcia-Montero, Carlos and Gomez de la Rosa, Maria},",
    "  journal = {Revista Iberoamericana de Ciencia y Tecnologia},",
    "  year = {2021},",
    "  volume = {15},",
    "  number = {2},",
    "  pages = {45-60},",
    "  abstract = {Este estudio analiza la innovacion...},",
    "  keywords = {innovacion, patentes, america latina},",
    "  doi = {10.5555/redalyc.2021.01},",
    "  issn = {1234-5678}",
    "}"
  )

  tmp_bib <- tempfile(fileext = ".bib")
  writeLines(bib_text, tmp_bib)
  on.exit(unlink(tmp_bib), add = TRUE)

  df <- read_redalyc(tmp_bib, convert = TRUE)
  expect_s3_class(df, "bibliometrixDB")
  expect_equal(nrow(df), 1L)
  expect_equal(df$PY, 2021)
  expect_equal(df$DI, "10.5555/REDALYC.2021.01")
  expect_true(grepl("GARCIA-MONTERO", df$AU))
  expect_true(grepl("GOMEZ DE LA ROSA", df$AU))
  expect_equal(df$SO, "Revista Iberoamericana de Ciencia y Tecnologia")
  expect_equal(df$DB, "redalyc")
})

test_that("read_redalyc parses RIS export format", {
  ris_text <- c(
    "TY  - JOUR",
    "TI  - Evaluacion cienciometrica de revistas abiertas",
    "AU  - Fernandez-Cano, Antonio",
    "AU  - Torralbo, Manuel",
    "JO  - Investigacion Bibliotecologica",
    "PY  - 2020",
    "VL  - 34",
    "IS  - 82",
    "SP  - 15",
    "EP  - 32",
    "AB  - Resumen del articulo...",
    "KW  - Cienciometria",
    "KW  - Acceso abierto",
    "DO  - 10.22201/iibi.24488321xe.2020.82.58145",
    "SN  - 2448-8321",
    "ER  - "
  )

  tmp_ris <- tempfile(fileext = ".ris")
  writeLines(ris_text, tmp_ris)
  on.exit(unlink(tmp_ris), add = TRUE)

  df <- read_redalyc(tmp_ris, convert = TRUE)
  expect_s3_class(df, "bibliometrixDB")
  expect_equal(nrow(df), 1L)
  expect_equal(df$PY, 2020)
  expect_true(grepl("FERNANDEZ-CANO", df$AU))
  expect_true(grepl("TORRALBO", df$AU))
  expect_equal(df$DT, "ARTICLE")
  expect_equal(df$DB, "redalyc")
})
