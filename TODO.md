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
- [x] **Passo 2 (Testes Adversariais Massivos e Benchmark Empírico)**:
  - Bateria de testes adversariais em `test-adversarial_merge_benchmark.R` com sequências de 4 partes, inversão de autores e sufixos ordinais.
  - Benchmark de matriz de confusão automatizado com 50 duplicatas reais versus 50 armadilhas adversariais atingindo FPR = 0,0% e Recall = 100%.
  - Expansão de abreviações de séries (`vol` -> `volume`, `pt` -> `parte`, `sec` -> `secao`) em `normalize_title_str()`.
- [x] **Passo 3 (Otimização Assintótica para Grandes Coleções em `merge_bibliolatam`)**:
  - Filtro matemático de extensão de string (*Length Bound Filter*, $O(1)$) baseado na desigualdade triangular de Levenshtein ($\lceil |t_1| \theta \rceil \le |t_2| \le \lfloor |t_1| / \theta \rfloor$), podando de 80% a 90% dos candidatos em nanossegundos.
  - Atalho de igualdade exata pré-Levenshtein (*Exact Match Fast-Path*, $O(1)$) com priorização de autores compatíveis, proporcionando speedup de mais de 200x para títulos idênticos.
  - Bloqueio por palavras de conteúdo significativas (*Significant Content Word Canopy*) para coleções densas de candidatos (> 15).
- [ ] **Passo 4 (Polimento da Aplicação Shiny `run_app()` & Módulos UI/Server)**:
  - [x] **Corrigir botão de recolher painel no Omnisearch (`R/shiny_omnisearch.R`)**: Substituído `shiny::removeUI(selector = "#omnisearchContent", immediate = TRUE)` por animação reversível via jQuery `slideToggle(300)` com `data-i18n-title="btn_collapse"` e 61 testes unitários em `test-shiny_omnisearch.R`.
  - [ ] **Completar cobertura trilíngue (i18n) nos rótulos internos das abas secundárias (`R/shiny_bdtd.R`, `R/shiny_oasisbr.R`, `R/shiny_redalyc.R`, `R/shiny_merge.R`)**: Mapear banners informativos, títulos dos cartões KPI (`TOTAL WORKS`, `TIMESPAN`, etc.), opções de filtro (`radioButtons`/`selectInput`) e botões de exportação com `bl_i18n()` e atributos `data-i18n` em `R/i18n.R`.
  - [ ] **Adicionar busca online por palavra-chave na aba dedicada SciELO (`scieloUI` / `scieloServer` em `R/shiny_scielo.R`)**: Integrar `download_scielo_search()` na aba SciELO (além da busca atual por lista de DOIs/PIDs via `download_scielo_jats()`), permitindo busca textual direta com filtro de ano e enriquecimento opcional de referências citadas (`CR`).
  - [ ] **Expor upload explícito para arquivos SPELL / ANPAD (`read_spell`) na interface gráfica (`run_app()`)**: Adicionar aba dedicada ou seletor explícito de upload para exportações CSV do SPELL com pré-visualização, cartões de resumo e exportação.
- [ ] **Passo 5 (Expansão da Cobertura Ibero-Americana 100% — Superação das Limitações 1, 2 e 3)**:
  - [ ] **Limitação 1 — Busca Online Multi-País no SciELO (`download_scielo_search.R`)**:
    - Expandir o filtro `filter=prefix:...` na API do Crossref (atualmente restrito ao prefixo `10.1590` do SciELO Brasil) para incluir os prefixos DOI das demais coleções nacionais da Rede SciELO:
      - SciELO Brasil / Saúde Pública: `10.1590`
      - SciELO Chile (ANID): `10.4067`
      - SciELO Espanha (ISCIII): `10.4321`
      - SciELO Costa Rica (UCR): `10.15517`
      - SciELO Peru: `10.17843`
      - SciELO Uruguai: `10.26461`
    - Adicionar parâmetro opcional `collections` / `prefixes` em `download_scielo_search()` para permitir buscar em toda a rede SciELO ibero-americana simultaneamente ou filtrar por país específico.
  - [ ] **Limitação 2 — Desenhar Solução de Busca Online para Redalyc/AmeliCA e SPELL (além de arquivo local)**:
    - Estudar e arquitetar estratégia para integrar Redalyc/AmeliCA e SPELL na descoberta online (`omnisearch_bibliolatam`), avaliando:
      - Resolução via **OpenAlex REST API / Crossref** filtrada por conjunto de ISSNs indexados no Redalyc/AmeliCA e SPELL; ou
      - Coleta via endpoints **OAI-PMH** / APIs públicas disponíveis nessas plataformas sem violar rate-limits.
  - [ ] **Limitação 3 — Desenhar Solução para Fontes Complementares e Especializadas (Dialnet, Biblat/CLASE, LILACS/PePSIC e Latindex)**:
    - Projetar arquitetura de cobertura para as bases regionais e disciplinares que ainda não possuem conector dedicado:
      - **Dialnet (Espanha / Ibero-América)** e **Biblat / CLASE / PERIÓDICA (UNAM - México)**: Criar parsers dedicados (`read_dialnet`, `read_biblat`) para exportações RIS/BibTeX/CSV e avaliar busca automatizada via OAI-PMH / OpenAlex.
      - **LILACS (BVS / BIREME)** e **PePSIC**: Criar parser dedicado (`read_lilacs`) para exportações RIS/CSV da BVS e investigar integração com a API/formato de busca iAHx da BVS.
      - **Latindex (Diretório e Catálogo 2.0)**: Projetar módulo de enriquecimento/validação de periódicos por ISSN (`SN`) para identificar e classificar revistas ibero-americanas de Acesso Aberto Diamante dentro de coleções `bibliometrixDB`.
- [ ] **Passo 6 (Menu de Configurações / Settings & Diagnóstico na Tela Inicial `run_app()` — Proposta em Análise)**:
  - [ ] **6.1. Arquitetura de Estado & Conformidade CRAN (Sem escrita em `~/`)**:
    - Criar container reativo `settings <- shiny::reactiveValues(...)` injetado nos módulos Server do `run_app()`, com persistência opcional apenas via `localStorage` no navegador (client-side) e suporte em scripts via `options(bibliolatam.*)`.
  - [ ] **6.2. Configurações de Rede & APIs (Network & Polite Pool)**:
    - Timeout HTTP global configurável (`15s` a `120s`, padrão `30s`) para lidar com lentidão intermitente do IBICT/Oasisbr.
    - Campo opcional de e-mail para o **Crossref Polite Pool** (`mailto:` no `User-Agent`, melhorando taxa e prioridade na API do SciELO/Crossref).
    - Número de retentativas em falhas transitórias (`1` a `5`, padrão `3`) e botão **"Verificar Status das APIs"** (ping leve em SciELO/Crossref, BDTD, Oasisbr e LA Referencia com indicador verde/vermelho).
  - [ ] **6.3. Padrões de Busca, Normalização & Deduplicação**:
    - Limite padrão de registros por fonte (`20`, `50`, `100`, `200`, `500`) e coleções SciELO padrão ativas (BR, CL, ES, CR, PE, UY).
    - Limiar padrão de similaridade de títulos (`similarity_threshold`: `0.85`–`0.98`, padrão `0.90`) e toggle global de normalização onomástica luso-hispânica (`normalize_authors`).
  - [ ] **6.4. Exportação & Reprodutibilidade Científica (FAIR)**:
    - Escolha do separador CSV padrão (`,` internacional vs. `;` para Microsoft Excel PT/ES) e opção de codificação **UTF-8 com BOM** (evita acentos corrompidos no Excel).
    - Toggle para espelhamento `DE -> ID` quando `ID` (Keywords Plus) estiver ausente.
    - Gerador de **Código R Reprodutível** correspondente à busca executada na GUI (para colar em scripts/artigos científicos).
  - [ ] **6.5. Gerenciamento de Sessão & Cabeçalho da Tela Inicial**:
    - Indicador discreto de coleção ativa no cabeçalho (ex.: contagem de registros em `values$M`), botão de acesso rápido **Settings** (aba dedicada ou modal), botão **"Resetar Padrões"**, botão **"Limpar Sessão Ativa"** e painel de diagnóstico do ambiente (versão R, `bibliolatam` e detecção de `bibliometrix`).
- [ ] OpenAlex Latin American harvester backend
- [ ] Canopy clustering e string distance heuristics para desambiguação avançada de autores
- [ ] Automated co-citation and bibliographic coupling graph export for Gephi / Pajek
