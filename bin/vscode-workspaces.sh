#!/usr/bin/env bash
# Um lancador por projeto no menu de aplicativos: cada entrada abre o .code-workspace dele no
# VS Code. Os .code-workspace moram em ~/Workspaces (fora do repo: caminho e projeto pessoal),
# o icone opcional em ~/Workspaces/icons/<Nome>.png, e a tabela abaixo diz quais viram lancador.
set -uo pipefail

WORKSPACES="$HOME/Workspaces"
DESTINO="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$DESTINO"

# nome no menu | arquivo relativo a ~/Workspaces
PROJETOS=(
    "MichiganRoleplay|MichiganRoleplay.code-workspace"
    "dotfiles|desktop/Dotfiles.code-workspace"
    "MeuEscolar|mobile/MeuEscolarApp.code-workspace"
)

feitos=0
for entrada in "${PROJETOS[@]}"; do
    IFS='|' read -r nome arquivo <<<"$entrada"
    [[ -f $WORKSPACES/$arquivo ]] || { printf '  !! %s: %s nao existe\n' "$nome" "$WORKSPACES/$arquivo"; continue; }
    base="$(basename "$arquivo" .code-workspace)"
    icone="code-oss"
    [[ -f $WORKSPACES/icons/$base.png ]] && icone="$WORKSPACES/icons/$base.png"
    desktop="$DESTINO/workspace-$base.desktop"
    tmp="$desktop.tmp"
    cat >"$tmp" <<FIM
[Desktop Entry]
Type=Application
Name=$nome
Comment=Abrir o projeto $nome no VS Code
Exec=code "$WORKSPACES/$arquivo"
Icon=$icone
Terminal=false
Categories=Development;IDE;
StartupWMClass=code-oss
Keywords=workspace;projeto;$nome;
FIM
    if cmp -s "$tmp" "$desktop"; then rm -f "$tmp"; else mv "$tmp" "$desktop"; feitos=$((feitos + 1)); fi
done
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$DESTINO" 2>/dev/null
printf '  ok %s lancador(es) de projeto escrito(s) em %s\n' "$feitos" "$DESTINO"
