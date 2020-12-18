#!/bin/bash

## Author : Aditya Shakya
## Github : adi1090x

# Custom Rofi Script

BORDER="#CC6666"
SEPARATOR="#FFFFFF"
FOREGROUND="#141C21"
BACKGROUND="#FFFFFF"
BACKGROUND_ALT="#F5F5F5"
HIGHLIGHT_BACKGROUND="#E7E7E7"
HIGHLIGHT_FOREGROUND="#CC6666"

sdir="$HOME/.config/polybar/scripts"

# Launch Rofi
menu="$(rofi -no-lazy-grab -sep "|" -dmenu -i -p 'Style :' \
-hide-scrollbar true \
-bw 0 \
-lines 5 \
-line-padding 5 \
-padding 15 \
-width 15 \
-xoffset -8 -yoffset -46 \
-location 5 \
-columns 1 \
-show-icons -icon-theme "Papirus" \
-font "Terminus (TTF) 9" \
-color-enabled true \
-color-window "$BACKGROUND,$BORDER,$SEPARATOR" \
-color-normal "$BACKGROUND_ALT,$FOREGROUND,$BACKGROUND_ALT,$HIGHLIGHT_BACKGROUND,$HIGHLIGHT_FOREGROUND" \
-color-active "$BACKGROUND,$MAGENTA,$BACKGROUND_ALT,$HIGHLIGHT_BACKGROUND,$HIGHLIGHT_FOREGROUND" \
-color-urgent "$BACKGROUND,$YELLOW,$BACKGROUND_ALT,$HIGHLIGHT_BACKGROUND,$HIGHLIGHT_FOREGROUND" \
<<< "♥ amber|♥ blue|♥ blue-grey|♥ brown|♥ cyan|♥ deep-orange|♥ deep-purple|♥ green|♥ grey|♥ indigo|♥ blue-light|♥ green-light|♥ lime|♥ orange|♥ pink|♥ purple|♥ red|♥ teal|♥ yellow")"
            case "$menu" in
				## Colors
				*amber) $sdir/colors.sh -amber ;;
				*blue) $sdir/colors.sh -blue ;;
				*blue-grey) $sdir/colors.sh -blue-grey ;;
				*brown) $sdir/colors.sh -brown ;;
				*cyan) $sdir/colors.sh -cyan ;;
				*deep-orange) $sdir/colors.sh -deep-orange ;;
				*deep-purple) $sdir/colors.sh -deep-purple ;;
				*green) $sdir/colors.sh -green ;;
				*grey) $sdir/colors.sh -grey ;;
				*indigo) $sdir/colors.sh -indigo ;;
				*blue-light) $sdir/colors.sh -light-blue ;;
				*green-light) $sdir/colors.sh -light-green ;;
				*lime) $sdir/colors.sh -lime ;;
				*orange) $sdir/colors.sh -orange ;;
				*pink) $sdir/colors.sh -pink ;;
				*purple) $sdir/colors.sh -purple ;;
				*red) $sdir/colors.sh -red ;;
				*teal) $sdir/colors.sh -teal ;;
				*yellow) $sdir/colors.sh -yellow
            esac
