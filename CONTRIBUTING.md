# Guia de Contribuição — bibliolatam

Obrigado pelo interesse em contribuir com o `bibliolatam`! Este pacote é mantido pela **BRAN Org** e segue diretrizes técnicas e operacionais para garantir confiabilidade acadêmica e código sustentável.

---

## 🏛️ Princípios de Integridade do Dado

1. **Inviolabilidade do Dado de Origem**:
   - Parsers e conversores **nunca** devem inferir, "adivinhar" ou inventar metadados ausentes na fonte primária.
   - Campos inexistentes ou não informados no arquivo de exportação devem permanecer como `NA_character_` (ou `NA`).
2. **Compatibilidade Rígida com `bibliometrix`**:
   - Todo conversor deve produzir um objeto com classe `c("bibliometrixDB", "data.frame")` e preencher os atributos obrigatórios (`attr(df, "dbsource")`).
   - A saída deve ser testada contra as funções do ecossistema `bibliometrix` (`biblioAnalysis`, `summary`, etc.).

---

## 🛠️ Fluxo de Trabalho Git

Seguimos a política padrão da BRAN Org:

1. **Branches**:
   - `main`: Branch de release e código estável. Commits diretos são bloqueados.
   - `development`: Branch base de integração ativa. Todo Pull Request deve ser direcionado para `development`.
   - Feature branches: Devem ser criadas a partir de `development` no formato `feat/nome-da-feature` ou `fix/nome-do-bug`.
2. **Commits**:
   - Padrão **Conventional Commits** estrito (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`).
   - Sem mensagens genéricas ou artefatos de IA.
3. **Pull Requests**:
   - Devem utilizar o template padrão do repositório.
   - Devem incluir testes em `tests/testthat/` para qualquer novo parser ou correção.
   - Devem passar limpos no `R CMD check` local antes de serem abertos.

---

## 🧪 Desenvolvimento Local e Testes

```r
# No R / RStudio:
devtools::load_all()    # Carregar código em desenvolvimento
devtools::document()    # Atualizar documentação e NAMESPACE
devtools::test()        # Rodar suíte de testes unitários
devtools::check()       # Executar R CMD check completo
```

Ao adicionar suporte a novos formatos de arquivos (RIS, BibTeX, CSV, XML), adicione um arquivo mínimo representativo em `inst/extdata/` e crie o respectivo teste de integração em `tests/testthat/`.
