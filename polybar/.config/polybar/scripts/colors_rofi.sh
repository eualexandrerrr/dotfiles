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

SDIR="$HOME/.config/polybar/scripts"

# Launch Rofi
MENU="$(rofi -no-lazy-grab -sep "|" -dmenu -i -p 'Style :' \
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
            case "$MENU" in
				## Colors
				*amber) $SDIR/colors.sh -amber ;;
				*blue) $SDIR/colors.sh -blue ;;
				*blue-grey) $SDIR/colors.sh -blue-grey ;;
				*brown) $SDIR/colors.sh -brown ;;
				*cyan) $SDIR/colors.sh -cyan ;;
				*deep-orange) $SDIR/colors.sh -deep-orange ;;
				*deep-purple) $SDIR/colors.sh -deep-purple ;;
				*green) $SDIR/colors.sh -green ;;
				*grey) $SDIR/colors.sh -grey ;;
				*indigo) $SDIR/colors.sh -indigo ;;
				*blue-light) $SDIR/colors.sh -light-blue ;;
				*green-light) $SDIR/colors.sh -light-green ;;
				*lime) $SDIR/colors.sh -lime ;;
				*orange) $SDIR/colors.sh -orange ;;
				*pink) $SDIR/colors.sh -pink ;;
				*purple) $SDIR/colors.sh -purple ;;
				*red) $SDIR/colors.sh -red ;;
				*teal) $SDIR/colors.sh -teal ;;
				*yellow) $SDIR/colors.sh -yellow
            esac
