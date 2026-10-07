# bibliolatam: Latin American Bibliographic Data Adapters for 'bibliometrix'

`bibliolatam` is an R companion package designed to bridge the gap between Latin American open-access scientific repositories and bibliometric workflows in [`bibliometrix`](https://github.com/massimoaria/bibliometrix).

---

## Why bibliolatam?

Mainstream bibliometric pipelines assume commercial, closed-access citation indexes (Web of Science, Scopus). However, Latin American scientific output is predominantly published in non-commercial Diamond Open Access journals (such as SciELO, Redalyc, and SPELL) and indexed in national thesis repositories and federations (BDTD/Oasisbr in Brazil, LA Referencia across 12 countries).

Because `bibliometrix` core deliberately limits its native parsers to global indexes to keep maintenance sustainable (see [bibliometrix issue #689](https://github.com/massimoaria/bibliometrix/issues/689)), `bibliolatam` serves as an external modular adapter. It parses export files and queries public REST APIs from regional repositories, harmonizes heterogeneous metadata into the standard `bibliometrixDB` S3 data frame contract, and provides direct integration into `biblioshiny`.

---

## Installation

Install the development version from GitHub:

```r
# Using remotes
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("BRAN-Org/bibliolatam")

# Or using pak
if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
pak::pkg_install("BRAN-Org/bibliolatam")
```

### Dependencies

- **Required**: R (>= 3.6.0).
- **Recommended for analyses**: `bibliometrix` (>= 4.0.0).
- **Recommended for REST APIs and GUI**: `jsonlite`, `shiny`.

---

## Architecture & Data Flow

```text
[ Regional Sources ]
├── SciELO          (Files: CSV, JATS XML | APIs: Crossref works, raw XMLs)
├── BDTD / Oasisbr  (Files: CSV, TSV      | APIs: IBICT VuFind Solr)
├── LA Referencia   (APIs: VuFind REST v1 across 12 national networks)
├── Redalyc         (Files: BibTeX, RIS, CSV)
└── SPELL / ANPAD   (Files: CSV)
         │
         ▼
[ bibliolatam Engine ]
├── Parsers & REST API Clients (Defensive networking & pagination)
├── Author Normalizer (Generational suffixes & Hispanic compound names)
├── Multi-Source Deduplication (Exact DOI + fuzzy title matching)
└── Schema Harmonizer (`as_bibliometrix`)
         │
         ▼
[ Canonical bibliometrixDB ]
├── Standalone R Scripts: `biblioAnalysis()`, `biblioNetwork()`, etc.
└── Web GUI: Direct reactive injection into `biblioshiny` or `.RData` export
```

---

## Supported Sources & Ingestion Modes

| Source | Geographic Scope | Typology | Ingestion Mode | Key Capabilities |
|:---|:---|:---|:---|:---|
| **SciELO** | Latin America, Caribbean, Iberia | Journal Articles | File (`read_scielo`, `read_scielo_jats`) & API (`download_scielo_search`, `download_scielo_jats`) | Cited references (`CR`) extracted from NLM/JATS XML; live search via Crossref DOI prefix `10.1590`. |
| **BDTD** | Brazil | Theses & Dissertations | File (`read_bdtd`) & REST API (`download_bdtd`) | Academic advisors (`RP`), degree mapping (`DT` as THESIS/DISSERTATION), IBICT VuFind Solr pagination. |
| **Oasisbr** | Brazil | Articles, Theses, Reports | File (`read_oasisbr`) & REST API (`download_oasisbr`) | National open-access research portal, typology normalization. |
| **LA Referencia** | 12 Countries (AR, BR, CL, CO, CR, EC, ES, MX, PA, PE, SV, UY) | National Repository Networks | REST API (`download_lareferencia`) | Federated querying across Latin American national repository infrastructures. |
| **Redalyc / AmeliCA** | Ibero-America | Diamond OA Journals | File (`read_redalyc`) | BibTeX (`.bib`), RIS (`.ris`), and CSV formats with Hispanic compound author normalization. |
| **SPELL (ANPAD)** | Brazil | Management & Economics | File (`read_spell`) | Tabular exports, auto-detection of delimiters (`;`, `,`, `\t`) and Latin-1/UTF-8 encodings. |
| **Omnisearch** | Regional (Multi-Source) | All Types | Federated Function & Shiny Panel | Simultaneous querying across SciELO, BDTD, Oasisbr, and LA Referencia with API year filtering. |

---

## Workflows & Examples

### Workflow 1: Federated Multi-Source Omnisearch (Online)

Retrieve and fuse records from multiple databases in a single command, with year filtering at the API endpoint level and automated deduplication:

```r
library(bibliolatam)
library(bibliometrix)

# Query SciELO, BDTD, Oasisbr, and LA Referencia simultaneously
results <- omnisearch_bibliolatam(
  query = "energia solar",
  sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
  limit_per_source = 50,
  years = c(2020, 2024),
  deduplicate = TRUE,
  progress = TRUE
)

# Run bibliometrix analysis directly
analysis <- biblioAnalysis(results)
summary(analysis)
```

### Workflow 2: Automated Single-Source REST API Retrieval

Target specific regional repositories programmatically:

```r
library(bibliolatam)

# 1. Brazilian theses and dissertations from BDTD
theses <- download_bdtd(
  query = "inteligencia artificial saude",
  limit = 50,
  years = c(2021, 2024)
)

# 2. SciELO journal articles enriched with Cited References (CR) via JATS XML
articles <- download_scielo_search(
  query = "vacina dengue",
  limit = 30,
  years = c(2020, 2024),
  enrich_references = TRUE
)

# 3. Federated Latin American repositories via LA Referencia
regional_papers <- download_lareferencia(
  query = "mudancas climaticas",
  limit = 50,
  years = c(2019, 2024)
)
```

### Workflow 3: Ingestion of Offline Export Files

For large searches conducted directly through portal web interfaces:

```r
library(bibliolatam)
library(bibliometrix)

# SciELO: CSV export or raw NLM/JATS XML
df_scielo <- read_scielo("scielo_results.csv")
df_jats   <- read_scielo_jats("scielo_article.xml")

# BDTD / Oasisbr: CSV or TSV exports
df_bdtd <- read_bdtd("bdtd_theses.csv")

# Redalyc: BibTeX, RIS, or CSV export
df_redalyc <- read_redalyc("redalyc_export.bib")

# SPELL: Administration / Economics CSV
df_spell <- read_spell("spell_articles.csv")

# Convert and ensure bibliometrix contract
M <- as_bibliometrix(df_scielo, dbsource = "scielo")
```

### Workflow 4: Cross-Database Deduplication & Fusion

When merging independent regional collections:

```r
library(bibliolatam)

# Merge two distinct collections (e.g. SciELO + Oasisbr)
# Resolves records by canonical DOI and fuzzy title matching (Levenshtein distance)
merged_corpus <- merge_bibliolatam(df_scielo, df_bdtd, match_by = c("doi", "title"))
```

### Workflow 5: Interactive GUI in Biblioshiny

1. **Direct Serialization**:
   ```r
   export_biblioshiny(results, "corpus_latino.RData")
   ```
   Open `biblioshiny::biblioshiny()` -> *Data -> Load bibliometrix RData* -> select `corpus_latino.RData`.

2. **Native Bibliolatam Panels**:
   When `bibliolatam` is mounted inside `biblioshiny`, access the dedicated **Bibliolatam** sidebar menu:
   - **Omnisearch**: Live federated search, date bounds, summary KPI cards, CSV/.RData downloads, and 1-click loading into the active `values$M` session.
   - **SciELO / BDTD / Oasisbr / Redalyc**: Individual portals for online search and local file uploads.
   - **Merge Collections**: Interactive entity resolution and deduplication interface.

---

## Analytics Compatibility & Known Data Limitations

Because Latin American repositories are managed by distinct public institutions with different indexing practices, not all metadata fields present in commercial databases (WoS/Scopus) are available across all regional sources.

Here is the exact compatibility matrix with `bibliometrix` routines:

| Analytical Module | Required Tags | Supported Regional Sources | Status & Practical Behavior |
|:---|:---|:---|:---|
| **Annual Production & Growth** | `PY`, `SO`, `DT` | **All** (SciELO, BDTD, Oasisbr, Redalyc, LA Referencia, SPELL) | **100% Functional**. Annual scientific production, Bradford's law, and source relevance run out of the box. |
| **Conceptual Structure & Topics** | `TI`, `AB`, `DE`, `ID` | **All** | **100% Functional**. Keyword co-occurrence networks, thematic maps (`thematicMap`), and factor analysis (MCA) work as expected. |
| **Author Collaboration Networks** | `AU`, `C1`, `RP` | **All** | **100% Functional**. Normalized via `normalize_authors()` (handles Brazilian and Hispanic compound names). BDTD maps academic advisors to `RP`. |
| **Intellectual Structure (Co-citation & Coupling)** | `CR` (Cited References) | **SciELO (via JATS XML)** | **Supported on SciELO**: `read_scielo_jats()` and `download_scielo_search(enrich_references = TRUE)` reconstruct `<ref-list>` into `CR`.<br>**Not Available on BDTD / LA Referencia / Redalyc CSV**: Repositories do not extract full bibliographies from PDF attachments. |
| **Impact & Times Cited Metrics** | `TC` (Times Cited) | N/A (initialized to `0`) | **Field Present, Metric Limited**: Open regional APIs do not provide proprietary global citation counts. `TC` is initialized to `0` so `bibliometrix` routines do not crash, but citation-based rankings will reflect uncounted regional metrics. |

---

## Schema Contract: `bibliometrixDB`

Every data frame produced by `bibliolatam` inherits the S3 class `bibliometrixDB` and adheres to standard Web of Science field tags:

- `TI` (Title), `AU` (Authors: `LASTNAME INITIALS; ...`), `SO` (Publication Venue / Degree Institution).
- `PY` (Year, integer), `DE` (Author Keywords), `AB` (Abstract), `C1` (Affiliations), `RP` (Advisor/Reprint).
- `CR` (Cited References), `TC` (Times Cited), `DI` (Clean DOI), `DT` (Document Type), `LA` (Language).
- `DB` (Database Provenance), `SR` & `SR_FULL` (Standard references for matrix routines), `JI` & `J9` (Journal identifiers).

Missing tags are populated with `NA` (or `0` for numeric citations) without data fabrication.

---

## Principles & Dual Licensing

- **[FAIR Principles](https://www.gofair.foundation/fair-principles)**: Enhancing Findability, Accessibility, Interoperability, and Reusability for Global South scientific literature.
- **[BOAI](https://www.budapestopenaccessinitiative.org/)**: Dedicated to non-commercial, Diamond Open Access infrastructures.
- **Dual Licensing**:
  - **Source Code**: [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html) - Free software copyleft guaranteeing open code.
  - **Sample Fixtures (`inst/extdata/`)**: [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/) - For academic validation and testing only.
