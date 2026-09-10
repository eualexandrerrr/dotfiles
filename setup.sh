#!/usr/bin/env bash
# Reconfigura e recarrega os dotfiles. NAO instala pacote nenhum -- isso e o install.sh.
#
#   ~/.dotfiles/setup.sh                  tudo
#   ~/.dotfiles/setup.sh links chrome     so as etapas citadas
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
    ok "~/.face (sddm e tela de bloqueio do Plasma)"
}

etapa_energia() {
    log "energia: nunca dormir, monitores em 5 min"
    bash "$DOTFILES_DIR/bin/power.sh" || falha "power.sh"
}

etapa_audio() {
    log "audio: saida analogica 80%, HDMI 50%, mic 80%"
    bash "$DOTFILES_DIR/bin/audio.sh" || falha "audio.sh"
}

etapa_dns() {
    log "DNS mais rapido"
    local sh="$DOTFILES_DIR/bin/dns-fastest.sh"
    [[ -x $sh ]] || { falha "dns-fastest.sh ausente"; return; }
    bash "$sh" || falha "dns-fastest.sh"
}

etapa_chrome() {
    log "Chrome: handler de link"

    # Link vindo de fora (Discord, RCode, terminal) tem de cair como aba na janela que ja
    # existe. Sem declarar http/https aqui, cada app resolve o handler por conta e algum
    # deles acaba abrindo janela nova.
    if command -v xdg-mime >/dev/null 2>&1; then
        local esquema
        for esquema in x-scheme-handler/http x-scheme-handler/https x-scheme-handler/about x-scheme-handler/unknown text/html application/xhtml+xml; do
            xdg-mime default google-chrome.desktop "$esquema" 2>/dev/null
        done
        xdg-settings set default-web-browser google-chrome.desktop 2>/dev/null
        ok "links abrem em aba do Chrome"
    else
        falha "xdg-mime nao instalado"
    fi

    # A pagina inicial customizada saiu em 09/09/2026: a politica gerenciada some junto, senao
    # o Chrome continua forcando um file:// que nao existe mais.
    local politica="/etc/opt/chrome/policies/managed/inicio.json"
    if [[ -f $politica ]]; then
        sudo rm -f "$politica" && ok "politica de pagina inicial removida"
    fi

    # A politica que forcava o enhanced-h264ify saiu em 10/09/2026: prendia o YouTube em
    # H.264, que nao tem 1440p, e o video ficava upscalado num monitor de 1440p. Trocar
    # nitidez por CPU tem que ser escolha na hora, pelo popup da extensao -- nao politica.
    local extensoes="/etc/opt/chrome/policies/managed/extensoes.json"
    if [[ -f $extensoes ]]; then
        sudo rm -f "$extensoes" && ok "politica de extensoes removida (h264ify nao e mais forcado)"
    fi
}

etapa_claude() {
    log "settings do Claude Code"
    # A pasta mora no repo PRIVADO ~/Claude, nunca aqui: skills, comandos e settings sao
    # material dele, e este repositorio e publico. Sem o clone, a etapa avisa e segue.
    local fonte="${CLAUDE_CENTRAL:-$HOME/Claude/maquina}"
    local base="$fonte/settings.json"
    local destino="$HOME/.claude/settings.json"
    if [[ ! -d $fonte ]]; then
        falha "$fonte nao existe -- git clone git@github.com:eualexandrerrr/Claude.git ~/Claude"
        return
    fi
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
        [[ -e "$fonte/$item" ]] || continue
        cp -a "$fonte/$item" "$HOME/.claude/" 2>/dev/null \
            && ok "~/.claude/$item" \
            || falha "~/.claude/$item nao copiado"
    done
}

CONSOLE_TIRAR=(quiet nvidia_drm.fbdev=1 nvidia_drm.fbdev=0 loglevel=3 rd.udev.log_level=3)
CONSOLE_POR=(
    fbcon=nodefer
    vt.global_cursor_default=0
    systemd.show_status=yes
    systemd.status_unit_format=name
    vt.default_red=0x1e,0xf3,0xa6,0xf9,0x89,0xf5,0x94,0xba,0x58,0xf3,0xa6,0xf9,0x89,0xf5,0x94,0xa6
    vt.default_grn=0x1e,0x8b,0xe3,0xe2,0xb4,0xc2,0xe2,0xc2,0x5b,0x8b,0xe3,0xe2,0xb4,0xc2,0xe2,0xad
    vt.default_blu=0x2e,0xa8,0xa1,0xaf,0xfa,0xe7,0xd5,0xde,0x70,0xa8,0xa1,0xaf,0xfa,0xe7,0xd5,0xc8
)

console_cmdline() {
    local entry antes depois p n=0
    sudo test -d /boot/loader/entries || { falha "systemd-boot nao encontrado; ajuste a cmdline na mao"; return; }
    while IFS= read -r entry; do
        antes="$(sudo grep -m1 -E '^options ' "$entry" 2>/dev/null)"
        [[ -n $antes ]] || continue
        depois=" $antes "
        for p in "${CONSOLE_TIRAR[@]}"; do depois="${depois// $p / }"; done
        for p in "${CONSOLE_POR[@]}"; do [[ $depois == *" $p "* ]] || depois="$depois$p "; done
        depois="$(printf '%s' "$depois" | tr -s ' ')"
        depois="${depois# }"; depois="${depois% }"
        [[ $depois == "$antes" ]] && continue
        sudo cp -f "$entry" "$entry.bak"
        sudo awk -v nova="$depois" '/^options /{print nova; next}{print}' "$entry" \
            | sudo tee "$entry.novo" >/dev/null && sudo mv -f "$entry.novo" "$entry" \
            && n=$((n+1))
    done < <(sudo find /boot/loader/entries -maxdepth 1 -name '*.conf' 2>/dev/null)
    if (( n )); then
        ok "cmdline ajustada em $n entrada(s), backup em .bak (vale no proximo boot)"
    else
        ok "cmdline ja correta"
    fi
}

etapa_console() {
    log "console do boot"

    local fonte='' f
    for f in ter-132b ter-124b ter-118b; do
        compgen -G "/usr/share/kbd/consolefonts/$f.psf*" >/dev/null && { fonte=$f; break; }
    done
    if [[ -n $fonte ]]; then
        local keymap
        keymap="$(sed -n 's/^KEYMAP=//p' /etc/vconsole.conf 2>/dev/null | head -1)"
        printf 'KEYMAP=%s\nFONT=%s\n' "${keymap:-br-abnt2}" "$fonte" \
            | sudo tee /etc/vconsole.conf >/dev/null \
            && ok "fonte do console: $fonte" || falha "nao gravou /etc/vconsole.conf"
        sudo setfont "$fonte" 2>/dev/null
    else
        falha "terminus-font ausente; rode o install.sh pra ter fonte legivel no console"
    fi

    if [[ -e /etc/systemd/system/tela-desligar.service || -e /usr/local/bin/tela-desligar ]]; then
        sudo /usr/bin/systemctl disable --now tela-desligar.service >/dev/null 2>&1
        sudo rm -f /etc/systemd/system/tela-desligar.service /usr/local/bin/tela-desligar
        sudo /usr/bin/systemctl daemon-reload 2>/dev/null
        ok "painel de desligamento removido, o console mostra o systemd cru"
    fi

    console_cmdline
}

etapa_thunar() {
    log "Thunar como gerenciador de arquivos"
    # O thunarrc de ~/.config/Thunar e ignorado pelo Thunar 4.20: as preferencias moram no
    # xfconf (canal thunar), e o xfconfd reescreve o XML sozinho -- por isso isto nao entra
    # no stow, e sim numa etapa que grava por xfconf-query.
    if ! command -v xfconf-query >/dev/null 2>&1; then
        falha "xfconf-query nao instalado"
        return
    fi
    xfconf-query -c thunar -p /default-view -n -t string -s ThunarDetailsView 2>/dev/null
    xfconf-query -c thunar -p /last-view -n -t string -s ThunarDetailsView 2>/dev/null
    # ligado para que a pasta que o Alexandre mudar a mao guarde a escolha dela e so dela
    xfconf-query -c thunar -p /misc-directory-specific-settings -n -t bool -s true 2>/dev/null
    ok "abre em lista detalhada, com preferencia por pasta"

    # Sem isto o Plasma abre pasta no Dolphin: quem registra inode/directory por ultimo
    # ganha. O mimeapps.list nao entra no stow porque os apps escrevem nele em runtime.
    if command -v xdg-mime >/dev/null 2>&1 && [[ -f /usr/share/applications/thunar.desktop ]]; then
        xdg-mime default thunar.desktop inode/directory 2>/dev/null \
            && ok "Thunar e o padrao para abrir pasta" \
            || falha "nao consegui registrar o Thunar em inode/directory"
    fi
}

etapa_barra() {
    log "barra do Plasma transparente"
    if ! command -v kwriteconfig6 >/dev/null 2>&1; then
        falha "kwriteconfig6 nao instalado"
        return
    fi

    # O Breeze nao tem barra transparente nem blur: quem da o visual e o Dream Color Plasma,
    # baixado pelo install.sh (etapa configure_tema_plasma).
    if command -v plasma-apply-desktoptheme >/dev/null 2>&1; then
        plasma-apply-desktoptheme Dream-Color-Plasma >/dev/null 2>&1 \
            && ok "tema Dream-Color-Plasma aplicado" \
            || falha "Dream-Color-Plasma nao aplicado; rode o install.sh"
    fi

    # O blur atras da barra e do KWin, nao do painel.
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 3
    kwriteconfig6 --file kwinrc --group Effect-blur --key NoiseStrength 0
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 && ok "blur do KWin recarregado"

    # Opacidade e espessura moram no plasmashellrc, e o id do painel muda a cada instalacao.
    local id
    id="$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
        'var p = panels(); print(p.length ? p[0].id : "")' 2>/dev/null | tr -dc '0-9')"
    if [[ -z $id ]]; then
        falha "plasmashell nao respondeu, barra nao configurada"
        return
    fi
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $id" --key floating 0
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $id" --group Defaults --key panelOpacity 2
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $id" --group Defaults --key thickness 48
    # 132 = Qt::AlignHCenter|AlignVCenter, os icones no meio da barra
    kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
        --group Containments --group "$id" --group General --key alignment 132
    ok "painel $id: colado no rodape, translucido, 48px, icones centralizados"

    systemctl --user restart plasma-plasmashell.service >/dev/null 2>&1 \
        && ok "plasmashell recarregado" \
        || falha "plasmashell nao recarregou"
}

ETAPAS=(links home perfil thunar energia audio dns console chrome claude barra)

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
