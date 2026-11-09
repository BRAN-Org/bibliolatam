# CRAN Submission Comments

## Package: bibliolatam 1.0.0

## Resubmission Summary

This is a resubmission addressing reviewer feedback from Leonore Hochhauser.

### Changes made in response to reviewer comments:

1. **Missing `\value` tags and output structure documentation**:
   - Added explicit `\value{No return value, called for side effects (registers reactive observers in the Shiny session).}` to all Shiny server modules, specifically fixing `bibliolatamMergeServer.Rd`, `omnisearchServer.Rd`, and `redalycServer.Rd` as requested, as well as `scieloServer.Rd`, `bdtdServer.Rd`, and `oasisbrServer.Rd`.
   - Documented the exact S3 class (`shiny.tag.list`) and HTML layout for all UI modules (`bibliolatamMergeUI`, `omnisearchUI`, `redalycUI`, `scieloUI`, `bdtdUI`, `oasisbrUI`, `bibliolatamInfoUI`).
   - Expanded `@return` descriptions across all parsing and conversion functions (`read_redalyc`, `read_scielo`, `read_scielo_jats`, `read_bdtd`, `read_oasisbr`, `read_spell`, `as_bibliometrix`, `merge_bibliolatam`, `export_biblioshiny`, `download_scielo_jats`, `download_scielo_search`, `download_bdtd`, `download_oasisbr`, `download_lareferencia`, `omnisearch_bibliolatam`), detailing the output S3 class (`c("bibliometrixDB", "data.frame")`), standard WoS/bibliometrix field tags (`AU`, `TI`, `SO`, `PY`, `CR`, `UT`, etc.), and their semantic meaning.

2. **Interactive functions wrapped in `if (interactive())`**:
   - Replaced `\dontrun{}` with `if (interactive()) { ... }` in `run_app()` and all Shiny UI and server module examples so users and automated checkers clearly see that these functions are meant for interactive sessions.

3. **Removal of commented-out code lines in `\examples{}`**:
   - In `read_redalyc.Rd`, removed all commented-out code lines. Added a representative Latin American BibTeX toy fixture (`inst/extdata/redalyc_sample.bib`) and an active, regularly executed toy example using `system.file("extdata", "redalyc_sample.bib", package = "bibliolatam")`.
   - Verified that no commented-out code lines exist in any `.Rd` files across the package.

4. **Rationale for `\donttest{}`**:
   - `\donttest{}` is used exclusively in the 6 functions that query remote public REST APIs over HTTP:
     - `download_scielo_search()` (Crossref REST API)
     - `download_scielo_jats()` (SciELO XML endpoint)
     - `download_bdtd()` (IBICT VuFind API)
     - `download_oasisbr()` (IBICT VuFind API)
     - `download_lareferencia()` (LA Referencia VuFind API)
     - `omnisearch_bibliolatam()` (Federated multi-source queries across the endpoints above)
   - These functions depend on external public web services and live internet connections. They are wrapped in `\donttest{}` with defensive `tryCatch()` to prevent check failures when internet access is unavailable or when remote servers exceed 5 seconds due to network latency or rate limits.
   - All local parsing functions (`read_scielo`, `read_scielo_jats`, `read_spell`, `read_bdtd`, `read_oasisbr`, `read_redalyc`, `as_bibliometrix`, `merge_bibliolatam`, `normalize_authors`) execute unconditionally using bundled toy files in `inst/extdata/` in less than 0.1 seconds.

5. **GPL-3.0 URL in `README.md`**:
   - The URL `https://www.gnu.org/licenses/gpl-3.0` was originally included in `README.md` to reference the GNU General Public License v3.0 terms in the context of the repository's dual licensing (GPL-3.0 for software code, CC BY-NC-SA 4.0 for scientometric fixtures).
   - In response to the reviewer's query and to eliminate transient network connection resets by `gnu.org` during CRAN's incoming URL check (`libcurl error 35`), this external URL has been removed from `README.md`, replacing it with standard plain-text references and internal anchor links.

---

## Test Environments
- Ubuntu 24.04 LTS (x86_64-pc-linux-gnu), R 4.4.x / R-devel 4.6.x (Docker & GitHub Actions CI)
- Windows 11 (x86_64-w64-mingw32), R 4.4.x
- macOS 14 Sonoma (aarch64-apple-darwin23), R 4.4.x

## R CMD check Results
Status: 0 ERRORS | 0 WARNINGS | 1 NOTE

- 1 NOTE: New submission (incoming feasibility check).

## Downstream Dependencies
There are currently no reverse dependencies (initial release).
