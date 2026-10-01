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
- [ ] Função auxiliar `export_biblioshiny()` para salvar `.RData` compatível
- [ ] Teste de carga de ponta a ponta simulando `bibliometrix::biblioAnalysis()`
