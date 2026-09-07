#!/usr/bin/env bash
# Tema Layan (vinceliuice, GPL-3), vendorado em vendor/layan. Conjunto inteiro,
# nao pedaco: estilo do Plasma, cores, decoracao Aurorae e Kvantum saem todos
# daqui. Misturar peca de tema diferente e o que deixa a area de trabalho feia.
#
# Kvantum e o LayanBlack: variante do LayanSolidDark com os cinzas escurecidos,
# gerada em vendor/layan. A translucida do Layan deixa a janela ilegivel por cima
# de pagina clara, e a Solid original e cinza demais.
set -uo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
V="$DOTFILES_DIR/vendor/layan"
[[ -d $V ]] || { printf 'layan: %s ausente\n' "$V" >&2; exit 1; }

mkdir -p ~/.config/Kvantum ~/.local/share/color-schemes ~/.local/share/aurorae/themes \
         ~/.local/share/plasma/desktoptheme ~/.local/share/plasma/look-and-feel
cp -r "$V/kvantum/LayanBlack" ~/.config/Kvantum/
cp "$V/colors/LayanBlack.colors" ~/.local/share/color-schemes/
cp -r "$V/aurorae/Layan" ~/.local/share/aurorae/themes/
cp -r "$V/plasma/Layan" ~/.local/share/plasma/desktoptheme/
cp -r "$V/look-and-feel/com.github.vinceliuice.Layan" ~/.local/share/plasma/look-and-feel/
printf '  ok   layan: instalado\n'

# O look-and-feel casa estilo, cores e decoracao de uma vez. Sem --resetLayout
# ele nao mexe no painel, entao o RicePanel fica onde esta.
plasma-apply-lookandfeel -a com.github.vinceliuice.Layan >/dev/null 2>&1
# O look-and-feel traz o esquema de cores claro do Layan junto; o escuro entra depois.
plasma-apply-colorscheme LayanBlack >/dev/null 2>&1
kwriteconfig6 --file ~/.config/Kvantum/kvantum.kvconfig --group General --key theme LayanBlack
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
# O look-and-feel troca o tema de icones pelo dele; as pastas amarelas voltam aqui.
kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-yellow-dark
qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
printf '  ok   layan: aplicado (estilo, cores, decoracao, kvantum)\n'
