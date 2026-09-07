#!/usr/bin/env bash
# Decoracao de janela Klassy com o preset RiceMac (vendor/klassy): botoes redondos
# coloridos a direita na ordem minimizar, maximizar, fechar; barra de titulo opaca,
# canto de 4px e sem borda lateral.
#
# Roda depois do layan.sh: o look-and-feel do Layan poe a decoracao Aurorae dele por
# cima, entao a troca pro Klassy tem que vir por ultimo.
#
# Editar ~/.config/klassy/klassyrc na mao nao adianta -- o Klassy so releva o arquivo
# quando um preset e carregado. Por isso o ajuste mora no .klpw, nao em kwriteconfig.
set -uo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
PRESET="$DOTFILES_DIR/vendor/klassy/RiceMac.klpw"

command -v klassy-settings >/dev/null 2>&1 || { printf 'klassy: nao instalado (pacote AUR klassy)\n' >&2; exit 1; }
[[ -f $PRESET ]] || { printf 'klassy: %s ausente\n' "$PRESET" >&2; exit 1; }

# Caminho relativo o klassy-settings rejeita como "Invalid Klassy Preset file".
klassy-settings -i "$(readlink -f "$PRESET")" >/dev/null 2>&1
klassy-settings -w RiceMac >/dev/null 2>&1 || { printf 'klassy: preset RiceMac nao carregou\n' >&2; exit 1; }

# O -w reescreve a posicao dos botoes no kwinrc, entao ela vem depois dele.
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.klassy
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme Klassy
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight IAX
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSize None
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false
qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
printf '  ok   klassy: preset RiceMac aplicado\n'
