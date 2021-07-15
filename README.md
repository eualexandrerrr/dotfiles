# ~/.dotfiles

![screenshot](https://raw.githubusercontent.com/mamutal91/dotfiles/master/screenshot.png)

## Some of the worthy tools that I use, develop or help maintain:

- [stow](https://www.gnu.org/software/stow/) (symlink manager)
- [i3-gaps](https://github.com/Airblader/i3) (window manager)
- [i3lock](https://github.com/i3/i3lock) (improved screen locker)
- [polybar](https://github.com/polybar/polybar) (A fast and easy-to-use status bar)
- [picom](https://github.com/yshui/picom) (A lightweight compositor for X11)
- [rofi](https://github.com/davatorium/rofi) (A window switcher, application launcher and dmenu replacement)
- [zsh](https://www.zsh.org) + [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) + [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) (terminal sexy <39)
- [alacritty](https://github.com/alacritty/alacritty) (A cross-platform, GPU-accelerated terminal emulator)
- [grim](https://github.com/emersion/grim) + [ffmpeg](https://github.com/FFmpeg/FFmpeg) + [slurp](https://github.com/emersion/slurp) + [xclip](https://github.com/astrand/xclip) (screenshots and screencasts)
- [htop](https://github.com/htop-dev/htop) (an interactive process viewer)

## How to use?

You need to install some packages that are dependencies for everything to work. The `setup.sh` script will do this for you, except if you don't use **ArchLinux** or derivatives, if not, adapt the packages for your distribution.

Do this preferably on some [**tty**](https://www.techwalla.com/articles/how-to-switch-tty)

[**Want to use Arch? Use my install script**](https://github.com/mamutal91/myarch)

```
$ sudo pacman -Sy git --noconfirm
$ git clone https://github.com/mamutal91/dotfiles ~/.dotfiles
$ cd ~/.dotfiles
$ ./setup/setup.sh
$ ./install.sh
$ startx
```

# Shortcuts
#### Shortcuts to apps

| Key1 | Key2 | Key3 | Description |
|--|--|--|--|
| Super | Enter | --- | Terminal
| Super | D | --- | Quick shortcuts defined by me
| Super | B | --- | Connect my bluetooth devices
| Super | P | --- | Power menu
| Super | F2 | --- | Google Chrome
| Super | F3 | --- | Telegram
| Control | Shift | K | Opens the screencast (screen recorder)
| Print | --- | --- | Cropped Screenshot
| Control | Print | --- | Full Screen Screenshot

#### Workspace usage shortcuts
| Key1 | Key2 | Key3 | Description |
|--|--|--|--|
| Super | W | --- | Close current window
| Super | Tab | --- | Next workspace
| Super | {0 to 9} | --- | Workspace change
| Control | Shift | {0 to 9} | Move the current window to another workspace corresponding to the number

#### How to resize floating windows
| Key1 | Key2 | Key3 | Description |
|--|--|--|--|
| Control | Shift | Space | Window in floating mode (To move it, hold Super, click and drag the window)
| Control | Shift | R | Activates resize mode, use keyboard arrow keys to set size

## Polybar
#### Available modules
 - volume
 - brightness
 - battery_bar
 - cpu_bar
 - filesystem_bar
 - memory_bar
 - mpd_bar
 - alsa
 - backlight
 - battery
 - cpu
 - date
 - filesystem
 - memory
 - mpd
 - wired-network
 - wireless-network
 - network
 - pulseaudio
 - temperature
 - keyboard
 - title
 - workspaces
 - updates
 - launcher
 - sysmenu
 - color-switch
 - sep
 - apps
 - term
 - files
 - browser
 - settings
 - powermenu
 - menu
