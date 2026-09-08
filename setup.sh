#!/usr/bin/env bash
# Reconfigura e recarrega os dotfiles. NAO instala pacote nenhum -- isso e o install.sh.
#
#   ~/.dotfiles/setup.sh                  tudo
#   ~/.dotfiles/setup.sh links wallpaper  so as etapas citadas
#   ~/.dotfiles/setup.sh --lista          mostra as etapas
#
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
export DOTFILES_DIR

GRN=$'\e[32m'; YEL=$'\e[33m'; BLU=$'\e[34m'; END=$'\e[0m'
FALHAS=()
N=0
TOTAL=0

log()   { N=$((N+1)); printf '\n%s==>%s [%d/%d] %s\n' "$BLU" "$END" "$N" "$TOTAL" "$*"; }
ok()    { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
falha() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*" >&2; FALHAS+=("$*"); }

tem_hyprland() { [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && command -v hyprctl >/dev/null 2>&1; }

etapa_links() {
    log "links do stow"
    command -v stow >/dev/null 2>&1 || { falha "stow nao instalado"; return; }
    local pkg nome n=0
    for pkg in "$DOTFILES_DIR"/*/; do
        nome="$(basename "$pkg")"
        [[ $nome == .git ]] && continue
        find "$pkg" -mindepth 1 -maxdepth 1 -name '.*' -print -quit 2>/dev/null | grep -q . || continue
        if stow --no-folding --restow --target="$HOME" --dir="$DOTFILES_DIR" "$nome" 2>/dev/null; then
            n=$((n+1))
        else
            falha "stow recusou o pacote $nome"
        fi
    done
    ok "$n pacote(s) relinkado(s)"
}

etapa_home() {
    log "home enxuta"
    local removidas=0 d
    for d in Documentos Imagens Modelos "Músicas" "Público" "Vídeos" "Área de trabalho" \
             Documents Pictures Templates Music Public Videos Desktop; do
        [[ -d "$HOME/$d" ]] || continue
        [[ -f "$HOME/$d/.directory" && $(find "$HOME/$d" -mindepth 1 | wc -l) -eq 1 ]] && rm -f "$HOME/$d/.directory"
        rmdir "$HOME/$d" 2>/dev/null && removidas=$((removidas+1)) || falha "$d nao esta vazia, mantida"
    done
    mkdir -p "$HOME/Downloads" "$HOME/.local/share/desktop"

    # Workspaces do VS Code, espelhando a arvore de workspaces/ dentro de ~/Workspaces.
    # Nao entram no stow porque o ~/Workspaces e do usuario, nao do repo: copia so o
    # que falta, e nunca por cima do que ele editou.
    local novos=0 origem destino
    while IFS= read -r origem; do
        destino="$HOME/Workspaces/${origem#"$DOTFILES_DIR/workspaces/"}"
        [[ -f $destino ]] && continue
        mkdir -p "$(dirname "$destino")"
        cp "$origem" "$destino" && novos=$((novos+1))
    done < <(find "$DOTFILES_DIR/workspaces" -name '*.code-workspace' -type f 2>/dev/null)
    (( novos )) && ok "$novos workspace(s) do VS Code criado(s)"
    ok "$removidas pasta(s) padrao removida(s)"
}

etapa_perfil() {
    log "avatar do usuario"
    local origem="$DOTFILES_DIR/perfil/avatar.png"
    [[ -f $origem ]] || { falha "perfil/avatar.png ausente"; return; }
    install -m 644 "$origem" "$HOME/.face"
    ok "~/.face (hyprlock e sddm)"
}

etapa_energia() {
    log "energia: nunca dormir, monitores em 5 min"
    bash "$DOTFILES_DIR/bin/energia.sh" || falha "energia.sh"
}

etapa_audio() {
    log "audio: saida analogica 80%, HDMI 50%, mic 80%"
    bash "$DOTFILES_DIR/bin/audio.sh" || falha "audio.sh"
}

etapa_dns() {
    log "DNS mais rapido"
    local sh="$DOTFILES_DIR/bin/dns-rapido.sh"
    [[ -x $sh ]] || { falha "dns-rapido.sh ausente"; return; }
    bash "$sh" || falha "dns-rapido.sh"
}

etapa_wallpaper() {
    log "wallpaper por monitor"
    tem_hyprland || { ok "sem sessao do Hyprland, pulado"; return; }
    bash "$DOTFILES_DIR/bin/wallpaper.sh" || falha "wallpaper.sh"
}

etapa_tema() {
    log "tema GTK e Qt"
    local gtk3="$HOME/.config/gtk-3.0/settings.ini"
    mkdir -p "$(dirname "$gtk3")" "$HOME/.config/gtk-4.0"
    cat > "$gtk3" <<'EOF'
[Settings]
gtk-theme-name=adw-gtk3-dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Fluent-dark-cursors
gtk-cursor-theme-size=24
gtk-font-name=Inter 11
gtk-application-prefer-dark-theme=1
gtk-cursor-blink=1
gtk-cursor-blink-time=500
EOF
    cp "$gtk3" "$HOME/.config/gtk-4.0/settings.ini"
    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-blink true 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-blink-time 500 2>/dev/null || true
    fi
    ok "GTK escuro (adw-gtk3-dark + Papirus-Dark)"
}

etapa_chrome() {
    log "pagina inicial do Chrome"
    local inicio="$HOME/.local/share/inicio/index.html"
    local destino="/etc/opt/chrome/policies/managed/inicio.json"
    [[ -f $inicio ]] || { falha "$inicio nao existe; rode a etapa links antes"; return; }
    local url="file://$inicio"
    local json
    json=$(printf '{\n  "HomepageLocation": "%s",\n  "HomepageIsNewTabPage": false,\n  "NewTabPageLocation": "%s",\n  "ShowHomeButton": true,\n  "RestoreOnStartup": 4,\n  "RestoreOnStartupURLs": ["%s"]\n}\n' "$url" "$url" "$url")
    if [[ -f $destino ]] && [[ $(cat "$destino") == "$json" ]]; then
        ok "politica ja aplicada"
        return
    fi
    sudo mkdir -p "$(dirname "$destino")" 2>/dev/null || { falha "sem permissao em $(dirname "$destino")"; return; }
    printf '%s' "$json" | sudo tee "$destino" >/dev/null || { falha "nao gravou $destino"; return; }
    ok "pagina inicial em $url"
}

etapa_claude() {
    log "settings do Claude Code"
    local base="$DOTFILES_DIR/claude/settings.json"
    local destino="$HOME/.claude/settings.json"
    [[ -f $base ]] || { falha "$base nao existe"; return; }
    command -v jq >/dev/null 2>&1 || { falha "jq nao instalado"; return; }
    mkdir -p "$HOME/.claude"
    [[ -f $destino ]] || printf '{}\n' >"$destino"
    local tmp
    tmp="$(mktemp)"
    # Merge, nunca substituicao: o Claude Code grava escolhas dele nesse arquivo (tema,
    # modelo) e um cp por cima apagaria tudo isso a cada setup.
    if jq -s '.[0] * .[1]' "$destino" "$base" >"$tmp" && [[ -s $tmp ]]; then
        mv "$tmp" "$destino"
        ok "remote control ligado no boot, chaves do repo aplicadas"
    else
        rm -f "$tmp"
        falha "merge do settings.json do Claude falhou"
    fi

    # Autorais dele: memoria global, statusline, comandos e skills proprias. Nao entram no
    # stow porque o ~/.claude e escrito pelo proprio Claude Code o tempo todo -- um symlink
    # ali some no primeiro save atomico. Copia por cima, que e o que o repo manda.
    local item
    for item in CLAUDE.md statusline.js mcp-doctor.js commands skills bin docs; do
        [[ -e "$DOTFILES_DIR/claude/$item" ]] || continue
        cp -a "$DOTFILES_DIR/claude/$item" "$HOME/.claude/" 2>/dev/null \
            && ok "~/.claude/$item" \
            || falha "~/.claude/$item nao copiado"
    done
}

etapa_recarregar() {
    log "recarregando hyprland, waybar e mako"
    tem_hyprland || { ok "sem sessao do Hyprland, nada a recarregar"; return; }
    hyprctl reload >/dev/null 2>&1 || falha "hyprctl reload"
    pkill -x waybar 2>/dev/null
    uwsm app -- "$DOTFILES_DIR/bin/waybar.sh" >/dev/null 2>&1 &
    pkill -x mako 2>/dev/null
    uwsm app -- "$DOTFILES_DIR/bin/mako.sh" >/dev/null 2>&1 &
    if command -v hyprexpose >/dev/null 2>&1; then
        pkill -x hyprexpose 2>/dev/null
        uwsm app -- "$DOTFILES_DIR/bin/hyprexpose.sh" >/dev/null 2>&1 &
    fi
    if command -v hyprswitch >/dev/null 2>&1; then
        pkill -x hyprswitch 2>/dev/null
        uwsm app -- hyprswitch init --custom-css "$HOME/.config/hyprswitch/style.css" \
            --show-title --workspaces-per-row 5 --size-factor 5 >/dev/null 2>&1 &
    fi
    ok "recarregado"
}

ETAPAS=(links home perfil tema energia audio dns wallpaper claude recarregar)

if [[ ${1:-} == --lista ]]; then
    printf 'etapas: %s\n' "${ETAPAS[*]}"
    exit 0
fi

if (( $# )); then
    pedidas=("$@")
    for p in "${pedidas[@]}"; do
        declare -F "etapa_$p" >/dev/null || { printf 'etapa desconhecida: %s\n' "$p" >&2; printf 'validas: %s\n' "${ETAPAS[*]}" >&2; exit 1; }
    done
else
    pedidas=("${ETAPAS[@]}")
fi

TOTAL=${#pedidas[@]}
printf '%s==>%s setup dos dotfiles em %s\n' "$BLU" "$END" "$(date '+%d/%m/%Y %H:%M:%S')"
for p in "${pedidas[@]}"; do "etapa_$p"; done

printf '\n'
if (( ${#FALHAS[@]} )); then
    printf '%s%d aviso(s):%s\n' "$YEL" "${#FALHAS[@]}" "$END"
    printf '  - %s\n' "${FALHAS[@]}"
    exit 1
fi
printf '%ssetup completo, %d etapa(s).%s\n' "$GRN" "$TOTAL" "$END"
