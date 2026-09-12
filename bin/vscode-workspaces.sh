#!/usr/bin/env bash
# Um lancador por projeto no menu de aplicativos: cada entrada abre o .code-workspace dele no
# VS Code. Os .code-workspace moram na raiz de ~/Workspaces, sem subpasta (fora do repo: caminho
# e projeto pessoal); o icone opcional e `workspace-<Base>.png` no tema de icones do usuario
# (~/.local/share/icons/hicolor/96x96/apps). A tabela abaixo diz quais viram lancador.
set -uo pipefail

WORKSPACES="$HOME/Workspaces"
DESTINO="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$DESTINO"

# nome no menu | arquivo relativo a ~/Workspaces
PROJETOS=(
    "MichiganRoleplay|MichiganRoleplay.code-workspace"
    "dotfiles|Dotfiles.code-workspace"
    "MeuEscolar|MeuEscolarApp.code-workspace"
)

feitos=0
for entrada in "${PROJETOS[@]}"; do
    IFS='|' read -r nome arquivo <<<"$entrada"
    [[ -f $WORKSPACES/$arquivo ]] || { printf '  !! %s: %s nao existe\n' "$nome" "$WORKSPACES/$arquivo"; continue; }
    base="$(basename "$arquivo" .code-workspace)"
    icone="com.visualstudio.code.oss"
    [[ -f ${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/96x96/apps/workspace-$base.png ]] && icone="workspace-$base"
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

# Clique duplo num .code-workspace abre no VS Code: o tipo MIME vem do pacote code-rcode
# (/usr/share/mime/packages/code-oss-workspace.xml); aqui so se fixa o editor como padrao.
MIME_USUARIO="${XDG_DATA_HOME:-$HOME/.local/share}/mime"
if [[ -f /usr/share/mime/packages/code-oss-workspace.xml && -f $MIME_USUARIO/packages/code-oss-workspace.xml ]]; then
    rm -f "$MIME_USUARIO/packages/code-oss-workspace.xml" && update-mime-database "$MIME_USUARIO" 2>/dev/null
fi
command -v xdg-mime >/dev/null 2>&1 && xdg-mime default code-oss.desktop application/x-code-oss-workspace 2>/dev/null \
    && printf '  ok .code-workspace abre no VS Code\n'

# Icone do VS Code na dock: enquanto o pacote instalado ainda traz o code-icon.svg generico como
# escalavel, um SVG nosso em ~/.local/share/icons embrulha o logo em PNG; some quando o pacote
# passa a instalar o PNG de 1024 px.
ICONE_USUARIO="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/com.visualstudio.code.oss.svg"
# O .code-workspace no gerenciador de arquivos usa o icone do tipo MIME; aponta pro logo.
MIME_ICONE="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/mimetypes/application-x-code-oss-workspace.svg"
mkdir -p "$(dirname "$MIME_ICONE")"
[[ -L $MIME_ICONE ]] || ln -sf ../apps/com.visualstudio.code.oss.svg "$MIME_ICONE"
if [[ -f /usr/share/icons/hicolor/1024x1024/apps/com.visualstudio.code.oss.png && -f $ICONE_USUARIO ]]; then
    rm -f "$ICONE_USUARIO"
elif [[ ! -f /usr/share/icons/hicolor/1024x1024/apps/com.visualstudio.code.oss.png && ! -f $ICONE_USUARIO && -f /usr/lib/code/resources/linux/code.png ]]; then
    mkdir -p "$(dirname "$ICONE_USUARIO")"
    printf '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1024 1024" width="1024" height="1024"><image width="1024" height="1024" xlink:href="data:image/png;base64,%s"/></svg>' \
        "$(base64 -w0 /usr/lib/code/resources/linux/code.png)" >"$ICONE_USUARIO"
fi
