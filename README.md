![dotfiles](https://dotfiles.github.io/images/dotfiles-logo.png)
<p align="center">
  <br><br>
  <img src="https://i.imgur.com/pVGr7tX.png">
</p>

**Hey**, these are the dotfiles that I use.

Search on the correct way for your distribution.

`sudo pacman -S i3-gaps i3lock compton dunst rofi mpd maim scrot feh python-pywal python-setuptools plasma-browser-integration termite terminus-font`

`yay -S polybar jsoncpp --noconfirm`

## How to use

**Use `gnu-stow` to link the files.**

For example if you need my `i3` config clone the repo then inside the repo use:
`stow i3`
This will symlink the necessary files.

```
git clone https://github.com/mamutal91/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow i3
```

**Or clone the repository in the same way as above, and run the script**
```
cd $HOME/.dotfiles
./install.sh
```

## Screenshots

![screenshot](https://raw.githubusercontent.com/mamutal91/dotfiles/master/screenshot.png)