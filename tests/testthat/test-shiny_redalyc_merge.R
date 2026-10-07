test_that("redalycUI and bibliolatamMergeUI return valid Shiny tags", {
  skip_if_not_installed("shiny")

  ui_redalyc <- redalycUI()
  expect_s3_class(ui_redalyc, "shiny.tag.list")
  ui_redalyc_str <- as.character(ui_redalyc)
  expect_true(grepl("Redalyc &amp; AmeliCA Collection", ui_redalyc_str))
  expect_true(grepl("redalycFile", ui_redalyc_str))
  expect_true(grepl("redalycProcessFile", ui_redalyc_str))

  ui_merge <- bibliolatamMergeUI()
  expect_s3_class(ui_merge, "shiny.tag.list")
  ui_merge_str <- as.character(ui_merge)
  expect_true(grepl("Cross-Database Merge &amp; Deduplication", ui_merge_str))
  expect_true(grepl("mergeFile2", ui_merge_str))
  expect_true(grepl("mergeRunAction", ui_merge_str))
})
