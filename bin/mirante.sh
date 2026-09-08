#!/usr/bin/env bash
set -uo pipefail

APP="${MIRANTE_DIR:-$HOME/Apps/desktop/RicePanel}"
ELECTRON="$APP/node_modules/electron/dist/electron"

[ -x "$ELECTRON" ] || exit 0

rm -f "$APP/mirante-stop.flag"
cd "$APP" || exit 0
exec "$ELECTRON" .
