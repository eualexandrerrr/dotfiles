#!/usr/bin/env bash
# Compila e instala os forks do COSMIC por cima do pacote do pacman sem tocar nele: o binario
# vai pra ~/.local/bin, que vem antes de /usr/bin no PATH da sessao, e o cosmic-session e o
# cosmic-panel abrem os componentes pelo nome.
#
#   cosmic-forks.sh            clona ou atualiza, compila o que mudou, instala
#   cosmic-forks.sh estado     o que esta instalado, de qual commit, quantos patches nossos
#   cosmic-forks.sh rebase     traz o upstream e rebase os nossos patches em cima dele
#   cosmic-forks.sh forkar     cria na org o que ainda nao existe (uma vez so)
#
# Os forks moram na org github.com/ReCosmicLabs, espelho do ecossistema inteiro da interface
# (GPL-3.0-only, derivados do pop-os; credito no README de cada um que tem patch nosso).
#
# Cada fork tem DUAS branches:
#   master (ou main)  espelho do upstream, nunca editada -- `gh repo sync` mantem em dia
#   recosmic          nossos patches, sempre rebaseados em cima do espelho; e a branch padrao
# Trabalhar assim (em vez de merge) mantem cada mudanca nossa como um commit isolado, que
# sobe pro upstream em PR sem arrastar historico, e faz atualizacao do COSMIC ser um rebase.
#
# So recompila quando o HEAD mudou desde o ultimo binario instalado: o marcador em
# ~/.local/state/dotfiles/ guarda o commit. Repo sem pacote cargo na tabela e so espelho.
set -uo pipefail

ORG="${COSMIC_FORKS_ORG:-ReCosmicLabs}"
BASE="${COSMIC_FORKS_BASE:-$HOME/Apps/desktop/ReCosmicLabs}"
BIN="$HOME/.local/bin"
ESTADO="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
RAMO="recosmic"
mkdir -p "$BIN" "$ESTADO" "$BASE"

# repo | pacote cargo | binario | dono do upstream | branch do upstream
# pacote vazio = espelho, nao compila. Compila so o que tem patch nosso.
FORKS=(
    "cosmic-panel|cosmic-panel-bin|cosmic-panel|pop-os|master"
    "cosmic-applets|cosmic-app-list|cosmic-app-list|pop-os|master"
    "cosmic-launcher|cosmic-launcher|cosmic-launcher|pop-os|master"
    "cosmic-settings|cosmic-settings|cosmic-settings|pop-os|master"
    "cosmic-ext-applet-now-playing|cosmic-ext-applet-now-playing|cosmic-ext-applet-now-playing|AdityaHebballe|main"
    "cosmic-comp|||pop-os|master"
    "cosmic-session|||pop-os|master"
    "cosmic-settings-daemon|||pop-os|master"
    "cosmic-applibrary|||pop-os|master"
    "cosmic-bg|||pop-os|master"
    "cosmic-osd|||pop-os|master"
    "cosmic-notifications|||pop-os|master"
    "cosmic-workspaces-epoch|||pop-os|master"
    "cosmic-idle|||pop-os|master"
    "cosmic-randr|||pop-os|master"
    "cosmic-screenshot|||pop-os|master"
    "cosmic-files|cosmic-files|cosmic-files|pop-os|master"
    "cosmic-term|||pop-os|master"
    "cosmic-edit|||pop-os|master"
    "cosmic-store|||pop-os|master"
    "cosmic-player|||pop-os|master"
    "cosmic-monitor|||pop-os|master"
    "cosmic-greeter|||pop-os|master"
    "cosmic-initial-setup|||pop-os|master"
    "cosmic-icons|||pop-os|master"
    "cosmic-wallpapers|||pop-os|master"
    "cosmic-sound-theme|||pop-os|master"
    "xdg-desktop-portal-cosmic|||pop-os|master"
    "cosmic-protocols|||pop-os|main"
    "cosmic-epoch|||pop-os|master"
    "launcher|||pop-os|master"
    "libcosmic|||pop-os|master"
)

ok()   { printf '  ok %s\n' "$*"; }
warn() { printf '  !! %s\n' "$*"; }

cada_fork() {
    local repo pacote binario upstream branch
    for entrada in "${FORKS[@]}"; do
        IFS='|' read -r repo pacote binario upstream branch <<<"$entrada"
        "$1" "$repo" "$pacote" "$binario" "$upstream" "$branch"
    done
}

sincronizar() {
    local repo="$1" upstream="$4" branch="$5" dir="$BASE/$1"
    if [[ -d $dir/.git ]]; then
        git -C "$dir" fetch -q origin 2>/dev/null
        git -C "$dir" rev-parse --verify -q "$RAMO" >/dev/null 2>&1 ||
            git -C "$dir" checkout -q -B "$RAMO" "origin/$RAMO" 2>/dev/null
        git -C "$dir" merge -q --ff-only "origin/$RAMO" 2>/dev/null
    else
        git clone -q -b "$RAMO" "https://github.com/$ORG/$repo.git" "$dir" 2>/dev/null ||
            git clone -q "https://github.com/$ORG/$repo.git" "$dir" ||
            { warn "$repo: clone falhou"; return 1; }
        git -C "$dir" remote add upstream "https://github.com/$upstream/$repo.git" 2>/dev/null
        ok "$repo clonado em $dir"
    fi
    git -C "$dir" remote set-url upstream "https://github.com/$upstream/$repo.git" 2>/dev/null
}

construir() {
    local repo="$1" pacote="$2" binario="$3"
    [[ -n $pacote ]] || return 0
    sincronizar "$@" || return 0
    local dir="$BASE/$repo" head marca="$ESTADO/fork-$binario.commit"
    head="$(git -C "$dir" rev-parse HEAD)"
    if [[ -x $BIN/$binario && -f $marca && $(<"$marca") == "$head" ]]; then
        ok "$binario ja esta no commit ${head:0:8}"
        return 0
    fi
    printf '  compilando %s (%s)...\n' "$binario" "${head:0:8}"
    if (cd "$dir" && cargo build --release -p "$pacote" >"$ESTADO/fork-$binario.log" 2>&1); then
        install -Dm755 "$dir/target/release/$binario" "$BIN/$binario"
        printf '%s' "$head" >"$marca"
        ok "$binario instalado em $BIN (log em $ESTADO/fork-$binario.log)"
        case "$binario" in
            cosmic-launcher) REINICIAR_LAUNCHER=1 ;;
            cosmic-settings|cosmic-files) ;;
            *) REINICIAR_PAINEL=1 ;;
        esac
    else
        warn "$binario: cargo build falhou -- veja $ESTADO/fork-$binario.log"
    fi
}

instalar() {
    cada_fork construir

    # Painel e launcher so leem binario novo quando nascem de novo. O cosmic-session respawna
    # sozinho, com espera que dobra a cada reinicio seguido -- nada de matar sem ter compilado.
    if [[ ${REINICIAR_PAINEL:-0} == 1 ]] && pgrep -x cosmic-panel >/dev/null 2>&1; then
        pkill -x cosmic-panel && ok "cosmic-panel reiniciado com os binarios novos"
    fi
    if [[ ${REINICIAR_LAUNCHER:-0} == 1 ]] && pgrep -x cosmic-launcher >/dev/null 2>&1; then
        pkill -x cosmic-launcher && ok "cosmic-launcher reiniciado com o binario novo"
    fi
}

rebase_um() {
    local repo="$1" upstream="$4" branch="$5" dir="$BASE/$repo"
    [[ -d $dir/.git ]] || return 0
    git -C "$dir" fetch -q upstream "$branch" 2>/dev/null || { warn "$repo: fetch do upstream falhou"; return 0; }
    local base antes
    base="upstream/$branch"
    antes="$(git -C "$dir" rev-list --count "$base..$RAMO" 2>/dev/null)"
    if [[ $(git -C "$dir" rev-list --count "$RAMO..$base" 2>/dev/null) == 0 ]]; then
        ok "$repo ja esta em cima do upstream (${antes:-0} patch(es))"
        return 0
    fi
    if git -C "$dir" rebase -q "$base" "$RAMO" 2>/dev/null; then
        git -C "$dir" branch -f "$branch" "$base" 2>/dev/null
        ok "$repo rebaseado: ${antes:-0} patch(es) em cima de $(git -C "$dir" rev-parse --short "$base")"
    else
        git -C "$dir" rebase --abort 2>/dev/null
        warn "$repo: rebase deu conflito, resolva a mao em $dir"
    fi
}

rebase() { cada_fork rebase_um; }

forkar_um() {
    local repo="$1" upstream="$4" branch="$5"
    if gh repo view "$ORG/$repo" >/dev/null 2>&1; then
        ok "$ORG/$repo ja existe"
        return 0
    fi
    if gh repo fork "$upstream/$repo" --org "$ORG" --default-branch-only --clone=false >/dev/null 2>&1; then
        ok "$ORG/$repo criado a partir de $upstream/$repo"
    else
        warn "$repo: fork na org falhou"
    fi
}

forkar() {
    command -v gh >/dev/null || { warn "gh nao instalado"; return 1; }
    cada_fork forkar_um
}

estado_um() {
    local repo="$1" pacote="$2" binario="$3" upstream="$4" branch="$5" dir="$BASE/$repo"
    local patches="-" onde="espelho"
    [[ -d $dir/.git ]] && patches="$(git -C "$dir" rev-list --count "upstream/$branch..$RAMO" 2>/dev/null || echo '?')"
    if [[ -n $binario ]]; then
        onde="$([[ -x $BIN/$binario ]] && echo "$BIN/$binario" || echo 'FALTA')"
    fi
    printf '%-30s %-42s %s patch(es)\n' "$repo" "$onde" "$patches"
}

estado() {
    cada_fork estado_um
    local p
    for prog in cosmic-panel cosmic-launcher; do
        p="$(pgrep -x "$prog" | head -1)"
        [[ -n $p ]] && printf '%s rodando de %s\n' "$prog" "$(readlink -f "/proc/$p/exe")"
    done
    return 0
}

REINICIAR_PAINEL=0
REINICIAR_LAUNCHER=0
case "${1:-instalar}" in
    instalar) instalar ;;
    estado)   estado ;;
    rebase)   rebase ;;
    forkar)   forkar ;;
    *) printf 'uso: cosmic-forks.sh [instalar|estado|rebase|forkar]\n' >&2; exit 2 ;;
esac
