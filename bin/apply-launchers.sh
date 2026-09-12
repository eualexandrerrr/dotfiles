#!/usr/bin/env bash
# Fixa os lancadores da barra de tarefas, na ordem de uso: Dolphin, Chrome, Discord, VS Code.
# O menu iniciar e applet separado (kickoff), ja no painel de fabrica -- nao entra aqui.
#
# Chrome pelo google-chrome.desktop, e nao pelo com.google.Chrome.desktop: a janela anuncia
# a classe `google-chrome`, e so o .desktop de nome igual funde o icone fixado com a janela
# aberta. O code-oss.desktop vem do pacote code-rcode (bin/vscode-build.sh); aqui so se
# aponta pra ele, igual o setup faz com o RicePanel.
#
# Tambem desliga o icone de auto-falante que o Plasma poe em cima de janela com audio
# (indicateAudioStreams, mesmo grupo do applet): e cosmetico, some sozinho quando o audio
# para, e o Alexandre nao quer isso na barra.
#
# Idempotente e silencioso: so age quando algo esta diferente. Quando age, derruba o
# plasmashell ANTES de gravar -- ele mantem a config em memoria e regrava o arquivo ao sair,
# entao escrever com ele de pe perde a alteracao no proximo logout.
set -uo pipefail

ARQUIVO="plasma-org.kde.plasma.desktop-appletsrc"
CAMINHO="${XDG_CONFIG_HOME:-$HOME/.config}/$ARQUIVO"
LANCADORES_DESEJADOS="applications:org.kde.dolphin.desktop,applications:google-chrome.desktop,applications:discord.desktop,applications:code-oss.desktop"

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

base=(--file "$ARQUIVO" --group Containments --group "$cont" --group Applets --group "$applet"
      --group Configuration --group General)

lancadores_atuais="$(kreadconfig6 "${base[@]}" --key launchers 2>/dev/null)"
audio_atual="$(kreadconfig6 "${base[@]}" --key indicateAudioStreams 2>/dev/null)"

[[ "$lancadores_atuais" == "$LANCADORES_DESEJADOS" && "$audio_atual" == "false" ]] && exit 0

de_pe=0
if /usr/bin/systemctl --user is-active --quiet plasma-plasmashell.service; then
    /usr/bin/systemctl --user stop plasma-plasmashell.service
    de_pe=1
fi

kwriteconfig6 "${base[@]}" --key launchers "$LANCADORES_DESEJADOS"
kwriteconfig6 "${base[@]}" --key indicateAudioStreams false

if (( de_pe )); then
    /usr/bin/systemctl --user start plasma-plasmashell.service
fi
