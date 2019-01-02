![dotfiles](https://dotfiles.github.io/images/dotfiles-logo.png)
<p align="center"> If there is a shell, there is a way</p>
<p align="center">
  <img src="https://img.shields.io/badge/Editor-neovim-brightgreen.svg" />
  <img src="https://img.shields.io/badge/Terminal-Alacritty-orange.svg" />
  <img src="https://img.shields.io/badge/Shell-zsh-yellow.svg" />
  <img src="https://img.shields.io/badge/Font-Operator%20Mono-lightgrey.svg" />
  <img src="https://img.shields.io/badge/Mail-neomutt-red.svg" />
  <img src="https://img.shields.io/badge/IRC-tiny-blue.svg" />
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

## Screenshots

![screenshot](https://raw.githubusercontent.com/mamutal91/dotfiles/master/screenshot.png)