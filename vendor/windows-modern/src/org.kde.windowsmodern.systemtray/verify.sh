#!/bin/bash
# ───────────────────────────────────────────────────────────────────
#  verify.sh — check system tray is installed and working correctly
# ───────────────────────────────────────────────────────────────────
set -euo pipefail

APP_ID="org.kde.windowsmodern.systemtray"
SO_PATH="/usr/lib64/qt6/plugins/plasma/applets/${APP_ID}.so"
KPACKAGE_PATH="/usr/share/plasma/plasmoids/${APP_ID}"
LOCAL_KPACKAGE="$HOME/.local/share/plasma/plasmoids/${APP_ID}"
LAYOUT_FILE="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; RESET="\033[0m"
pass() { echo -e "  ${GREEN}✓${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; }

echo ""
echo "System Tray — health check"
echo "=========================="
echo ""

# 1. .so file
if [ -f "$SO_PATH" ]; then
    pass ".so installed at $SO_PATH"
else
    fail ".so NOT FOUND at $SO_PATH — run ./dev.sh"
fi

# 2. No KPackage (critical: prevents dark rectangle)
if [ -d "$KPACKAGE_PATH" ] || [ -d "$LOCAL_KPACKAGE" ]; then
    fail "KPackage EXISTS — will cause dark rectangle popup"
    echo "       Remove: sudo rm -rf $KPACKAGE_PATH $LOCAL_KPACKAGE"
else
    pass "No KPackage (dark rectangle prevented)"
fi

# 3. Layout config
if grep -q "plugin=${APP_ID}" "$LAYOUT_FILE" 2>/dev/null; then
    pass "Panel layout includes ${APP_ID}"
else
    fail "${APP_ID} not in panel layout"
fi

if grep -q "plugin=metadata" "$LAYOUT_FILE" 2>/dev/null; then
    fail "Corrupted plugin=metadata entry in layout — will cause loading error"
else
    pass "No corrupted plugin=metadata"
fi

# 4. Symbols
if [ -f "$SO_PATH" ]; then
    for sym in SYSTEM_TRAY DBUSMENUQT; do
        if [ -n "$(nm -D "$SO_PATH" 2>/dev/null | grep "_Z.*${sym}v")" ]; then
            pass "Symbol ${sym} defined"
        else
            fail "Symbol ${sym} UNDEFINED — .so won't load"
        fi
    done
fi

# 5. Recent errors
errors=$(journalctl --user -u plasma-plasmashell.service --since "1 minute ago" --no-pager 2>&1 | grep -c "error.*${APP_ID}\|Cannot load.*${APP_ID}\|undefined symbol.*${APP_ID}" || true)
if [ "$errors" -eq 0 ]; then
    pass "No recent loading errors in plasmashell"
else
    fail "$errors recent loading errors in plasmashell"
fi

echo ""
echo "To fix issues: cd plasma/applets/org.kde.windowsmodern.systemtray && ./dev.sh"
