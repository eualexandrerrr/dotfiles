# Windows Modern Lock Screen (Session Lock — Meta+L)

## What this is
A Windows 11-inspired session lock screen for KDE Plasma 6. It replaces the
Breeze lock screen when you press **Meta+L** or the screen auto-locks.

## How kscreenlocker resolves the lock screen

kscreenlocker resolves the session lock screen from the **current desktop
shell package** (`org.kde.plasma.desktop`). It does NOT load a random
standalone shell ID from `kscreenlockerrc` for Meta+L.

To theme it safely, `install-kscreenlocker.sh` creates a **complete**
user-level overlay of `org.kde.plasma.desktop`:

1. Symlink every system directory EXCEPT `lockscreen` back to the system shell.
2. Replace `contents/lockscreen` with our custom Windows Modern files.
3. On uninstall, **delete the entire user shell directory**. Never leave an
   incomplete shell behind — an incomplete shell triggers the ugly Qt widget
   fallback.

This way the shell package is always complete, and kscreenlocker never sees a
broken override.

## File Layout

The source files live here as a standalone shell package:
```
plasma/shells/org.kde.windowsmodern.lockscreen/
├── metadata.json
└── contents/
    └── lockscreen/
        ├── LockScreen.qml       # Root item (kscreenlocker entry point)
        ├── LockScreenUi.qml     # Background, clock, status, unlock UI
        ├── MainBlock.qml        # Password entry block (Win11 styled)
        ├── NoPasswordUnlock.qml # Direct unlock when no password
        ├── MediaControls.qml    # Idle media playback controls
        ├── config.qml           # Config UI
        ├── config.xml           # Config schema
        └── qmldir               # QML module definition
```

At install time, `install-kscreenlocker.sh` copies these files into:
```
~/.local/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/
```
while symlinking every other directory back to the system shell.

## Design (Win11 dark palette)

- **Background**: KDE-configured wallpaper via `WallpaperFader` (same as Breeze).
- **Dark overlay**: `#000000` @ 0.45 opacity when the unlock UI is visible.
- **Clock**: Centered, upper-middle. Segoe UI DemiBold 96px time, 24px date.
  Visible only when idle; fades out when the unlock prompt appears.
- **Status icons**: Bottom-right, icon-only (network, volume, battery). Idle only.
- **Power menu**: `#2C2C2C` fill, `#3F3F3F` border, `#33FFFFFF` item hover.
- **Password field**: 1px border, `#A0A0A0` idle / `#4CC2FF` focus (dark accent).
- **Animations**: `Kirigami.Units.veryLongDuration * 2` (~800ms), `InOutQuad`.

## Installation
```bash
./install.sh lockscreen
```

## Uninstallation / Emergency Reset
If you see the ugly fallback or get locked out:
```bash
./uninstall.sh lockscreen
```
This restores Breeze immediately.

## Testing (Safe)
```bash
/usr/libexec/kscreenlocker_greet --testing
```
Opens the lock screen in a test window without actually locking your session.
Watch the terminal for QML errors.
