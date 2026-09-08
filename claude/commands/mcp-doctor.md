---
description: Diagnostica e repara os MCP servers (handshake real, pacotes globais, locks)
allowed-tools: PowerShell, Bash, Read, Edit
---

Rode o diagnóstico completo dos MCP servers:

```
node "C:\Users\Alexandre\.claude\mcp-doctor.js" --fix
```

Depois:

1. Mostre a tabela de handshake ao Alexandre, destacando qualquer servidor acima de 25000ms ou com FALHA.
2. Se o script listar problemas que ele mesmo não reparou, investigue a causa e corrija.
3. Se algum servidor estiver caído nesta sessão, lembre que `/mcp` reconecta sem reiniciar o Claude Code.

Argumentos extras do usuário: $ARGUMENTS
