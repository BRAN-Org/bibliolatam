# bibliolatam: Latin American Bibliographic Data Adapters for 'bibliometrix'

<p align="left">
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-english.svg" alt="English Version" height="28" /></a>
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.pt-BR.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-portugues.svg" alt="Versão em Português" height="28" /></a>
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.es.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-espanol.svg" alt="Versión en Español" height="28" /></a>
</p>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23623700.svg)](https://doi.org/10.5281/zenodo.23623700)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

`bibliolatam` is an R package designed to bridge Latin American, Caribbean, and Iberian open-access scientific repositories both for self-contained exploration (**Standalone Mode**) and for deep scientometric pipelines in [`bibliometrix`](https://github.com/massimoaria/bibliometrix) and [`biblioshiny`](https://github.com/massimoaria/bibliometrix).

---

## Why bibliolatam?

Mainstream bibliometric pipelines assume commercial, closed-access citation indexes from the Global North (Web of Science, Scopus). However, scientific production in Latin America, the Caribbean, and Iberia is historically published under non-commercial **Diamond Open Access** models (such as SciELO, Redalyc, and SPELL) and preserved in national thesis and dissertation repositories (such as BDTD and Oasisbr in Brazil, and the LA Referencia federation across 12 countries).

Because the core `bibliometrix` package deliberately restricts its native parsers to major international multidisciplinary indexes to keep maintenance sustainable (as documented in [bibliometrix issue #689](https://github.com/massimoaria/bibliometrix/issues/689)), `bibliolatam` serves as a modular, decoupled bridge. It enables researchers to harvest, deduplicate, normalize, and export regional data **100% autonomously** or convert them into the canonical S3 `bibliometrixDB` class for advanced bibliometric and network modeling.

---

## Two Operating Modes: Standalone or Integrated

`bibliolatam` is designed to be completely decoupled. You can use it in two distinct modes:

### 1. Standalone Mode (Independent)
* **No `bibliometrix` dependency**: Operates using only base R and lightweight packages (`shiny`, `jsonlite`, `utils`, `tools`).
* **Self-Contained Web App (`run_app()`)**: Features a complete interactive dashboard with **live trilingual support** (🇬🇧 English, 🇧🇷 Portuguese, and 🇪🇸 Spanish).
* **Flexible Harvesting & Ingestion**: Harvests live data from public REST APIs (SciELO, BDTD, Oasisbr, LA Referencia) or parses local files (JATS XML, CSV, TSV, RIS, BibTeX).
* **Regional Entity Resolution**: Vectorized normalization of Brazilian generational suffixes and Hispanic compound surnames, plus cross-database entity deduplication (canonical DOI + fuzzy title distance).
* **Universal Export**: Exports harmonized datasets directly to `.csv` or `.RData` for immediate use in R, Python, Excel, VOSviewer, or Gephi.

### 2. Integrated Mode (with `bibliometrix` & `biblioshiny`)
* **Canonical S3 `bibliometrixDB` Contract**: Normalizes and validates all standard tags (`TI`, `AU`, `SO`, `PY`, `CR`, `DE`, `DI`, etc.) for seamless compatibility with `bibliometrix` routines.
* **Advanced Scientometric Analytics**: Direct execution of `biblioAnalysis()`, bibliometric laws (Bradford, Lotka), thematic evolution maps, and co-authorship networks.
* **Co-citation & Bibliographic Coupling**: Unlocked by full cited references (`CR`) extraction from SciELO NLM/JATS XML full texts.
* **Native Biblioshiny Extension**: 1-click reactive injection into the active `values$M` session inside `biblioshiny` or manual import of exported `.RData` files.

---

## Feature Comparison Matrix by Operating Mode

| Feature / Capability | Standalone Mode (`bibliolatam`) | Integrated Mode (`bibliolatam` + `bibliometrix`) |
|:---|:---:|:---:|
| **Requires `bibliometrix` installed?** | ❌ No (Only R + Shiny/jsonlite) | ✅ Yes (`bibliometrix` >= 4.0.0) |
| **Interactive Web Application** | ✅ `bibliolatam::run_app()` (Trilingual EN/PT/ES) | ✅ `biblioshiny` GUI |
| **Federated Online Search (Omnisearch)** | ✅ Yes (SciELO, BDTD, Oasisbr, LA Referencia) | ✅ Yes |
| **Local File Uploads (XML/CSV/RIS/BibTeX)** | ✅ Yes | ✅ Yes |
| **Cited References Extraction (`CR`)** | ✅ Yes (SciELO JATS XML) | ✅ Yes |
| **Regional Author Normalization** | ✅ Yes (`normalize_authors`) | ✅ Yes |
| **Cross-Database Deduplication & Fusion** | ✅ Yes (`merge_bibliolatam`) | ✅ Yes |
| **Direct CSV & .RData Exports** | ✅ Yes | ✅ Yes |
| **Bibliometric Analytics (`biblioAnalysis`, Bradford)** | ❌ Requires bibliometrix | ✅ Yes |
| **Co-citation & Coupling Networks (`biblioNetwork`)** | ❌ Requires bibliometrix | ✅ Yes |
| **Thematic Maps & Conceptual Structure** | ❌ Requires bibliometrix | ✅ Yes |

---

## Architecture & Data Flow

```text
[ Latin American & Iberian Repositories ]
├── SciELO          (Files: CSV, JATS XML | APIs: Crossref works, NLM XMLs)
├── BDTD / Oasisbr  (Files: CSV, TSV      | APIs: IBICT VuFind Solr)
├── LA Referencia   (APIs: VuFind REST v1 across 12 national networks)
├── Redalyc         (Files: BibTeX, RIS, CSV)
└── SPELL / ANPAD   (Files: CSV)
         │
         ▼
[ bibliolatam Engine (Independent) ]
├── REST Clients & Local Parsers (Pagination, defensive network handling)
├── Author Normalizer (Brazilian generational suffixes & Hispanic compound names)
├── Cross-Database Deduplication (Canonical DOI + fuzzy Levenshtein title matching)
└── Canonical Harmonizer (`as_bibliometrix`)
         │
         ├───▶ [ STANDALONE MODE (Without bibliometrix) ]
         │     ├── Dedicated Web App: `bibliolatam::run_app()` (Trilingual: EN, PT, ES)
         │     ├── Direct File Export: `.csv` and `.RData` files
         │     └── Data Manipulation: Base R / Tidyverse / Python / VOSviewer / Gephi
         │
         └───▶ [ INTEGRATED MODE (With bibliometrix) ]
               ├── Scientometric Analysis: `biblioAnalysis()`, Bradford, Lotka
               ├── Knowledge Networks: Co-citation (CR), Co-authorship, Coupling
               └── Biblioshiny Interface: Direct reactive injection into `values$M`
```

---

## Installation

Install the stable development version directly from GitHub:

```r
# Using remotes
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("BRAN-Org/bibliolatam")

# Or using pak
if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
pak::pkg_install("BRAN-Org/bibliolatam")
```

### Requirements & Dependencies

- **Mandatory for core**: R (>= 3.6.0), `jsonlite`, `utils`, `tools`.
- **For standalone interactive web GUI (`run_app()`)**: `shiny`.
- **For advanced scientometric modeling & networks (optional)**: `bibliometrix` (>= 4.0.0).

---

## Supported Sources & Access Methods

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

### Workflow 1: Standalone Trilingual Web Application

`bibliolatam` provides its own standalone interactive web application in Shiny. It does not require `bibliometrix` to run:

```r
library(bibliolatam)

# Launch the standalone interactive dashboard in your default browser
run_app()

# Or configure port and default interface language (en, pt, or es)
run_app(port = 7860, default_lang = "en")
```

**Standalone App Features:**
* **Real-Time Language Switcher**: Toggle dynamically between 🇬🇧 English, 🇧🇷 Portuguese, and 🇪🇸 Spanish in the navbar header without reloading the page or losing typed query parameters.
* **Omnisearch Panel**: Query SciELO, BDTD, Oasisbr, and LA Referencia simultaneously with date range bounds, source limits, and automated deduplication.
* **Dedicated Portals**: Targeted modules for SciELO (DOI/PID lookup or JATS XML parsing), BDTD (degree filters: master vs doctoral), Oasisbr, and Redalyc.
* **Collection Harmonizer**: Visual interface to merge two independent datasets and resolve duplicates via fuzzy string matching.
* **1-Click Export**: Download harmonized datasets directly as `.csv` or `.RData`.

---

### Workflow 2: Standalone Scripting (Without bibliometrix)

You can perform batch querying, data harvesting, and deduplication using only `bibliolatam` functions:

```r
library(bibliolatam)

# 1. Federated query across 4 repositories simultaneously
unified_data <- omnisearch_bibliolatam(
  query = "artificial intelligence health",
  sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
  limit_per_source = 50,
  years = c(2020, 2024),
  deduplicate = TRUE,
  progress = TRUE
)

# 2. Inspect record counts by provenance
table(unified_data$DB)

# 3. Export directly to CSV for analysis in Python, Excel, or VOSviewer
write.csv(unified_data, "latam_health_ai.csv", row.names = FALSE)
```

---

### Workflow 3: Integrated Mode with bibliometrix (Scientometric Modeling)

When `bibliometrix` is installed, every data frame produced by `bibliolatam` is natively recognized as a `bibliometrixDB` object:

```r
library(bibliolatam)
library(bibliometrix)

# Harvest SciELO journal articles enriched with cited references (CR)
scielo_corpus <- download_scielo_search(
  query = "dengue vaccine",
  limit = 40,
  years = c(2018, 2024),
  enrich_references = TRUE
)

# 1. Global bibliometric summary
analysis <- biblioAnalysis(scielo_corpus)
summary(analysis, k = 10)

# 2. Reference co-citation network (powered by JATS XML CR extraction)
cocit_net <- biblioNetwork(
  scielo_corpus,
  analysis = "co-citation",
  network = "references",
  sep = ";"
)
networkPlot(cocit_net, n = 30, type = "fruchterman", size = TRUE)

# 3. Author collaboration network
collab_net <- biblioNetwork(
  scielo_corpus,
  analysis = "collaboration",
  network = "authors",
  sep = ";"
)
networkPlot(collab_net, n = 30, type = "sphere", Title = "Co-authorship")
```

---

### Workflow 4: Integrated Mode in Biblioshiny

You can bridge `bibliolatam` into `biblioshiny` using two complementary approaches:

1. **Exporting `.RData` for Manual Import**:
   ```r
   export_biblioshiny(unified_data, "my_collection.RData")
   ```
   Launch `biblioshiny::biblioshiny()`, navigate to *Data -> Load bibliometrix RData*, and select the exported file.

2. **Native Biblioshiny Extension Panels**:
   When `bibliolatam` is installed in your R library, its regional modules (`scieloUI`, `bdtdUI`, `omnisearchUI`) become accessible inside `biblioshiny` to push harvested data directly into the active `values$M` session without saving intermediate files.

---

## Analytics Compatibility & Known Data Limitations

Because Latin American repositories are managed by distinct public institutions with different indexing practices, not all metadata fields present in commercial databases (WoS/Scopus) are available across all regional sources.

Here is the exact compatibility matrix with `bibliometrix` routines:

| Analytical Module | Required Tags | Supported Regional Sources | Practical Behavior & Status |
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
  - **Sample Fixtures (`inst/extdata/`)**: [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/) - For academic validation and testing only, with anti-AI commercial scraping clauses.

---

## Citation

If you use `bibliolatam` in your research or scientometric workflows, please cite:

```bibtex
@manual{bibliolatam2026,
  title  = {bibliolatam: Latin American Bibliographic Data Parsers for 'bibliometrix'},
  author = {Gama, Gabriel and {BRAN Org}},
  year   = {2026},
  note   = {R package version 1.0.0},
  url    = {https://github.com/BRAN-Org/bibliolatam},
  doi    = {10.5281/zenodo.23623700}
}
```
