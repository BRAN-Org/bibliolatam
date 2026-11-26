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
- [x] **Passo 4 (Polimento da Aplicação Shiny `run_app()` & Módulos UI/Server)**:
  - [x] **Corrigir botão de recolher painel no Omnisearch (`R/shiny_omnisearch.R`)**: Substituído `shiny::removeUI(selector = "#omnisearchContent", immediate = TRUE)` por animação reversível via jQuery `slideToggle(300)` com `data-i18n-title="btn_collapse"` e 61 testes unitários em `test-shiny_omnisearch.R`.
  - [x] **Completar cobertura trilíngue (i18n) nos rótulos internos das abas secundárias (`R/shiny_bdtd.R`, `R/shiny_oasisbr.R`, `R/shiny_redalyc.R`, `R/shiny_merge.R`)**: Mapear banners informativos, títulos dos cartões KPI (`TOTAL WORKS`, `TIMESPAN`, etc.), opções de filtro (`radioButtons`/`selectInput`) e botões de exportação com `bl_i18n()` e atributos `data-i18n` em `R/i18n.R`.
  - [x] **Adicionar busca online por palavra-chave na aba dedicada SciELO (`scieloUI` / `scieloServer` em `R/shiny_scielo.R`)**: Integrar `download_scielo_search()` na aba SciELO (além da busca atual por lista de DOIs/PIDs via `download_scielo_jats()`), permitindo busca textual direta com filtro de ano e enriquecimento opcional de referências citadas (`CR`).
  - [x] **Expor upload explícito para arquivos SPELL / ANPAD (`read_spell`) na interface gráfica (`run_app()`)**: Adicionar aba dedicada (`spellUI` / `spellServer` em `R/shiny_spell.R`) para exportações CSV/TSV do SPELL com pré-visualização, cartões KPI de resumo e exportação.
- [ ] **Passo 5 (Expansão da Cobertura Ibero-Americana 100% — Superação das Limitações 1, 2 e 3)**:
  - [x] **Limitação 1 — Busca Online Multi-País no SciELO (`download_scielo_search.R`)**:
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
- [ ] **Passo 7 (Busca Multilíngue Automática / Cross-Lingual Query Expansion PT <-> ES <-> EN)**:
  - Permitir que o pesquisador informe uma palavra-chave ou tema em **um único idioma** (ex.: `"saude publica"`) e ative a expansão multilíngue automática para buscar simultaneamente o mesmo conceito em **Português, Espanhol e Inglês** (ex.: `"saude publica" OR "salud publica" OR "public health"`) sem precisar repetir a busca manualmente em 3 idiomas.
  - Avaliar fontes abertas e reprodutíveis para resolução conceitual trilíngue (sem chaves pagas e 100% compatível com CRAN):
    - **Vocabulários controlados abertos**: API **DeCS/MeSH** (BIREME/OPAS), **Tesauro da UNESCO** (SKOS) e **OpenAlex Topics/Concepts / Wikidata** (mapeamento nativo PT/ES/EN por conceito científico).
    - **Transparência & Reprodutibilidade (FAIR)**: Exibir e permitir edição dos termos expandidos na interface (`omnisearchUI` / *Advanced Settings*) e registrar a query booleana expandida nos atributos do objeto `bibliometrixDB` para auditoria científica.
- [x] **Passo 8 (Auditoria Científica: Blindagem Anti-Falso Positivo Residual, Normalização Hispânica & Transparência Metodológica)**:
  - [x] **Achado #1 — Conflito explícito de DOIs distintos no Passo 2 (`R/merge_bibliolatam.R`)**: Bloquear o matching aproximado por título sempre que **ambos** os registros possuírem DOI válido não-vazio e `dois1[i] != dois2[c_idx]` (evitando fundir artigo + errata/comentário ou tese com DOI institucional + artigo publicado derivado com DOI de periódico).
  - [x] **Achado #2 — Transparência metodológica para imputação `TC = 0` e espelhamento `ID <- DE` (`R/as_bibliometrix.R`)**: Documentar explicitamente em `vignettes/introduction-to-bibliolatam.Rmd`, na aba *About* (`R/shiny_info.R`) e na seção de Metodologia do artigo que `df$TC[is.na(df$TC)] <- 0` é convenção técnica de compatibilidade com `bibliometrix` (em bases sem índice de citações como BDTD, Oasisbr, LA Referencia e SPELL significa *"citação não indexada nesta fonte"*, e não *"zero citações reais"*) e que `df$ID <- df$DE` espelha *Author Keywords* em *Keywords Plus* quando ausente.
  - [x] **Achado #3 — Fusão Tese/Dissertação vs. Artigo homônimo (`DT`) & Deduplicação intra-fonte (`R/merge_bibliolatam.R`, `R/omnisearch_bibliolatam.R`)**:
    - Adicionar guardrail (padrão ou configurável) de compatibilidade de Tipo Documental (`DT`) para não fundir automaticamente `THESIS`/`DISSERTATION` com `ARTICLE` homônimos quando ambos estiverem declarados e sem DOI em comum (mesmo com `|PY1 - PY2| <= 1`).
    - Implementar deduplicação intra-fonte antes do `Reduce(merge_bibliolatam, results_list)` em `omnisearch_bibliolatam()` para eliminar registros já duplicados dentro de uma mesma fonte (comum em Oasisbr e LA Referencia quando um trabalho está espelhado em múltiplos repositórios universitários).
  - [x] **Achado #4 — Sobrenomes compostos hispânicos sem vírgula (`R/normalize_authors.R`)**: Aprimorar a heurística para nomes retornados sem vírgula pelas APIs (ex.: `"Gabriel García Márquez"` atualmente vira `"MÁRQUEZ GG"` em vez de preservar o sobrenome composto como em `"García Márquez, Gabriel"` -> `"GARCÍA MÁRQUEZ G"`), evitando fragmentação de autores hispano-americanos entre bases heterogêneas.
  - [x] **Testes adversariais de regressão (`test-merge_bibliolatam.R`, `test-adversarial_merge_benchmark.R`, `test-author_normalization.R`)**: Cobrir pares com DOIs divergentes + título idêntico, tese vs. artigo homônimo, duplicatas intra-fonte e variações com/sem vírgula de sobrenomes compostos hispânicos.
- [ ] **Passo 9 (Auditoria de Inclusividade Multilíngue & Otimização de Estágios em `merge_bibliolatam`)**:
  - [x] **Reordenação dos filtros $O(1)$ antes do loop onomástico (`R/merge_bibliolatam.R`)**: Antecipar o *Length-Bound Filter* vetorizado, o *Exact Match Fast-Path* e o *Content Word Canopy* para antes da verificação `surnames_compatible()` (`utils::adist`), reduzindo o tempo em lotes densos sem DOI em ~28,5x com equivalência exata de resultados.
  - [x] **Marcadores de séries acadêmicas em espanhol seguidos de subtítulo (`R/merge_bibliolatam.R`)**: Expandir a regex de `extract_part_token()` (antes restrita a PT/EN `parte|part|volume|vol|secao|section|fase|phase|ensaio`) para reconhecer `volumen`, `seccion`, `tomo`, `entrega` e `capitulo` mesmo quando seguidos de subtítulo (`", Volumen I: analisis regional"` vs `", Volumen II: analisis regional"`).
  - [x] **Prefixos onomásticos não-distintivos hispânicos e sufixos isolados (`R/merge_bibliolatam.R`)**: Filtrar `san`, `santa`, `santo`, `sao`, `van`, `von` e sufixos agnáticos mal formatados em `extract_author_surnames()`, impedindo falso match pelo sub-token de 3 letras `"SAN"` entre autores disjuntos (ex.: `SAN MARTÍN J` vs `SAN ROMÁN F`, `SANTA CRUZ R` vs `SANTA MARÍA T`).
  - [ ] **Títulos bilíngues concatenados no OAI-PMH sem DOI (`R/merge_bibliolatam.R`)**: Tratar registros de repositórios DSpace/VuFind (ex.: Oasisbr, RCAAP, LA Referencia) que concatenam dois idiomas no mesmo campo `TI` (`"Título em Português / English Title"` ou `"Título = English Title"`), evitando que o dobro de comprimento ($L_2 \approx 2L_1$) cause descarte imediato no *Length-Bound Filter* quando não há DOI.
  - [ ] **Colisão translinguística de cognatos próximos `PT <-> ES` em artigos distintos (`R/merge_bibliolatam.R`)**: Adicionar guardrail morfológico de idioma (`LA` / marcadores exclusivos `ção/ções/nh/lh` vs `ción/ciones/ñ/del/los`) para impedir fusão sem DOI entre dois artigos distintos (um em português e outro em espanhol sobre tema cognato com $>90\%$ de similaridade lexical) publicados por autores distintos com sobrenomes ibéricos irmãos (`RODRIGUES` vs `RODRÍGUEZ`, `GOMES` vs `GÓMEZ`, `SILVA` vs `SILVA`).
- [ ] OpenAlex Latin American harvester backend
- [ ] Canopy clustering e string distance heuristics para desambiguação avançada de autores
- [ ] Automated co-citation and bibliographic coupling graph export for Gephi / Pajek
