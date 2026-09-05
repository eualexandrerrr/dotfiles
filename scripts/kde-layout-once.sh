#!/usr/bin/env bash
marca="$HOME/.config/.kde-layout-aplicado"
[[ -e $marca ]] && exit 0
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

# O tema vem de vendor/windows-modern; nada de clone nem da lib do upstream.
tema="$HOME/.dotfiles/scripts/tema-instalar.sh"
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
    # Painel flutuante e translucido. Nao da pra fazer pela API de script do Plasma: o
    # setter de opacity nao grava nada (mandar "adaptive" nao muda nem o valor vivo nem o
    # arquivo) e o de floating so vale ate o plasmashell reiniciar, que era por que o
    # painel voltava a ficar colado. As duas coisas moram no plasmashellrc, em
    # [PlasmaViews][Panel <id>]; o plasmashell le esse arquivo quando sobe.
    #   floating=1        descolado das bordas, cantos arredondados
    #   panelOpacity=2    0 adaptativo, 1 opaco, 2 translucido
    painel_id="$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'print(panels()[0].id);' 2>/dev/null | tr -dc '0-9')"
    if [[ -n $painel_id ]]; then
        kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $painel_id" --key floating 1
        kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $painel_id" --key panelOpacity 2
        systemctl --user restart plasma-plasmashell.service || true
        printf 'painel flutuante e translucido (Panel %s)\n' "$painel_id"
    else
        printf 'nao descobri o id do painel; ajuste em Configurar painel > Opacidade/Flutuante\n'
    fi
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
