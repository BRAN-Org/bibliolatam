# TODO - bibliolatam

## Parsers & Data Adapters
- [x] SPELL / ANPAD parser (`read_spell`)
- [x] SciELO tabular CSV parser (`read_scielo`)
- [x] SciELO NLM/JATS XML parser (`read_scielo_jats`) with Cited References (`CR`) extraction
- [x] Direct automated XML retrieval helper (`download_scielo_jats`): download raw XMLs from official SciELO endpoints by vector of DOIs or PID article identifiers
- [x] BDTD / Oasisbr tabular and OAI-PMH thesis/dissertation parser (`read_bdtd` / `read_oasisbr`)
- [ ] Redalyc metadata parser (`read_redalyc`)
- [ ] LA Referencia regional aggregator parser (`read_lareferencia`)

## Core Features & Workflow Integrations
- [x] Canonical `as_bibliometrix()` converter enforcing `bibliometrixDB` class contract
- [x] Standalone Brazilian/Hispanic author normalizer (`normalize_authors`) with generational suffixes and particles
- [x] Web GUI exporter (`export_biblioshiny`) creating loadable `.RData` objects
- [ ] OpenAlex / Crossref live metadata reconciliation helper for Latin American repositories

## Developer Tooling & Agent Guidelines
- [ ] Create `AGENTS.md`: repository architecture, code standards, and execution protocols for AI coding agents

