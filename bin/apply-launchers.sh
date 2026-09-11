#!/usr/bin/env bash
# Fixa os lancadores da barra de tarefas, na ordem de uso: Dolphin, Chrome, Discord, RCode.
# O menu iniciar e applet separado (kickoff), ja no painel de fabrica -- nao entra aqui.
#
# Chrome pelo google-chrome.desktop, e nao pelo com.google.Chrome.desktop: a janela anuncia
# a classe `google-chrome`, e so o .desktop de nome igual funde o icone fixado com a janela
# aberta. O rcode.desktop quem instala e o proprio RCode (scripts/instalar.mjs); aqui so se
# aponta pra ele, igual o setup faz com o RicePanel.
#
# Idempotente e silencioso: so age quando a lista esta diferente. Quando age, derruba o
# plasmashell ANTES de gravar -- ele mantem a config em memoria e regrava o arquivo ao sair,
# entao escrever com ele de pe perde a alteracao no proximo logout.
set -uo pipefail

ARQUIVO="plasma-org.kde.plasma.desktop-appletsrc"
CAMINHO="${XDG_CONFIG_HOME:-$HOME/.config}/$ARQUIVO"
DESEJADO="applications:org.kde.dolphin.desktop,applications:google-chrome.desktop,applications:discord.desktop,applications:rcode.desktop"

[[ -f $CAMINHO ]] || exit 0
command -v kwriteconfig6 >/dev/null 2>&1 || exit 0

# O numero do applet muda a cada instalacao limpa: achar pelo plugin, nunca fixar no numero.
grupo="$(awk '
    /^\[Containments\]\[[0-9]+\]\[Applets\]\[[0-9]+\]$/ { g = $0 }
    /^plugin=org\.kde\.plasma\.icontasks$/ { print g; exit }
' "$CAMINHO")"

[[ $grupo =~ ^\[Containments\]\[([0-9]+)\]\[Applets\]\[([0-9]+)\]$ ]] || exit 0
cont="${BASH_REMATCH[1]}"
applet="${BASH_REMATCH[2]}"

cfg=(--file "$ARQUIVO" --group Containments --group "$cont" --group Applets --group "$applet"
     --group Configuration --group General --key launchers)

[[ "$(kreadconfig6 "${cfg[@]}" 2>/dev/null)" == "$DESEJADO" ]] && exit 0

de_pe=0
if /usr/bin/systemctl --user is-active --quiet plasma-plasmashell.service; then
    /usr/bin/systemctl --user stop plasma-plasmashell.service
    de_pe=1
fi

kwriteconfig6 "${cfg[@]}" "$DESEJADO"

if (( de_pe )); then
    /usr/bin/systemctl --user start plasma-plasmashell.service
fi
