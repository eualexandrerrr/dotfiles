#!/usr/bin/env bash
# Wallpaper por monitor, com a mesma regra do MyWinISO: a imagem em pe vai para o monitor
# em pe, a paisagem vai para os outros. As duas imagens sao as mesmas que estao la, para o
# Windows e o Arch nao terem cara diferente.
#
#   ~/.dotfiles/bin/wallpaper.sh
set -uo pipefail

aqui="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(dirname "$aqui")"
destino="$HOME/.local/share/wallpapers/mywiniso"
PAISAGEM="Jason_and_Lucia_Robbery_landscape.jpg"
RETRATO="Real_Dimez_portrait.jpg"

[[ -d $repo/wallpaper ]] || { echo "sem a pasta wallpaper/ em $repo"; exit 1; }
mkdir -p "$destino"
install -m 644 "$repo/wallpaper/$PAISAGEM" "$repo/wallpaper/$RETRATO" "$destino/"

command -v awww >/dev/null 2>&1 || { echo "awww nao instalado"; exit 1; }
command -v hyprctl >/dev/null 2>&1 || { echo "sem sessao do Hyprland"; exit 0; }

if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    for _ in {1..30}; do awww query >/dev/null 2>&1 && break; sleep 0.1; done
fi
awww query >/dev/null 2>&1 || { echo "awww-daemon nao subiu"; exit 1; }

n=0
while IFS='|' read -r nome largura altura; do
    [[ -n $nome ]] || continue
    if (( altura > largura )); then img="$destino/$RETRATO"; else img="$destino/$PAISAGEM"; fi
    if awww img --outputs "$nome" --resize crop --transition-type grow --transition-fps 60 --transition-duration 1 "$img" 2>/dev/null; then
        printf '  ok   %s (%sx%s) -> %s\n' "$nome" "$largura" "$altura" "$(basename "$img")"
        n=$((n+1))
    else
        printf '  !!   %s nao aceitou o wallpaper\n' "$nome" >&2
    fi
done < <(hyprctl monitors -j | python3 -c "
import json,sys
for m in json.load(sys.stdin):
    t = m.get('transform', 0)
    w, h = m['width'], m['height']
    if t in (1, 3, 5, 7):
        w, h = h, w
    print(f\"{m['name']}|{w}|{h}\")
")

printf 'wallpaper aplicado em %d monitor(es)\n' "$n"
