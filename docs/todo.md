# To-Do — bibliolatam

## Fase 1: Fundação & SPELL
- [x] Construtor canônico `as_bibliometrix()`
- [x] Validação de campos essenciais mínimos (`AU`, `TI`, `SO`, `PY`)
- [x] Injeção de tags padrão ISI/WoS ausentes como `NA_character_` (sem inferência)
- [x] Coerção segura de tipos (`PY`, `TC` como numéricos)
- [x] Atribuição de classe `c("bibliometrixDB", "data.frame")` e atributo `dbsource`
- [x] Testes unitários do construtor (`tests/testthat/test-as_bibliometrix.R`)
- [x] Parser SPELL / ANPAD (`read_spell`)
- [x] Função auxiliar `export_biblioshiny()` para salvar `.RData` compatível (variável canônica `M`)
- [x] Teste de isolamento de carga simulando consumo do `biblioshiny` via `load()`

---

## Fase 2: SciELO, BDTD, Oasisbr, Redalyc & Federação
- [x] Parser SciELO Tabular (`read_scielo`)
- [x] Parser SciELO JATS XML (`read_scielo_jats`) com extração de `CR`
- [x] Cliente de busca SciELO via Crossref (`download_scielo_search`)
- [x] Cliente direto de download SciELO JATS XML (`download_scielo_jats`)
- [x] Parsers e clientes de API para teses/dissertações IBICT (`read_bdtd`, `download_bdtd`, `read_oasisbr`, `download_oasisbr`)
- [x] Parser para Redalyc / AmeliCA (`read_redalyc`)
- [x] Cliente regional LA Referencia (`download_lareferencia`)
- [x] Motor federado Omnisearch (`omnisearch_bibliolatam`)
- [x] Motor de fusão e desduplicação cruzada de metadados (`merge_bibliolatam`)

---

## Fase 3: Interface Gráfica & Aplicação Standalone
- [x] Módulos de interface para cada repositório (`scieloUI`, `bdtdUI`, `oasisbrUI`, `redalycUI`, `bibliolatamMergeUI`, `omnisearchUI`, `bibliolatamInfoUI`)
- [x] Módulos de servidor resilientes com fallback para execução fora do `biblioshiny` (`values = NULL`)
- [x] Lançador oficial da aplicação standalone interativa (`run_app()`)
- [x] Exportação de dados direta para `.csv` e `.RData`

---

## Fase 4: Prontidão para Submissão ao CRAN
- [x] Harmonização e conformidade estrita de metadados no `DESCRIPTION` (`Imports`, `Description`, `Authors@R`, `Version 1.0.0`)
- [x] Vetorização completa de `normalize_authors()` para vetores de texto arbitrários
- [x] Seção `\examples{}` completa e executável em 100% das funções exportadas
- [x] Seção `\value{}` / `@return` adicionada em todas as funções Shiny Server
- [x] Sanitização de caracteres acentuados corrompidos (mojibake)
- [x] Elaboração do `cran-comments.md` documentando ambientes de teste e resultados de check
- [x] Elaboração de vignette instrutiva em `vignettes/introduction-to-bibliolatam.Rmd`

---

## Fase 5: Internacionalização (i18n) & Suporte Trilíngue
- [x] Módulo central de internacionalização (`R/i18n.R`) com suporte a Inglês (`en`), Português (`pt`) e Espanhol (`es`)
- [x] Seletor dinâmico de idiomas no cabeçalho do `run_app()` com preservação do estado de formulários
- [x] Parametrização `lang` em todos os componentes de UI (`scieloUI`, `bdtdUI`, `oasisbrUI`, etc.)
- [x] Documentação completa em Espanhol (`README.es.md`) e badges trilíngues de navegação em todos os READMEs
- [x] Suíte de testes automatizados para internacionalização (`test-i18n.R`) com 391 testes aprovados

---

## Fase 6: Polimento da Aplicação Shiny (`run_app()`) & UX
- [x] Corrigir botão de recolher painel no Omnisearch (`R/shiny_omnisearch.R`), substituindo `shiny::removeUI(selector = "#omnisearchContent")` por `slideToggle(300)` reversível (com 61 testes unitários)
- [x] Completar cobertura 100% trilíngue (i18n) nos rótulos internos, banners, cartões KPI e seletores das abas `bdtdUI`, `oasisbrUI`, `redalycUI` e `bibliolatamMergeUI`
- [x] Integrar busca online por palavra-chave (`download_scielo_search()`) na aba dedicada SciELO (`scieloUI` / `scieloServer`), além da busca por lista de DOIs/PIDs
- [x] Expor upload e pré-visualização explícita para arquivos CSV do SPELL / ANPAD (`read_spell()` via `spellUI` / `spellServer`) na interface gráfica do `run_app()`

---

## Fase 7: Expansão da Cobertura Ibero-Americana 100% (Limitações 1, 2 e 3)
- [x] **Limitação 1 (Busca Online SciELO Multi-País)**: Expandir `download_scielo_search()` além do prefixo `10.1590` (Brasil), adicionando os prefixos DOI de SciELO Chile (`10.4067`), SciELO Espanha/ISCIII (`10.4321`), SciELO Costa Rica (`10.15517`), SciELO Peru (`10.17843`) e SciELO Uruguai (`10.26461`)
- [ ] **Limitação 2 (Busca Online para Redalyc/AmeliCA e SPELL)**: Arquitetar solução para consulta online dessas fontes no `omnisearch_bibliolatam()` (ex.: filtragem por lista de ISSNs via OpenAlex/Crossref ou endpoints OAI-PMH)
- [ ] **Limitação 3 (Fontes Complementares e Especializadas)**: Projetar solução dedicada para **Dialnet**, **Biblat (CLASE / PERIÓDICA)**, **LILACS (BVS) / PePSIC** (parsers nativos e/ou conectores de busca) e **Latindex** (enriquecimento e classificação de periódicos por ISSN `SN`)

---

## Fase 8: Menu de Configurações (`Settings`) & Diagnóstico na Tela Inicial (`run_app()`)
- [ ] **Arquitetura CRAN-safe**: Estado reativo `settings` + persistência opcional via `localStorage` no navegador e `options(bibliolatam.*)` (zero escrita no disco do usuário)
- [ ] **Rede & APIs**: Timeout HTTP global (`15s`–`120s`), e-mail do usuário para *Crossref Polite Pool*, controle de retentativas e botão *"Verificar Status das APIs"*
- [ ] **Padrões de Busca & Merge**: Limite padrão por base, coleções SciELO ativas (BR/CL/ES/CR/PE/UY), limiar de similaridade (`similarity_threshold`) e toggle global de `normalize_authors`
- [ ] **Exportação & Reprodutibilidade**: Separador CSV (`,` vs `;`), opção UTF-8 com BOM para Excel, toggle de espelhamento `DE -> ID` e gerador de snippet de código R reproduzível
- [ ] **Sessão & Cabeçalho**: Indicador de coleção ativa (`values$M`), botão **Settings**, *"Resetar Padrões"*, *"Limpar Sessão"* e diagnóstico do ambiente (R, `bibliolatam`, `bibliometrix`)
---

## Fase 9: Busca Multilíngue Automática (Cross-Lingual Query Expansion PT <-> ES <-> EN)
- [ ] Projetar motor de expansão multilíngue de consultas (`expand_query_multilingual()`), permitindo digitar um termo em um único idioma (ex.: Português) e consultar automaticamente o tema equivalente em **Português, Espanhol e Inglês** nas bases federadas do `omnisearch_bibliolatam()`
- [ ] Avaliar integração com vocabulários controlados abertos (**DeCS/MeSH**, **Tesauro UNESCO**, **OpenAlex/Wikidata**) com pré-visualização editável dos termos expandidos na gaveta *Advanced Settings* do Omnisearch para garantir transparência e reprodutibilidade científica

## Fase 10: Auditoria Científica — Blindagem Anti-Falso Positivo, Normalização Hispânica & Transparência Metodológica
- [x] **Achado #1 — Conflito explícito de DOIs distintos (`R/merge_bibliolatam.R`)**: No bloco 2.1 do Passo 2 (matching por título), bloquear a fusão sempre que ambos os registros tiverem DOI válido não-vazio e `dois1[i] != dois2[c_idx]` (evitando fundir artigo + errata/comentário ou tese com DOI institucional + artigo derivado)
- [x] **Achado #2 — Transparência metodológica de `TC = 0` e `ID <- DE` (`R/as_bibliometrix.R`, vinheta e aba *About*)**: Documentar explicitamente que `TC = 0` em fontes sem índice de citações (BDTD, Oasisbr, LA Referencia, SPELL) é convenção técnica exigida pelo `bibliometrix` (*não indexado*, não *zero citações reais*), e que `ID <- DE` espelha *Author Keywords* em *Keywords Plus* quando ausente
- [x] **Achado #3 — Compatibilidade de `DT` (Tese vs. Artigo) & Deduplicação intra-fonte (`R/merge_bibliolatam.R`, `R/omnisearch_bibliolatam.R`)**: Adicionar guardrail de `DT` impedindo fundir `THESIS`/`DISSERTATION` com `ARTICLE` homônimos sem DOI comum, e executar deduplicação intra-fonte antes do `Reduce()` no Omnisearch para eliminar duplicatas espelhadas em múltiplos repositórios (Oasisbr / LA Referencia)
- [x] **Achado #4 — Sobrenomes compostos hispânicos sem vírgula (`R/normalize_authors.R`)**: Aprimorar normalização de nomes hispano-americanos no formato `"Nome Sobrenome1 Sobrenome2"` (sem vírgula, ex.: `"Gabriel García Márquez"`), alinhando ao formato com vírgula (`"GARCÍA MÁRQUEZ G"`) para evitar fragmentação de autores
- [x] **Cobertura adversarial**: Expandir `test-merge_bibliolatam.R`, `test-adversarial_merge_benchmark.R` e `test-author_normalization.R` validando os 4 achados acima

---

## Fase 11: Inclusividade Multilíngue, Fronteiras Translinguísticas & Reordenação Assintótica (`merge_bibliolatam`)
- [x] **Reordenação dos estágios $O(1)$ (`R/merge_bibliolatam.R`)**: Executar *Length-Bound Filter*, *Exact Match Fast-Path* e *Content Word Canopy* antes do loop onomástico `surnames_compatible()`, acelerando coleções densas sem DOI em ~28,5x e substituindo mocks sintéticos por fixture real de periódicos em `test-adversarial_merge_benchmark.R`
- [x] **Séries em espanhol seguidas de subtítulo (`R/merge_bibliolatam.R`)**: Incluir `volumen`, `seccion`, `tomo`, `entrega` e `capitulo` em `extract_part_token()` para bloquear falsos positivos quando há subtítulo após o numeral (`", Volumen I: analisis regional"` vs `", Volumen II: analisis regional"`)
- [x] **Prefixos onomásticos hispânicos `SAN` / `SANTA` (`R/merge_bibliolatam.R`)**: Excluir partículas toponímicas/hagionímicas não-distintivas (`san`, `santa`, `santo`, `sao`, `van`, `von`) da extração de sub-tokens isolados em `extract_author_surnames()`, bloqueando colisões falsas entre `SAN MARTÍN J` e `SAN ROMÁN F`
- [x] **Títulos bilíngues colados no OAI-PMH sem DOI (`R/merge_bibliolatam.R`)**: Detectar e segmentar títulos concatenados por `" / "` ou `" = "` típicos de repositórios DSpace/VuFind (`"Título PT / English Title"`) quando $L_2 \approx 2L_1$ e não há DOI compartilhado, evitando perda de recall pelo corte do *Length-Bound Filter*
- [x] **Colisão de cognatos `PT <-> ES` em artigos distintos (`R/merge_bibliolatam.R`)**: Implementar verificação de incompatibilidade morfológica de idioma quando não há DOI para impedir falso positivo (risco residual de ~7,5%) entre artigos distintos em português e espanhol sobre temas cognatos escritos por autores com sobrenomes irmãos (`RODRIGUES` vs `RODRÍGUEZ`, `GOMES` vs `GÓMEZ`, `SILVA` vs `SILVA`)
