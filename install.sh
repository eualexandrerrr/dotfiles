#!/usr/bin/env bash
# github.com/mamutal91

clear

cd $HOME/.dotfiles
for DOTFILES in $(find . -maxdepth 1  -not -name "etc" ! -name ".*" ! -name "setup" ! -name "vim" -type d -printf '%f\n')
do
  stow --adopt $DOTFILES || echo "Error on gnu/stow"
  echo "$DOTFILES stowed."
done

# etc
if [ "$HOSTNAME" = "odin" ];
then
  $HOME/.dotfiles/setup/etc.sh || echo "Error configure etc"
  echo "/etc configured."
fi

play $HOME/.bin/sounds/completed.wav
swaymsg reload
exit 0
