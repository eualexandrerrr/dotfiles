# Attribution & Licenses

Windows Modern is a derivative work released under the GNU General Public
License v3.0 (GPL-3.0). This file lists the upstream projects that were
used to create it and the licenses that apply to them.

## Project License

- **Windows Modern** — GPL-3.0 (see `LICENSE`)

## Code & Theme Components

| Component | Author | Source | License | Usage |
|-----------|--------|--------|---------|-------|
| Win11OS-kde | yeyushengfan258 | <https://github.com/yeyushengfan258/Win11OS-kde> | GPL-3.0 | Base Plasma desktop theme, Aurorae window decorations, Kvantum configs, color schemes, look-and-feel packages |
| Fluent-kde | vinceliuice | <https://github.com/vinceliuice/Fluent-kde> | GPL-3.0 | Kvantum SVG and configuration base |
| OnzeMenuKDE | adhec | <https://github.com/adhec/OnzeMenuKDE> | GPL-3.0 / GPL-2.0+ | Start menu ancestor |
| menu-11-next | Eisteed | <https://github.com/Eisteed/menu-11-next> | GPL-2.0+ | Start menu reference / design basis |
| Win7 Show Desktop | Zren / Chris Holland | <https://github.com/Zren/plasma-applet-win7showdesktop> | GPL-2.0+ (upstream KDE) | Show Desktop applet reference |
| KDE Plasma System Tray | KDE e.V. | <https://invent.kde.org/plasma/plasma-workspace> | GPL-2.0+ | C++ system tray containment fork source |

## Wallpapers

The `wallpaper/Windows-modern/` package uses
photographs sourced from Pexels. Both are licensed under the **Pexels License**:
free to use, modify, and distribute; attribution is not strictly required but is
included here as a courtesy.

The wallpaper package uses Plasma 6's light/dark image mechanism: `contents/images/`
holds the light image and `contents/images_dark/` holds the dark image. Plasma
auto-switches between them based on the active color scheme.

| Image | Photographer | Source | License | Usage |
|-------|--------------|--------|---------|-------|
| Dark image | Mahmoud Ramadan | <https://www.pexels.com/photo/31622984/> | Pexels License | `wallpaper/Windows-modern/contents/images_dark/` |
| Light image | Ace Visuals Co | <https://www.pexels.com/photo/19931186/> | Pexels License | `wallpaper/Windows-modern/contents/images/` |

## Icon Pack Sources

The `icons/windows-modern/` icon theme is a curated derivative work.
**Eleven** is the anchor pack; the other packs listed below were used only
where Eleven was missing an icon or where another pack provided a clearly
superior match for Windows 11 style.

| Pack | Author | Source | License | Role in final theme |
|------|--------|--------|---------|---------------------|
| **Eleven** | mjkim0727 | <https://github.com/mjkim0727/Eleven-icon-theme> | GPL-3.0 | Anchor pack — the majority of icons |
| **Fluent** | vinceliuice | <https://github.com/vinceliuice/Fluent-icon-theme> | GPL-3.0 | Quality overrides (weather, dialog, security, applications, media controls) |
| **Win11** | yeyushengfan258 | <https://github.com/yeyushengfan258/Win11-icon-theme> | GPL-3.0 | Gap-filling (network, cellular, emotes, animations, MIME types, devices) |
| **We10X** | yeyushengfan258 | <https://github.com/yeyushengfan258/We10X-icon-theme> | GPL-3.0 | Small gap-fills (security-high, folder-visiting, mail icons) |
| **Fluentwin** | — | <https://store.kde.org/p/1395671> | No explicit license listed on the store page; the author's other projects are GPL-3.0 | Tiny fills (preferences-desktop-personal, cs-cat-admin, cs-cat-prefs) |

The following packs were considered during curation but **not selected**
for the final output:

- Cobalt-icons
- Windows-Eleven
- Windows-Beuty

## Selling / Distribution Notice

Because this project is built almost entirely from GPL/AGPL-licensed
upstream works, you may charge a fee for distribution, support, or
packaging. However, anyone who receives the work also receives the full
rights granted by those licenses, including:

- the right to receive the complete corresponding source code,
- the right to redistribute copies freely or for a fee,
- the right to modify and share their modifications.

You may not impose additional restrictions that would prevent recipients
from exercising those rights.

> **I am not a lawyer.** For commercial distribution, consult a lawyer
> familiar with open-source licensing.
