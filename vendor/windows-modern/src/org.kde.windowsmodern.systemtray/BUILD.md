# Build Instructions: Windows Modern System Tray

## Prerequisites

This applet requires C++ compilation (it's a Plasma Containment, not a pure QML plasmoid).

### Install Build Dependencies

**Fedora:**
```bash
sudo dnf install gcc-c++ cmake extra-cmake-modules \
  qt6-qtbase-devel qt6-qtdeclarative-devel \
  kf6-kpackage-devel kf6-kconfig-devel kf6-ki18n-devel kf6-kcoreaddons-devel \
  kf6-kwindowsystem-devel kf6-kio-devel kf6-kiconthemes-devel \
  kf6-kitemmodels-devel kf6-kservice-devel kf6-kxmlgui-devel \
  kf6-kjobwidgets-devel kf6-kcmutils-devel \
  libplasma-devel plasma-workspace-devel plasma-workspace-libs
```

**Arch Linux:**
```bash
sudo pacman -S cmake extra-cmake-modules qt6-base qt6-declarative \
  kpackage kconfig ki18n kwindowsystem kio kiconthemes \
  kitemmodels kservice kxmlgui kjobwidgets kcmutils \
  plasma-framework plasma-workspace dbusmenu-qt6
```

**Debian/Ubuntu:**
```bash
sudo apt install cmake extra-cmake-modules \
  qt6-base-dev qt6-declarative-dev \
  libkf6package-dev libkf6config-dev libkf6i18n-dev \
  libkf6windowsystem-dev libkf6kio-dev libkf6iconthemes-dev \
  libkf6itemmodels-dev libkf6service-dev libkf6xmlgui-dev \
  libkf6jobwidgets-dev libkf6kcmutils-dev \
  libplasma-dev plasma-workspace-dev \
  libdbusmenu-qt6-dev
```

## Build

```bash
cd plasma/applets/org.kde.windowsmodern.systemtray

cmake -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build --parallel $(nproc)
```

## Install

The recommended way is to use the repository-wide installer, which builds,
installs the `.so`, removes any conflicting KPackage, prunes stale local
copies, and restarts plasmashell:

```bash
cd plasma/applets/org.kde.windowsmodern.systemtray
./dev.sh
```

Or from the repo root:

```bash
./install.sh systray
```

If you prefer a manual install:

```bash
sudo cmake --install build
systemctl --user restart plasma-plasmashell.service
```

## Local plugin shadowing

If you have an old copy of the plugin at
`~/.local/lib64/qt6/plugins/plasma/applets/org.kde.windowsmodern.systemtray.so`
(or `~/.local/lib/qt6/plugins/...`), Qt will load that local copy instead of
the system one, and your changes will appear to have no effect. The install
scripts above remove these stale copies automatically.

## Pre-compiled Binary Distribution

After building, the only runtime artifact is:

```
/usr/lib64/qt6/plugins/plasma/applets/org.kde.windowsmodern.systemtray.so
```

The QML and config files are compiled into the `.so` via
`ecm_target_qml_sources`. A separate KPackage directory at
`/usr/share/plasma/plasmoids/org.kde.windowsmodern.systemtray/` must
**not** be installed — it causes the dark-rectangle popup bug.

For distribution, bundle the `.so` with an install script that copies it to
the distro-specific Qt plugin directory. Users do not need a C++ compiler —
they just need the runtime libs which come with any Plasma installation.

## File Summary

### C++ Source (38 files)
```
systemtray.h/.cpp              - Main Plasma::Containment class
systemtraymodel.h/.cpp         - Data models (PlasmoidModel, StatusNotifierModel, SystemTrayModel)
systemtraysettings.h/.cpp      - KConfig settings management
plasmoidregistry.h/.cpp        - Applet discovery and lifecycle
dbusserviceobserver.h/.cpp     - DBus service start/stop monitoring
statusnotifieritemhost.h/.cpp  - SNI watcher singleton
statusnotifieritemsource.h/.cpp- Per-SNI data source (~700 lines)
sortedsystemtraymodel.h/.cpp   - Sorting proxy model
systemtraytypes.h/.cpp         - DBus type marshalling
systemtraytypedefs.h           - KDbusImageStruct, KDbusToolTipStruct
debug.h                        - Logging category
metadata.json                  - Plugin metadata (org.kde.windowsmodern.systemtray)
kf6_org.kde.StatusNotifierItem.xml        - DBus interface XML
kf6_org.kde.StatusNotifierWatcher.xml     - DBus interface XML
org.freedesktop.DBus.Properties.xml       - DBus interface XML
CMakeLists.txt                 - Build system
```

### QML UI
```
contents/ui/main.qml                    - Root ContainmentItem
contents/ui/AbstractItem.qml            - Base delegate for all item types
contents/ui/PlasmoidItem.qml            - Plasma applet delegate
contents/ui/StatusNotifierItem.qml      - SNI icon delegate
contents/ui/BackgroundAppItem.qml       - Flatpak background app delegate
contents/ui/ItemLoader.qml              - Dynamic delegate loader
contents/ui/CompactApplet.qml           - Applet compact view wrapper
contents/ui/ExpanderArrow.qml           - Chevron toggle button
contents/ui/ExpandedRepresentation.qml  - Popup content
contents/ui/HiddenItemsView.qml         - Hidden items grid
contents/ui/PlasmoidPopupsContainer.qml - Active applet popup container
contents/ui/ConfigGeneral.qml           - Settings page
contents/ui/SystemTrayState.qml         - State management
contents/ui/CurrentItemHighLight.qml    - Active item highlight
contents/ui/PulseAnimation.qml          - Attention pulse animation
contents/ui/config.qml                  - Config category
contents/ui/lib/                        - Reusable tiles / sliders / page chrome
contents/ui/components/                 - Quick-settings tiles and detail pages
contents/ui/js/                         - Shared JS helpers
contents/config/main.xml                - KConfig schema
```
