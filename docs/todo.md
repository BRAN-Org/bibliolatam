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
