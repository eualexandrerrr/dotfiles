#!/usr/bin/env bash
# Restaura no ~/.claude.json os 8 MCP que rodavam no Windows, convertidos pro Linux.
#
# Os caminhos originais eram C:\Users\Alexandre\AppData\Roaming\npm\node_modules\<pkg>\...
# (npm global do Windows). Aqui vira `npx -y <pkg>`: nao precisa instalar nada global,
# o npx resolve e cacheia sozinho, e atualiza sem mexer no config.
#
# Idempotente: rode de novo se o Claude Code sobrescrever o arquivo.
#   ~/.dotfiles/scripts/mcp-restaurar.sh
#
# A URL do firecrawl carrega chave de API: vem de FIRECRAWL_MCP_URL, exportada pelo
# ~/.dotfiles-private/env.sh (que o .zshrc ja carrega). Sem ela, o firecrawl e pulado.

set -euo pipefail

ALVO="$HOME/.claude.json"
CLAUDE_DIR="$HOME/Apps/_CLAUDE"
VAULT="$CLAUDE_DIR/Obsidian/Cérebro"
PERFIL="$CLAUDE_DIR/.secrets/perfil-navegador"
JAVA_HOME_ARCH="/usr/lib/jvm/java-17-openjdk"

[[ -f $ALVO ]] || { printf 'restaurar-mcp: %s nao existe\n' "$ALVO" >&2; exit 1; }
[[ -n ${FIRECRAWL_MCP_URL:-} ]] || printf 'restaurar-mcp: FIRECRAWL_MCP_URL vazia, firecrawl sera pulado (veja ~/.dotfiles-private/env.sh)\n' >&2
[[ -d $VAULT ]] || printf 'restaurar-mcp: aviso, vault nao encontrado em %s\n' "$VAULT" >&2

# O perfil do navegador do playwright ficava em _CLAUDE\.secrets, que NAO entrou no
# backup de proposito. E so um profile do Chromium: o playwright recria no primeiro uso.
mkdir -p "$PERFIL"

cp -f "$ALVO" "$ALVO.bak-$(date +%Y%m%d%H%M%S)"

VAULT="$VAULT" PERFIL="$PERFIL" FIRECRAWL_MCP_URL="${FIRECRAWL_MCP_URL:-}" JAVA_HOME_ARCH="$JAVA_HOME_ARCH" ALVO="$ALVO" python3 <<'PY'
import json, os, pathlib

alvo = pathlib.Path(os.environ['ALVO'])
d = json.loads(alvo.read_text())

d['mcpServers'] = {
    "chrome-devtools": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "chrome-devtools-mcp@latest"],
    },
    "playwright": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@playwright/mcp@latest", "--user-data-dir", os.environ['PERFIL']],
    },
    # http: a URL carrega a chave de API, entao vem do dotfiles-private (env.sh), nunca daqui

    "obsidian": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "obsidian-mcp", "serve", "--vault", f"cerebro={os.environ['VAULT']}"],
    },
    "whatsapp": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@kaptionai/mcp-extension"],
    },
    "n8n": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "n8n-mcp"],
        "env": {"MCP_MODE": "stdio", "LOG_LEVEL": "error", "DISABLE_CONSOLE_OUTPUT": "true"},
    },
    "shadcn": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "shadcn@latest", "mcp"],
    },
    # maestro-bin (AUR) instala em /usr/bin/maestro; no Windows era o maestro.bat
    "maestro": {
        "type": "stdio",
        "command": "maestro",
        "args": ["mcp"],
        "env": {
            "JAVA_HOME": os.environ['JAVA_HOME_ARCH'],
            "MAESTRO_CLI_NO_ANALYTICS": "1",
            "MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED": "true",
            "MAESTRO_DISABLE_UPDATE_CHECK": "true",
            "MAESTRO_DRIVER_STARTUP_TIMEOUT": "60000",
        },
    },
}

if os.environ.get('FIRECRAWL_MCP_URL'):
    d['mcpServers']['firecrawl'] = {"type": "http", "url": os.environ['FIRECRAWL_MCP_URL']}

alvo.write_text(json.dumps(d, indent=2, ensure_ascii=False) + "\n")
print(f"{len(d['mcpServers'])} MCP gravados em {alvo}")
for n in d['mcpServers']:
    print(f"  - {n}")
PY

printf '\nReinicie o Claude Code pra carregar. Conferir com: claude mcp list\n'
