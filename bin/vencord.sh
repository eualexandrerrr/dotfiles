#!/usr/bin/env bash
# Vencord com os plugins do fork eualexandrerrr/Vencord, injetado no Discord do packages.txt.
#
#   ~/.dotfiles/bin/vencord.sh          baixa/atualiza, builda e injeta
#   ~/.dotfiles/bin/vencord.sh estado   diz o que existe e o que falta
#
# O pacote discord do repo-oficial e so um bootstrap: o Electron real so existe depois
# do primeiro `discord` rodar, e isso abre janela GUI. Pra nao travar o install.sh sem
# tela, o script chama o updater_bootstrap sozinho (--no-zenity, sem exec do app).
#
# `pnpm inject` sozinho pergunta qual instalacao de Discord usar; roda o runInstaller.mjs
# direto com --branch stable pra nao esperar input.
set -uo pipefail

REPO_FORK="${VENCORD_REPO:-https://github.com/eualexandrerrr/Vencord.git}"
REPO_UPSTREAM="https://github.com/Vendicated/Vencord.git"
DIR="$HOME/Apps/desktop/Vencord"
DISCORD_CONFIG="$HOME/.config/discord"

log()  { printf '\n==> %s\n' "$*"; }
ok()   { printf '  ok %s\n' "$*"; }
die()  { printf '  erro: %s\n' "$*" >&2; exit 1; }

discord_baixado() {
    local d
    for d in "$DISCORD_CONFIG"/app-*; do
        [[ -d "$d/resources" ]] && return 0
    done
    return 1
}

bootstrap_discord() {
    discord_baixado && { ok "Discord ja baixado em $DISCORD_CONFIG"; return 0; }

    local bootstrap="/usr/share/discord/updater_bootstrap"
    [[ -x $bootstrap ]] || die "$bootstrap ausente -- pacote discord instalado?"

    mkdir -p "$DISCORD_CONFIG"
    "$bootstrap" --no-zenity "$DISCORD_CONFIG" stable "https://updates.discord.com/" \
        || die "bootstrap do Discord falhou"
    discord_baixado || die "bootstrap rodou mas nenhum app-* apareceu em $DISCORD_CONFIG"
    ok "Discord baixado em $DISCORD_CONFIG"
}

clonar_ou_atualizar() {
    if [[ -d "$DIR/.git" ]]; then
        git -C "$DIR" pull --ff-only && ok "$DIR atualizado" || die "git pull falhou em $DIR"
        return
    fi

    mkdir -p "$(dirname "$DIR")"
    git clone "$REPO_FORK" "$DIR" || die "git clone falhou"
    git -C "$DIR" remote rename origin fork
    git -C "$DIR" remote add origin "$REPO_UPSTREAM"
    ok "$DIR clonado (remote fork = seu fork, origin = upstream)"
}

instalar() {
    command -v pnpm >/dev/null 2>&1 || die "pnpm nao encontrado -- veja packages.txt [dev-web]"

    bootstrap_discord
    clonar_ou_atualizar
    ( cd "$DIR" && CI=true pnpm install ) || die "pnpm install falhou"
    ( cd "$DIR" && pnpm build ) || die "pnpm build falhou"
    local tentativa
    for tentativa in 1 2 3 4 5; do
        ( cd "$DIR" && node scripts/runInstaller.mjs -- --install --branch stable ) && break
        (( tentativa == 5 )) && die "injecao falhou"
        printf '  injecao falhou (tentativa %s/5), repetindo em 10 s\n' "$tentativa"
        sleep 10
    done
    ok "Vencord injetado no Discord stable"
}

estado() {
    printf 'repo     %s\n' "$([[ -d $DIR/.git ]] && echo "$DIR" || echo 'FALTA clonar')"
    printf 'pnpm     %s\n' "$(command -v pnpm || echo FALTA)"
    printf 'discord  %s\n' "$(discord_baixado && echo "baixado em $DISCORD_CONFIG" || echo 'FALTA rodar bootstrap')"
}

case "${1:-instalar}" in
    instalar) instalar ;;
    estado)   estado ;;
    *) die "uso: vencord.sh [instalar|estado]" ;;
esac
