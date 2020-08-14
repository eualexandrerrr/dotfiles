![dotfiles](https://dotfiles.github.io/images/dotfiles-logo.png)

<p align="center">
  <img src="https://img.shields.io/badge/Maintained%3F-Yes-blueviolet?style=flat-square">
  <img src="https://img.shields.io/github/license/adi1090x/polybar-themes?style=flat-square">
  <img src="https://img.shields.io/github/stars/adi1090x/polybar-themes?color=red&style=flat-square">
  <img src="https://img.shields.io/github/forks/adi1090x/polybar-themes?style=flat-square">
  <img src="https://img.shields.io/github/issues/adi1090x/polybar-themes?style=flat-square">
</p>


**Hey**, these are the dotfiles that I use.

These settings are personal, for my use, and my PC ... surely you will not have a 100% effective operation without any adjustments being made. Feel free to copy, paste, distribute, or fork the project.

Search on the correct way for your distribution.

The complete list of packages I use are here:
https://github.com/mamutal91/dotfiles/blob/master/aspire/.config/setup/packages.sh

## Arch
```
sudo pacman -S alacritty compton dunst i3-gaps rofi feh terminus-font
```

```
yay -S polybar --noconfirm
```

## How to use

**Use `gnu-stow` to link the files.**

For example if you need my `i3` config clone the repo then inside the repo use:
`stow i3`
This will symlink the necessary files.

```
git clone https://github.com/mamutal91/dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
stow i3
```

**Or clone the repository in the same way as above, and run the script**
```
cd $HOME/.dotfiles
./install.sh
```

## Screenshots

### i3-gaps
![screenshot](https://raw.githubusercontent.com/mamutal91/dotfiles/master/files/.config/files/screenshots/i3-gaps.jpg)
### i3-lock
![screenshot](https://raw.githubusercontent.com/mamutal91/dotfiles/master/files/.config/files/screenshots/i3-lock.jpg)
### neofetch
![screenshot](https://raw.githubusercontent.com/mamutal91/dotfiles/master/files/.config/files/screenshots/neofetch.jpg)
