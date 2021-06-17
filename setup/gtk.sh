#!/usr/bin/env bash

SWAY=$HOME/.config/sway/config
GTK_FILE_2="$HOME/.gtkrc-2.0"
GTK_FILE_3="$HOME/.config/gtk-3.0/settings.ini"
GTK_THEME=$(grep 'set $theme' $SWAY | awk '{ print $3 }')
GTK_ICON=$(grep 'set $icon' $SWAY | awk '{ print $3 }')
GTK_CURSOR=$(grep 'set $cursor' $SWAY | awk '{ print $3 }')
GTK_FONT=$(grep 'set $font' $SWAY | awk '{ print $3 }')
GTK_FONT2=$(grep 'set $font' $SWAY | awk '{ print $4 }')
GTK_FONT_SIZE=$(grep 'set $size_font' $SWAY | awk '{ print $3 }')

THEME_GTK="gtk-theme-name=$GTK_THEME\n
gtk-icon-theme-name=$GTK_ICON\n
gtk-cursor-theme-name=$GTK_CURSOR\n
gtk-font-name=$GTK_FONT $GTK_FONT2 $GTK_FONT_SIZE"

THEME_PLUS="gtk-cursor-theme-size=0\n
gtk-toolbar-style=GTK_TOOLBAR_BOTH\n
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR\n
gtk-button-images=1\n
gtk-menu-images=1\n
gtk-enable-event-sounds=1\n
gtk-enable-input-feedback-sounds=1\n
gtk-xft-antialias=1\n
gtk-xft-hinting=1\n
gtk-xft-hintstyle=hintfull"

mkdir -p $HOME/.config/gtk-3.0
echo -e $THEME_GTK > $GTK_FILE_2
echo -e "[Settings]" > $GTK_FILE_3
echo -e $THEME_GTK >> $GTK_FILE_3
sed -i 's/=/="/g' $GTK_FILE_2
sed -i "s/$/\"/" $GTK_FILE_2
sed -i 's/]"/]/g' $GTK_FILE_2

echo -e $THEME_PLUS >> $GTK_FILE_2
echo -e $THEME_PLUS >> $GTK_FILE_3
sed -i 's/hintfull/"hintfull"/g'   $GTK_FILE_2

sed -i "s/^ //" $GTK_FILE_2
sed -i "s/^ //" $GTK_FILE_3

chmod 644 $GTK_FILE_2
chmod 644 $GTK_FILE_3
