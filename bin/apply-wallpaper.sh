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

# O COSMIC guarda cada campo num arquivo separado, em RON. `same-on-all` desligado e a chave
# de ter arte diferente por monitor; a lista de saidas usa o nome do conector.
backend_cosmic() {
    local dir="$CFG/cosmic/com.system76.CosmicBackground/v1"
    mkdir -p "$dir"
    printf 'false' > "$dir/same-on-all"
    local saida img
    for saida in "$principal:$DEITADA" "$vertical:$EM_PE"; do
        [[ -n ${saida%%:*} ]] || continue
        img="${saida#*:}"
        mkdir -p "$dir/backgrounds"
        printf 'Entry(\n    output: "%s",\n    source: Path("%s"),\n    filter_by_theme: true,\n    rotation_frequency: 300,\n    filter_method: Lanczos,\n    scaling_mode: Zoom,\n    sampling_method: Alphanumeric,\n)\n' \
            "${saida%%:*}" "$img" > "$dir/output.${saida%%:*}"
    done
}

if [[ ${XDG_CURRENT_DESKTOP:-} == *KDE* ]] && command -v qdbus6 >/dev/null 2>&1; then
    backend_plasma
elif [[ ${XDG_CURRENT_DESKTOP:-} == *COSMIC* ]]; then
    backend_cosmic
elif [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] || [[ ${XDG_CURRENT_DESKTOP:-} == *Hyprland* ]]; then
    backend_hyprpaper
elif [[ ${XDG_CURRENT_DESKTOP:-} == *XFCE* ]] && command -v xfconf-query >/dev/null 2>&1; then
    backend_xfce
elif [[ ${XDG_CURRENT_DESKTOP:-} == *Cinnamon* ]]; then
    backend_gsettings org.cinnamon.desktop.background uri
elif [[ ${XDG_CURRENT_DESKTOP:-} == *MATE* ]]; then
    backend_gsettings org.mate.background filename
elif [[ ${XDG_CURRENT_DESKTOP:-} == *LXQt* ]] && command -v pcmanfm-qt >/dev/null 2>&1; then
    backend_lxqt
elif command -v gsettings >/dev/null 2>&1; then
    # GNOME, Budgie e qualquer outro que use o esquema do GNOME.
    backend_gsettings org.gnome.desktop.background uri
fi
