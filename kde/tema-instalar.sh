#!/usr/bin/env bash
# Instala o Windows Modern a partir de vendor/windows-modern, sem clonar nada e sem rodar
# o instalador do upstream. Ver vendor/windows-modern/PROVENIENCIA.md.
#
#   kde/tema-instalar.sh                instala e aplica
#   kde/tema-instalar.sh --sem-aplicar  so copia e compila
#
# Respeita XDG_DATA_HOME e XDG_CONFIG_HOME, entao roda dentro do
# kde/sessao-teste.sh sem encostar na sessao de verdade.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
VENDOR="$DOTFILES_DIR/vendor/windows-modern"
SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
TEMA="org.kde.windowsmodern.dark"
APLICAR=1
[[ ${1:-} == --sem-aplicar ]] && APLICAR=0

passo() { printf '  -- %s\n' "$1"; }
aviso() { printf '  !! %s\n' "$1" >&2; }

[[ -d $VENDOR ]] || { printf 'vendor/windows-modern nao existe em %s\n' "$DOTFILES_DIR" >&2; exit 1; }

# ── 1. arquivos puros ────────────────────────────────────────────────────────
passo "copiando temas, plasmoids e Kvantum"
mkdir -p "$SHARE" "$CFG"
cp -r "$VENDOR/share/." "$SHARE/"
cp -r "$VENDOR/config/." "$CFG/"

# O Kvantum escolhe o tema pelo nome-base; quem seleciona a variante escura e o estilo
# Qt "kvantum-dark", que o look-and-feel poe no widgetStyle. Por isso aqui vai
# "Windows-modern" e nao "Windows-modernDark".
kwriteconfig6 --file "$CFG/Kvantum/kvantum.kvconfig" --group General --key theme Windows-modern

# O upstream nao traz catalogo de traducao nenhum, entao todo i18n() do menu iniciar caia
# na string-fonte em ingles mesmo com a sessao em pt_BR. O dominio que o Plasma monta pra
# um applet e "plasma_applet_" + o Id do metadata.json.
DOMINIO="plasma_applet_org.kde.windowsmodern.startmenu"
PO="$DOTFILES_DIR/kde/i18n/startmenu.pt_BR.po"
if [[ -f $PO ]] && command -v msgfmt >/dev/null 2>&1; then
    MO="$SHARE/locale/pt_BR/LC_MESSAGES/$DOMINIO.mo"
    mkdir -p "$(dirname "$MO")"
    if msgfmt -o "$MO" "$PO"; then
        passo "menu iniciar em pt_BR ($MO)"
    else
        aviso "msgfmt falhou, menu iniciar fica em ingles"
    fi
elif [[ -f $PO ]]; then
    aviso "msgfmt ausente (pacote gettext), menu iniciar fica em ingles"
fi

# ── 2. tela de bloqueio ──────────────────────────────────────────────────────
# O kscreenlocker le a tela de bloqueio do pacote da shell ATUAL
# (org.kde.plasma.desktop), nao de um pacote proprio. Pra trocar so o Meta+L montamos um
# overlay no nivel do usuario: symlink pra tudo do pacote do sistema, menos o lockscreen,
# que vem do vendor. A shell tem que ficar COMPLETA -- faltando peca, o Plasma cai no
# fallback feio de widget do Qt.
SHELL_SIS="/usr/share/plasma/shells/org.kde.plasma.desktop"
SHELL_USR="$SHARE/plasma/shells/org.kde.plasma.desktop"
LOCK_VENDOR="$SHARE/plasma/shells/org.kde.windowsmodern.lockscreen"
if [[ -d $SHELL_SIS ]]; then
    passo "montando overlay da shell pra tela de bloqueio"
    rm -rf "$SHELL_USR"
    mkdir -p "$SHELL_USR/contents"
    cp "$SHELL_SIS/metadata.json" "$SHELL_USR/"
    for item in "$SHELL_SIS/contents/"*; do
        [[ $(basename "$item") == lockscreen ]] && continue
        ln -sfn "$item" "$SHELL_USR/contents/$(basename "$item")"
    done
    cp -r "$LOCK_VENDOR/contents/lockscreen" "$SHELL_USR/contents/"
    # qmldir e config.xml as vezes so existem no pacote do sistema
    for f in qmldir config.xml; do
        [[ -f "$SHELL_SIS/contents/lockscreen/$f" && ! -f "$SHELL_USR/contents/lockscreen/$f" ]] \
            && cp "$SHELL_SIS/contents/lockscreen/$f" "$SHELL_USR/contents/lockscreen/"
    done
    # o Greeter apontando pra shell que nao existe mais deixa o bloqueio sem tema
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme --delete 2>/dev/null || true
else
    aviso "pacote da shell do sistema ausente, tela de bloqueio fica a padrao"
fi
# o pacote-fonte nao serve de shell: sai, senao o KPackage tenta carregar
rm -rf "$LOCK_VENDOR"

# ── 3. bandeja do sistema, unico componente em C++ ───────────────────────────
SO_DEST="/usr/lib/qt6/plugins/plasma/applets/org.kde.windowsmodern.systemtray.so"
SRC="$VENDOR/src/org.kde.windowsmodern.systemtray"
if [[ -f $SO_DEST && $SO_DEST -nt $SRC/systemtray.cpp ]]; then
    passo "bandeja ja compilada e mais nova que o fonte, pulando"
elif command -v cmake >/dev/null 2>&1; then
    passo "compilando a bandeja (C++)"
    BUILD="$(mktemp -d)"
    trap 'rm -rf "$BUILD"' EXIT
    if cmake -S "$SRC" -B "$BUILD" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release >/dev/null 2>&1 \
       && cmake --build "$BUILD" --parallel "$(nproc)" >/dev/null 2>&1; then
        SO="$(find "$BUILD" -name 'org.kde.windowsmodern.systemtray.so' -type f | head -1)"
        if [[ -n $SO ]]; then
            sudo install -Dm755 "$SO" "$SO_DEST" && passo "bandeja instalada em $SO_DEST"
        else
            aviso "compilou mas nao achei o .so; a bandeja fica a padrao do Plasma"
        fi
    else
        aviso "compilacao da bandeja falhou; a bandeja fica a padrao do Plasma"
    fi
else
    aviso "cmake ausente, bandeja nao compilada"
fi

# O KService so enxerga plasmoid novo depois disso.
kbuildsycoca6 >/dev/null 2>&1 || true

# ── 4. aplicar ───────────────────────────────────────────────────────────────
if (( APLICAR )); then
    passo "aplicando $TEMA"
    plasma-apply-lookandfeel -a "$TEMA" >/dev/null 2>&1 || aviso "plasma-apply-lookandfeel falhou"
    # O look-and-feel pede o tema de icones "windows-modern", que nao vendoramos -- o
    # icone desta maquina e o Tela-dark. O kde-apply.sh repoe as decisoes do repo por
    # cima, entao ele tem que rodar DEPOIS.
    bash "$DOTFILES_DIR/kde/apply.sh" || aviso "kde-apply.sh falhou"
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
fi

printf 'tema pronto\n'
