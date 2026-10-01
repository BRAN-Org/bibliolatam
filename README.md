# bibliolatam

`bibliolatam` is an R companion package designed to bridge the gap between Latin American open-access scientific repositories and bibliometric workflows in [`bibliometrix`](https://github.com/massimoaria/bibliometrix).

## Motivation

Mainstream bibliometric tools primarily support global multidisciplinary indexes (Scopus, Web of Science, Dimensions, PubMed). In Latin America, high-impact regional science is published extensively under Diamond Open Access platforms (SciELO, SPELL, Redalyc) and archived in national dissertation repositories (such as BDTD/Oasisbr in Brazil and LA Referencia regionally).

Because `bibliometrix` core deliberately limits its built-in converters to global multidisciplinary databases to keep maintenance manageable (see [bibliometrix issue #689](https://github.com/massimoaria/bibliometrix/issues/689)), `bibliolatam` serves as an external adapter. It parses export files and API payloads from Latin American repositories and transforms them directly into standard `bibliometrixDB` data frames.

## Scope & Target Databases

The project focuses on parsing and mapping metadata into standard WoS/Scopus-like field tags (`AU`, `TI`, `SO`, `PY`, `DE`, `AB`, `C1`, `RP`, `CR`, `TC`, `DI`, `DT`):

- **SciELO**: Direct file exports (CSV, BibTeX, XML JATS) and OpenAlex-assisted collections.
- **SPELL (ANPAD)**: Business, Public Administration, and Economics literature.
- **BDTD / Oasisbr**: Brazilian theses and dissertations via tabular exports and OAI-PMH.
- **Redalyc & LA Referencia**: Regional journal networks and federated institutional repositories across Latin America (planned).

## Planned Workflow

```r
library(bibliolatam)
library(bibliometrix)

# Read and parse exported files from regional portals
df_spell <- read_spell("spell_export.csv")

# Convert to a bibliometrix-compatible object
M <- as_bibliometrix(df_spell, dbsource = "spell")

# Run bibliometrix analysis directly
results <- biblioAnalysis(M)
summary(results)
```

## Repository Structure

- `R/`: Core parsing and data adaptation functions.
- `inst/extdata/`: Minimal, curated export samples for automated unit testing.
- `tests/testthat/`: Test suites ensuring schema compatibility with `bibliometrix`.

## Principles & License

- **[FAIR Principles](https://www.go-fair.org/fair-principles/)**: Focus on making Latin American scientific literature Findable, Accessible, Interoperable, and Reusable.
- **[BOAI](https://www.budapestopenaccessinitiative.org/)**: Committed to Diamond Open Access and open scientific communication.
- **Dual Licensing**:
  - **Source Code**: [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html) — Guarantees software freedom and prevents proprietary closures.
  - **Sample Datasets & Metadata Fixtures (`inst/extdata/`)**: [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/) — For academic research and validation only; unauthorized bulk ingestion for training commercial AI models without prior consent is prohibited.