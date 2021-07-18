#!/usr/bin/env bash

stylesScript=$HOME/.Xstyle-switch.sh

echo '#!/usr/bin/env bash' > $stylesScript
echo >> $stylesScript
echo 'changeStyle() {' >> $stylesScript
echo '  chmod +x $HOME/.Xrasi && echo "@import \"~/.config/styles/${1}.rasi\"" > $HOME/.Xrasi' >> $stylesScript
echo '  $HOME/.dotfiles/install.sh &> /dev/null' >> $stylesScript
echo '}' >> $stylesScript
echo >> $stylesScript
echo '# Launch Rofi' >> $stylesScript
echo 'MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' -theme $HOME/.config/polybar/scripts/rofi/styles.rasi \' >> $stylesScript

pwd=$(pwd)
cd $HOME/.config/styles
for i in $(printf '%s ' '*'); do
  i=$(basename "$i" .rasi)
  printf " $i|' ''*'" | tr -d "*''" >> $stylesScript
done
cd $pwd

sed -i '10s/^/  <<< " /' $stylesScript
sed -i '10s/$/")"/' $stylesScript

echo >> $stylesScript
echo 'case "$MENU" in' >> $stylesScript

pwd=$(pwd)
cd $HOME/.config/styles
for i in $(ls *.rasi); do
  i=$(basename "$i" .rasi)
  echo "    *$i)    changeStyle    $i    ;;" >> $stylesScript
done
cd $pwd

echo 'esac' >> $stylesScript
echo 'bash $HOME/.dotfiles/install.sh' >> $stylesScript

# END
chmod +x $stylesScript
