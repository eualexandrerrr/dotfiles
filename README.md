![dotfiles](https://dotfiles.github.io/images/dotfiles-logo.png)
<p align="center"> If there is a shell, there is a way</p>
<p align="center">
  <br><br>
  <img src="https://i.imgur.com/pVGr7tX.png">
</p>

**Hey**, these are the dotfiles that I use.

It includes my `compton` `dunst` `i3-gaps` `i3lock` `polybar` `rofi` `termite` `terminus-font` `zsh` `scrot` `feh` `pywal` , ... config files.

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
cd $HOME/.dotfiles/home/.local/bin
./dotfiles.sh
```

## Screenshots

![screenshot](https://raw.githubusercontent.com/mamutal91/dotfiles/master/screenshot.png)