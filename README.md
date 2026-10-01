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

## License

This project is licensed under a dual structure:
- Source code is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.
- Sample datasets and scientometric metadata fixtures are licensed under **CC BY-NC-SA 4.0**.