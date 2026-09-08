#!/usr/bin/env bash
# Um comando para o ciclo inteiro dos dotfiles: reinstalar, olhar o log, conferir se o desktop
# tem o que precisa e reiniciar. Existe porque quando o compositor nao sobe voce esta numa tty,
# sem navegador e sem lembrar o caminho do log -- e o que falta saber e sempre a mesma coisa.
#
# `dot zero` roda a partir de /tmp de proposito: ele apaga o proprio ~/.dotfiles antes de clonar,
# e um script nao sobrevive a ter o proprio arquivo removido no meio da execucao.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/eualexandrerrr/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
LOGDIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
LOGFILE="$LOGDIR/install.log"

RED=$'\e[1;31m'; GRN=$'\e[1;32m'; YEL=$'\e[1;33m'; BLU=$'\e[1;34m'; BLD=$'\e[1m'; END=$'\e[0m'

uso() {
    cat <<EOF
${BLD}dot${END} -- ciclo dos dotfiles

  ${BLD}dot${END} ${BLU}instalar${END}    git pull e roda o install.sh (nao apaga nada)
  ${BLD}dot${END} ${BLU}zero${END}        apaga ~/.dotfiles, clona do GitHub e instala do zero
  ${BLD}dot${END} ${BLU}log${END}         mostra o log da ultima instalacao
  ${BLD}dot${END} ${BLU}log -f${END}      acompanha o log ao vivo
  ${BLD}dot${END} ${BLU}erros${END}       so os avisos e erros do ultimo log
  ${BLD}dot${END} ${BLU}status${END}      confere o que o desktop precisa pra subir
  ${BLD}dot${END} ${BLU}telas${END}       o que o kernel enxerga de GPU e de saida de video
  ${BLD}dot${END} ${BLU}reiniciar${END}   reinicia a maquina

  Se nada disso resolver: bote o pendrive, opcao 4 do menu do live.
EOF
}

instalar() {
    [[ -d $DOTFILES_DIR/.git ]] || { printf '%s!!%s %s nao e um clone git; use: dot zero\n' "$RED" "$END" "$DOTFILES_DIR"; return 1; }
    git -C "$DOTFILES_DIR" pull --ff-only origin "$DOTFILES_BRANCH" || printf '%s!!%s pull nao aplicado, seguindo com a arvore local\n' "$YEL" "$END"
    bash "$DOTFILES_DIR/install.sh"
}

zero() {
    printf '%s!!%s isso apaga %s inteiro e clona de novo. [enter] segue, [ctrl-c] cancela ' "$YEL" "$END" "$DOTFILES_DIR"
    read -r _
    cd /tmp || return 1
    rm -rf "$DOTFILES_DIR"
    git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR" || return 1
    bash "$DOTFILES_DIR/install.sh"
}

ver_log() {
    [[ -f $LOGFILE ]] || { printf '%s!!%s sem log em %s\n' "$RED" "$END" "$LOGFILE"; return 1; }
    if [[ ${1:-} == -f ]]; then
        tail -f "$LOGFILE"
    else
        ${PAGER:-less -R} "$LOGFILE"
    fi
}

erros() {
    [[ -f $LOGFILE ]] || { printf '%s!!%s sem log em %s\n' "$RED" "$END" "$LOGFILE"; return 1; }
    grep -niE '!!|erro|falhou|nao encontrado|ausente|pendencia' "$LOGFILE" || printf '%sok%s nenhum aviso no log\n' "$GRN" "$END"
}

status() {
    local faltou=0 bin alvo="$HOME/.config/hypr/hyprland.lua"

    if [[ -L $alvo && -e $alvo ]]; then
        printf '%sok%s hyprland.lua -> %s\n' "$GRN" "$END" "$(readlink -f "$alvo")"
    else
        printf '%s!!%s %s nao e link valido pro repo\n' "$RED" "$END" "$alvo"; faltou=1
    fi

    for bin in Hyprland waybar mako fuzzel uwsm stow; do
        command -v "$bin" >/dev/null 2>&1 \
            && printf '%sok%s %s\n' "$GRN" "$END" "$bin" \
            || { printf '%s!!%s %s nao instalado\n' "$RED" "$END" "$bin"; faltou=1; }
    done

    systemctl is-enabled sddm.service >/dev/null 2>&1 \
        && printf '%sok%s sddm habilitado\n' "$GRN" "$END" \
        || { printf '%s!!%s sddm nao habilitado, o boot cai na tty -- sudo systemctl enable sddm.service\n' "$RED" "$END"; faltou=1; }

    [[ -f /etc/sddm.conf.d/10-dotfiles.conf ]] \
        && printf '%sok%s autologin configurado\n' "$GRN" "$END" \
        || { printf '%s!!%s /etc/sddm.conf.d/10-dotfiles.conf ausente\n' "$YEL" "$END"; faltou=1; }

    local u
    for u in hyprpolkitagent.service ricepanel.service; do
        systemctl --user is-enabled "$u" >/dev/null 2>&1 \
            && printf '%sok%s %s\n' "$GRN" "$END" "$u" \
            || printf '%s!!%s %s nao habilitado -- systemctl --user enable %s\n' "$YEL" "$END" "$u" "$u"
    done

    local desenha="" conector card drv
    for conector in /sys/class/drm/card*-*/status; do
        [[ -e $conector ]] || continue
        [[ $(cat "$conector") == connected ]] || continue
        card="$(basename "$(dirname "$conector")")"; card="${card%%-*}"
        drv="$(basename "$(readlink -f "/sys/class/drm/$card/device/driver" 2>/dev/null)")"
        [[ -n $drv && $drv != . ]] && { desenha="$drv"; break; }
    done

    if [[ -n $desenha ]]; then
        printf '%sok%s telas desenhadas pela %s (%s)\n' "$GRN" "$END" "$desenha" "$card"
        if [[ $desenha != nvidia && -n ${__GLX_VENDOR_LIBRARY_NAME:-} ]]; then
            printf '%s!!%s __GLX_VENDOR_LIBRARY_NAME=%s com as telas na %s: o Electron nao importa o dmabuf e cai em swiftshader (CPU)\n' \
                "$RED" "$END" "$__GLX_VENDOR_LIBRARY_NAME" "$desenha"; faltou=1
        fi
        if [[ $desenha != nvidia && ${LIBVA_DRIVER_NAME:-} == nvidia ]]; then
            printf '%s!!%s LIBVA_DRIVER_NAME=nvidia com as telas na %s: sem aceleracao de video\n' \
                "$RED" "$END" "$desenha"; faltou=1
        fi
    fi

    local software
    software="$(pgrep -af 'use-angle=swiftshade[r]' 2>/dev/null | grep -oE 'user-data-dir=[^ ]+' | sed 's|.*/||' | sort -u | tr '\n' ' ')"
    if [[ -n $software ]]; then
        printf '%s!!%s renderizando por software, na CPU: %s\n' "$RED" "$END" "$software"; faltou=1
    fi

    if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors >/dev/null 2>&1; then
        local principal barra
        principal="$("$DOTFILES_DIR/bin/monitor.sh" principal 2>/dev/null)"
        barra="$(hyprctl layers 2>/dev/null | awk '/^Monitor /{m=$2} /namespace: waybar/{print m; exit}' | tr -d ':')"
        if [[ -z $barra ]]; then
            printf '%s!!%s waybar sem layer em nenhuma tela\n' "$RED" "$END"; faltou=1
        elif [[ -n $principal && $barra != "$principal" ]]; then
            printf '%s!!%s waybar no %s; o principal e o %s -- bin/waybar.sh resolveu a marca errada\n' \
                "$RED" "$END" "$barra" "$principal"; faltou=1
        else
            printf '%sok%s waybar no monitor principal (%s)\n' "$GRN" "$END" "$barra"
        fi
    fi

    (( faltou )) && { printf '\n%s!!%s falta coisa pro desktop subir. Log: dot erros\n' "$RED" "$END"; return 1; }
    printf '\n%sok%s tudo no lugar\n' "$GRN" "$END"
}

telas() {
    printf '%s== GPUs ==%s\n' "$BLD" "$END"
    lspci -nnk | grep -A3 -iE 'vga|3d controller' || true
    printf '\n%s== driver de cada card ==%s\n' "$BLD" "$END"
    local d
    for d in /sys/class/drm/card*/device/driver; do
        [[ -e $d ]] || continue
        printf '  %s -> %s\n' "$(basename "$(dirname "$(dirname "$d")")")" "$(basename "$(readlink -f "$d")")"
    done
    printf '\n%s== saidas ==%s\n' "$BLD" "$END"
    for d in /sys/class/drm/card*-*/status; do
        [[ -e $d ]] || continue
        printf '  %-22s %-10s enabled=%s\n' "$(basename "$(dirname "$d")")" "$(cat "$d")" "$(cat "$(dirname "$d")/enabled" 2>/dev/null || echo '?')"
    done
    printf '\n%s== AQ_DRM_DEVICES ==%s\n' "$BLD" "$END"
    printf '  %s\n' "${AQ_DRM_DEVICES:-nao definido nesta shell (so vale dentro da sessao do uwsm)}"
    if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors >/dev/null 2>&1; then
        printf '\n%s== hyprctl monitors ==%s\n' "$BLD" "$END"
        hyprctl monitors | grep -E '^Monitor|^\s+(description|active workspace|availableModes)' | head -30
    fi
}

case "${1:-}" in
    instalar|install) instalar ;;
    zero)             zero ;;
    log)              shift; ver_log "${1:-}" ;;
    erros|erro)       erros ;;
    status|check)     status ;;
    telas|gpu)        telas ;;
    reiniciar|reboot) sudo reboot ;;
    ''|-h|--help|ajuda) uso ;;
    *) printf '%s!!%s subcomando desconhecido: %s\n\n' "$RED" "$END" "$1"; uso; exit 1 ;;
esac
