#!/usr/bin/env bash
# Compila e instala o VS Code (Code - OSS) a partir do fork privado eualexandrerrr/vscode,
# branch `main`, como pacote do pacman: `code-rcode`, que substitui o `code` do repo.
#
#   vscode-build.sh            compila se o HEAD da branch mudou desde o pacote instalado
#   vscode-build.sh estado     versao instalada x commit da branch
#   vscode-build.sh rebase     traz o upstream (microsoft/vscode) e rebase os patches
#
# E o mesmo modelo dos forks do COSMIC (bin/cosmic-forks.sh): `upstream` espelha o
# microsoft/vscode e `main` carrega so os nossos patches, rebaseados em cima da tag que o Arch
# empacota (a branch de trabalho e sempre `main`, regra dele). So
# que aqui o produto e um pacote, nao um binario em ~/.local/bin: o VS Code sao 300 MB de
# recursos, .desktop, icones e completions, e o PKGBUILD do Arch (copiado em vscode/pkg/)
# ja sabe montar tudo isso -- trocamos so a fonte.
#
# O build exige Node com o mesmo major do .nvmrc do VS Code (24 hoje). O sistema tem o 26 e o
# pacote nodejs-lts-krypton conflita com ele, entao um Node 24 avulso e baixado pra
# ~/.cache/dotfiles/node e entra no PATH so durante o makepkg. Uns 20 min na primeira vez.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
REPO="${VSCODE_FORK_DIR:-$HOME/Apps/desktop/vscode}"
RAMO="main"
ESPELHO="upstream"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
ESTADO="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
BUILD="$CACHE/vscode-build"
mkdir -p "$CACHE" "$ESTADO"

ok()   { printf '  ok %s\n' "$*"; }
warn() { printf '  !! %s\n' "$*"; }

sincronizar() {
    if [[ -d $REPO/.git ]]; then
        git -C "$REPO" fetch -q origin 2>/dev/null
        git -C "$REPO" checkout -q "$RAMO" 2>/dev/null
        git -C "$REPO" merge -q --ff-only "origin/$RAMO" 2>/dev/null
    else
        mkdir -p "$(dirname "$REPO")"
        git clone -q -b "$RAMO" git@github.com:eualexandrerrr/vscode.git "$REPO" || { warn "clone do fork falhou"; return 1; }
        git -C "$REPO" remote add upstream https://github.com/microsoft/vscode.git 2>/dev/null
    fi
}

node_do_build() {
    # Major pedido pelo .nvmrc do VS Code; baixa a ultima versao desse major se ainda nao tem.
    local major versao url dir
    major="$(cut -d. -f1 "$REPO/.nvmrc" 2>/dev/null | tr -d 'v')"
    [[ -n $major ]] || major=24
    dir="$CACHE/node"
    if [[ -x $dir/bin/node ]] && [[ $("$dir/bin/node" --version) == v$major.* ]]; then
        printf '%s' "$dir/bin"; return 0
    fi
    versao="$(curl -fsSL https://nodejs.org/dist/index.json | python3 -c "
import sys, json
for v in json.load(sys.stdin):
    if v['version'].startswith('v$major.'):
        print(v['version']); break")"
    [[ -n $versao ]] || { warn "nao achei Node $major no nodejs.org"; return 1; }
    url="https://nodejs.org/dist/$versao/node-$versao-linux-x64.tar.xz"
    rm -rf "$dir" && mkdir -p "$dir"
    curl -fsSL "$url" | tar -xJ -C "$dir" --strip-components=1 || { warn "download do Node $versao falhou"; return 1; }
    printf '%s' "$dir/bin"
}

compilar() {
    sincronizar || return 1
    # A versao do pacote carrega a tag, a contagem de commits e o sha (pkgver() do PKGBUILD):
    # comparar com o que o pacman tem instalado e o que diz se precisa compilar.
    local head marca="$ESTADO/fork-vscode.commit" tag esperado instalado
    head="$(git -C "$REPO" rev-parse HEAD)"
    tag="$(git -C "$REPO" describe --tags --abbrev=0)"
    esperado="$tag.r$(git -C "$REPO" rev-list --count "$tag..HEAD").g${head:0:7}"
    instalado="$(/usr/bin/pacman -Q code-rcode 2>/dev/null | cut -d' ' -f2)"
    if [[ $instalado == "$esperado-"* ]]; then
        ok "code-rcode $instalado ja e o commit ${head:0:8}"
        return 0
    fi

    local nodebin
    nodebin="$(node_do_build)" || return 1
    ok "Node do build: $("$nodebin/node" --version)"

    rm -rf "$BUILD" && mkdir -p "$BUILD"
    cp "$DOTFILES_DIR"/vscode/pkg/* "$BUILD"/
    printf '  compilando o VS Code (%s)... uns 20 min, log em %s\n' "${head:0:8}" "$ESTADO/fork-vscode.log"
    if (cd "$BUILD" && PATH="$nodebin:$PATH" makepkg -si --noconfirm >"$ESTADO/fork-vscode.log" 2>&1); then
        printf '%s' "$head" >"$marca"
        ok "code-rcode $(/usr/bin/pacman -Q code-rcode | cut -d' ' -f2) instalado"
    else
        warn "makepkg falhou -- veja $ESTADO/fork-vscode.log"
        return 1
    fi
}

rebase() {
    [[ -d $REPO/.git ]] || { warn "fork nao clonado"; return 1; }
    git -C "$REPO" fetch -q upstream main
    local base tag antes
    base="upstream/main"
    tag="$(git -C "$REPO" describe --tags --abbrev=0 "$RAMO" 2>/dev/null)"
    antes="$(git -C "$REPO" rev-list --count "$base..$RAMO")"
    printf '  base atual: tag %s, %s patch(es) nossos\n' "$tag" "$antes"
    # Rebase na tag que o Arch empacota, nao no main: o PKGBUILD e os patches deles casam com
    # a tag. Passe a tag como argumento (vscode-build.sh rebase 1.138.0).
    local alvo="${1:-}"
    [[ -n $alvo ]] || { warn "diga a tag alvo: vscode-build.sh rebase <tag>"; return 1; }
    git -C "$REPO" fetch -q upstream "refs/tags/$alvo:refs/tags/$alvo" 2>/dev/null
    if git -C "$REPO" rebase -q --onto "$alvo" "$tag" "$RAMO" 2>/dev/null; then
        git -C "$REPO" branch -f "$ESPELHO" "$base"
        # O makepkg clona do GitHub e o pkgver() le a tag de la: a tag alvo tem que subir junto.
        git -C "$REPO" push -q origin "refs/tags/$alvo" "$ESPELHO" 2>/dev/null
        ok "$RAMO rebaseado de $tag pra $alvo"
    else
        git -C "$REPO" rebase --abort 2>/dev/null
        warn "rebase deu conflito, resolva a mao em $REPO"
    fi
}

estado() {
    printf 'pacote:  %s\n' "$(/usr/bin/pacman -Q code-rcode 2>/dev/null || echo 'nao instalado')"
    if [[ -d $REPO/.git ]]; then
        printf 'fork:    %s em %s, %s patch(es) sobre a tag %s\n' "$RAMO" "$REPO" \
            "$(git -C "$REPO" rev-list --count "$(git -C "$REPO" describe --tags --abbrev=0 "$RAMO")..$RAMO")" \
            "$(git -C "$REPO" describe --tags --abbrev=0 "$RAMO")"
    fi
    return 0
}

case "${1:-compilar}" in
    compilar) compilar ;;
    estado)   estado ;;
    rebase)   shift; rebase "$@" ;;
    *) printf 'uso: vscode-build.sh [compilar|estado|rebase <tag>]\n' >&2; exit 2 ;;
esac
