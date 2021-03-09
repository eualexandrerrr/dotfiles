#!/usr/bin/env bash

SWAY=$HOME/.config/sway/config
GTK_FILE_2="$HOME/.gtkrc-2.0"
GTK_FILE_3="$HOME/.config/gtk-3.0/settings.ini"
GTK_THEME=$(grep 'set $theme' $SWAY | awk '{ print $3 }')
GTK_ICON=$(grep 'set $icon' $SWAY | awk '{ print $3 }')
GTK_CURSOR=$(grep 'set $cursor' $SWAY | awk '{ print $3 }')
GTK_FONT=$(grep 'set $font' $SWAY | awk '{ print $3 }')

THEME_GTK="gtk-theme-name=$GTK_THEME\n
gtk-icon-theme-name=$GTK_ICON\n
gtk-cursor-theme-name=$GTK_CURSOR\n
gtk-font-name=$GTK_FONT"

mkdir -p $HOME/.config/gtk-3.0
echo -e $THEME_GTK > $GTK_FILE_2
echo -e "[Settings]" > $GTK_FILE_3
echo -e $THEME_GTK >> $GTK_FILE_3
sed -i "s/^ //" $GTK_FILE_2
sed -i "s/^ //" $GTK_FILE_3
sed -i "s/=/=\"/g" $GTK_FILE_3
sed -i "s/$/\"/" $GTK_FILE_3
sed -i "s/]\"/]/g" $GTK_FILE_3

chmod 644 $GTK_FILE_2
chmod 644 $GTK_FILE_3

echo
echo $GTK_FILE2
cat $GTK_FILE_2

echo
echo $GTK_FILE3
cat $GTK_FILE_3
