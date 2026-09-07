#!/bin/bash
# ───────────────────────────────────────────────────────────────────
#  Windows Modern Start Menu — dev cycle
#
#  Pure QML applet. Installs to ~/.local/share/plasma/plasmoids/ and
#  restarts plasmashell so the new QML is picked up.
#
#  Usage:  ./dev.sh
# ───────────────────────────────────────────────────────────────────
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_ID="org.kde.windowsmodern.startmenu"
APPLETS_DIR="$HOME/.local/share/plasma/plasmoids"

BOLD="\033[1m"; GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"; RESET="\033[0m"
info()  { echo -e "${GREEN}==>${RESET} ${BOLD}$*${RESET}"; }
warn()  { echo -e "${YELLOW}==>${RESET} $*"; }
err()   { echo -e "${RED}==>${RESET} $*"; }

# ── Install ───────────────────────────────────────────────────────
info "Installing $APP_ID..."
mkdir -p "$APPLETS_DIR"
rm -rf "$APPLETS_DIR/$APP_ID"
cp -r "$SRC_DIR" "$APPLETS_DIR/"
info "Installed."

# ── Restart plasmashell ───────────────────────────────────────────
info "Restarting plasmashell..."
systemctl --user restart plasma-plasmashell.service
sleep 3

# ── Tail recent plasmashell log lines for this applet ─────────────
info "Recent log lines for $APP_ID:"
journalctl --user -u plasma-plasmashell.service --since "30 seconds ago" --no-pager 2>/dev/null \
    | grep -iE "startmenu|windowsmodern|kicker|qml|error" | tail -40 || true

info "Done."
