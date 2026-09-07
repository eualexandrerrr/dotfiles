#!/usr/bin/env bash
# Reconfigura e recarrega os dotfiles. NAO instala pacote nenhum -- isso e o install.sh.
#
#   ~/.dotfiles/setup.sh              tudo
#   ~/.dotfiles/setup.sh links kde    so as etapas citadas
#   ~/.dotfiles/setup.sh --lista      mostra as etapas
#
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
export DOTFILES_DIR

GRN=$'\e[32m'; YEL=$'\e[33m'; BLU=$'\e[34m'; RED=$'\e[31m'; END=$'\e[0m'
FALHAS=()
N=0
TOTAL=0

log()   { N=$((N+1)); printf '\n%s==>%s [%d/%d] %s\n' "$BLU" "$END" "$N" "$TOTAL" "$*"; }
ok()    { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
falha() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*" >&2; FALHAS+=("$*"); }

tem_plasma() {
    command -v qdbus6 >/dev/null 2>&1 &&
        qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1
}

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

    # O Dolphin guarda os Locais num .xbel proprio: as pastas removidas continuam
    # listadas la, apontando pra lugar que nao existe mais.
    local xbel="$HOME/.local/share/user-places.xbel"
    if [[ -f $xbel ]]; then
        python3 - "$xbel" <<'PY' || true
import re, sys, os, urllib.parse, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text(encoding='utf-8'); n = 0
for b in re.findall(r'\s*<bookmark href="[^"]*">.*?</bookmark>', s, re.S):
    m = re.search(r'href="(file://[^"]*)"', b)
    if not m: continue
    d = urllib.parse.unquote(m.group(1)[7:])
    if d and not os.path.isdir(d):
        s = s.replace(b, ''); n += 1
if n: p.write_text(s, encoding='utf-8')
print(f"  ok {n} local(is) morto(s) removido(s) do Dolphin")
PY
    fi
    ok "$removidas pasta(s) padrao removida(s)"
}

etapa_kde() {
    log "chaves do KDE (settings.conf)"
    bash "$DOTFILES_DIR/kde/layan.sh" || falha "layan.sh"
    bash "$DOTFILES_DIR/kde/apply.sh" || falha "apply.sh"
}

etapa_energia() {
    log "energia: nunca dormir, monitores em 5 min"
    bash "$DOTFILES_DIR/kde/energia.sh" || falha "energia.sh"
    qdbus6 org.freedesktop.ScreenSaver /ScreenSaver org.kde.screensaver.configure >/dev/null 2>&1 || true
}

etapa_monitores() {
    log "disposicao dos monitores"
    bash "$DOTFILES_DIR/kde/monitores.sh" || falha "monitores.sh"
}

etapa_wallpaper() {
    log "wallpaper por monitor"
    tem_plasma || { ok "sem sessao do Plasma, pulado"; return; }
    bash "$DOTFILES_DIR/kde/wallpaper.sh" || falha "wallpaper.sh"
}

etapa_painel() {
    log "painel"
    tem_plasma || { ok "sem sessao do Plasma, pulado"; return; }
    bash "$DOTFILES_DIR/kde/painel-ajustar.sh" || falha "painel-ajustar.sh"
}

etapa_icones() {
    log "pastas amarelas"
    bash "$DOTFILES_DIR/kde/icones.sh" || falha "icones.sh"
}

etapa_audio() {
    log "audio: saida analogica 80%, HDMI 50%, mic 80%"
    bash "$DOTFILES_DIR/kde/audio.sh" || falha "audio.sh"
}

etapa_dns() {
    log "DNS mais rapido"
    local sh="$DOTFILES_DIR/bin/dns-rapido.sh"
    [[ -x $sh ]] || { falha "dns-rapido.sh ausente"; return; }
    bash "$sh" || falha "dns-rapido.sh"
}

etapa_login() {
    log "tela de login: wallpaper, foto e greeter so no principal"
    bash "$DOTFILES_DIR/kde/login.sh" || falha "login.sh"
}

etapa_recarregar() {
    log "recarregando kwin e sycoca"
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
    qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect kwin4_effect_shapecorners >/dev/null 2>&1 || true
    kbuildsycoca6 >/dev/null 2>&1 || true
    ok "recarregado"
}

ETAPAS=(links home kde icones energia audio dns monitores wallpaper painel login recarregar)

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
