#!/usr/bin/env bash
# github.com/mamutal91

clear

cd ~/.dotfiles
for DOTFILES in $(find . -maxdepth 1  -not -name "etc" ! -name ".*" ! -name "setup" -type d -printf '%f\n')
do
  stow --adopt $DOTFILES || echo "Error on gnu/stow"
  echo "$DOTFILES stowed."
done

# etc
if [ "$USER" = "mamutal91" ];
then
  sudo stow --adopt -t /etc etc || echo "Error on gnu/stow (/etc)"
  echo "/etc stowed."
fi

play $HOME/.bin/sounds/completed.wav
pkill waybar && exec waybar
swaymsg reload
exit 0
