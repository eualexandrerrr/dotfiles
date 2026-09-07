// Windows Modern Panel — Win11-style centered taskbar layout for Plasma 6
// Applied automatically when the global theme is applied and the user
// chooses to use the desktop layout from this theme.
// Creates a bottom panel on every currently connected screen with:
//   [...........] [Start] [icon-only tasks] [...........] [system tray] [clock] [show desktop]
//
// Default height is 48px (authentic Win11 taskbar height). The same layout
// works at 30/32px — just resize the panel after applying it.
//
// NOTE: this script runs once when the global theme is applied. Monitors
// connected afterwards will not automatically get this panel; re-apply the
// theme to update all screens.

// Remove any existing panels so the global theme's layout replaces the
// previous desktop layout rather than adding a second panel.
var existingPanels = panels();
for (var i = existingPanels.length - 1; i >= 0; i--) {
    existingPanels[i].remove();
}

// Create one Windows Modern panel on every screen currently connected.
for (var screenId = 0; screenId < screenCount; screenId++) {
    createWindowsModernPanel(screenId);
}

function createWindowsModernPanel(screenId) {
    var panel = new Panel;

    // --- Panel geometry & behavior -------------------------------------------
    // Set the target screen immediately; panel config groups depend on it.
    panel.screen = screenId;
    panel.location = "bottom";
    panel.height = 48;
    panel.alignment = "center";
    panel.hiding = "none";
    panel.lengthMode = "fill";

    // Panel is docked to the screen edge (NOT floating).
    // NOTE: "Applets Only" floating (panel docked + applets inset) cannot be
    // set from a layout script. It requires the PanelView property
    // `floatingApplets`, which is not exposed in the Plasma scripting API.
    // Writing it via ConfigFile("plasmashellrc") does NOT work because
    // plasmashell holds its config in memory (KSharedConfig) and won't see
    // an external write — PanelView reads floatingApplets from its in-memory
    // cache and gets the default (false). Users must toggle "Floating →
    // Applets Only" manually in Panel Settings after applying this layout.
    panel.floating = false;

    // Opaque panel background: Plasma's default "adaptive" opacity toggles
    // translucency when windows touch the panel, which looks inconsistent.
    // Win11 keeps a stable background, so force opaque (our theme is fully
    // opaque anyway). Use "translucent" instead if blur is desired later.
    panel.opacity = "opaque";

    // --- Widgets -------------------------------------------------------------
    // Order of addWidget calls determines left-to-right order in the panel.
    // Custom applets fall back to stock Plasma widgets if not installed.

    // 1. Left expanding spacer — pushes the centered Start + tasks group to
    //    the middle of the panel, matching Win11's centered taskbar.
    var spacerLeft = panel.addWidget("org.kde.plasma.panelspacer");

    // 2. Start button — custom Win11 start menu, or fall back to Kickoff.
    var start = panel.addWidget("org.kde.windowsmodern.startmenu");
    if (!start) { start = panel.addWidget("org.kde.plasma.kickoff"); }
    start.currentConfigGroup = new Array("General");
    start.writeConfig("icon", "start-here");

    // 3. Icon-only task manager — custom Win11 style, or fall back to stock.
    var tasks = panel.addWidget("org.kde.plasma.icontasks");
    if (!tasks) { tasks = panel.addWidget("org.kde.plasma.icontasks"); }
    tasks.currentConfigGroup = new Array("General");
    tasks.writeConfig("launchers", "");
    tasks.writeConfig("showOnlyCurrentScreen", "false");
    tasks.writeConfig("showOnlyCurrentDesktop", "false");
    tasks.writeConfig("showOnlyCurrentActivity", "false");
    tasks.writeConfig("groupingStrategy", "1");

    // 4. Right expanding spacer — separates the centered Start + tasks group
    //    from the system tray / clock on the far right.
    var spacerRight = panel.addWidget("org.kde.plasma.panelspacer");

    // 5. System tray — custom Win11/10 hybrid tray, or fall back to stock.
    var tray = panel.addWidget("org.kde.windowsmodern.systemtray");
    if (!tray) { tray = panel.addWidget("org.kde.plasma.systemtray"); }

    // 6. Digital clock — Win11 puts the clock at the far right, with the date
    //    stacked below the time. Use the custom Windows Modern digital clock
    //    so the compact view respects padding and matches the icon-task icon
    //    height. Fall back to the upstream clock if the custom applet is not
    //    installed.
    //    autoFontAndSize = true lets the clock follow the system font while
    //    compactPadding still keeps vertical padding around the text.
    //    use24hFormat = 1 lets the clock follow the user's locale/region
    //    defaults instead of forcing 12- or 24-hour time.
    //    dateDisplayFormat = 2 forces the date below the time (BelowTime).
    var clock = panel.addWidget("org.kde.windowsmodern.digitalclock");
    if (!clock) { clock = panel.addWidget("org.kde.plasma.digitalclock"); }
    clock.currentConfigGroup = new Array("Appearance");
    clock.writeConfig("autoFontAndSize", "true");
    clock.writeConfig("showDate", "true");
    clock.writeConfig("dateDisplayFormat", "2");
    clock.writeConfig("showSeconds", "0");
    clock.writeConfig("use24hFormat", "1");
    clock.writeConfig("compactPadding", "0.18");
    clock.writeConfig("expandedWidth", "320");

    // 7. Show Desktop — custom Win11-style thin sliver, or fall back to stock.
    var peek = panel.addWidget("org.kde.windowsmodern.showdesktop");
    if (!peek) { peek = panel.addWidget("org.kde.plasma.showdesktop"); }
    peek.currentConfigGroup = new Array("General");
    peek.writeConfig("size", "6");

    // Ensure correct ordering by index.
    spacerLeft.index = 0;
    start.index = 1;
    tasks.index = 2;
    spacerRight.index = 3;
    tray.index = 4;
    clock.index = 5;
    peek.index = 6;
}
