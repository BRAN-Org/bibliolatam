# AGENTS.md: Developer & Agent Architecture Guide

This document defines the architectural principles, data contracts, coding standards, and verification protocols for AI coding assistants and human developers working on `bibliolatam`.

---

## 1. Mission & Core Philosophy

`bibliolatam` is a companion package for [`bibliometrix`](https://github.com/massimoaria/bibliometrix). Its primary goal is to adapt Latin American open-access scientific literature into canonical `bibliometrixDB` data frames without modifying or monkey-patching the core `bibliometrix` codebase.

Key tenets:
- **Zero data fabrication**: If a field is not present in the original repository record, fill it with `NA_character_` or `0` (for citations). Never invent metadata.
- **Fail-safe network requests**: Remote repositories (IBICT, SciELO, LA Referencia) occasionally experience rate-limits or downtime. API clients must never crash the R session or a running Shiny app; always isolate network failures with `tryCatch`.
- **Strict schema contract**: Any dataset exported or returned by `bibliolatam` must be ready for `bibliometrix::biblioAnalysis()` and `bibliometrix::biblioNetwork()`.

---

## 2. Package Architecture

The package is structured into five distinct layers:

### A. Ingestion Layer (Offline File Parsers)
- `read_spell(file, ...)`: Parsers for Brazilian administration and economics exports (CSV). Auto-detects delimiters (`;`, `,`, `\t`) and Latin-1/UTF-8 encodings.
- `read_scielo(file, ...)`: Tabular CSV parser for SciELO search exports in Portuguese, Spanish, or English.
- `read_scielo_jats(file_or_dir, ...)`: Full-text NLM/JATS XML parser supporting individual files, directories, or `.zip` archives. Extracts cited references (`<ref-list>`) into the canonical `CR` tag.
- `read_bdtd(file, ...)` / `read_oasisbr(file, ...)`: Parsers for IBICT's national thesis, dissertation, and repository exports.
- `read_redalyc(file, ...)`: Multi-format parser for Redalyc/AmeliCA diamond open-access exports (BibTeX `.bib`, RIS `.ris`, and CSV).

### B. Acquisition Layer (Online REST API Clients)
- `download_scielo_jats(dois, ...)`: Direct NLM/JATS XML retriever from SciELO endpoints with HTTP redirect following.
- `download_scielo_search(query, limit, years, enrich_references, ...)`: Live search client using the public Crossref works API filtered by SciELO's DOI prefix (`10.1590`).
- `download_bdtd(query, limit, years, ...)`: Official IBICT VuFind Search REST API client for Brazilian theses and dissertations.
- `download_oasisbr(query, limit, years, ...)`: IBICT VuFind Search API client for multidisciplinary Brazilian repository outputs.
- `download_lareferencia(query, limit, years, ...)`: Official LA Referencia VuFind REST API v1 client covering repository networks across 12 Latin American nations.

### C. Federation & Entity Resolution Layer
- `omnisearch_bibliolatam(query, sources, limit_per_source, years, enrich_references, deduplicate, ...)`: Federated engine querying SciELO, BDTD, Oasisbr, and LA Referencia concurrently.
- `merge_bibliolatam(...)`: Multi-source deduplication and metadata fusion engine. Resolves entities via exact normalized DOIs and fuzzy title matching (Levenshtein distance), fusing complementary metadata tags (`CR`, `AB`, `DE`, `DI`).

### D. Canonical Transformation Layer
- `as_bibliometrix(df, dbsource)`: Enforces the `bibliometrixDB` class contract. Standardizes data types, coerces `PY` and `TC`, generates canonical standard references (`SR`, `SR_FULL`, `JI`, `J9`), and injects standard missing WoS tags.
- `normalize_authors(authors)`: Standalone author normalization engine supporting Brazilian and Hispanic name conventions (generational suffixes `Neto`, `Filho`, `Junior`, `Sobrinho` and compound particles `da`, `de`, `del`, `van`).

### E. Presentation & GUI Layer
- `export_biblioshiny(data, file)`: Serializes canonical collections into `.RData` files containing the standard object `M`.
- Shiny UI & Server modules: `scieloUI`/`scieloServer`, `bdtdUI`/`bdtdServer`, `oasisbrUI`/`oasisbrServer`, `redalycUI`/`redalycServer`, `bibliolatamMergeUI`/`bibliolatamMergeServer`, and `omnisearchUI`/`omnisearchServer`.

---

## 3. The `bibliometrixDB` Data Contract

All data outputs returned by `bibliolatam` must satisfy the following column requirements:

| Tag | Name | Type | Description / Notes |
|:---|:---|:---|:---|
| `TI` | Title | Character | Title in uppercase or original casing, unescaped HTML entities. |
| `AU` | Authors | Character | Formatted as `LASTNAME INITIALS; LASTNAME INITIALS`. |
| `SO` | Source / Journal | Character | Publication venue, journal title, or degree-granting institution. |
| `PY` | Publication Year | Numeric/Integer | 4-digit publication year. |
| `DE` | Author Keywords | Character | Semicolon-separated author keywords. |
| `ID` | Keywords Plus | Character | Standardized indexing keywords or topic terms. |
| `AB` | Abstract | Character | Full text abstract. |
| `C1` | Affiliations | Character | Author institutional affiliations. |
| `RP` | Reprint / Advisor | Character | In BDTD/Oasisbr, stores the academic advisor name. |
| `CR` | Cited References | Character | Semicolon-separated references formatted for co-citation routines. |
| `TC` | Times Cited | Numeric/Integer | Global times cited count (defaults to `0` if unknown). |
| `DI` | DOI | Character | Clean DOI string (without `https://doi.org/` prefix). |
| `DT` | Document Type | Character | Canonical descriptors (`ARTICLE`, `THESIS`, `DISSERTATION`, `BOOK`). |
| `LA` | Language | Character | Standardized uppercase descriptor (`PORTUGUESE`, `SPANISH`, `ENGLISH`). |
| `DB` | Database Source | Character | Provenance indicator (`scielo`, `bdtd`, `oasisbr`, `redalyc`, etc.). |
| `SR` | Standard Reference | Character | Generated: `FIRST_AUTHOR, YEAR, JOURNAL, V..., P..., DOI...`. |
| `SR_FULL` | Full Reference | Character | Canonical key used by `cocMatrix()` and network routines. |
| `JI` | Journal ISO | Character | ISO abbreviation of the source journal. |
| `J9` | 29-Char Journal | Character | Truncated journal identifier for network matrices. |

---

## 4. Code Standards & CRAN Hygiene

1. **ASCII Only in R Source Code**: All `.R` files under `R/` must contain strictly pure ASCII characters. Avoid raw unescaped accented characters (e.g. `ã`, `é`, `ç`) in strings, UI labels, or notifications. Use unaccented text or Unicode escape sequences (`\uxxxx`).
2. **Namespace Discipline**: Always use explicit package qualification for external packages (`jsonlite::fromJSON`, `utils::read.csv`, `shiny::div`). Add all required packages to `Imports` or `Suggests` in `DESCRIPTION`.
3. **Defensive Programming**:
   - Check file existence and type validity early (`fail-fast`).
   - Clean up connections and temp files via `on.exit(close(conn), add = TRUE)`.
   - Never assume API payloads are valid JSON; check headers and string boundaries.

---

## 5. Testing & Verification Protocols

The test suite uses `testthat` (edition 3) located in `tests/testthat/`.

### Guidelines:
- **Zero CRAN Network Calls**: Any test making live calls to external endpoints (Crossref, SciELO, IBICT, LA Referencia) **must** start with `skip_on_cran()` and be wrapped in a `tryCatch` that skips on network failure:
  ```r
  skip_on_cran()
  df <- tryCatch(
    download_scielo_search("dengue", limit = 3L, progress = FALSE),
    error = function(e) skip(paste("Endpoint offline:", e$message))
  )
  ```
- **Deterministic Mocking**: For testing URL parameter construction and edge-case payload parsing, use `testthat::with_mocked_bindings` on `base::url` or internal helpers.
- **Docker Testing Workflow**:
  ```bash
  # Run unit tests locally
  docker exec biblioshiny-app Rscript -e 'testthat::test_local("/workspace")'

  # Run full CRAN check
  docker exec biblioshiny-app bash -c 'cd /tmp && rm -rf bibliolatam*.tar.gz bibliolatam.Rcheck && R CMD build /workspace && R CMD check bibliolatam_*.tar.gz --no-manual --as-cran'
  ```
- **Passing Threshold**: 100% test pass rate, 0 errors, 0 warnings.

---

## 6. Git & Contribution Hygiene

- **Conventional Commits**: Every commit message must strictly follow Conventional Commits (`feat(...)`, `fix(...)`, `docs(...)`, `chore(...)`, `test(...)`).
- **No Chat/Prompt Leakage**: Never commit conversational artifacts ("Please provide", "Certainly", "Here is").
- **Clean Branching**: Use lowercase `kebab-case` with standard prefixes: `feat/<feature>`, `fix/<bug>`, `chore/<task>`.
