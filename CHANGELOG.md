# Changelog

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/), e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- Estrutura inicial do pacote R `bibliolatam` com compatibilidade planejada para `bibliometrix`.
- Conversor canônico `as_bibliometrix()` com geração automática de tags `SR`, `SR_FULL`, `JI`, `J9` e validação de contrato `bibliometrixDB`.
- Parser tabular SPELL / ANPAD (`read_spell`) com detecção automática de delimitadores e normalização de autores.
- Parser tabular SciELO CSV (`read_scielo`) para exportações multilíngues.
- Parser de XML completo NLM/JATS SciELO (`read_scielo_jats`) com reconstrução de referências citadas (`CR`).
- Motor de download automatizado SciELO (`download_scielo_jats`) com resolução de DOI/PID/URL, retentativas em falhas de gateway e validação de integridade XML.
- Extração e normalização de idioma (`LA`) a partir do atributo `xml:lang` no parser JATS SciELO.
- Módulo de interface gráfica para teses e dissertações da BDTD no `biblioshiny` (`bdtdUI` e `bdtdServer`) com busca online direta na API VuFind, filtro por grau acadêmico, cartões métricos e injeção reativa.
- Módulo de interface gráfica dedicado para o portal Oasisbr no `biblioshiny` (`oasisbrUI` e `oasisbrServer`) com busca online na API VuFind, upload local e filtros por tipo de documento (`DT`).
- Motor de consulta e download direto via API REST VuFind/IBICT (`download_bdtd` e `download_oasisbr`).
- Motor de consulta e download para a rede latino-americana LA Referencia (`download_lareferencia`) via API REST VuFind v1.
- Motor de busca online para artigos do SciELO (`download_scielo_search`) via API pública do Crossref com filtro de prefixo DOI `10.1590`.
- Motor de busca federada unificada Latino-Americana (`omnisearch_bibliolatam`) com agregação paralela, deduplicação automática e fusão de metadados via `merge_bibliolatam`.
- Painel interativo de Omnisearch no `biblioshiny` (`omnisearchUI` e `omnisearchServer`) com carregamento direto no `values$M`.
- Motor de fusão e deduplicação entre bases heterogêneas (`merge_bibliolatam`) com resolução exata por DOI e correspondência aproximada por título em português e espanhol.
- Parser de periódicos científicos do Redalyc e AmeliCA (`read_redalyc`) com suporte a formatos BibTeX, RIS e CSV, e normalização de nomes compostos hispânicos.
- Módulo de interface gráfica para o Redalyc (`redalycUI`, `redalycServer`) e painel de fusão de coleções (`bibliolatamMergeUI`, `bibliolatamMergeServer`) no `biblioshiny`.
- Módulo de interface gráfica para o `biblioshiny` (`scieloUI`, `scieloServer`, `bibliolatamInfoUI`) criando menu dedicado "Bibliolatam" com submenus para SciELO e aba de Informações ("Info & About").
- Exportador para interface gráfica `export_biblioshiny()` gerando arquivos `.RData` prontos para importação direta.
- Normalizador independente de nomes de autores (`normalize_authors`) com suporte a sufixos geracionais brasileiros e partículas.
- Licença dual (GNU GPL-3.0 para software e CC BY-NC-SA 4.0 para dados de exemplo).
- Documentação inicial, código de conduta e diretrizes de contribuição da BRAN Org.
- Templates de Pull Request e Issues para bugs e novas bases de dados.
- Workflow de CI com `R CMD check` no GitHub Actions.
