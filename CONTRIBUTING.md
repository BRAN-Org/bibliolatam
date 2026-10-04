# Guia de Contribuicao - bibliolatam

Obrigado pelo interesse em contribuir com o bibliolatam. Este pacote e mantido pela BRAN Org e segue diretrizes tecnicas e operacionais para garantir confiabilidade academica e codigo sustentavel.

---

## 1. Principios de Integridade do Dado

1. **Inviolabilidade do Dado de Origem**:
   - Parsers e conversores nunca devem inferir ou inventar metadados ausentes na fonte primaria.
   - Campos inexistentes ou nao informados no arquivo de exportacao devem permanecer como `NA_character_` (ou `NA`).
2. **Compatibilidade Rigida com bibliometrix**:
   - Todo conversor deve produzir um objeto com classe `c("bibliometrixDB", "data.frame")` e preencher os atributos obrigatorios (`attr(df, "dbsource")`).
   - A saida deve ser testada contra as funcoes do ecossistema bibliometrix (`biblioAnalysis`, `summary`, etc.).

---

## 2. Fluxo de Trabalho Git

Seguimos a politica padrao da BRAN Org:

1. **Branches**:
   - `main`: Branch de release e codigo estavel. Commits diretos sao bloqueados.
   - `development`: Branch base de integracao ativa. Todo Pull Request deve ser direcionado para `development`.
   - Feature branches: Devem ser criadas a partir de `development` no formato `feat/nome-da-feature` ou `fix/nome-do-bug`.
2. **Commits**:
   - Padrao Conventional Commits estrito (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`).
   - Sem mensagens genericas ou artefatos de IA.
3. **Pull Requests**:
   - Devem utilizar o template padrao do repositorio.
   - Devem incluir testes em `tests/testthat/` para qualquer novo parser ou correcao.
   - Devem passar limpos no `R CMD check` antes de serem aprovados.

---

## 3. Desenvolvimento Local e Testes

```r
devtools::load_all()    # Carregar codigo em desenvolvimento
devtools::document()    # Atualizar documentacao e NAMESPACE
devtools::test()        # Rodar suite de testes unitarios
devtools::check()       # Executar R CMD check completo
```

Ao adicionar suporte a novos formatos de arquivos (RIS, BibTeX, CSV, XML), adicione um arquivo minimo representativo em `inst/extdata/` e crie o respectivo teste de integracao em `tests/testthat/`.
