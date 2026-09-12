#!/usr/bin/env bash
# Poe o papel de parede do repo em qualquer desktop: a arte deitada no monitor principal e a
# em pe no monitor girado, onde o desktop souber separar os dois.
#
# Cada familia guarda isso num lugar diferente -- plasmashell por D-Bus, gsettings no GNOME,
# xfconf no XFCE, hyprpaper no Hyprland --, entao aqui e um backend por familia, igual ao
# bin/apply-screens.sh. Quem nao sabe separar por monitor recebe so a arte deitada.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

# Rodando de um tty (o setup.sh, por exemplo) nada disso esta no ambiente: pegar da sessao
# grafica de pe, senao o backend escolhido seria o errado -- ou nenhum.
for _v in XDG_CURRENT_DESKTOP XDG_SESSION_TYPE WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE; do
    [[ -n ${!_v:-} ]] && continue
    _val="$(/usr/bin/systemctl --user show-environment 2>/dev/null | sed -n "s/^$_v=//p" | head -1)"
    [[ -n $_val ]] && export "$_v=$_val"
done
unset _v _val

# Qual familia de desktop aplicar. A sessao de pe manda; sem ela (o setup.sh logo depois do
# format, antes do primeiro login) vale a escolha gravada pelo install.sh. Backend que so
# funciona com o compositor rodando sai vazio nesse caso -- quem aplica dali e a
# apply-screens.service, no login.
DEFILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/de"
familia() {
    if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then printf 'hypr'; return; fi
    case "${XDG_CURRENT_DESKTOP:-}" in
        *COSMIC*)   printf 'cosmic'; return ;;
        *KDE*)      printf 'kde';    return ;;
        *Hyprland*) printf 'hypr';   return ;;
        *XFCE*)     printf 'xfce';   return ;;
        *Cinnamon*) printf 'cinnamon'; return ;;
        *MATE*)     printf 'mate';   return ;;
        *LXQt*)     printf 'lxqt';   return ;;
        *GNOME*|*Budgie*) printf 'gnome'; return ;;
    esac

    local escolhido=""
    [[ -f $DEFILE ]] && escolhido="$(<"$DEFILE")"
    case "${escolhido//[[:space:]]/}" in
        kde)                 printf 'kde'      ;;
        gnome|budgie)        printf 'gnome'    ;;
        xfce)                printf 'xfce'     ;;
        cinnamon)            printf 'cinnamon' ;;
        mate)                printf 'mate'     ;;
        lxqt)                printf 'lxqt'     ;;
        cosmic)              printf 'cosmic'   ;;
        hyprland|nandoroid)  printf 'hypr'     ;;
    esac
}

DEITADA="$DOTFILES_DIR/wallpaper/Jason_and_Lucia_Robbery_landscape.jpg"
EM_PE="$DOTFILES_DIR/wallpaper/Real_Dimez_portrait.jpg"
[[ -f $DEITADA && -f $EM_PE ]] || exit 0

principal="$("$DOTFILES_DIR/bin/monitor.sh" principal 2>/dev/null)"
vertical="$("$DOTFILES_DIR/bin/monitor.sh" vertical 2>/dev/null)"

backend_plasma() {
    # O plasma-apply-wallpaperimage poe a mesma imagem em tudo. Pra separar por monitor e
    # preciso falar com cada containment, e isso so existe na API de script do plasmashell:
    # o desktop girado tem altura maior que largura, e e esse que recebe a arte em pe.
    local js
    js=$(cat <<JS
var deitada = "file://$DEITADA";
var em_pe = "file://$EM_PE";
for (var i = 0; i < desktops().length; i++) {
    var d = desktops()[i];
    var geo = screenGeometry(d.screen);
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    d.writeConfig("Image", geo.height > geo.width ? em_pe : deitada);
    d.writeConfig("FillMode", 2);
}
JS
)
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$js" >/dev/null 2>&1
}

# GNOME, Budgie e Cinnamon guardam no dconf e nao sabem separar por monitor: a arte deitada
# vale pros dois, com zoom. picture-uri-dark existe porque o tema escuro tem chave propria.
backend_gsettings() {
    local esquema="$1" chave="$2"
    case "$chave" in
        uri)
            gsettings set "$esquema" picture-uri "file://$DEITADA" 2>/dev/null
            gsettings set "$esquema" picture-uri-dark "file://$DEITADA" 2>/dev/null
            gsettings set "$esquema" picture-options zoom 2>/dev/null
            ;;
        filename)
            gsettings set "$esquema" picture-filename "$DEITADA" 2>/dev/null
            gsettings set "$esquema" picture-options zoom 2>/dev/null
            ;;
    esac
}

# O XFCE guarda uma imagem por monitor, com o nome que o X da a saida -- por isso o
# monitor.sh --xrandr. image-style 5 e "zoomed".
backend_xfce() {
    local px vx alvo img
    px="$("$DOTFILES_DIR/bin/monitor.sh" --xrandr principal 2>/dev/null)"
    vx="$("$DOTFILES_DIR/bin/monitor.sh" --xrandr vertical 2>/dev/null)"
    for alvo in "$px:$DEITADA" "$vx:$EM_PE"; do
        [[ -n ${alvo%%:*} ]] || continue
        img="${alvo#*:}"
        local base="/backdrop/screen0/monitor${alvo%%:*}/workspace0"
        xfconf-query -c xfce4-desktop -p "$base/last-image" -n -t string -s "$img" 2>/dev/null
        xfconf-query -c xfce4-desktop -p "$base/image-style" -n -t int -s 5 2>/dev/null
    done
}

backend_lxqt() {
    # O pcmanfm-qt desenha o desktop no LXQt e aceita uma imagem por tela na linha de comando.
    pcmanfm-qt --set-wallpaper="$DEITADA" --wallpaper-mode=crop >/dev/null 2>&1
}

# O hyprpaper e quem desenha papel de parede no Hyprland: config declarativa, uma linha por
# saida, e ele mesmo recarrega quando o arquivo muda (ou no proximo login).
backend_hyprpaper() {
    command -v hyprpaper >/dev/null 2>&1 || return 0
    mkdir -p "$CFG/hypr"
    {
        printf '# Gerado por ~/.dotfiles/bin/apply-wallpaper.sh -- nao edite aqui.\n'
        printf 'preload = %s\n' "$DEITADA" "$EM_PE"
        [[ -n $principal ]] && printf 'wallpaper = %s,%s\n' "$principal" "$DEITADA"
        [[ -n $vertical ]] && printf 'wallpaper = %s,%s\n' "$vertical" "$EM_PE"
        printf 'splash = false\n'
    } > "$CFG/hypr/hyprpaper.conf"

    if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && command -v hyprctl >/dev/null 2>&1; then
        hyprctl hyprpaper reload ,"$DEITADA" >/dev/null 2>&1
    fi
}

# O cosmic-bg guarda um arquivo por chave em ~/.config/cosmic/com.system76.CosmicBackground/v1,
# em RON: `same-on-all`, `backgrounds` com a lista de saidas e um arquivo por saida, cujo nome
# e o proprio conector. `all` e o padrao de quem nao tiver arquivo proprio.
backend_cosmic() {
    local dir="$CFG/cosmic/com.system76.CosmicBackground/v1"
    mkdir -p "$dir"
    printf 'false' > "$dir/same-on-all"
    printf '["%s", "%s"]' "$principal" "$vertical" > "$dir/backgrounds"

    entrada() {
        printf 'Entry(\n    output: "%s",\n    source: Path("%s"),\n    filter_by_theme: false,\n    rotation_frequency: 300,\n    filter_method: Lanczos,\n    scaling_mode: Zoom,\n    sampling_method: Alphanumeric,\n)\n' "$1" "$2"
    }
    entrada all "$DEITADA" > "$dir/all"
    [[ -n $principal ]] && entrada "$principal" "$DEITADA" > "$dir/$principal"
    [[ -n $vertical ]] && entrada "$vertical" "$EM_PE" > "$dir/$vertical"
    return 0
}

# O NAnDoroid nao usa hyprpaper: quem desenha o papel de parede e o proprio shell, que le
# ~/.config/nandoroid/config.json. Merge com jq, nunca sobrescrever -- o arquivo guarda todas
# as preferencias dele no shell.
backend_nandoroid() {
    local cfg="$CFG/nandoroid/config.json"
    command -v jq >/dev/null 2>&1 || return 0
    mkdir -p "$(dirname "$cfg")"
    [[ -f $cfg ]] || printf '{}\n' > "$cfg"
    local tmp
    tmp="$(mktemp)"
    if jq --arg w "file://$DEITADA" \
          '.appearance.background.wallpaperPath = $w' "$cfg" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$cfg"
    else
        rm -f "$tmp"
    fi
}

case "$(familia)" in
    kde)
        command -v qdbus6 >/dev/null 2>&1 && backend_plasma ;;
    cosmic)
        backend_cosmic ;;
    hypr)
        # NAnDoroid e Hyprland puro dividem a familia: o shell tem config propria, o Hyprland
        # de fabrica depende do hyprpaper. Rodar os dois nao atrapalha quem nao usa o outro.
        [[ -d "$CFG/quickshell/nandoroid" ]] && backend_nandoroid
        backend_hyprpaper ;;
    xfce)
        command -v xfconf-query >/dev/null 2>&1 && backend_xfce ;;
    cinnamon)
        backend_gsettings org.cinnamon.desktop.background uri ;;
    mate)
        backend_gsettings org.mate.background filename ;;
    lxqt)
        command -v pcmanfm-qt >/dev/null 2>&1 && backend_lxqt ;;
    gnome)
        backend_gsettings org.gnome.desktop.background uri ;;
esac
