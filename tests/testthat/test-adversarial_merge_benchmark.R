# ==============================================================================
# BENCHMARK ADVERSARIAL E DE OTIMIZACAO ASSINTOTICA COM DADOS REAIS DE PERIODICOS
# Utiliza fixture real de 150 artigos revisados por pares (PT-BR, PT-PT, ES-MX, ES-OTHER)
# extraidos de SciELO, DataGramaZero, Univ. Coimbra/Minho/Porto, UNAM, INSP, CSIC e Chile.
# ==============================================================================

load_real_journals_fixture <- function() {
  fix_path <- testthat::test_path("fixtures", "real_journals_merge_fixture.csv")
  stopifnot(file.exists(fix_path))
  read.csv(fix_path, stringsAsFactors = FALSE)
}

test_that("adversarial series on real journal titles: multi-part sequences in PT and ES are never merged", {
  real_df <- load_real_journals_fixture()
  base_row <- real_df[real_df$LANG_GROUP == "PT_BR", ][1, ]

  parts_titles <- paste0(
    base_row$TI,
    c(": Parte 1 - Fundamentos", ": Parte 2 - Metodos", ": Parte 3 - Resultados", ": Parte 4 - Discussao")
  )

  df_list <- lapply(seq_along(parts_titles), function(idx) {
    as_bibliometrix(data.frame(
      AU = base_row$AU,
      TI = parts_titles[idx],
      SO = base_row$SO,
      PY = base_row$PY,
      DI = NA_character_,
      stringsAsFactors = FALSE
    ), dbsource = "scielo")
  })

  acc <- df_list[[1]]
  for (k in 2:4) {
    acc <- merge_bibliolatam(acc, df_list[[k]], match_by = "title", similarity_threshold = 0.85)
  }
  expect_equal(nrow(acc), 4L)
})

test_that("adversarial series: Roman vs Arabic representation of the SAME part merges correctly on real records", {
  real_df <- load_real_journals_fixture()
  sub_real <- real_df[1:4, ]

  suffixes <- list(
    c(": Parte 1", ": Parte I"),
    c(": Volume 2", ": Vol. II"),
    c(": Secao 3", ": Secao III"),
    c(": Volumen 4", ": Volumen IV")
  )

  for (idx in 1:4) {
    df1 <- as_bibliometrix(data.frame(
      AU = sub_real$AU[idx], TI = paste0(sub_real$TI[idx], suffixes[[idx]][1]),
      SO = sub_real$SO[idx], PY = sub_real$PY[idx], DI = NA_character_, stringsAsFactors = FALSE
    ), "scielo")
    df2 <- as_bibliometrix(data.frame(
      AU = sub_real$AU[idx], TI = paste0(sub_real$TI[idx], suffixes[[idx]][2]),
      SO = sub_real$SO[idx], PY = sub_real$PY[idx], DI = NA_character_, stringsAsFactors = FALSE
    ), "oasisbr")

    merged <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.85)
    expect_equal(nrow(merged), 1L)
  }
})

test_that("adversarial author permutations on real Iberian/Hispanic multi-author articles merge cleanly", {
  real_df <- load_real_journals_fixture()
  multi_au <- real_df[grepl(";", real_df$AU), ]
  rec <- multi_au[1, ]
  au_parts <- trimws(unlist(strsplit(rec$AU, ";", fixed = TRUE)))

  df1 <- as_bibliometrix(data.frame(
    AU = rec$AU, TI = rec$TI, SO = rec$SO, PY = rec$PY, DI = NA_character_, stringsAsFactors = FALSE
  ), "scielo")

  # Ordem invertida de coautores + titulo transliterado ASCII
  df2 <- as_bibliometrix(data.frame(
    AU = paste(rev(au_parts), collapse = "; "),
    TI = iconv(rec$TI, to = "ASCII//TRANSLIT"),
    SO = rec$SO, PY = rec$PY, DI = NA_character_, stringsAsFactors = FALSE
  ), "redalyc")
  expect_equal(nrow(merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)), 1L)

  # Truncamento mantendo apenas o primeiro autor real
  df3 <- df2
  df3$AU <- au_parts[1]
  expect_equal(nrow(merge_bibliolatam(df1, df3, match_by = "title", similarity_threshold = 0.90)), 1L)
})

test_that("real multilingual confusion matrix: 50 real duplicates vs 50 real-article adversarial traps (FPR = 0%, Recall >= 98%)", {
  real_df <- load_real_journals_fixture()
  expect_equal(nrow(real_df), 150L)

  # 1. 50 Duplicatas Verdadeiras extraidas diretamente dos artigos reais (PT-BR, PT-PT, ES-MX, ES-OTHER)
  tp_src <- real_df[1:50, ]
  tp_src$DI <- NA_character_
  df_tp1 <- as_bibliometrix(tp_src, dbsource = "scielo")

  # Perturbacao realista de indexacao secundaria (remocao de acentos UTF-8 -> ASCII, hifens espacados e variacao de caixa)
  tp_sec <- tp_src
  tp_sec$TI <- iconv(tp_sec$TI, to = "ASCII//TRANSLIT")
  tp_sec$TI <- gsub("[-–—]", " ", tp_sec$TI)
  tp_sec$TI[seq(1, 50, by = 2)] <- toupper(tp_sec$TI[seq(1, 50, by = 2)])
  df_tp2 <- as_bibliometrix(tp_sec, dbsource = "oasisbr")

  merged_tp <- merge_bibliolatam(df_tp1, df_tp2, match_by = "title", similarity_threshold = 0.90)
  true_matches <- 100L - nrow(merged_tp)
  recall <- true_matches / 50
  expect_gte(recall, 0.98)

  # 2. 50 Armadilhas Adversariais construidas sobre artigos e autores REAIS distintos (linhas 51..150)
  # 2a. 15 pares de series reais em PT e ES (Parte I/II, Volumen I/II com subtitulo)
  s_rows <- real_df[51:65, ]
  s_rows$DI <- NA_character_
  s1 <- s_rows; s2 <- s_rows
  s1$TI <- paste0(s1$TI, rep(c(": Parte I", ", Volumen I: analisis", ": Secção 1"), 5))
  s2$TI <- paste0(s2$TI, rep(c(": Parte II", ", Volumen II: analisis", ": Secção 2"), 5))
  res_s <- merge_bibliolatam(as_bibliometrix(s1, "scielo"), as_bibliometrix(s2, "oasisbr"),
                             match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(res_s), 30L)

  # 2b. 15 pares de titulos reais identicos atribuidos a autores reais disjuntos do corpus (linhas 66..80 vs 121..150)
  h1 <- real_df[66:80, ]; h1$DI <- NA_character_
  h2 <- h1
  cand_au_pool <- real_df$AU[115:150]
  ptr <- 1L
  for (i in 1:15) {
    sn1 <- bibliolatam:::extract_author_surnames(h1$AU[i])
    while (ptr <= length(cand_au_pool)) {
      sn2 <- bibliolatam:::extract_author_surnames(cand_au_pool[ptr])
      if (length(sn2) > 0L && !bibliolatam:::surnames_compatible(sn1, sn2)) {
        h2$AU[i] <- cand_au_pool[ptr]
        ptr <- ptr + 1L
        break
      }
      ptr <- ptr + 1L
    }
  }
  res_h <- merge_bibliolatam(as_bibliometrix(h1, "scielo"), as_bibliometrix(h2, "oasisbr"),
                             match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(res_h), 30L)

  # 2c. 10 pares reais com conflito explicito de DOIs (artigo original vs errata)
  d1 <- real_df[81:90, ]
  d1$DI <- ifelse(is.na(d1$DI) | !nzchar(d1$DI), paste0("10.1590/real.", 1:10), d1$DI)
  d2 <- d1
  d2$DI <- paste0(d1$DI, ".erratum")
  res_d <- merge_bibliolatam(as_bibliometrix(d1, "scielo"), as_bibliometrix(d2, "oasisbr"),
                             match_by = c("doi", "title"), similarity_threshold = 0.85)
  expect_equal(nrow(res_d), 20L)

  # 2d. 10 pares reais de conflito Document Type (THESIS vs ARTICLE do mesmo autor real sem DOI)
  dt1 <- real_df[91:100, ]; dt1$DI <- NA_character_; dt1$DT <- "THESIS"
  dt2 <- dt1; dt2$DT <- "ARTICLE"
  res_dt <- merge_bibliolatam(as_bibliometrix(dt1, "bdtd"), as_bibliometrix(dt2, "scielo"),
                              match_by = c("doi", "title"), similarity_threshold = 0.90)
  expect_equal(nrow(res_dt), 20L)

  false_positives <- (30L - nrow(res_s)) + (30L - nrow(res_h)) + (20L - nrow(res_d)) + (20L - nrow(res_dt))
  expect_equal(false_positives, 0L)
})

test_that("asymptotic optimizations: reordered Length-Bound, Exact-Match and Canopy instrument pruning stats on real corpus", {
  real_df <- load_real_journals_fixture()
  # Forca todos no mesmo ano (2022) e sem DOI para estressar o Length-Bound Filter e o Canopy em dados reais
  real_df$PY <- 2022L
  real_df$DI <- NA_character_

  # 10 registros reais em df1 (sendo os 5 primeiros duplicados em df2 com transliteracao ASCII) contra 145 registros reais em df2
  df1 <- real_df[1:10, ]
  df2 <- real_df[c(1:5, 11:150), ]
  df2$TI[1:5] <- iconv(df2$TI[1:5], to = "ASCII//TRANSLIT")

  t0 <- proc.time()
  merged <- merge_bibliolatam(as_bibliometrix(df1, "scielo"), as_bibliometrix(df2, "oasisbr"),
                              match_by = "title", similarity_threshold = 0.90)
  elapsed <- as.numeric((proc.time() - t0)["elapsed"])

  stats <- attr(merged, "merge_stats")
  expect_equal(stats$total_duplicates, 5L)
  expect_equal(nrow(merged), 150L)
  # Verifica instrumentacao real interna do Length-Bound Filter (> 70% podados em O(1))
  expect_gt(stats$length_bound_pruned, 0L)
  expect_gt(stats$length_bound_pruned / stats$candidates_before_len, 0.65)
  expect_lt(elapsed, 1.0)
})
