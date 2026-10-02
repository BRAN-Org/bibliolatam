# To-Do — Fase 1 (Core Engine & SPELL)

## 1. Fundação e Contrato de Dados (as_bibliometrix)
- [x] Construtor canônico `as_bibliometrix()`
- [x] Validação de campos essenciais mínimos (`AU`, `TI`, `SO`, `PY`)
- [x] Injeção de tags padrão ISI/WoS ausentes como `NA_character_` (sem inferência)
- [x] Coerção segura de tipos (`PY`, `TC` como numéricos)
- [x] Atribuição de classe `c("bibliometrixDB", "data.frame")` e atributo `dbsource`
- [x] Testes unitários do construtor (`tests/testthat/test-as_bibliometrix.R`)

## 2. Parser SPELL / ANPAD (read_spell)
- [x] Leitura de CSV do portal SPELL com detecção de separador e encoding
- [x] Sanitização de quebras de linha e encoding UTF-8 / Latin-1
- [x] Mapeamento e normalização de autoria (`SOBRENOME INICIAIS; ...`)
- [x] Curadoria de fixture de teste real em `inst/extdata/spell_sample.csv`
- [x] Testes unitários do parser (`tests/testthat/test-spell.R`)

## 3. Interoperabilidade com biblioshiny
- [x] Função auxiliar `export_biblioshiny()` para salvar `.RData` compatível (variável canônica `M`)
- [x] Teste de isolamento de carga simulando consumo do `biblioshiny` via `load()`

---

# To-Do — Fase 2 (SciELO)

## 1. Parser SciELO Tabular (read_scielo)
- [x] Leitura de CSV do portal SciELO com detecção de separador e encoding
- [x] Mapeamento multilíngue de tags pt/es/en (`title`/`titulo`, `authors`/`autores`, `journal`/`revista`)
- [x] Normalização de autoria para o padrão canônico WoS/bibliometrix (`SOBRENOME INICIAIS; ...`)
- [x] Fixture pública representativa em `inst/extdata/scielo_sample.csv`
- [x] Testes unitários do parser (`tests/testthat/test-scielo.R`)

## 2. Parser SciELO JATS XML (read_scielo_jats)
- [ ] Parser XML via `xml2` para extrair corpo e árvore de referências citadas (`<ref-list>`)
- [ ] Construção do campo `CR` (Cited References) no padrão `AUTOR, ANO, PERIODICO...`
- [ ] Fixture JATS XML real em `inst/extdata/scielo_sample.xml`
- [ ] Testes unitários de extração de referências citadas
