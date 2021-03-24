#!/usr/bin/env bash

I3=$HOME/.config/i3/config
GTK_FILE_1="$HOME/.gtkrc-2.0"
GTK_FILE_2="$HOME/.config/gtk-3.0/settings.ini"
XRESOURCES_FILE="$HOME/.Xresources"
GTK_THEME=$(grep 'set $theme' $I3 | awk '{ print $3 }')
GTK_ICON=$(grep 'set $icon' $I3 | awk '{ print $3 }')
GTK_CURSOR=$(grep 'set $cursor' $I3 | awk '{ print $3 }')
GTK_CURSOR2=$(grep 'set $cursor' $I3 | awk '{ print $4 }')
GTK_FONT=$(grep 'set $font' $I3 | awk '{ print $3 }')
GTK_FONT2=$(grep 'set $font' $I3 | awk '{ print $4 }')
GTK_FONT_SIZE=$(grep 'set $size_font' $I3 | awk '{ print $3 }')

THEME_GTK="gtk-theme-name=$GTK_THEME\n
gtk-icon-theme-name=$GTK_ICON\n
gtk-cursor-theme-name=$GTK_CURSOR $GTK_CURSOR2\n
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
echo -e $THEME_GTK > $GTK_FILE_1
echo -e "[Settings]" > $GTK_FILE_2
echo -e $THEME_GTK >> $GTK_FILE_2
sed -i 's/=/="/g' $GTK_FILE_1
sed -i "s/$/\"/" $GTK_FILE_1
sed -i 's/]"/]/g' $GTK_FILE_1

echo -e $THEME_PLUS >> $GTK_FILE_1
echo -e $THEME_PLUS >> $GTK_FILE_2
sed -i 's/hintfull/"hintfull"/g'   $GTK_FILE_1

sed -i "s/^ //" $GTK_FILE_1
sed -i "s/^ //" $GTK_FILE_2

chmod 644 $GTK_FILE_1
chmod 644 $GTK_FILE_2

echo -e "Xcursor.theme: $GTK_CURSOR" > $XRESOURCES_FILE
