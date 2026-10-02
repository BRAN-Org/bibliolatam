#' Normalize author names into standard bibliometric format
#'
#' Converts diverse author string formats (e.g. 'Sobrenome, Nome', 'Nome Sobrenome',
#' with generational suffixes like Junior, Filho, Neto) into the canonical
#' WoS/bibliometrix format: `SOBRENOME INICIAIS; ...`.
#'
#' @param au_str Character string containing one or multiple author names separated by semicolons.
#' @return A normalized character string, or `NA_character_` if empty.
#' @export
normalize_authors <- function(au_str) {
  if (is.na(au_str) || !nzchar(trimws(au_str))) {
    return(NA_character_)
  }

  raw_authors <- unlist(strsplit(au_str, ";", fixed = TRUE))
  norm_authors <- character(0L)

  # particulas que nao viram iniciais em padrao cienciometrico
  particulas <- c("da", "de", "do", "das", "dos", "del", "della", "van", "von", "der", "e", "y")
  # sufixos geracionais brasileiros e hispanicos
  sufixos <- c("junior", "jr", "filho", "neto", "sobrinho", "segundo", "terceiro")

  for (a in raw_authors) {
    a <- trimws(a)
    if (!nzchar(a)) next

    if (grepl(",", a, fixed = TRUE)) {
      # formato: 'Sobrenome, Nome Meio' ou 'Sobrenome Filho, Nome'
      parts <- unlist(strsplit(a, ",", fixed = TRUE))
      sobrenome <- toupper(trimws(parts[1]))
      restante <- if (length(parts) > 1) trimws(parts[2]) else ""
      prenomes <- unlist(strsplit(restante, "\\s+"))
      prenomes <- prenomes[nzchar(prenomes)]

      # extrai iniciais ignorando particulas (ex: 'da', 'de')
      iniciais_tokens <- prenomes[!tolower(prenomes) %in% particulas]
      iniciais <- paste0(substr(iniciais_tokens, 1, 1), collapse = "")

      norm_a <- if (nzchar(iniciais)) paste(sobrenome, toupper(iniciais)) else sobrenome
    } else {
      # formato: 'Nome Meio Sobrenome'
      tokens <- unlist(strsplit(a, "\\s+"))
      tokens <- tokens[nzchar(tokens)]

      if (length(tokens) == 1) {
        norm_a <- toupper(tokens)
      } else {
        last_tok <- tolower(tokens[length(tokens)])
        # trata sufixo geracional (ex: Silva Junior)
        if (last_tok %in% sufixos && length(tokens) >= 3) {
          sobrenome <- toupper(paste(tokens[length(tokens) - 1], tokens[length(tokens)]))
          prenomes <- tokens[1:(length(tokens) - 2)]
        } else {
          sobrenome <- toupper(tokens[length(tokens)])
          prenomes <- tokens[-length(tokens)]
        }

        iniciais_tokens <- prenomes[!tolower(prenomes) %in% particulas]
        iniciais <- paste0(substr(iniciais_tokens, 1, 1), collapse = "")

        norm_a <- if (nzchar(iniciais)) paste(sobrenome, toupper(iniciais)) else sobrenome
      }
    }
    norm_authors <- c(norm_authors, norm_a)
  }

  if (length(norm_authors) == 0L) {
    return(NA_character_)
  }

  paste(norm_authors, collapse = "; ")
}
