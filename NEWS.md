# bibliolatam (development version)

- **Initial repository structure and governance**: Scaffolded package infrastructure, dual licensing (GPL-3.0 for code and CC BY-NC-SA 4.0 for scientometric fixtures), and standard BRAN Org community health files.
- **R CMD check hygiene and build flags**: Added `.Rbuildignore` to strip top-level repo metadata (`.github/`, docs, changelog, licensing files) from the R build tarball, preventing non-standard file warnings.
- **Base converter `as_bibliometrix()`**: Introduced canonical converter enforcing the `bibliometrixDB` class contract. Validates essential fields (`AU`, `TI`, `SO`, `PY`), coerces numerical tags (`PY`, `TC`), and injects standard WoS-like tags missing in source files as `NA` without data fabrication.
- **SPELL / ANPAD parser `read_spell()`**: Added resilient parser for Brazilian administration and economics exports (CSV). Supports automatic delimiter detection (`;`, `,`, `\t`), encoding fallback (UTF-8 to Latin-1), and normalizes author names to the standard WoS format (`SOBRENOME INICIAIS; ...`).
