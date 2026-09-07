#!/usr/bin/env bash
marca="$HOME/.config/.kde-layout-aplicado"
[[ -e $marca ]] && exit 0
js="$HOME/.dotfiles/kde/layout.js"
log="$HOME/kde-layout-once.log"
exec > >(tee -a "$log") 2>&1
printf '== %s kde-layout-once\n' "$(date '+%d/%m/%Y %H:%M:%S')"

falhas=0
bash "$HOME/.dotfiles/kde/monitores.sh" || { printf 'monitores.sh falhou\n'; falhas=$((falhas+1)); }

if ! command -v qdbus6 >/dev/null 2>&1; then
    printf 'qdbus6 ausente (pacote qt6-tools): painel, wallpaper e tema nao serao aplicados\n' >&2
    exit 1
fi

plasma_vivo=0
for _ in $(seq 1 90); do
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && { plasma_vivo=1; break; }
    sleep 1
done
if [[ $plasma_vivo -eq 0 ]]; then
    printf 'plasmashell nao respondeu em 90s, abortando sem marcar como aplicado\n' >&2
    exit 1
fi

# Teclado, mouse, tema, icones e terminal padrao: tudo do kde-settings.conf.
bash "$HOME/.dotfiles/kde/apply.sh" || true

# Wallpaper por monitor: retrato no que esta em pe, paisagem nos outros. Mesmas imagens do
# MyWinISO, para o Windows e o Arch nao terem cara diferente.
bash "$HOME/.dotfiles/kde/wallpaper.sh" || { printf 'wallpaper.sh falhou\n'; falhas=$((falhas+1)); }

# O tema vem de vendor/windows-modern; nada de clone nem da lib do upstream.
tema="$HOME/.dotfiles/kde/tema-instalar.sh"
if [[ -f $tema ]]; then
    printf 'aplicando Windows Modern (dark)\n'
    bash "$tema" || { printf 'tema-instalar.sh falhou\n'; falhas=$((falhas+1)); }
    sleep 2
    systemctl --user restart plasma-plasmashell.service || true
    for _ in $(seq 1 60); do
        qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && break
        sleep 1
    done
    sleep 3
    # Painel: opacidade, flutuante e gerenciador de tarefas. Fica num script proprio
    # porque o look-and-feel devolve o painel ao padrao toda vez que e aplicado.
    bash "$HOME/.dotfiles/kde/painel-ajustar.sh" || { printf 'painel-ajustar.sh falhou\n'; falhas=$((falhas+1)); }
    if [[ $falhas -eq 0 ]]; then
        touch "$marca"
    else
        printf '%d etapa(s) falharam, sem marcar como aplicado: roda de novo no proximo login\n' "$falhas" >&2
    fi
else
    printf 'tema-instalar.sh ausente, caindo pro Breeze Dark\n'
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop >/dev/null 2>&1 || true
    plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
    kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-dark
    [[ -f $js ]] && qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$js")" >/dev/null 2>&1 && touch "$marca"
fi

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
printf 'fim\n'
