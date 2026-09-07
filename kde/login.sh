#!/usr/bin/env bash
# Tela de login: wallpaper, foto do perfil e greeter so no monitor principal.
#
#   ~/.dotfiles/kde/login.sh              instala o que esta no repo
#   ~/.dotfiles/kde/login.sh --gerar      regera o kwinoutputconfig do greeter
#
# O formato do kwinoutputconfig.json e um array com as secoes "outputs" (cada saida, casada
# por edidHash) e "setups" (quem fica ligado e onde). Escrito a mao o kwin ignora calado,
# entao o --gerar deriva do arquivo da sessao viva.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
PRINCIPAL="${PRINCIPAL:-DP-1}"
ok() { printf '  ok   %s\n' "$*"; }
aviso() { printf '  !!   %s\n' "$*" >&2; }

if [[ ${1:-} == --gerar ]]; then
    vivo="$HOME/.config/kwinoutputconfig.json"
    [[ -f $vivo ]] || { aviso "$vivo nao existe; entre no Plasma primeiro"; exit 1; }
    python3 - "$vivo" "$DOTFILES_DIR/sddm/kwinoutputconfig.json" "$PRINCIPAL" <<'PY'
import json, sys, copy
vivo, destino, principal = sys.argv[1], sys.argv[2], sys.argv[3]
orig = json.load(open(vivo))
outs = [e for e in orig if e['name'] == 'outputs'][0]['data']
setup = {"lidClosed": False, "outputs": []}
for i, o in enumerate(outs):
    é = (o.get('connectorName') == principal)
    setup['outputs'].append({"enabled": é, "outputIndex": i,
                             "position": {"x": 0, "y": 0},
                             "priority": 1 if é else -1, "replicationSource": ""})
json.dump([{"data": copy.deepcopy(outs), "name": "outputs"},
           {"data": [setup], "name": "setups"}],
          open(destino, 'w'), indent=4, ensure_ascii=False)
print(f"  ok   gerado para {principal} (de {len(outs)} saidas)")
PY
fi

if [[ -f $DOTFILES_DIR/sddm/kwinoutputconfig.json ]]; then
    sudo install -Dm644 -o sddm -g sddm "$DOTFILES_DIR/sddm/kwinoutputconfig.json" \
        /var/lib/sddm/.local/share/kwinoutputconfig.json 2>/dev/null \
        && sudo chown -R sddm:sddm /var/lib/sddm/.local 2>/dev/null \
        && ok "greeter so no $PRINCIPAL" || aviso "nao instalei a config do greeter"
fi

fundo="$DOTFILES_DIR/wallpaper/Jason_and_Lucia_Robbery_landscape.jpg"
if [[ -f $fundo ]]; then
    sudo install -Dm644 "$fundo" /usr/share/sddm/themes/breeze/dotfiles-bg.jpg 2>/dev/null \
        && printf '[General]\ntype=image\nbackground=/usr/share/sddm/themes/breeze/dotfiles-bg.jpg\nneedsFullUserModel=false\n' \
           | sudo tee /usr/share/sddm/themes/breeze/theme.conf.user >/dev/null \
        && ok "wallpaper da tela de login"
fi

if [[ -d $DOTFILES_DIR/splash ]]; then
    destino="$HOME/.local/share/plasma/look-and-feel/dotfiles-splash"
    mkdir -p "$destino"
    cp -a "$DOTFILES_DIR/splash/metadata.json" "$DOTFILES_DIR/splash/contents" "$destino/" 2>/dev/null
    cp -f "$DOTFILES_DIR/wallpaper/Jason_and_Lucia_Robbery_landscape.jpg" "$destino/contents/splash/images/fundo.jpg" 2>/dev/null
    cp -f "$DOTFILES_DIR/perfil/avatar.png" "$destino/contents/splash/images/avatar.png" 2>/dev/null
    kwriteconfig6 --file ksplashrc --group KSplash --key Theme dotfiles-splash
    kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
    ok "splash de boot"
fi

avatar="$DOTFILES_DIR/perfil/avatar.png"
if [[ -f $avatar ]]; then
    install -Dm644 "$avatar" "$HOME/.face.icon"
    sudo install -Dm644 "$avatar" "/var/lib/AccountsService/icons/$USER" 2>/dev/null
    printf '[User]\nIcon=/var/lib/AccountsService/icons/%s\nSystemAccount=false\n' "$USER" \
        | sudo tee "/var/lib/AccountsService/users/$USER" >/dev/null 2>&1
    ok "foto do perfil"
fi
