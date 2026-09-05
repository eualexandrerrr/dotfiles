#!/usr/bin/env bash
# Sobe um Plasma completo dentro de uma janela, isolado da sessao real, pra testar o
# dotfiles sem arriscar o que esta aberto. Se quebrar, fecha a janela e acabou.
#
#   scripts/kde-sessao-teste.sh              sobe a sessao
#   scripts/kde-sessao-teste.sh dentro CMD   roda um comando dentro dela
#   scripts/kde-sessao-teste.sh estado       diz se esta de pe
#   scripts/kde-sessao-teste.sh parar        derruba
#
# O isolamento e triplo, e cada parte importa:
#   HOME proprio      -- o Plasma grava dezenas de arquivos em ~/.config; sem isso o teste
#                        sobrescreveria a configuracao da sessao real
#   D-Bus proprio     -- em socket de caminho fixo, pra dar pra falar com a sessao de fora
#                        (o dbus-run-session sorteia o endereco e o /proc/PID/environ nem
#                        sempre e legivel, entao nao serve)
#   socket Wayland    -- nomeado, pra rodar app dentro da sessao e tirar print dela
#
# Por que nao reiniciar o KWin de verdade: no Wayland ele E o servidor grafico, todo
# cliente esta conectado nele. Reiniciar derruba tudo que estiver aberto. Ja o
# plasmashell reinicia sozinho sem perder janela:
#   systemctl --user restart plasma-plasmashell.service

set -euo pipefail

BASE="${KDE_TESTE_DIR:-/tmp/kde-teste-$USER}"
SOCK="kde-teste"
LARGURA="${KDE_TESTE_LARGURA:-1600}"
ALTURA="${KDE_TESTE_ALTURA:-900}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

DBUS_SOCK="$BASE/dbus.sock"
PIDFILE="$BASE/kwin.pid"
LOG="$BASE/sessao.log"

# Array, nao string: caminho com espaco tem que sobreviver inteiro ate o env.
AMBIENTE=(
    "HOME=$BASE"
    "XDG_CONFIG_HOME=$BASE/.config"
    "XDG_DATA_HOME=$BASE/.local/share"
    "XDG_STATE_HOME=$BASE/.local/state"
    "XDG_CACHE_HOME=$BASE/.cache"
    "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    "DBUS_SESSION_BUS_ADDRESS=unix:path=$DBUS_SOCK"
    "DOTFILES_DIR=$BASE/.dotfiles"
)

viva() { [[ -f $PIDFILE ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; }

subir() {
    viva && { printf 'ja esta de pe (pid %s)\n' "$(cat "$PIDFILE")"; return 0; }

    [[ -n ${WAYLAND_DISPLAY:-} ]] || { printf 'sem WAYLAND_DISPLAY: rode de dentro da sessao grafica\n' >&2; exit 1; }

    rm -rf "$BASE"
    mkdir -p "$BASE"/{.config,.local/share,.local/state,.cache}
    # O repo entra por symlink: editar aqui e testar la, sem copiar nada.
    ln -sfn "$DOTFILES_DIR" "$BASE/.dotfiles"

    dbus-daemon --session --address="unix:path=$DBUS_SOCK" --fork

    # O WAYLAND_DISPLAY do ambiente aponta pro compositor do HOST: e nele que a janela
    # abre. O --socket nomeia o socket que a sessao aninhada passa a servir.
    env "${AMBIENTE[@]}" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
        kwin_wayland --width "$LARGURA" --height "$ALTURA" \
                     --socket "$SOCK" --xwayland plasmashell \
        > "$LOG" 2>&1 &
    echo $! > "$PIDFILE"

    for _ in $(seq 1 60); do
        env "${AMBIENTE[@]}" WAYLAND_DISPLAY="$SOCK" \
            qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && break
        sleep 1
    done

    estado
}

dentro() {
    viva || { printf 'a sessao nao esta de pe; rode "%s" primeiro\n' "$(basename "$0")" >&2; exit 1; }
    env "${AMBIENTE[@]}" WAYLAND_DISPLAY="$SOCK" "$@"
}

estado() {
    if viva; then
        printf 'de pe   pid=%s  home=%s\n' "$(cat "$PIDFILE")" "$BASE"
        printf 'dbus    %s\n' "unix:path=$DBUS_SOCK"
        printf 'wayland %s\n' "$SOCK"
        printf 'log     %s\n' "$LOG"
    else
        printf 'parada\n'
    fi
}

parar() {
    if viva; then
        kill "$(cat "$PIDFILE")" 2>/dev/null || true
        sleep 2
        kill -9 "$(cat "$PIDFILE")" 2>/dev/null || true
    fi
    rm -f "$PIDFILE"
    printf 'parada\n'
}

case "${1:-subir}" in
    subir|"")  subir ;;
    parar)     parar ;;
    estado)    estado ;;
    dentro)    shift; dentro "$@" ;;
    *)         printf 'uso: %s [subir|parar|estado|dentro CMD...]\n' "$(basename "$0")" >&2; exit 1 ;;
esac
