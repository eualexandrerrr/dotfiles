#!/usr/bin/env bash
# Compila e instala os forks do COSMIC por cima do pacote do pacman sem tocar nele: o binario
# vai pra ~/.local/bin, que vem antes de /usr/bin no PATH da sessao, e o cosmic-session e o
# cosmic-panel abrem os componentes pelo nome.
#
#   cosmic-forks.sh            clona ou atualiza, compila o que mudou, instala
#   cosmic-forks.sh estado     o que esta instalado, de qual commit, quantos patches nossos
#   cosmic-forks.sh rebase     traz o upstream e rebase os nossos patches em cima dele
#   cosmic-forks.sh forkar     cria na org o que ainda nao existe (uma vez so)
#   cosmic-forks.sh ramos      poe as branches de cada fork no padrao main + upstream
#
# Os forks moram na org github.com/ReCosmicLabs, espelho do ecossistema inteiro da interface
# (GPL-3.0-only, derivados do pop-os; credito no README de cada um que tem patch nosso).
#
# Cada fork tem DUAS branches (a de trabalho e sempre `main`, regra do Alexandre):
#   upstream   espelho do upstream (o `master` ou `main` deles), nunca editada
#   main       nossos patches, sempre rebaseados em cima do espelho; e a branch padrao
# Num repo sem patch nosso as duas apontam pro mesmo commit. Trabalhar assim (em vez de merge) mantem cada mudanca nossa como um commit isolado, que
# sobe pro upstream em PR sem arrastar historico, e faz atualizacao do COSMIC ser um rebase.
#
# So recompila quando o HEAD mudou desde o ultimo binario instalado: o marcador em
# ~/.local/state/dotfiles/ guarda o commit. Repo sem pacote cargo na tabela e so espelho.
set -uo pipefail

ORG="${COSMIC_FORKS_ORG:-ReCosmicLabs}"
BASE="${COSMIC_FORKS_BASE:-$HOME/Apps/desktop/ReCosmicLabs}"
BIN="$HOME/.local/bin"
ESTADO="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
RAMO="main"
ESPELHO="upstream"
mkdir -p "$BIN" "$ESTADO" "$BASE"

# repo | pacote cargo | binario | dono do upstream | branch do upstream (so pro fetch)
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
    "cosmic-app-library|||pop-os|master"
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
        sleep 3
        ramos_um "$@"
    else
        warn "$repo: fork na org falhou"
    fi
}

forkar() {
    command -v gh >/dev/null || { warn "gh nao instalado"; return 1; }
    cada_fork forkar_um
}

# Poe um fork no padrao: `upstream` espelha a branch deles, `main` e a nossa e a padrao.
# Serve pro fork recem-criado (que nasce so com a branch deles) e pra migrar os antigos, que
# usavam `recosmic` como branch de trabalho.
ramos_um() {
    local repo="$1" branch="$5" dir="$BASE/$repo" tem
    tem="$(gh api "repos/$ORG/$repo/branches?per_page=100" --jq '.[].name' 2>/dev/null)" || { warn "$repo: nao li as branches"; return 0; }
    # O rename do GitHub e assincrono: o segundo seguido falha enquanto o primeiro assenta.
    renomear() {
        local t
        for t in 1 2 3 4 5; do
            gh api -X POST "repos/$ORG/$repo/branches/$1/rename" -f new_name="$2" >/dev/null 2>&1 && return 0
            sleep 2
        done
        warn "$repo: nao renomeei $1 -> $2"
        return 1
    }
    if ! grep -qx "$ESPELHO" <<<"$tem"; then
        if grep -qx recosmic <<<"$tem" || [[ $branch != "$RAMO" ]] || grep -qx "$branch" <<<"$tem"; then
            renomear "$branch" "$ESPELHO" && tem="$(sed "s/^$branch\$/$ESPELHO/" <<<"$tem")"
        fi
    fi
    if grep -qx recosmic <<<"$tem"; then
        renomear recosmic "$RAMO" && tem="$(sed "s/^recosmic\$/$RAMO/" <<<"$tem")"
    fi
    if ! grep -qx "$RAMO" <<<"$tem" && ! grep -qx recosmic <<<"$tem"; then
        local sha
        sha="$(gh api "repos/$ORG/$repo/git/ref/heads/$ESPELHO" --jq .object.sha 2>/dev/null)"
        [[ -n $sha ]] && gh api -X POST "repos/$ORG/$repo/git/refs" -f ref="refs/heads/$RAMO" -f sha="$sha" >/dev/null 2>&1
    fi
    [[ $(gh repo view "$ORG/$repo" --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null) == "$RAMO" ]] ||
        gh api -X PATCH "repos/$ORG/$repo" -f default_branch="$RAMO" >/dev/null 2>&1
    if [[ -d $dir/.git ]]; then
        git -C "$dir" fetch -q --prune origin 2>/dev/null
        git -C "$dir" show-ref -q --verify refs/heads/recosmic && {
            git -C "$dir" show-ref -q --verify "refs/heads/$RAMO" && git -C "$dir" branch -m "$RAMO" "$ESPELHO" 2>/dev/null
            git -C "$dir" branch -m recosmic "$RAMO"
        }
        git -C "$dir" show-ref -q --verify "refs/heads/$ESPELHO" || {
            git -C "$dir" show-ref -q --verify "refs/heads/$branch" && [[ $branch != "$RAMO" ]] && git -C "$dir" branch -m "$branch" "$ESPELHO"
        }
        git -C "$dir" branch -q -u "origin/$RAMO" "$RAMO" 2>/dev/null
        git -C "$dir" branch -q -u "origin/$ESPELHO" "$ESPELHO" 2>/dev/null
        git -C "$dir" checkout -q "$RAMO" 2>/dev/null
    fi
    ok "$repo: $RAMO (padrao) + $ESPELHO"
}

ramos() {
    command -v gh >/dev/null || { warn "gh nao instalado"; return 1; }
    cada_fork ramos_um
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
    ramos)    ramos ;;
    *) printf 'uso: cosmic-forks.sh [instalar|estado|rebase|forkar|ramos]\n' >&2; exit 2 ;;
esac
