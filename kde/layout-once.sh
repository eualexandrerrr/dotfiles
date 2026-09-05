#!/usr/bin/env bash
marca="$HOME/.config/.kde-layout-aplicado"
[[ -e $marca ]] && exit 0
js="$HOME/.dotfiles/kde/layout.js"
log="$HOME/kde-layout-once.log"
exec > >(tee -a "$log") 2>&1
printf '== %s kde-layout-once\n' "$(date '+%d/%m/%Y %H:%M:%S')"

for _ in $(seq 1 90); do
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && break
    sleep 1
done

# Teclado, mouse, tema, icones e terminal padrao: tudo do kde-settings.conf.
bash "$HOME/.dotfiles/kde/apply.sh" || true

# O tema vem de vendor/windows-modern; nada de clone nem da lib do upstream.
tema="$HOME/.dotfiles/kde/tema-instalar.sh"
if [[ -f $tema ]]; then
    printf 'aplicando Windows Modern (dark)\n'
    bash "$tema" || printf 'tema-instalar.sh falhou\n'
    sleep 2
    systemctl --user restart plasma-plasmashell.service || true
    for _ in $(seq 1 60); do
        qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && break
        sleep 1
    done
    sleep 3
    # Painel: opacidade, flutuante e gerenciador de tarefas. Fica num script proprio
    # porque o look-and-feel devolve o painel ao padrao toda vez que e aplicado.
    bash "$HOME/.dotfiles/kde/painel-ajustar.sh" || printf 'painel-ajustar.sh falhou\n'
    touch "$marca"
else
    printf 'tema-instalar.sh ausente, caindo pro Breeze Dark\n'
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop >/dev/null 2>&1 || true
    plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
    kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-dark
    [[ -f $js ]] && qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$js")" >/dev/null 2>&1 && touch "$marca"
fi

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
printf 'fim\n'
