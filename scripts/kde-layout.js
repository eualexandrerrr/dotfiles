var existentes = panels();
for (var i = 0; i < existentes.length; i++) { existentes[i].remove(); }

var p = new Panel;
p.location = "bottom";
p.alignment = "center";
p.lengthMode = "fill";
p.floating = true;
p.hiding = "none";
p.height = 48;

var esq = p.addWidget("org.kde.plasma.panelspacer");
esq.currentConfigGroup = ["General"];
esq.writeConfig("expanding", true);

var menu = p.addWidget("org.kde.plasma.kickoff");
menu.currentConfigGroup = ["General"];
menu.writeConfig("icon", "start-here-symbolic");
menu.writeConfig("favoritesDisplay", 0);
menu.writeConfig("applicationsDisplay", 0);
menu.writeConfig("showActionButtonCaptions", false);
menu.writeConfig("compactMode", false);

var tarefas = p.addWidget("org.kde.plasma.icontasks");
tarefas.currentConfigGroup = ["General"];
tarefas.writeConfig("launchers", ["applications:org.kde.dolphin.desktop", "applications:google-chrome.desktop", "applications:kitty.desktop", "applications:discord.desktop", "applications:steam.desktop"]);
tarefas.writeConfig("iconSpacing", 1);
tarefas.writeConfig("showOnlyCurrentDesktop", false);

var dir = p.addWidget("org.kde.plasma.panelspacer");
dir.currentConfigGroup = ["General"];
dir.writeConfig("expanding", true);

var tray = p.addWidget("org.kde.plasma.systemtray");

var relogio = p.addWidget("org.kde.plasma.digitalclock");
relogio.currentConfigGroup = ["Appearance"];
relogio.writeConfig("showDate", true);
relogio.writeConfig("dateFormat", "shortDate");
relogio.writeConfig("use24hFormat", 2);

p.addWidget("org.kde.plasma.showdesktop");
