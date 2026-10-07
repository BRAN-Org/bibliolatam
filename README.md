# bibliolatam

`bibliolatam` is an R companion package that bridges Latin American open-access scientific repositories with bibliometric workflows in [`bibliometrix`](https://github.com/massimoaria/bibliometrix).

## Motivation

Mainstream bibliometric tools primarily support global multidisciplinary indexes (Scopus, Web of Science, PubMed). In Latin America, regional science is published extensively under Diamond Open Access platforms (SciELO, SPELL, Redalyc) and curated in national and regional repository networks (such as BDTD/Oasisbr in Brazil and LA Referencia across 12 countries).

Because `bibliometrix` core limits its built-in converters to global commercial databases (see [bibliometrix issue #689](https://github.com/massimoaria/bibliometrix/issues/689)), `bibliolatam` provides external adapters. It ingests export files and API payloads from Latin American repositories and converts them into standard `bibliometrixDB` data frames.

## Supported Databases & Features

| Database / Source | Typology | Ingestion Mode | Key Capabilities |
|:---|:---|:---|:---|
| **SciELO** | Journal Articles | File (`read_scielo`, `read_scielo_jats`) & API (`download_scielo_search`, `download_scielo_jats`) | Cited references (`CR`) via JATS XML, DOI search via Crossref |
| **BDTD** | Theses & Dissertations | File (`read_bdtd`) & REST API (`download_bdtd`) | Academic advisors (`RP`), degrees (`DT`), IBICT VuFind Solr pagination |
| **Oasisbr** | Multidisciplinary Repositories | File (`read_oasisbr`) & REST API (`download_oasisbr`) | National open-access research outputs, typology mapping |
| **Redalyc / AmeliCA** | Diamond OA Journals | File (`read_redalyc`) | BibTeX (`.bib`), RIS (`.ris`), and CSV exports with Hispanic author normalizer |
| **LA Referencia** | 12 Latin American Countries | REST API (`download_lareferencia`) | Regional federation across national repository networks |
| **SPELL (ANPAD)** | Business & Economics | File (`read_spell`) | Brazilian management and economics tabular exports |
| **Omnisearch** | Federated Discovery | `omnisearch_bibliolatam` & Shiny UI | Concurrent multi-base search, API year filtering, automated deduplication |

---

## Quickstart & Examples

### 1. Offline File Ingestion

Export files from the official portals and load them into `bibliometrix`:

```r
library(bibliolatam)
library(bibliometrix)

# Read SciELO CSV or NLM/JATS XML (extracts cited references for co-citation networks)
df_scielo <- read_scielo("scielo_export.csv")
# Or full JATS XML:
df_jats <- read_scielo_jats("article.xml")

# Read BDTD theses and dissertations
df_bdtd <- read_bdtd("bdtd_export.csv")

# Read Redalyc (BibTeX, RIS, or CSV)
df_redalyc <- read_redalyc("redalyc_export.bib")

# Read SPELL management literature
df_spell <- read_spell("spell_export.csv")

# Run bibliometrix analysis
results <- biblioAnalysis(df_scielo)
summary(results)
```

### 2. Automated Online Retrieval via REST APIs

Retrieve bibliographic records directly from R without manual file downloads:

```r
library(bibliolatam)

# Search Brazilian theses and dissertations on BDTD (2020 to 2024)
theses <- download_bdtd("inteligencia artificial", limit = 50, years = c(2020, 2024))

# Search SciELO journal articles with optional Cited References (CR) enrichment
articles <- download_scielo_search("dengue vacina", limit = 30, enrich_references = TRUE)

# Search LA Referencia repository network across 12 countries
regional <- download_lareferencia("educacion ambiental", limit = 50, years = c(2018, 2023))
```

### 3. Federated Latin American Omnisearch

Query all databases simultaneously, with automated cross-database deduplication:

```r
library(bibliolatam)

# Query SciELO, BDTD, Oasisbr, and LA Referencia simultaneously
omni_results <- omnisearch_bibliolatam(
  query = "energia solar",
  sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
  limit_per_source = 25,
  years = c(2019, 2024),
  deduplicate = TRUE
)

# Export directly for biblioshiny web GUI
export_biblioshiny(omni_results, "energia_solar_latin_america.RData")
```

### 4. Interactive Biblioshiny Integration

`bibliolatam` ships with modular Shiny panels that mount directly into `biblioshiny` under the **Bibliolatam** sidebar menu:
- **Omnisearch**: Federated multi-source discovery, date filtering, live metric cards, CSV download, and 1-click loading into the active `biblioshiny` session.
- **Dedicated Portals**: SciELO, BDTD, Oasisbr, Redalyc, and Collection Merge.

---

## Principles & License

- **[FAIR Principles](https://www.gofair.foundation/fair-principles)**: Focus on making Latin American scientific literature Findable, Accessible, Interoperable, and Reusable.
- **[BOAI](https://www.budapestopenaccessinitiative.org/)**: Committed to Diamond Open Access and open scientific communication.
- **Dual Licensing**:
  - **Source Code**: [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html).
  - **Metadata Fixtures (`inst/extdata/`)**: [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/).
