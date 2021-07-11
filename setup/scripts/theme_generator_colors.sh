#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

Xrasi=$HOME/.Xrasi
Xresources=$HOME/.Xresources
Xpolybar=$HOME/.Xpolybar

# Definir um tema padrão pois não pode faltar
if [[ ! -f $Xrasi ]]; then
  echo "${RED}Xrasi ${GRE}created."
  echo '@import "~/.config/styles/dark.rasi"' | sudo tee $Xrasi
  cat $Xrasi
fi

# Capturando tema atual
currentTheme=$(cat $Xrasi | tr -d '"' | cut -c26-50)
currentTheme=$(basename $currentTheme .rasi)
rasi=$HOME/.config/styles/${currentTheme}.rasi

# Cores padrão
white=#FFFFFF
black=#000000
red=#EC7875
pink=#EC6798
purple=#BE78D1
blue=#75A4CD
cyan=#00C7DF
teal=#00B19F
green=#61C766
lime=#B9C244
yellow=#EBD369
amber=#EDB83F
orange=#E57C46
brown=#AC8476
gray=#9E9E9E
indigo=#6C77BB

createXpolybar() {
  echo "[color]
  accent = #A9C03F
  background = #141c21
  background-light = #1C252A
  foreground = #93a1a1
  foreground-light = #93a1a1
  on = #5BB462
  off = #DE635E

  white = $white
  black = $black
  red = $red
  pink = $pink
  purple = $purple
  blue = $blue
  cyan = $cyan
  teal = $teal
  green = $green
  lime = $lime
  yellow = $yellow
  amber = $amber
  orange = $orange
  brown = $brown
  gray = $gray
  indigo = $indigo" | tee $Xpolybar
}
[[ ! -f $Xpolybar ]] && echo "${RED}Xpolybar ${GRE}created." && createXpolybar &> /dev/null

createXresources() {
  cat $rasi | tee $Xresources

  sed -i "1d" $Xresources
  sed -i "7d" $Xresources
  sed -i "s/^  /*./" $Xresources
  sed -i '1 i\! Main colors' $Xresources

  echo -e "\n! Colors
  *.white:            $white;
  *.black:            $black;
  *.red:              $red;
  *.pink:             $pink;
  *.purple:           $purple;
  *.blue:             $blue;
  *.cyan:             $cyan;
  *.teal:             $teal;
  *.green:            $green;
  *.lime:             $lime;
  *.yellow:           $yellow;
  *.amber:            $amber;
  *.orange:           $orange;
  *.brown:            $brown;
  *.gray:             $gray;
  *.indigo:           $indigo;" | tee -a $Xresources

  echo -e "\n! Fonts {{{
  Xft.antialias: true
  Xft.hinting:   true
  Xft.rgba:      rgb
  Xft.hintstyle: hintslight
  Xft.dpi:       96
  ! }}}" | tee -a $Xresources
}
[[ ! -f $Xresources ]] && echo "${RED}Xresources ${GRE}created." && createXresources &> /dev/null

sed -i "s/^ //" $Xresources
sed -i "s/^ //" $Xpolybar
sed -i "s/^ //" $Xrasi

chmod 777 $Xresources
chmod 777 $Xpolybar
chmod 777 $Xrasi
