[Português](README.pt-BR.md)

# dotfiles

Post-install for my development machine: **Arch Linux + KDE Plasma** on Wayland, with RTX 3090
passthrough to a Windows VM. Every config in its own package, symlinked by GNU Stow.

The desktop is **stock Plasma**, deliberately: panel, launcher, notifications, screenshots and
display settings are the native ones. What this repo adds is what Plasma does not do -- GPU
passthrough, system tuning, packages and credentials.

```
git clone https://github.com/eualexandrerrr/dotfiles ~/.dotfiles
bash ~/.dotfiles/install.sh
```

Three scripts, that is all. All idempotent:

| | what | when |
|---|---|---|
| `install.sh` | packages, driver, kernel, services, login manager | you touched `packages.txt` |
| `setup.sh` | configures everything, VM included — no network | you touched a config |
| `reload.sh` | reloads the session already running | something drifted just now |

`setup.sh` steps: `links home perfil arquivos sistema graficos vm ddcutil energia atalhos audio dns console chrome claude notificacoes painel tema servicos`.

## Package cache

Pacman and makepkg keep everything under `/home/.pkgcache/`, which lives on the `Files`
partition and is never formatted. Reinstalling redownloads and rebuilds only what changed
version.

## Which desktop

`install.sh` shows a numbered menu (same layout as the ISO's `myarch-menu`) and records the answer in
`~/.local/state/dotfiles/de`. The menu shows up on every run: a previous answer is flagged as the
current one and Enter keeps it, so switching desktops is running it again and picking another
number:

```
./install.sh --de=gnome     # skip the question (or DE=gnome ./install.sh)
```

| | |
|---|---|
| `packages.txt` | base: what any desktop needs |
| `packages/<name>.txt` | `kde` `gnome` `xfce` `cinnamon` `mate` `lxqt` `budgie` `cosmic` `hyprland` `nandoroid` — only the chosen one gets installed |

`nandoroid` is the odd one out: not a desktop but Hyprland plus the
[NAnDoroid](https://github.com/na-ive/nandoroid-shell) shell, styled after Android 16.
`bin/nandoroid.sh` clones the shell and writes a Hyprland config that behaves like a windowed
desktop — everything floating and centered, no workspaces at all.

**Only KDE is configured here** — it is this machine's desktop. Picking another one
installs it stock: the `plasma/` stow package and the `arquivos atalhos notificacoes painel
tema` steps are skipped.

Hardware is the exception and lives in the `graficos` step, which runs on every desktop. It
asks `bin/render-gpu.sh` which GPU has a monitor attached, then writes
`~/.config/environment.d/50-dotfiles.conf` (`GTK_IM_MODULE=simple` for dead keys in GTK apps
on ABNT2, `LANGUAGE`, `LIBVA_DRIVER_NAME`, `KWIN_DRM_DEVICES`, `AQ_DRM_DEVICES`) and
`/etc/udev/rules.d/61-dotfiles-gpu.rules`, which tags the AMD card
`mutter-device-preferred-primary` and the 3090 `mutter-device-ignore`. Mutter has no
`KWIN_DRM_DEVICES`: without that rule it picks the primary GPU by Boot VGA, lands on the
3090 and paints GNOME onto its dummy plugs, leaving the real monitor on a blank blue screen.

---

## What I use

| Role | Program |
|---|---|
| Desktop | `plasma-meta` (panel, KRunner, Klipper, powerdevil) |
| Files | `dolphin` |
| Screenshots | `spectacle` (screen, region, annotation and video) |
| Terminal | `ghostty` + zsh with `starship`, `atuin`, `fzf`, `zoxide` |
| Editor | `micro` (terminal) · RCode (GUI) |

---

## The four techniques holding this up

**1. Match monitors by brand, never by connector.** Swapping the motherboard renumbers the
ports, and a rule pinned to `DP-1` starts applying to the wrong screen. No versioned file
holds a connector name: the brand lives in `screens.conf` and is resolved at use time by
`bin/monitor.sh`, which reads the EDID straight from `/sys/class/drm`. Depending on no
compositor, it works the same inside the session, on a tty, or in a systemd
`ExecCondition=`.

**2. Session environment lives in `environment.d`.** GNOME, Plasma and Hyprland under uwsm
all start the session from `systemd --user`, which reads `~/.config/environment.d/` — the one
env location that holds on all four desktops. That is where `GTK_IM_MODULE=simple` fixes dead
keys in GTK apps on an ABNT2 layout, and where the video driver is picked **by reading which
`card` belongs to which GPU** -- hardcoding `nvidia` while the displays hang off the AMD card
kills video acceleration.

**3. Stow with `--no-folding --restow`.** Without `--no-folding`, stow symlinks the whole
directory and apps start writing inside the repo. A package is any folder with a dotted entry
at its root (`.config`, `.zshrc`); a folder without one is tooling.

**4. The Chrome profile must not depend on a keyring.** On the `basic` backend cookies are
`v10` and self-contained: the profile survives a reinstall without depending on the login
password staying the same. On `v11` the key moves into the keyring, and since login here is
automatic nobody types the password that unlocks it — you would wake up logged out of
everything.

Until 09/2026 this was guaranteed by installing no keyring at all. `plasma-meta` pulls in
`kwallet-pam`, and `pam_kwallet` lands in `/etc/pam.d/sddm` on its own, so now there is one.
What holds the guarantee is `--password-store=basic` in `chrome/.config/chrome-flags.conf`.
`gnome-keyring` stays out of `packages.txt`.

---

## Shortcuts

Plasma's own, out of the box — `Meta` opens the menu, `Meta+Space` KRunner, `Print` Spectacle,
`Meta+L` locks. Change any of them in **System Settings > Shortcuts**, not in a file here.

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
| HDMI | RX 550 | ASUS XG27ACS · **HDMI** input | Linux, day to day, 2560x1440@144 |
| DisplayPort | RX 550 | LG UltraGear (rotated) | RicePanel, 1920x1080@144 |
| Dummy plug | RTX 3090 · free DP | — | keeps a display alive inside the VM |
| Ethernet | motherboard 2.5G LAN | router | **the only way in: there is no wifi** |

**Primary video in the BIOS: `PCIEX16_2`** (the RX 550), under Advanced › Onboard Devices
Configuration. That is where Linux and the systemd-boot menu live — a recovery entry is only
useful if it shows up on the screen you use every day.

**Why Linux does not reach 180 Hz:** 1440p@180 needs about 19.3 Gbps. DP 1.4 carries 25.9 and
makes it; the RX 550's HDMI 2.0b carries 18 and does not. That was a deliberate trade to keep
DP on the 3090 — inside Windows the result is identical. `bin/apply-screens.sh` asks for what
the cable can carry, `2560x1440@144`, and reapplies it on a timer because KWin forgets on its
own after the screen blanks.

The dummy plug is not just insurance against running out of cables: with the ASUS wired to
both cards and its input set to HDMI, the monitor can drop DisplayPort hot-plug detect, and
then Windows stops producing frames mid-game.

The VM has its own documentation in [`vm/README.md`](vm/README.md).

---

## When the desktop does not come up

| Command | What it does |
|---|---|
| `dot config` / `dot reload` | runs `setup.sh` / reloads displays, audio, panel and KWin |
| `dot status` | checks Plasma binaries, sddm, autologin, services and the displays |
| `dot telas` | GPUs, driver per `card`, connected outputs, roles from `screens.conf` |
| `dot erros` / `dot log` | warnings from the last install / the whole log (`-f` follows) |
| `dot instalar` / `dot zero` | `git pull` + reinstall / wipe and clone from scratch |

The log lives in `~/.local/state/dotfiles/install.log`. If that is not enough — a desktop
that will not start leaves you on a tty, and a tty with no network has no way out — the answer
is the USB stick: **option 4** in the live menu reinstalls the dotfiles without formatting
anything.

### Gotchas

- The shell is zsh: `for p in $var` does not word-split. Use an array or `bash -c`.
- `pacman -Q` lies about installed packages on this machine. Use `command -v` for a binary and
  `pacman -Si` to check whether one exists in the repos.

## Credits

The `plasma/` package vendors the dark variant of the [Win11OS KDE theme](https://github.com/yeyushengfan258/Win11OS-kde)
by [yeyushengfan258](https://github.com/yeyushengfan258), licensed GPLv3 (kept in
`vendor/win11os/`). Only the Aurorae window decoration, color scheme, Kvantum style
and Plasma desktop/look-and-feel splash for the dark variant are included; the icon theme
and cursor theme it references are separate KDE Store downloads and are not part of this
repo, so `bin/apply-theme-win11os-dark.sh` never touches those two settings. The vendored
Kvantum config has one deliberate change from upstream: `translucent_windows`, `blurring`
and `popup_blurring` are set to `false` (opaque windows/menus instead of the theme's default
glass effect).

The icon theme and cursor theme the Win11OS package leaves out are filled in from their own
upstream sources:

- [Tela-icon-theme](https://github.com/vinceliuice/Tela-icon-theme) (`Tela-dracula-dark`,
  plus the `Tela-dracula` base it inherits from) by
  [vinceliuice](https://github.com/vinceliuice), GPLv3, credits in `vendor/tela-icons/`.
- [Bibata_Cursor](https://github.com/ful1e5/Bibata_Cursor) (`Bibata-Modern-Ice`, prebuilt
  release asset) by [ful1e5](https://github.com/ful1e5), GPLv3, credits in
  `vendor/bibata-cursor/`.
