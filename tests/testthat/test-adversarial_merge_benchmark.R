test_that("adversarial series: multi-part sequences are never merged despite high similarity", {
  # 1. Sequencia de 4 partes com mesmo autor, mesmo ano e titulos com > 95% de similaridade
  parts_titles <- c(
    "Ciencia da Informacao e Cienciometria no Brasil: Parte 1 - Fundamentos",
    "Ciencia da Informacao e Cienciometria no Brasil: Parte 2 - Metodos",
    "Ciencia da Informacao e Cienciometria no Brasil: Parte 3 - Resultados",
    "Ciencia da Informacao e Cienciometria no Brasil: Parte 4 - Conclusoes"
  )

  df_list <- lapply(seq_along(parts_titles), function(idx) {
    df <- data.frame(
      AU = "GAMA G; SILVA J",
      TI = parts_titles[idx],
      SO = "Revista de Cienciometria",
      PY = 2022,
      DI = NA_character_,
      stringsAsFactors = FALSE
    )
    as_bibliometrix(df, dbsource = "scielo")
  })

  # Fundir sequencialmente Parte 1 com Parte 2, 3 e 4
  merged_1_2 <- merge_bibliolatam(df_list[[1]], df_list[[2]], match_by = "title", similarity_threshold = 0.85)
  expect_equal(nrow(merged_1_2), 2L)

  merged_2_3 <- merge_bibliolatam(df_list[[2]], df_list[[3]], match_by = "title", similarity_threshold = 0.85)
  expect_equal(nrow(merged_2_3), 2L)

  merged_3_4 <- merge_bibliolatam(df_list[[3]], df_list[[4]], match_by = "title", similarity_threshold = 0.85)
  expect_equal(nrow(merged_3_4), 2L)

  # Sequencia completa acumulada de 4 artigos distintos nao deve colapsar nenhum registro
  acc <- df_list[[1]]
  for (k in 2:4) {
    acc <- merge_bibliolatam(acc, df_list[[k]], match_by = "title", similarity_threshold = 0.85)
  }
  expect_equal(nrow(acc), 4L)
})

test_that("adversarial series: Roman vs Arabic representation of the SAME part merges correctly", {
  # Representacao romana vs arabica para o MESMO artigo deve fundir
  pairs <- list(
    list("Estudo de Caso Regional: Parte 1", "Estudo de Caso Regional: Parte I"),
    list("Analise Cienciometrica: Volume 2", "Analise Cienciometrica: Vol. II"),
    list("Pesquisa em Saude Coletiva: Secao 3", "Pesquisa em Saude Coletiva: Secao III"),
    list("Avaliacao da Pos Graduacao: Fase 4", "Avaliacao da Pos Graduacao: Fase IV")
  )

  for (p in pairs) {
    df1 <- as_bibliometrix(data.frame(
      AU = "ALMEIDA R", TI = p[[1]], SO = "Revista A", PY = 2021, DI = NA_character_, stringsAsFactors = FALSE
    ), "scielo")
    df2 <- as_bibliometrix(data.frame(
      AU = "ALMEIDA R", TI = p[[2]], SO = "Revista A", PY = 2021, DI = NA_character_, stringsAsFactors = FALSE
    ), "oasisbr")

    merged <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.85)
    expect_equal(nrow(merged), 1L)
  }
})

test_that("adversarial author permutations: inverted order and truncated coauthors merge cleanly", {
  # Caso 1: Ordem de autores invertida entre bases
  df1 <- as_bibliometrix(data.frame(
    AU = "GAMA G; SILVA J; SANTOS M",
    TI = "Indicadores cienciometricos em repositorios abertos latino-americanos",
    SO = "Transinformacao", PY = 2023, DI = NA_character_, stringsAsFactors = FALSE
  ), "scielo")

  df2 <- as_bibliometrix(data.frame(
    AU = "SANTOS M; SILVA J; GAMA G",
    TI = "Indicadores cienciometricos em repositorios abertos latino americanos",
    SO = "Transinformacao", PY = 2023, DI = NA_character_, stringsAsFactors = FALSE
  ), "redalyc")

  merged_inv <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(merged_inv), 1L)

  # Caso 2: Coautores truncados (primeiro autor mantido, outros omitidos)
  df3 <- as_bibliometrix(data.frame(
    AU = "GAMA G",
    TI = "Indicadores cienciometricos em repositorios abertos latino-americanos",
    SO = "Transinformacao", PY = 2023, DI = NA_character_, stringsAsFactors = FALSE
  ), "oasisbr")

  merged_trunc <- merge_bibliolatam(df1, df3, match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(merged_trunc), 1L)
})

test_that("adversarial author collisions: identical titles by disjoint authors are strictly preserved", {
  # 5 editoriais com titulos identicos em anos diferentes ou iguais, escritos por pessoas disjuntas
  common_titles <- c(
    "Editorial: Os novos rumos da comunicacao cientifica e o acesso aberto",
    "Apresentacao do dossie tematico sobre metricas alternativas da ciencia",
    "Introducao: Os desafios da avaliacao da pesquisa no Sul Global",
    "Prefacio: Ciencia aberta, dados abertos e soberania informacional",
    "Debate: O papel dos repositorios institucionais na ciencia contemporanea"
  )

  authors_group1 <- c("SILVA J", "GAMA G", "SOUZA M", "PEREZ C", "RODRIGUEZ L")
  authors_group2 <- c("BARRETO A", "MORAES F", "OLIVEIRA K", "CASTRO N", "FERREIRA T")

  for (k in seq_along(common_titles)) {
    df1 <- as_bibliometrix(data.frame(
      AU = authors_group1[k], TI = common_titles[k], SO = "Revista Alpha", PY = 2022, DI = NA_character_, stringsAsFactors = FALSE
    ), "scielo")

    df2 <- as_bibliometrix(data.frame(
      AU = authors_group2[k], TI = common_titles[k], SO = "Revista Beta", PY = 2022, DI = NA_character_, stringsAsFactors = FALSE
    ), "oasisbr")

    # Mesmo com 100% de similaridade no titulo e mesmo ano, autores sao disjuntos -> DEVE MANTER 2 REGISTROS!
    res <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)
    expect_equal(nrow(res), 2L)
  }
})

test_that("confusion matrix benchmark: 50 true duplicates vs 50 adversarial traps (FPR = 0%, Recall >= 98%)", {
  set.seed(42)

  # 1. Geracao de 50 pares de Duplicatas Verdadeiras (True Positives) com perturbacoes realistas
  base_titles <- paste("Estudo Cienciometrico e Avaliacao da Literatura Academica no Brasil Caso", 1:50)
  base_authors <- paste0("PESQUISADOR", 1:50, " J; COLABORADOR", 1:50, " M")
  base_years <- rep(c(2020, 2021, 2022, 2023), length.out = 50)

  # df_tp1: colecao 1 com formato limpo
  df_tp1 <- data.frame(
    AU = base_authors,
    TI = base_titles,
    SO = paste("Revista Cientifica", 1:50),
    PY = base_years,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df_tp1 <- as_bibliometrix(df_tp1, dbsource = "scielo")

  # df_tp2: colecao 2 com perturbacoes graficas (acentos, caixa, pontuacao, espacos)
  perturbed_titles <- vapply(base_titles, function(t) {
    # Altera "Avaliacao" para "Avaliação", "pos" para "pós", insere hifens
    t <- gsub("Avaliacao", "Avaliação", t)
    t <- gsub("Academica", "Acadêmica", t)
    t <- gsub("Caso", "Caso -", t)
    t
  }, character(1L), USE.NAMES = FALSE)

  df_tp2 <- data.frame(
    AU = base_authors,
    TI = perturbed_titles,
    SO = paste("Revista Cientifica", 1:50),
    PY = base_years,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df_tp2 <- as_bibliometrix(df_tp2, dbsource = "oasisbr")

  # 2. Executa merge sobre as duplicatas verdadeiras
  merged_tp <- merge_bibliolatam(df_tp1, df_tp2, match_by = "title", similarity_threshold = 0.90)
  # Espera-se que 50 artigos duplicados colapsem em 50 registros unicos
  true_matches <- 100 - nrow(merged_tp)
  recall <- true_matches / 50
  expect_gte(recall, 0.98) # Recall >= 98%

  # 3. Geracao de 50 pares de Armadilhas Adversariais (True Negatives)
  # 25 pares de series "Parte 1" vs "Parte 2" com mesmo autor
  series_titles_1 <- paste("Producao Cientifica e Visibilidade Internacional no Brasil: Parte 1 Dimensoes", 1:25)
  series_titles_2 <- paste("Producao Cientifica e Visibilidade Internacional no Brasil: Parte 2 Dimensoes", 1:25)
  df_trap_series_1 <- as_bibliometrix(data.frame(
    AU = paste0("AUTORSERIE", 1:25, " A"),
    TI = series_titles_1,
    SO = "Revista de Informacao",
    PY = 2022,
    DI = NA_character_,
    stringsAsFactors = FALSE
  ), "scielo")
  df_trap_series_2 <- as_bibliometrix(data.frame(
    AU = paste0("AUTORSERIE", 1:25, " A"),
    TI = series_titles_2,
    SO = "Revista de Informacao",
    PY = 2022,
    DI = NA_character_,
    stringsAsFactors = FALSE
  ), "oasisbr")

  merged_series_traps <- merge_bibliolatam(df_trap_series_1, df_trap_series_2, match_by = "title", similarity_threshold = 0.90)
  # Nenhum par de series deve ser fundido: 25 + 25 = 50 registros mantidos
  expect_equal(nrow(merged_series_traps), 50L)

  # 25 pares com titulos identicos mas autores completamente distintos
  common_trap_titles <- paste("Editorial Especial: Desafios Contemporaneos da Pos-Graduacao no Pais Edicao", 1:25)
  df_trap_authors_1 <- as_bibliometrix(data.frame(
    AU = paste0("GRUPOUM", 1:25, " X"),
    TI = common_trap_titles,
    SO = "Revista Um",
    PY = 2023,
    DI = NA_character_,
    stringsAsFactors = FALSE
  ), "scielo")
  df_trap_authors_2 <- as_bibliometrix(data.frame(
    AU = paste0("GRUPODOIS", 1:25, " Y"),
    TI = common_trap_titles,
    SO = "Revista Dois",
    PY = 2023,
    DI = NA_character_,
    stringsAsFactors = FALSE
  ), "oasisbr")

  merged_author_traps <- merge_bibliolatam(df_trap_authors_1, df_trap_authors_2, match_by = "title", similarity_threshold = 0.90)
  # Nenhum par com autores disjuntos deve ser fundido: 25 + 25 = 50 registros mantidos
  expect_equal(nrow(merged_author_traps), 50L)

  # 4. Metricas Finais do Benchmark
  total_traps <- 50
  false_positives <- (50 - nrow(merged_series_traps)) + (50 - nrow(merged_author_traps))
  fpr <- false_positives / total_traps

  expect_equal(fpr, 0.0) # Taxa de Falsos Positivos = 0.0%
})
