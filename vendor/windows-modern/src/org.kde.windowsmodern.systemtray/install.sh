#!/bin/bash
# ──────────────────────────────────────────────────────────────────
# Windows Modern System Tray — build & install
#
# This applet is a C++ Plasma::Containment (not pure QML).
# It must be compiled before installation.
# ──────────────────────────────────────────────────────────────────

set -euo pipefail

SRC_DIR=$(cd "$(dirname "$0")" && pwd)
APP_ID="org.kde.windowsmodern.systemtray"
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info()  { echo -e "${GREEN}==>${RESET} ${BOLD}$*${RESET}"; }
warn()  { echo -e "${YELLOW}==>${RESET} $*"; }
err()   { echo -e "${RED}==>${RESET} $*"; }
die()   { err "$*"; exit 1; }

# ── Check if we already have a pre‑compiled binary ────────────────
PLUGIN_SO="$SRC_DIR/build/lib/plasma/applets/${APP_ID}.so"

# ── Ask root via pkexec ─────────────────────────────────────────────
if command -v pkexec &>/dev/null; then
    PKEXEC="pkexec"
else
    die "pkexec not found. Please install policykit."
fi

# ── Detect distro ────────────────────────────────────────────────────
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID}"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# ── Install build dependencies ──────────────────────────────────────
do_deps() {
    local DISTRO
    DISTRO=$(detect_distro)

    info "Detected distro: $DISTRO"

    local DEPS_LIST=""
    case "$DISTRO" in
        fedora)
            DEPS_LIST="gcc-c++ cmake extra-cmake-modules qt6-qtbase-devel qt6-qtdeclarative-devel kf6-kpackage-devel kf6-kconfig-devel kf6-ki18n-devel kf6-kcoreaddons-devel kf6-kwindowsystem-devel kf6-kio-devel kf6-kiconthemes-devel kf6-kitemmodels-devel kf6-kservice-devel kf6-kxmlgui-devel kf6-kjobwidgets-devel kf6-kcmutils-devel libplasma-devel plasma-workspace-devel"
            PKG_CMD="dnf install -y --skip-unavailable"
            CHECK_CMD="rpm -q"
            ;;
        arch|archlinux)
            DEPS_LIST="gcc cmake extra-cmake-modules qt6-base qt6-declarative kpackage kconfig ki18n kwindowsystem kio kiconthemes kitemmodels kservice kxmlgui kjobwidgets plasma-framework plasma-workspace dbusmenu-qt6"
            PKG_CMD="pacman -S --noconfirm"
            CHECK_CMD="pacman -Qi"
            ;;
        debian|ubuntu)
            DEPS_LIST="g++ cmake extra-cmake-modules qt6-base-dev qt6-declarative-dev libkf6package-dev libkf6config-dev libkf6i18n-dev libkf6windowsystem-dev libkf6kio-dev libkf6iconthemes-dev libkf6itemmodels-dev libkf6service-dev libkf6xmlgui-dev libkf6jobwidgets-dev libplasma-dev plasma-workspace-dev libdbusmenu-qt6-dev"
            PKG_CMD="apt-get install -y"
            CHECK_CMD="dpkg -s"
            ;;
        *)
            warn "Unknown distro. You'll need to install build dependencies manually."
            warn "See BUILD.md for the list."
            return
            ;;
    esac

    # Check which packages are missing
    local MISSING=""
    for pkg in $DEPS_LIST; do
        if ! $CHECK_CMD "$pkg" &>/dev/null 2>&1; then
            MISSING="$MISSING $pkg"
        fi
    done

    if [ -z "$MISSING" ]; then
        info "All build dependencies already installed."
        return
    fi

    info "Installing build dependencies:${MISSING}"
    $PKEXEC sh -c "$PKG_CMD $MISSING"

    if [ $? -ne 0 ]; then
        die "Failed to install dependencies. Check your connection and try again."
    fi

    info "Build dependencies installed."
}

# ── Detect install paths ────────────────────────────────────────────
detect_paths() {
    # Try pkg-config for the plugin dir, fallback to known locations
    if command -v pkg-config &>/dev/null; then
        QT_PLUGIN_DIR=$(pkg-config --variable=plugindir Qt6Core 2>/dev/null || true)
    fi
    if [ -z "${QT_PLUGIN_DIR:-}" ]; then
        if [ -d /usr/lib64/qt6/plugins ]; then
            QT_PLUGIN_DIR=/usr/lib64/qt6/plugins
        elif [ -d /usr/lib/qt6/plugins ]; then
            QT_PLUGIN_DIR=/usr/lib/qt6/plugins
        else
            QT_PLUGIN_DIR=/usr/lib64/qt6/plugins
        fi
    fi

    PLUGIN_INSTALL_DIR="$QT_PLUGIN_DIR/plasma/applets"

    if command -v kf6-config &>/dev/null; then
        DATA_INSTALL_DIR=$(kf6-config --path plasmapkg 2>/dev/null | cut -d: -f1 | sed 's|/*$||')
    else
        DATA_INSTALL_DIR=/usr/share/plasma/plasmoids
    fi
}

# ── Build ──────────────────────────────────────────────────────────
do_build() {
    info "Building System Tray (Windows Modern)..."

    # Check for cmake
    if ! command -v cmake &>/dev/null; then
        die "cmake is required but not installed."
    fi

    # Check for ECM (extra-cmake-modules)
    if ! cmake --find-package -DNAME=ECM -DCOMPILER_ID=GNU -DLANGUAGE=CXX -DMODE=EXIST 2>/dev/null; then
        warn "extra-cmake-modules may not be installed."
        warn "Install with: sudo dnf install extra-cmake-modules"
    fi

    cd "$SRC_DIR"

    cmake -S "$SRC_DIR" -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build --parallel "$(nproc)"

    PLUGIN_SO="$SRC_DIR/build/lib/plasma/applets/${APP_ID}.so"

    if [ ! -f "$PLUGIN_SO" ]; then
        # Try alternate location
        PLUGIN_SO=$(find "$SRC_DIR/build" -name "${APP_ID}.so" -type f 2>/dev/null | head -1)
    fi

    if [ ! -f "${PLUGIN_SO:-}" ]; then
        die "Build completed but could not find ${APP_ID}.so in build directory."
    fi

    info "Build successful — plugin at ${PLUGIN_SO}"
}

# ── Install ─────────────────────────────────────────────────────────
do_install() {
    detect_paths

    if [ ! -f "${PLUGIN_SO:-}" ]; then
        warn "No pre-compiled binary found. Building now..."
        do_build
    fi

    info "Installing compiled plugin via pkexec..."
    info "  Plugin: $PLUGIN_INSTALL_DIR/$(basename "$PLUGIN_SO")"

    # Write a temporary install script for pkexec
    TMP_INSTALL=$(mktemp /tmp/windowsmodern-systray-install.XXXXXX)
    chmod +x "$TMP_INSTALL"

    cat > "$TMP_INSTALL" << SCRIPTEOF
#!/bin/bash
set -e

PLUGIN_SRC="$PLUGIN_SO"
PLUGIN_DST="$PLUGIN_INSTALL_DIR"
APP_ID="$APP_ID"
KPACKAGE_DIR="/usr/share/plasma/plasmoids/\$APP_ID"

# Install compiled plugin
mkdir -p "\$PLUGIN_DST"
cp "\$PLUGIN_SRC" "\$PLUGIN_DST/"

# Ensure no stale KPackage copy exists: the compiled .so already embeds
# QML/config via ecm_target_qml_sources. A KPackage at the same plugin id
# causes the dark-rectangle popup bug.
rm -rf "\$KPACKAGE_DIR"

echo "Installation complete."
SCRIPTEOF

    $PKEXEC bash "$TMP_INSTALL"
    rm -f "$TMP_INSTALL"

    # Prune stale local copies that take precedence over the system plugin
    rm -rf "$HOME/.local/share/plasma/plasmoids/$APP_ID" 2>/dev/null || true
    rm -f "$HOME/.local/lib64/qt6/plugins/plasma/applets/$APP_ID.so" 2>/dev/null || true
    rm -f "$HOME/.local/lib/qt6/plugins/plasma/applets/$APP_ID.so" 2>/dev/null || true

    info "Files installed."
}

# ── Restart plasmashell ────────────────────────────────────────────
do_restart() {
    info "Restarting plasmashell to pick up new applet..."

    # Try systemd user service first
    if systemctl --user is-active plasma-plasmashell.service &>/dev/null; then
        systemctl --user restart plasma-plasmashell.service
    else
        # Fallback: kill and restart
        kquitapp6 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null || true
        sleep 1
        nohup plasmashell --replace >/dev/null 2>&1 &
    fi

    info "PlasmaShell restarted."
}

# ── Main ────────────────────────────────────────────────────────────

case "${1:-build-install}" in
    deps)
        do_deps
        ;;
    build)
        do_deps
        do_build
        ;;
    install)
        do_install
        ;;
    build-install)
        do_deps
        do_build
        do_install
        do_restart
        ;;
    install-only)
        # Install pre-compiled binary without building
        if [ ! -f "${PLUGIN_SO:-}" ]; then
            die "No pre-compiled binary found at ${PLUGIN_SO:-}. Run 'build' first."
        fi
        do_install
        do_restart
        ;;
    uninstall)
        detect_paths
        info "Uninstalling via pkexec..."
        TMP_UNINSTALL=$(mktemp /tmp/windowsmodern-systray-uninstall.XXXXXX)
        chmod +x "$TMP_UNINSTALL"
        cat > "$TMP_UNINSTALL" << SCRIPTEOF
#!/bin/bash
set -e
rm -f "$PLUGIN_INSTALL_DIR/$APP_ID.so"
rm -rf "/usr/share/plasma/plasmoids/$APP_ID"
rm -rf "$DATA_INSTALL_DIR/$APP_ID"
echo "Uninstall complete."
SCRIPTEOF
        $PKEXEC bash "$TMP_UNINSTALL"
        rm -f "$TMP_UNINSTALL"
        info "Uninstalled. Restart plasmashell to remove the applet."
        ;;
    *)
        echo "Usage: $0 {build|install|build-install|install-only|uninstall}"
        echo ""
    echo "  build          — compile C++ only"
    echo "  install        — install pre-built .so (build first)"
    echo "  build-install  — build + install + restart (default)"
    echo "  install-only   — install from existing build dir"
    echo "  uninstall      — remove from system"
        exit 1
        ;;
esac
