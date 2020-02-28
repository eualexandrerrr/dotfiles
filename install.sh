#!/bin/bash
# github.com/mamutal91

echo "Initializing configurations..."
echo "stow's..."
echo "Removing actual .dotfiles and copying /media/storage/GitHub/dotfiles from /home/mamutal91/.dotfiles"

rm -rf $HOME/.dotfiles && cp -rf /media/storage/GitHub/dotfiles $HOME/.dotfiles
rm -rf $HOME/.zshrc
cd $HOME/.dotfiles

for STOW in \
    compton \
    dunst \
    files \
    gpicview \
    home \
    i3 \
    neofetch \
    polybar \
    rofi \
    scripts \
    setup \
    smplayer \
    vim
do
    stow $STOW
done

sudo stow bbswitch -t /etc

function systemd() {
  echo "systemd's..."
  sudo rm -rf /etc/systemd/logind.conf
  sudo cp -rf $HOME/.dotfiles/systemd/logind.conf /etc/systemd
  sudo rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
  sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
  sudo cp -rf $HOME/.dotfiles/systemd/override.conf /etc/systemd/system/getty@tty1.service.d/
}

function X11() {
    echo "X11..."
    sudo rm -rf /etc/X11/nvidia-xorg.conf.d
    sudo rm -rf /etc/X11/xorg.conf.d
    sudo cp -rf $HOME/.dotfiles/X11/* /etc/X11
}

function first_boot() {
  echo "Removing default configs..."
  cd $HOME/.config
  rm -rf compton dunst files gpicview i3 neofetch polybar rofi scripts smplayer vim
  cd /etc/X11 && sudo rm -rf *
  cd $HOME
  rm -rf .crontab .nanorc .nvidia-xinitrc .Xdefaults .Xresources .zlogin .zshrc
}

#first_boot
systemd
X11

canberra-gtk-play --file=$HOME/.config/files/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh
