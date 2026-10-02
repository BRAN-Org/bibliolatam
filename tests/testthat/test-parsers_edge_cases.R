test_that("read_spell lida com delimitador ponto-e-virgula e tabulacao", {
  # cria csv com ponto-e-virgula
  tmp_csv_semicolon <- tempfile(fileext = ".csv")
  writeLines(
    c(
      "Titulo;Autores;Periodico;Ano",
      "Inovacao Aberta;Silva, Carlos;Revista A;2023",
      "Capacidades Dinamicas;Costa, Ana;Revista B;2024"
    ),
    tmp_csv_semicolon
  )

  M_semi <- read_spell(tmp_csv_semicolon, convert = TRUE)
  expect_equal(nrow(M_semi), 2L)
  expect_equal(M_semi$AU[1], "SILVA C")
  expect_equal(M_semi$AU[2], "COSTA A")
  unlink(tmp_csv_semicolon)

  # cria tsv com tabulacao
  tmp_tsv <- tempfile(fileext = ".tsv")
  writeLines(
    c(
      "Titulo\tAutores\tPeriodico\tAno",
      "Economia Regional\tGama, Gabriel\tRevista C\t2022"
    ),
    tmp_tsv
  )

  M_tsv <- read_spell(tmp_tsv, convert = TRUE)
  expect_equal(nrow(M_tsv), 1L)
  expect_equal(M_tsv$AU[1], "GAMA G")
  unlink(tmp_tsv)
})

test_that("read_scielo lida com delimitador ponto-e-virgula e campos multilinha", {
  tmp_scielo <- tempfile(fileext = ".csv")
  writeLines(
    c(
      "title;authors;journal;year;abstract",
      "Saude Coletiva;Silva, Pedro;Cadernos de Saude;2021;\"Resumo com quebra\nde linha e espacos.\""
    ),
    tmp_scielo
  )

  M_scielo <- read_scielo(tmp_scielo, convert = TRUE)
  expect_equal(nrow(M_scielo), 1L)
  expect_equal(M_scielo$AU[1], "SILVA P")
  expect_true(grepl("quebra", M_scielo$AB[1]))
  unlink(tmp_scielo)
})

test_that("as_bibliometrix higieniza tipos nao-padrao", {
  # testa com factors e strings
  df_dirty <- data.frame(
    AU = factor(c("SILVA J", "GAMA G")),
    TI = c("Artigo 1", "Artigo 2"),
    SO = factor(c("Revista A", "Revista B")),
    PY = factor(c("2021", "2024")),
    TC = c("15", "0"),
    stringsAsFactors = FALSE
  )

  M_clean <- as_bibliometrix(df_dirty, dbsource = "spell")
  expect_type(M_clean$PY, "double")
  expect_type(M_clean$TC, "double")
  expect_equal(M_clean$TC, c(15, 0))
  expect_true(is.character(M_clean$AU))
  expect_true(is.character(M_clean$SO))
})

test_that("pipeline completo encadeado de SPELL e SciELO bate com biblioshiny", {
  spell_file <- testthat::test_path("../../inst/extdata/spell_sample.csv")
  if (!file.exists(spell_file)) {
    spell_file <- system.file("extdata", "spell_sample.csv", package = "bibliolatam")
  }
  scielo_file <- testthat::test_path("../../inst/extdata/scielo_sample.csv")
  if (!file.exists(scielo_file)) {
    scielo_file <- system.file("extdata", "scielo_sample.csv", package = "bibliolatam")
  }

  M_spell <- read_spell(spell_file, convert = TRUE)
  M_scielo <- read_scielo(scielo_file, convert = TRUE)

  # testa export do spell
  tmp_spell_rdata <- tempfile(fileext = ".RData")
  export_biblioshiny(M_spell, tmp_spell_rdata)
  env_spell <- new.env()
  load(tmp_spell_rdata, envir = env_spell)
  expect_equal(attr(env_spell$M, "dbsource"), "spell")
  unlink(tmp_spell_rdata)

  # testa export do scielo
  tmp_scielo_rdata <- tempfile(fileext = ".RData")
  export_biblioshiny(M_scielo, tmp_scielo_rdata)
  env_scielo <- new.env()
  load(tmp_scielo_rdata, envir = env_scielo)
  expect_equal(attr(env_scielo$M, "dbsource"), "scielo")
  unlink(tmp_scielo_rdata)
})
