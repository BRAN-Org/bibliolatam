test_that("normalize_authors lida com entradas vazias e nulas", {
  expect_true(is.na(normalize_authors("")))
  expect_true(is.na(normalize_authors("   ")))
  expect_true(is.na(normalize_authors(NA_character_)))
  expect_true(is.na(normalize_authors("; ;  ;")))
})

test_that("normalize_authors trata nomes simples e unicos", {
  expect_equal(normalize_authors("Platao"), "PLATAO")
  expect_equal(normalize_authors("FIOCRUZ"), "FIOCRUZ")
})

test_that("normalize_authors formata Sobrenome, Nome", {
  expect_equal(normalize_authors("Gama, Gabriel"), "GAMA G")
  expect_equal(normalize_authors("Silva, Carlos Alberto"), "SILVA CA")
  expect_equal(normalize_authors("Oliveira, Maria da Conceicao"), "OLIVEIRA MC")
})

test_that("normalize_authors formata Nome Sobrenome direto", {
  expect_equal(normalize_authors("Gabriel Gama"), "GAMA G")
  expect_equal(normalize_authors("Carlos Alberto Silva"), "SILVA CA")
  expect_equal(normalize_authors("Maria da Conceicao Oliveira"), "OLIVEIRA MC")
})

test_that("normalize_authors preserva sufixos geracionais brasileiros", {
  # formato Nome Sobrenome Sufixo
  expect_equal(normalize_authors("Jose da Silva Junior"), "SILVA JUNIOR J")
  expect_equal(normalize_authors("Antonio Carlos Neto"), "CARLOS NETO A")
  expect_equal(normalize_authors("Paulo Roberto Filho"), "ROBERTO FILHO P")
  expect_equal(normalize_authors("Lucas Mendes Sobrinho"), "MENDES SOBRINHO L")

  # formato Sobrenome Sufixo, Nome
  expect_equal(normalize_authors("Silva Junior, Jose da"), "SILVA JUNIOR J")
  expect_equal(normalize_authors("Moraes Filho, Carlos"), "MORAES FILHO C")

  # formato Sobrenome, Nome Meio Sufixo
  expect_equal(normalize_authors("Batista, Jose Rodrigues Filho"), "BATISTA FILHO JR")
})

test_that("normalize_authors ignora particulas minusculas nas iniciais", {
  # de, da, do, dos, das, van, der, del
  expect_equal(normalize_authors("Joao da Silva"), "SILVA J")
  expect_equal(normalize_authors("Pedro de Alcantara"), "ALCANTARA P")
  expect_equal(normalize_authors("Maria das Gracas de Souza"), "SOUZA MG")
  expect_equal(normalize_authors("Vincent van Gogh"), "GOGH V")
})

test_that("normalize_authors lida com multiplos autores e espacamento sujo", {
  raw_mult <- "Silva, Carlos ; ; Santos, Mariana Costa ;  Oliveira, Lucas "
  res <- normalize_authors(raw_mult)
  expect_equal(res, "SILVA C; SANTOS MC; OLIVEIRA L")
})
