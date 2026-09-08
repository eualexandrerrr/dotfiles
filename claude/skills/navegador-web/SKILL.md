---
name: navegador-web
description: Como acessar a web e automatizar navegador - sempre por MCP, nunca por script Node. Use ao abrir site, clicar, preencher formulário, tirar screenshot de página, ler console ou rede, rodar Lighthouse, fazer login, raspar conteúdo, buscar documentação ou pesquisar na internet.
---

# Navegador e web: sempre por MCP

Regra dura. Nunca escrever script Node com `playwright`/`puppeteer` da pasta
`~/Claude/ferramentas` para navegar. A única exceção é renderizar HTML→PNG/PDF em lote.

## Qual MCP para cada caso

| Preciso de... | MCP |
|---|---|
| Buscar na web, raspar página sem interação | `firecrawl` |
| Navegar, clicar, preencher, screenshot, login | `playwright` |
| Console, rede, performance, Lighthouse | `chrome-devtools` |

Conteúdo da web sem interação começa no `firecrawl`. Só sobe para o `playwright` quando
exige login ou clique.

Detalhe e receitas em `~/Claude/playwright.md`.
