#!/usr/bin/env bash
marca="$HOME/.config/.kde-layout-aplicado"
[[ -e $marca ]] && exit 0
wm="$HOME/.local/src/KDE-Windows-Modern"
js="$HOME/.dotfiles/scripts/kde-layout.js"
log="$HOME/kde-layout-once.log"
exec > >(tee -a "$log") 2>&1
printf '== %s kde-layout-once\n' "$(date '+%d/%m/%Y %H:%M:%S')"

for _ in $(seq 1 90); do
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && break
    sleep 1
done

# Teclado, mouse, tema, icones e terminal padrao: tudo do kde-settings.conf.
bash "$HOME/.dotfiles/scripts/kde-apply.sh" || true

if [[ -d $wm/scripts && -d $HOME/.local/share/plasma/look-and-feel/org.kde.windowsmodern.dark ]]; then
    printf 'aplicando Windows Modern (dark)\n'
    source "$wm/scripts/install-lib.sh"
    post_kwin_borders || true
    apply_lookandfeel org.kde.windowsmodern.dark reset || true
    apply_kvantum_engine dark || true
    sleep 2
    restart_plasmashell || true
    for _ in $(seq 1 60); do
        qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && break
        sleep 1
    done
    sleep 3
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'var ps = panels(); for (var i = 0; i < ps.length; i++) { ps[i].floating = true; }' >/dev/null 2>&1 && printf 'painel flutuante ativado\n' || printf 'nao consegui ativar flutuante por script; ative em Configurar painel > Flutuante\n'
    touch "$marca"
else
    printf 'Windows Modern ausente, aplicando layout Breeze Dark proprio\n'
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop >/dev/null 2>&1 || true
    plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
    kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-dark
    [[ -f $js ]] && qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$js")" >/dev/null 2>&1 && touch "$marca"
fi

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
printf 'fim\n'
