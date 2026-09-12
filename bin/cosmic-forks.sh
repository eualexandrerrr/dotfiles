#!/usr/bin/env bash
# Compila e instala os forks do COSMIC que este desktop precisa, por cima do pacote do pacman
# sem tocar nele: o binario vai pra ~/.local/bin, que vem antes de /usr/bin no PATH da
# sessao, e o cosmic-session e o cosmic-panel abrem os applets pelo nome.
#
#   ~/.dotfiles/bin/cosmic-forks.sh          clona ou atualiza, compila se mudou, instala
#   ~/.dotfiles/bin/cosmic-forks.sh estado   diz o que esta instalado e de qual commit
#
# Os forks sao do Alexandre (GPL-3.0-only, derivados do pop-os, credito no README de cada um):
#   github.com/eualexandrerrr/cosmic-panel                  background_per_group, exclusive_gap
#   github.com/eualexandrerrr/cosmic-applets                ignored, show_divider, hover_popup_delay_ms
#   github.com/eualexandrerrr/cosmic-ext-applet-now-playing  Spotify na ala esquerda (derivado do AdityaHebballe)
#
# So recompila quando o HEAD do repo mudou desde o ultimo binario instalado: o marcador em
# ~/.local/state/dotfiles/ guarda o commit. Compilar do zero leva uns 3 min; incremental, 30 s.
set -uo pipefail

DONO="${COSMIC_FORKS_OWNER:-eualexandrerrr}"
BIN="$HOME/.local/bin"
ESTADO="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
mkdir -p "$BIN" "$ESTADO"

# repo | pacote cargo | binario | dono do upstream | branch
FORKS=(
    "cosmic-panel|cosmic-panel-bin|cosmic-panel|pop-os|master"
    "cosmic-applets|cosmic-app-list|cosmic-app-list|pop-os|master"
    "cosmic-ext-applet-now-playing|cosmic-ext-applet-now-playing|cosmic-ext-applet-now-playing|AdityaHebballe|main"
)

ok()   { printf '  ok %s\n' "$*"; }
warn() { printf '  !! %s\n' "$*"; }

sincronizar() {
    local repo="$1" upstream="$2" branch="$3" dir="$HOME/$1"
    if [[ -d $dir/.git ]]; then
        git -C "$dir" pull -q --ff-only origin "$branch" 2>/dev/null || warn "$repo: pull nao aplicou, seguindo com o que esta no disco"
    else
        git clone -q "https://github.com/$DONO/$repo.git" "$dir" || { warn "$repo: clone falhou"; return 1; }
        git -C "$dir" remote add upstream "https://github.com/$upstream/$repo.git" 2>/dev/null
        ok "$repo clonado em $dir"
    fi
}

instalar() {
    local repo pacote binario upstream branch
    for entrada in "${FORKS[@]}"; do
        IFS='|' read -r repo pacote binario upstream branch <<<"$entrada"
        sincronizar "$repo" "$upstream" "$branch" || continue
        local dir="$HOME/$repo" head marca="$ESTADO/fork-$binario.commit"
        head="$(git -C "$dir" rev-parse HEAD)"
        if [[ -x $BIN/$binario && -f $marca && $(<"$marca") == "$head" ]]; then
            ok "$binario ja esta no commit ${head:0:8}"
            continue
        fi
        printf '  compilando %s (%s)...\n' "$binario" "${head:0:8}"
        if (cd "$dir" && cargo build --release -p "$pacote" >"$ESTADO/fork-$binario.log" 2>&1); then
            install -Dm755 "$dir/target/release/$binario" "$BIN/$binario"
            printf '%s' "$head" >"$marca"
            ok "$binario instalado em $BIN (log em $ESTADO/fork-$binario.log)"
            REINICIAR_PAINEL=1
        else
            warn "$binario: cargo build falhou -- veja $ESTADO/fork-$binario.log"
        fi
    done

    # O painel so le binario novo quando nasce de novo. So mexe se a sessao for COSMIC e o
    # painel estiver de pe; o cosmic-session respawna sozinho.
    if [[ ${REINICIAR_PAINEL:-0} == 1 ]] && pgrep -x cosmic-panel >/dev/null 2>&1; then
        pkill -x cosmic-panel && ok "cosmic-panel reiniciado com os binarios novos"
    fi
}

estado() {
    local repo pacote binario marca
    for entrada in "${FORKS[@]}"; do
        IFS='|' read -r repo pacote binario _ _ <<<"$entrada"
        marca="$ESTADO/fork-$binario.commit"
        printf '%-16s %s  commit %s\n' "$binario" \
            "$([[ -x $BIN/$binario ]] && echo "$BIN/$binario" || echo 'FALTA')" \
            "$([[ -f $marca ]] && cut -c1-8 "$marca" || echo '-')"
    done
    local p
    p="$(pgrep -x cosmic-panel | head -1)"
    [[ -n $p ]] && printf 'painel rodando de %s\n' "$(readlink -f "/proc/$p/exe")"
    return 0
}

REINICIAR_PAINEL=0
case "${1:-instalar}" in
    instalar) instalar ;;
    estado)   estado ;;
    *) printf 'uso: cosmic-forks.sh [instalar|estado]\n' >&2; exit 2 ;;
esac
