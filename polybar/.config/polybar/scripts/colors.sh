#!/bin/bash

## Author : Aditya Shakya
## Github : adi1090x

polydir="$HOME/.config/polybar"
launch="$HOME/.config/polybar/launch.sh"

if  [[ $1 = "-amber" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #FFA000/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #FFB300/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #FFC107/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #FFCA28/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #FFD54F/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #FFE082/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-blue" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #1976D2/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #1E88E5/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #2196F3/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #42A5F5/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #64B5F6/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #90CAF9/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-blue-grey" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #455A64/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #546E7A/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #607D8B/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #78909C/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #90A4AE/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #B0BEC5/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #546E7A/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-brown" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #5D4037/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #6D4C41/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #795548/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #8D6E63/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #A1887F/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #BCAAA4/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #6D4C41/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-cyan" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #0097A7/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #00ACC1/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #00BCD4/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #26C6DA/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #4DD0E1/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #80DEEA/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #00ACC1/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-deep-orange" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #E64A19/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #F4511E/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #FF5722/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #FF7043/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #FF8A65/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #FFAB91/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #F4511E/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-deep-purple" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #512DA8/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #5E35B1/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #673AB7/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #7E57C2/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #9575CD/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #B39DDB/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #5E35B1/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-green" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #388E3C/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #43A047/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #4CAF50/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #66BB6A/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #81C784/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #A5D6A7/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #43A047/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-grey" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #616161/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #757575/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #9E9E9E/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #BDBDBD/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #D4D4D4/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #EEEEEE/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #757575/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-indigo" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #303F9F/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #3949AB/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #3F51B5/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #5C6BC0/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #7986CB/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #9FA8DA/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #3949AB/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-light-blue" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #0288D1/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #039BE5/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #03A9F4/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #29B6F6/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #4FC3F7/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #81D4FA/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #039BE5/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-light-green" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #689F38/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #7CB342/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #8BC34A/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #9CCC65/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #AED581/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #C5E1A5/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #7CB342/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-lime" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #AFB42B/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #C0CA33/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #CDDC39/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #D4E157/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #DCE775/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #E6EE9C/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #C0CA33/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-orange" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #F57C00/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #FB8C00/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #FF9800/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #FFA726/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #FFB74D/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #FFCC80/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #FB8C00/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-pink" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #C2185B/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #D81B60/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #E91E63/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #EC407A/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #F06292/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #F48FB1/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #D81B60/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-purple" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #7B1FA2/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #8E24AA/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #9C27B0/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #AB47BC/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #BA68C8/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #CE93D8/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #8E24AA/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-red" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #D32F2F/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #E53935/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #EE413D/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #EF5350/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #E57373/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #EF9A9A/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #E53935/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-teal" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #00796B/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #00897B/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #009688/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #26A69A/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #4DB6AC/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #80CBC4/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #00897B/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

elif  [[ $1 = "-yellow" ]]; then
# Replacing colors
sed -i -e 's/shade1 = .*/shade1 = #FBC02D/g' $polydir/colors.conf
sed -i -e 's/shade2 = .*/shade2 = #FDD835/g' $polydir/colors.conf
sed -i -e 's/shade3 = .*/shade3 = #FFEB3B/g' $polydir/colors.conf
sed -i -e 's/shade4 = .*/shade4 = #FFEE58/g' $polydir/colors.conf
sed -i -e 's/shade5 = .*/shade5 = #FFF176/g' $polydir/colors.conf
sed -i -e 's/shade6 = .*/shade6 = #FFF59D/g' $polydir/colors.conf
sed -i -e 's/accent = .*/accent = #FDD835/g' $polydir/colors.conf
sed -i -e 's/bg = .*/bg = #141C21/g' $polydir/colors.conf
# Restarting polybar
$launch &

else
echo "Available options:
-amber		-blue			-blue-grey		-brown
-cyan		-deep-orange		-deep-purple		-green
-grey		-indigo			-light-blue		-light-green
-lime		-orange			-pink			-purple
-red		-teal			-yellow"
fi
