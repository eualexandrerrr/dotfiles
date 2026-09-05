#!/bin/bash
# ───────────────────────────────────────────────────────────────────
#  Windows Modern System Tray — dev cycle
#
#  The ONLY command to build and install this C++ applet.
#  Do NOT copy directories to ~/.local/share/plasma/plasmoids/
#  or /usr/share/plasma/plasmoids/ — that causes the dark rectangle.
#
#  Usage:  ./dev.sh
# ───────────────────────────────────────────────────────────────────
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SRC_DIR/build"
APP_ID="org.kde.windowsmodern.systemtray"
LAYOUT_FILE="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

BOLD="\033[1m"; GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"; RESET="\033[0m"
info()  { echo -e "${GREEN}==>${RESET} ${BOLD}$*${RESET}"; }
warn()  { echo -e "${YELLOW}==>${RESET} $*"; }
err()   { echo -e "${RED}==>${RESET} $*"; }

# ── Detect install paths ───────────────────────────────────────────
detect_paths() {
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
    PLUGIN_DST="$QT_PLUGIN_DIR/plasma/applets"
    KPACKAGE_DIR="/usr/share/plasma/plasmoids/${APP_ID}"
}

# ── Build ─────────────────────────────────────────────────────────
info "Building..."
cmake -S "$SRC_DIR" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release > /dev/null
cmake --build "$BUILD_DIR" --parallel "$(nproc)" 2>&1 | tail -3

# ── Stop plasmashell ──────────────────────────────────────────────
info "Stopping plasmashell..."
systemctl --user stop plasma-plasmashell.service 2>/dev/null || true
sleep 1

# ── Fix layout if corrupted ───────────────────────────────────────
if grep -q "plugin=metadata" "$LAYOUT_FILE" 2>/dev/null; then
    info "Fixing corrupted plugin=metadata in layout..."
    sed -i "/\[Containments\]\[.*\]\[Applets\]/,/\[/s/^plugin=metadata$/plugin=${APP_ID}/" "$LAYOUT_FILE"
fi

# ── Install .so only (no KPackage) ───────────────────────────────
info "Installing..."
PLUGIN_SRC="$BUILD_DIR/lib/plasma/applets/${APP_ID}.so"
detect_paths

pkexec bash -s <<INSTALLEOF
set -e
mkdir -p "$PLUGIN_DST"
cp "$PLUGIN_SRC" "$PLUGIN_DST/"
rm -rf "$KPACKAGE_DIR"
echo "Installed."
INSTALLEOF

# Also prune local copies (stale .so in ~/.local/lib* takes precedence over /usr)
rm -rf "$HOME/.local/share/plasma/plasmoids/${APP_ID}" 2>/dev/null || true
rm -f "$HOME/.local/lib64/qt6/plugins/plasma/applets/${APP_ID}.so" 2>/dev/null || true
rm -f "$HOME/.local/lib/qt6/plugins/plasma/applets/${APP_ID}.so" 2>/dev/null || true
info "Installed."

# ── Start plasmashell ────────────────────────────────────────────
# In batch mode (WM_BATCH=1) the parent 'all' driver restarts Plasma
# Shell once at the very end — skipping the start here avoids a storm
# of restarts when systray + icontasks install back-to-back.
if [ "${WM_BATCH:-0}" = "1" ]; then
    info "Installed (batch mode — Plasma Shell will restart at end of 'all')."
    exit 0
fi

info "Restarting plasmashell..."
systemctl --user start plasma-plasmashell.service
sleep 3

# ── Verify ───────────────────────────────────────────────────────
if [ -x "$SRC_DIR/verify.sh" ]; then
    info "Running health check..."
    bash "$SRC_DIR/verify.sh"
fi
