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

`install.sh` is idempotent. `setup.sh` reconfigures and reloads in seconds, no network needed:

| | what | when |
|---|---|---|
| `install.sh` | packages, driver, services, SDDM | you touched `packages.txt` |
| `setup.sh` | configures and reloads | you touched a config |

Steps: `links home perfil energia audio dns console chrome claude`.

---

## What I use

| Role | Program |
|---|---|
| Desktop | `plasma-meta` (panel, KRunner, Klipper, powerdevil) |
| Files | `dolphin` (GUI) · `yazi` (terminal) |
| Screenshots | `spectacle` (screen, region, annotation and video) |
| Terminal | `ghostty` + zsh with `starship`, `atuin`, `fzf`, `zoxide` |

---

## The four techniques holding this up

**1. Match monitors by brand, never by connector.** Swapping the motherboard renumbers the
ports, and a rule pinned to `DP-1` starts applying to the wrong screen. No versioned file
holds a connector name: the brand lives in `telas.conf` and is resolved at use time by
`bin/monitor.sh`, which reads the EDID straight from `/sys/class/drm`. Depending on no
compositor, it works the same inside the session, on a tty, or in a systemd
`ExecCondition=`.

**2. Session environment lives in `plasma-workspace/env/`.** Plasma sources everything under
`~/.config/plasma-workspace/env/` before starting the session. That is where
`GTK_IM_MODULE=simple` fixes dead keys in GTK apps on an ABNT2 layout, and where the video
driver is picked **by reading which `card` belongs to which GPU** -- hardcoding `nvidia` while
the displays hang off the AMD card kills video acceleration.

**3. Stow with `--no-folding --restow`.** Without `--no-folding`, stow symlinks the whole
directory and apps start writing inside the repo. A package is any folder with a dotted entry
at its root (`.config`, `.zshrc`); a folder without one is tooling.

**4. No keyring installed.** With no keyring, Chrome falls back to the `basic` backend
(`v10` cookies) and the profile survives a reinstall without depending on the login password.
`gnome-keyring` would move it to `v11` and create that dependency — which is why it is not in
`packages.txt` and must not sneak in for any app's convenience.

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
| `dot status` | checks Plasma binaries, sddm, autologin, services and the displays |
| `dot telas` | GPUs, driver per `card`, connected outputs, roles from `telas.conf` |
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
