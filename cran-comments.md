# CRAN Submission Comments

## Package: bibliolatam 1.0.0

### Submission Summary
This is the initial submission of `bibliolatam` to CRAN.
`bibliolatam` provides parsers and data conversion pipelines to adapt Latin American open-access bibliographic databases (SciELO, SPELL, BDTD, Oasisbr, Redalyc, and LA Referencia) into standardized data frames compatible with `bibliometrix` and `biblioshiny`.

### Test Environments
- Windows 11 (x86_64-w64-mingw32)
- Ubuntu 22.04 LTS (x86_64-pc-linux-gnu), R 4.4.x (GitHub Actions CI)
- macOS 14 Sonoma (aarch64-apple-darwin23), R 4.4.x

### R CMD check Results
Status: 0 ERRORS | 0 WARNINGS | 0 NOTES

### Downstream Dependencies
There are currently no reverse dependencies (initial release).

### Notes for CRAN Gatekeepers
- **Network calls**: Functions querying remote repositories (`download_scielo_search`, `download_bdtd`, `download_oasisbr`, `download_lareferencia`, `omnisearch_bibliolatam`) contain defensive error handling (`tryCatch`) and their unit tests and documentation examples use `skip_on_cran()` and `\donttest{}` to ensure zero internet requests during CRAN package checks.
- **Authorship and Copyright**: Gabriel Gama is the author, maintainer, and copyright holder (`role = c("aut", "cre", "cph")`). BRAN Org provides institutional and hosting support as a contributor (`role = "ctb"`).
