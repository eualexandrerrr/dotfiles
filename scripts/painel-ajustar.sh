#!/usr/bin/env bash
# Repoe as decisoes do painel: opacidade, flutuante e a configuracao do gerenciador de
# tarefas. Idempotente -- rode sempre que o painel voltar ao padrao, o que acontece toda
# vez que um look-and-feel e aplicado por cima.
#
#   scripts/painel-ajustar.sh
#
# Chamado pelo scripts/kde-layout-once.sh depois que o tema entra.

set -euo pipefail

# Array, nao string: splitting acidental em nome de servico D-Bus e erro silencioso.
PS=(org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript)

qdbus6 "${PS[@]}" "" >/dev/null 2>&1 || { printf 'painel: plasmashell nao responde\n' >&2; exit 1; }

# ── gerenciador de tarefas ───────────────────────────────────────────────────
# Escrito pela API de script porque a config de applet vive no
# plasma-org.kde.plasma.desktop-appletsrc, com o numero do applet no meio do caminho --
# esse numero muda a cada painel recriado, entao nao da pra fixar no kde-settings.conf.
#
#   launchers            os fixados. Alem de serem a barra em si, o badge de nao-lidas
#                        (API LauncherEntry do Unity, que o Plasma expoe em
#                        com.canonical.Unity) SO aparece em app fixado: sem o launcher,
#                        a contagem nao tem onde grudar. Verificado emitindo o sinal na
#                        mao -- sem fixar nao aparece nada, fixado aparece na hora.
#   indicateAudioStreams o alto-falante sobreposto no icone de quem toca som.
qdbus6 "${PS[@]}" '
var p = panels()[0];
var ids = p.widgetIds;
for (var i = 0; i < ids.length; i++) {
  var w = p.widgetById(ids[i]);
  if (w.type !== "org.kde.plasma.icontasks" && w.type !== "org.kde.plasma.taskmanager") continue;
  w.currentConfigGroup = ["General"];
  w.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:google-chrome.desktop",
    "applications:com.mitchellh.ghostty.desktop",
    "applications:discord.desktop",
    "applications:steam.desktop"
  ]);
  w.writeConfig("indicateAudioStreams", false);
  print("tarefas: " + w.type + " id=" + w.id);
}' >/dev/null 2>&1 || printf 'painel: nao consegui ajustar o gerenciador de tarefas\n' >&2

# ── opacidade e flutuante ────────────────────────────────────────────────────
# Nao da pra fazer pela API de script: o setter de opacity nao grava nada e o de floating
# so vale ate o plasmashell reiniciar. Os dois moram no plasmashellrc, lido no boot dele.
painel_id="$(qdbus6 "${PS[@]}" 'print(panels()[0].id);' 2>/dev/null | tr -dc '0-9')"
if [[ -n $painel_id ]]; then
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $painel_id" --key floating 1
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $painel_id" --key panelOpacity 2
    printf 'painel: flutuante e translucido (Panel %s)\n' "$painel_id"
else
    printf 'painel: nao descobri o id\n' >&2
fi

# O plasmashell le o plasmashellrc so quando sobe. Reiniciar nao perde janela nenhuma --
# quem nao pode reiniciar no Wayland e o KWin.
systemctl --user restart plasma-plasmashell.service 2>/dev/null || true
