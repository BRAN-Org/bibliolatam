# TODO - bibliolatam

## Parsers & Data Adapters
- [x] SPELL / ANPAD parser (`read_spell`)
- [x] SciELO tabular CSV parser (`read_scielo`)
- [x] SciELO NLM/JATS XML parser (`read_scielo_jats`) with Cited References (`CR`) extraction
- [x] Direct automated XML retrieval helper (`download_scielo_jats`): download raw XMLs from official SciELO endpoints by vector of DOIs or PID article identifiers
- [x] BDTD / Oasisbr tabular and OAI-PMH thesis/dissertation parser (`read_bdtd` / `read_oasisbr`)
- [x] Redalyc / AmeliCA metadata parser (`read_redalyc`)
- [x] LA Referencia regional aggregator parser and API client (`download_lareferencia`)
- [x] SciELO Crossref search client (`download_scielo_search`)
- [x] Federated Latin American Omnisearch engine (`omnisearch_bibliolatam`)
- [x] Cross-database deduplication & metadata fusion engine (`merge_bibliolatam`)

## Core Features & Workflow Integrations
- [x] Canonical `as_bibliometrix()` converter enforcing `bibliometrixDB` class contract
- [x] Standalone Brazilian/Hispanic author normalizer (`normalize_authors`) with generational suffixes and particles
- [x] Vectorized support for `normalize_authors()` (accepts character vectors directly)
- [x] Web GUI exporter (`export_biblioshiny`) creating loadable `.RData` objects
- [x] Biblioshiny UI/Server modules (`scieloUI`, `bdtdUI`, `oasisbrUI`, `redalycUI`, `bibliolatamMergeUI`, `omnisearchUI`)
- [x] Standalone interactive Shiny application launcher (`run_app()`)

## CRAN Submission Readiness
- [x] Standardize `DESCRIPTION` (`Imports` for `jsonlite`/`utils`/`tools`, compliant Description text)
- [x] Harmonize versioning across code, docs, and HTTP User-Agents (`1.0.0`)
- [x] Update maintainer details (`Gabriel Gama <gabrielngama@gmail.com>`), ORCID (`0009-0000-3113-9820`), and institutional contribution (`BRAN Org` as `ctb`) across `DESCRIPTION`, `CITATION`, `CITATION.cff`, and `.zenodo.json`
- [x] Archive package on Zenodo and register permanent DOI (`10.5281/zenodo.23623700`)
- [x] Add executable `@examples` to all 28 exported functions in Roxygen documentation
- [x] Add `@return` / `\value` documentation for all Shiny server modules
- [x] Sanitize non-ASCII / corrupted mojibake characters in R comments and roxygen tags
- [x] Make Shiny server modules resilient to standalone mode (`values = NULL` fallback)
- [x] Create `cran-comments.md` documenting testing environments and check results
- [x] Create introductory package vignette (`vignettes/introduction-to-bibliolatam.Rmd`)
- [ ] Pre-flight submission check via Win-Builder (`R-release` and `R-devel`)
- [ ] Official CRAN submission form submission (`cransubmit`)

## Developer Tooling & Agent Guidelines
- [x] Create `AGENTS.md`: repository architecture, code standards, and execution protocols for AI coding agents

## Internationalization (i18n) & Multilingual Documentation
- [x] Dedicated trilingual engine (`R/i18n.R`) supporting English (`en`), Portuguese (`pt`), and Spanish (`es`)
- [x] Dynamic in-app language switcher in `run_app()` header preserving form inputs
- [x] Full Spanish documentation (`README.es.md`) and trilingual navigation badges across all README files
- [x] Unit test coverage for translations and localized UI components (`test-i18n.R`)

## Post-CRAN Roadmap (v1.1.0+)
- [x] **Passo 1 (Anti-Falso Positivo)**: Guardrails determinísticos no `merge_bibliolatam`:
  - Detecção e bloqueio de discrepância entre séries e numerais ordinais (`Parte I` vs `Parte II`, `Parte 1` vs `Parte 2`).
  - Bloqueio por sobreposição de sobrenomes de autores com tolerância fonética a grafias comuns (ex.: `Sousa` vs `Souza`).
  - Elevação automática de threshold para 0.95 quando registros não possuem autor declarado.
- [ ] **Passo 2 (Melhoria Futura - Testes Adversariais Massivos)**:
  - Bateria de testes adversariais com matrizes sintéticas de títulos colidentes e permutações de homônimos.
  - Benchmarking empírico automatizado para mensuração contínua da taxa de falsos positivos em coleções heterogêneas.
- [ ] **Passo 3 (Melhoria Futura - Otimização Assintótica para Grandes Coleções)**:
  - Indexação prévia de títulos por prefixos e hashes de *q-grams* para evitar o produto cartesiano $O(N \times M)$ do Levenshtein em coleções censitárias gigantes (> 50.000 artigos).
  - Bloqueio pré-Levenshtein por chaves fonéticas (Metaphone/Soundex lusófono) para acelerar a busca em memória.
- [ ] OpenAlex Latin American harvester backend
- [ ] Canopy clustering e string distance heuristics para desambiguação avançada de autores
- [ ] Automated co-citation and bibliographic coupling graph export for Gephi / Pajek


