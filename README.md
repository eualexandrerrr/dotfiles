![dotfiles](https://dotfiles.github.io/images/dotfiles-logo.png)
<p align="center">
  <br><br>
  <img src="https://i.imgur.com/pVGr7tX.png">
</p>

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/mamutal91/dotfiles)
![GitHub repo size](https://img.shields.io/github/repo-size/mamutal91/dotfiles)
![GitHub contributors](https://img.shields.io/github/contributors/mamutal91/dotfiles)
![GitHub last commit](https://img.shields.io/github/last-commit/mamutal91/dotfiles)
![GitHub language count](https://img.shields.io/github/languages/count/mamutal91/dotfiles)
![GitHub top language](https://img.shields.io/github/languages/top/mamutal91/dotfiles)

![GitHub followers](https://img.shields.io/github/followers/mamutal91?style=social)
![GitHub forks](https://img.shields.io/github/forks/mamutal91/dotfiles?style=social)
![GitHub stars](https://img.shields.io/github/stars/mamutal91/dotfiles?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/mamutal91/dotfiles?style=social)


**Hey**, these are the dotfiles that I use.

These settings are personal, for my use, and my PC ... surely you will not have a 100% effective operation without any adjustments being made. Feel free to copy, paste, distribute, or fork the project.

Search on the correct way for your distribution.

The complete list of packages I use are here:
https://github.com/mamutal91/dotfiles/blob/master/setup/.config/setup/packages.sh

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
