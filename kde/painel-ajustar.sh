#!/usr/bin/env bash
# Repoe as decisoes do painel: opacidade, flutuante e a configuracao do gerenciador de
# tarefas. Idempotente -- rode sempre que o painel voltar ao padrao, o que acontece toda
# vez que um look-and-feel e aplicado por cima.
#
#   kde/painel-ajustar.sh
#
# Chamado pelo kde/layout-once.sh depois que o tema entra.

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
#   showToolTips         false troca as miniaturas grandes por uma lista compacta ao
#                        passar o mouse num app com varias janelas. Nao ha ajuste de
#                        tamanho: a miniatura e gridUnit*16, derivada da fonte, e a
#                        lista e a unica alternativa menor que o applet oferece.
# ── area de trabalho sem icones ──────────────────────────────────────────────
# O XDG_DESKTOP_DIR aponta pra uma pasta escondida e vazia (a home enxuta nao tem
# "Area de trabalho"). Sem reapontar os containments, a Vista de Pasta continua lendo
# o $HOME antigo e a area de trabalho vira uma vitrine das pastas de projeto.
qdbus6 "${PS[@]}" '
var n = 0;
for (var i = 0; i < desktops().length; i++) {
  var d = desktops()[i];
  d.currentConfigGroup = ["General"];
  d.writeConfig("url", "file://" + "'"$HOME"'/.local/share/desktop");
  n++;
}
print("areas de trabalho reapontadas: " + n);' >/dev/null 2>&1 \
    || printf 'painel: nao consegui reapontar a area de trabalho\n' >&2

# ── um painel so, nunca na tela vertical ─────────────────────────────────────
# O monitor em pe e ocupado em tela cheia pelo RicePanel: painel ali so rouba altura.
# A regra e por geometria, nao por indice de tela -- o indice muda quando o kscreen
# reordena as saidas, a orientacao nao.
qdbus6 "${PS[@]}" '
var ps = panels();
for (var i = 0; i < ps.length; i++) {
  var g = screenGeometry(ps[i].screen);
  if (g.height > g.width) { print("painel removido da tela vertical: " + ps[i].id); ps[i].remove(); }
}' 2>/dev/null || printf 'painel: nao consegui checar as telas verticais\n' >&2

painel_da_horizontal() {
    qdbus6 "${PS[@]}" '
var ps = panels();
for (var i = 0; i < ps.length; i++) {
  var g = screenGeometry(ps[i].screen);
  if (g.width >= g.height) { print(ps[i].id); break; }
}' 2>/dev/null | tr -dc '0-9'
}

qdbus6 "${PS[@]}" '
var p = null;
var ps = panels();
for (var i = 0; i < ps.length; i++) { var g = screenGeometry(ps[i].screen); if (g.width >= g.height) { p = ps[i]; break; } }
if (!p) { print("sem painel em tela horizontal"); }
var ids = p ? p.widgetIds : [];
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
  w.writeConfig("showToolTips", false);
  print("tarefas: " + w.type + " id=" + w.id);
}' >/dev/null 2>&1 || printf 'painel: nao consegui ajustar o gerenciador de tarefas\n' >&2

# ── menu iniciar ─────────────────────────────────────────────────────────────
# A coluna da direita do menu lista Documentos, Imagens e Musica por padrao -- pastas que a
# home enxuta nao tem. E o botao de suspender nao faz nada nesta maquina.
qdbus6 "${PS[@]}" '
var ps = panels();
for (var i = 0; i < ps.length; i++) {
  var ids = ps[i].widgetIds;
  for (var j = 0; j < ids.length; j++) {
    var w = ps[i].widgetById(ids[j]);
    if (w.type !== "org.kde.windowsmodern.startmenu") continue;
    w.currentConfigGroup = ["General"];
    w.writeConfig("rightColumnItems", ["home","downloads","recent","thispc","update","terminal","run"]);
    w.writeConfig("showSleepButton", false);
    print("menu iniciar: sem Documentos/Imagens/Musica, sem suspender");
  }
}' >/dev/null 2>&1 || printf 'painel: nao consegui ajustar o menu iniciar\n' >&2

# ── opacidade e flutuante ────────────────────────────────────────────────────
# Nao da pra fazer pela API de script: o setter de opacity nao grava nada e o de floating
# so vale ate o plasmashell reiniciar. Os dois moram no plasmashellrc, lido no boot dele.
#
# floating=0 (encostado) e obrigatorio, nao gosto pessoal. Flutuante, a janela do painel
# fica com 64px (48 de painel + 16 de folga), mas o KWin so reserva os 48: os 16 sobram
# por cima da janela maximizada e comem o rodape dela. Medido no ASUS (tela em y=262,
# altura 1440): janela maximizada terminava em 1654 e o painel comecava em 1638. O Plasma
# deveria descolar o painel sozinho quando ha janela maximizada e nao descola aqui -- e
# suspeito do monitor girado 90 graus na origem, que bagunca o indice de tela. Com
# floating=0 o painel vai pra 1654 e a sobreposicao zera.
painel_id="$(painel_da_horizontal)"
if [[ -n $painel_id ]]; then
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $painel_id" --key floating 0
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $painel_id" --key panelOpacity 2
    printf 'painel: encostado e translucido (Panel %s)\n' "$painel_id"
else
    printf 'painel: nao descobri o id\n' >&2
fi

# O plasmashell le o plasmashellrc so quando sobe. Reiniciar nao perde janela nenhuma --
# quem nao pode reiniciar no Wayland e o KWin.
systemctl --user restart plasma-plasmashell.service 2>/dev/null || true
