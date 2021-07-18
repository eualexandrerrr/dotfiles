#!/usr/bin/env bash

easyMenuScript=$HOME/.Xeasy-menu.sh

echo '#!/usr/bin/env bash' > $easyMenuScript
echo >> $easyMenuScript
echo 'changeStyle() {' >> $easyMenuScript
echo '  chmod +x $HOME/.Xrasi && echo "@import \"~/.config/styles/${1}.rasi\"" > $HOME/.Xrasi' >> $easyMenuScript
echo '  $HOME/.dotfiles/install.sh &> /dev/null' >> $easyMenuScript
echo '}' >> $easyMenuScript
echo >> $easyMenuScript
echo '# Launch Rofi' >> $easyMenuScript
echo 'MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' -theme $HOME/.config/polybar/scripts/rofi/easy-menu.rasi \' >> $easyMenuScript

pwd=$(pwd)
cd $HOME/.config/styles
for i in $(ls $HOME/.dotfiles/rofi/.config/rofi/applets/*.sh); do
  i=$(basename "$i" .sh)
  printf " $i|' ''*'" | tr -d "*''" >> $easyMenuScript
done
cd $pwd

sed -i '10s/^/  <<< " /' $easyMenuScript
sed -i '10s/$/")"/' $easyMenuScript

echo >> $easyMenuScript
echo 'case "$MENU" in' >> $easyMenuScript

pwd=$(pwd)
cd $HOME/.config/styles
for i in $(ls $HOME/.dotfiles/rofi/.config/rofi/applets/*.sh); do
  i=$(basename "$i" .sh)
  echo "    *$i) source $HOME/.config/rofi/applets/$i.sh ;;" >> $easyMenuScript
done
cd $pwd

echo 'esac' >> $easyMenuScript

# END
chmod +x $easyMenuScript
