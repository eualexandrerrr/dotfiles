[Português](README.pt-BR.md)

# dotfiles

Post-install for my development machine: **Arch Linux + Hyprland** on Wayland, with RTX 3090
passthrough to a Windows VM. Every config in its own package, symlinked by GNU Stow.

```
git clone https://github.com/eualexandrerrr/dotfiles ~/.dotfiles
bash ~/.dotfiles/install.sh
```

`install.sh` is idempotent. `setup.sh` reconfigures and reloads in seconds, no network needed:

| | what | when |
|---|---|---|
| `install.sh` | packages, driver, services, SDDM | you touched `packages.txt` |
| `setup.sh` | configures and reloads | you touched a config |

Steps: `links home perfil tema energia audio dns wallpaper console claude recarregar`.

---

## What I use

| Role | Program |
|---|---|
| Compositor / bar / launcher | `hyprland` · `waybar` · `fuzzel` |
| Notifications / lock / idle | `swaync` · `hyprlock` · `hypridle` |
| Wallpaper / night filter / OSD | `awww` · `hyprsunset` (on demand) · `swayosd` |
| Files | `thunar` (GUI) · `yazi` (terminal) |
| Screenshots | `grim` + `slurp` + `satty` |
| Terminal | `ghostty` + zsh with `starship`, `atuin`, `fzf`, `zoxide` |
| Alt+Tab / Super+Tab | `hyprexpose` (patched) · `hyprswitch` |

---

## The five techniques holding this up

**1. The Hyprland config is Lua, not hyprlang.** The `.conf` format has been deprecated since
0.55, and on 0.56 hyprlang `windowrule` entries fail outright. A broken config **fails
silently**: it is ignored and the session comes up crooked. So, before shipping any change:

```
Hyprland --verify-config                # answers "config ok" or lists the errors
bash ~/.dotfiles/setup.sh recarregar    # hyprctl reload + waybar + swaync
```

The offline reference matching the installed version is `/usr/share/hypr/stubs/hl.meta.lua` —
worth more than the wiki, which documents the newest release instead of yours.

**2. Match monitors by brand, never by connector.** Swapping the motherboard renumbers the
ports, and with rules pinned to a connector the vertical monitor's `transform` lands on the
main one, waybar comes up with no bar at all, and the lock screen loses its password field.
One symptom, four files. Today no versioned file holds a `DP-x`: the brand lives in
`hypr/.config/hypr/telas.lua` and is resolved at use time — from Lua via `telas.desc()`, and
outside it via `bin/monitor.sh`. Waybar, hyprlock and hyprswitch only accept connector
names (swaync takes the full monitor description instead), so each one starts through a
wrapper in `bin/` that resolves the brand and writes the config into `$XDG_RUNTIME_DIR`.

**3. The session runs inside systemd.** SDDM launches `hyprland-uwsm.desktop`, not plain
Hyprland: [uwsm](https://github.com/Vladimir-csp/uwsm) is what makes
`graphical-session.target` actually exist. Every app in the session starts with
`uwsm app -- <program>`, becomes a scope and dies with the session instead of being orphaned.
`uwsm/env` is also where the graphics driver is resolved **by reading which `card` belongs to
which GPU** — hardcoding `nvidia` there drops every Electron app into swiftshader, rendering
on the CPU.

**4. Stow with `--no-folding --restow`.** Without `--no-folding`, stow symlinks the whole
directory and apps start writing inside the repo. A package is any folder with a dotted entry
at its root (`.config`, `.zshrc`); a folder without one is tooling.

**5. No keyring installed.** With no keyring, Chrome falls back to the `basic` backend (`v10`
cookies) and the profile survives a reinstall without depending on the login password.
`gnome-keyring` would move it to `v11` and create that dependency — which is why it is not in
`packages.txt` and must not sneak in as some app's convenience.

---

## Keybindings

| Key | Action |
|---|---|
| `Meta+Return` · `Meta+R` · `Meta+E` · `Meta+B` | terminal · launcher · files · browser |
| `Meta+Q` · `Meta+F` · `Meta+T` · `Meta+V` | close · fullscreen · float · clipboard |
| `Meta+1..9` / `Meta+Shift+1..9` | go to workspace / move window there |
| `Meta+arrows` / `Meta+Shift+arrows` / `Meta+Alt+arrows` | focus / move / resize |
| `Alt+Tab` · `Super+Tab` | live-preview overview · window switcher |
| `Print` · `Shift+Print` · `Meta+Shift+A` · `Meta+Shift+R` | screen · region · annotate · record |
| `Meta+L` · `Meta+Shift+E` · `Ctrl+Shift+Home` | lock · log out · reload session |

Workspaces are pinned by rule: **1** Chrome · **2** Discord · **3** RCode · **4** VM/games ·
**6** terminals · **9** RicePanel on the vertical screen.

---

## Hardware

![The machine](docs/img/maquina.jpg)

| Part | Model |
|---|---|
| CPU | Ryzen 7 5700X (8c/16t, no integrated graphics) |
| Motherboard | ASUS TUF Gaming B550M-PLUS — **no wifi, no bluetooth** |
| RAM | 64 GB DDR4 dual channel (4x16 GB) |
| VM GPU | Gainward RTX 3090 24 GB — `PCIEX16_1` (top, straight off the CPU), **on a riser** |
| Host GPU | PCYes Radeon RX 550 4 GB — `PCIEX16_2` (bottom), straight into the slot |
| SSD | Corsair MP700 ELITE 932 GB, single M.2 |
| PSU | 850 W Gold |
| Case | PCYes Forcefield Mini Black Vulcan (GPU up to 310 mm) |
| Monitors | ASUS XG27ACS 1440p180 (main) · LG UltraGear 1080p144 (portrait) |

**The RX 550 is what draws Linux.** The 3090 is bound to `vfio-pci` and goes whole into the
Windows VM.

**The 3090 is the card on the riser** — a 20 cm PCIe 3.0 x16 with a 90° plug — and it lives
**outside the case**: its cooler is 2.7 slots thick and covers the bottom slot if mounted
directly. A riser holding a card that heavy needs support; never let it hang from the
connector alone, which turns into a lever. The RX 550 goes **straight into the bottom slot**,
no riser and no extra power: it draws its 75 W from the slot.

![Motherboard and the 3090](docs/img/placas.jpg)

The 3090 sits alone in **IOMMU group 16** with its own audio function, so passthrough needs no
ACS override. The RX 550 could not take its place: the bottom slot hangs off the chipset,
behind the same bridge as group 15, which drags USB, SATA and Ethernet along with it.

---

## Cable map

Two DisplayPort cables, two HDMI and one Ethernet. The ASUS takes **two** inputs and switches
with its own button: HDMI (Linux) day to day, DP (bare-metal Windows) to play. **The session
survives either way.**

![How the cables connect the two GPUs to the two monitors](docs/img/cabos.png)

| Cable | From | To | For |
|---|---|---|---|
| DisplayPort | RTX 3090 | ASUS XG27ACS · **DP** input | bare-metal Windows, 2560x1440@180 |
| HDMI | RX 550 | ASUS XG27ACS · **HDMI** input | Linux, day to day, 2560x1440@120 |
| DisplayPort | RX 550 | LG UltraGear (rotated) | RicePanel, 1920x1080@144 |
| Dummy plug | RTX 3090 · free DP | — | keeps a display alive inside the VM |
| Ethernet | motherboard 2.5G LAN | router | **the only way in: there is no wifi** |

**Primary video in the BIOS: `PCIEX16_2`** (the RX 550), under Advanced › Onboard Devices
Configuration. That is where Linux and the systemd-boot menu live — a recovery entry is only
useful if it shows up on the screen you use every day.

**Why Linux runs at 120 Hz:** 1440p@180 needs about 19.3 Gbps. DP 1.4 carries 25.9 and makes
it; the RX 550's HDMI 2.0b carries 18 and does not. That was a deliberate trade to keep DP on
the 3090 — inside Windows the result is identical. So `monitores.lua` asks for `@120` on the
main screen, and `mode = "highrr"` does **not** fix it: it maximises refresh rate rather than
resolution, and drops the screen to 1024x768@180.

The dummy plug is not just insurance against running out of cables: with the ASUS wired to
both cards and its input set to HDMI, the monitor can drop DisplayPort hot-plug detect, and
then Windows stops producing frames mid-game.

The VM has its own documentation in [`vm/README.md`](vm/README.md).

---

## When the desktop does not come up

| Command | What it does |
|---|---|
| `dot status` | checks the `hyprland.lua` symlink, binaries, sddm, autologin, services |
| `dot telas` | GPUs, driver per `card`, connected outputs, `AQ_DRM_DEVICES` in use |
| `dot erros` / `dot log` | warnings from the last install / the whole log (`-f` follows) |
| `dot instalar` / `dot zero` | `git pull` + reinstall / wipe and clone from scratch |

The log lives in `~/.local/state/dotfiles/install.log`. If that is not enough — a compositor
that will not start leaves you on a tty, and a tty with no network has no way out — the answer
is the USB stick: **option 4** in the live menu reinstalls the dotfiles without formatting
anything.

### Gotchas

- `hyprctl keyword` is gone. To change config at runtime, use `hyprctl dispatch` with a Lua
  function.
- `hyprctl reload` does not reload waybar, and `SIGUSR2` is not enough when it came up with no
  bar at all: `setup.sh recarregar` kills it and starts it again.
- `transform = 1` is 90°. If the vertical screen comes up upside down, the right value is `3`.
- The shell is zsh: `for p in $var` does not word-split. Use an array or `bash -c`.
- `pacman -Q` lies about installed packages on this machine. Use `command -v` for a binary and
  `pacman -Si` to check whether one exists in the repos.

---

## Credits

The `Alt+Tab` overview is **[hyprexpose](https://github.com/ThiagoAVicente/hyprexpose)**, by
ThiagoAVicente, MIT licensed. This repo ships a **patched version**: `pacotes/hyprexpose/`
builds upstream with `0001-ignorar-monitores-e-alt-tab.patch`, which adds an `ignore_monitors`
key (absent upstream) to keep the vertical monitor out of the overview, teaches the overlay to
read `Tab` and the Alt release on its own surface, and pins the grid to a single row. Nothing
else was changed.

The `Super+Tab` switcher is **[hyprswitch](https://github.com/egnrse/hyprswitch)** (a fork of
[H3rmt/hyprshell](https://github.com/H3rmt/hyprshell)), MIT, used unmodified.
