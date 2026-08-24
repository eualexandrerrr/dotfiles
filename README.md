<div align="center">

# dotfiles

**Arch Linux · Hyprland · Quickshell**

Setup de desktop com RTX 3090, tema Everforest, config do Hyprland em Lua.

[![Arch](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat-square&logo=hyprland&logoColor=black)](https://hypr.land)
[![Quickshell](https://img.shields.io/badge/Quickshell-41CD52?style=flat-square&logo=qt&logoColor=white)](https://quickshell.outfoxxed.me)
[![NVIDIA](https://img.shields.io/badge/nvidia--open--dkms-76B900?style=flat-square&logo=nvidia&logoColor=white)](https://wiki.archlinux.org/title/NVIDIA)

</div>

---

## Stack

| Camada | Programa |
|:--|:--|
| Compositor | `hyprland` |
| Shell, barra e dock | `quickshell` |
| Lançador | `rofi` |
| Terminal | `kitty` |
| Notificações | `dunst` |
| Wallpaper | `awww` |
| Bloqueio e idle | `hyprlock` · `hypridle` |
| Login | `sddm` |
| Prompt | `starship` |
| Driver | `nvidia-open-dkms` |

## Estrutura

```
dotfiles
├── .config
│   ├── ags              widget do hub
│   ├── color-schemes    paletas Everforest
│   ├── dunst            notificações
│   ├── fastfetch        splash do terminal
│   ├── hypr             hyprland.lua, hyprlock, hypridle, shaders, scripts
│   ├── khal             calendário
│   ├── kitty            terminal
│   ├── kvantum          tema Qt
│   ├── qt6ct            cores Qt6
│   ├── quickshell       barra, dock, hub, menu de energia
│   ├── rofi             lançador e menus
│   ├── spicetify        tema do Spotify
│   ├── vdirsyncer       sync de calendário
│   └── starship.toml    prompt
├── home                 .zshrc, .zprofile
├── install.sh           pós-instalação do Arch
└── packages.txt         pacotes por repositório
```

## Instalação

```bash
sudo pacman -Sy git --noconfirm
git clone https://github.com/eualexandrerrr/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

O script é **idempotente** — rodar de novo não quebra nada. Ele faz, em ordem:

1. Habilita `multilib` e atualiza o sistema
2. Instala os pacotes de `packages.txt` do repositório oficial
3. Faz bootstrap do `paru` e instala os do AUR
4. Configura a NVIDIA: `modprobe.d`, módulos no `mkinitcpio`, parâmetros de kernel, `mkinitcpio -P`
5. Habilita serviços e adiciona seu usuário aos grupos
6. Clona/atualiza os dotfiles e cria os symlinks
7. Baixa do upstream os binários e mídia que este repo não versiona
8. Aplica o tema do sddm

Reinicie no fim. Kernel, initramfs e grupos novos só valem depois do boot.

```bash
cat /sys/module/nvidia_drm/parameters/modeset   # tem que retornar Y
```

## Monitores

Definido em `.config/hypr/hyprland.lua`:

| | Saída | Modo | Posição | Transform |
|:--|:--|:--|:--|:--|
| Secundário — retrato, esquerda | `DP-2` | 1920x1080 | `0x0` | `1` |
| Principal — paisagem, direita | `DP-1` | 2560x1440 | `1080x0` | — |

Workspaces 1–5 no principal, 6–10 no secundário.

> Os nomes `DP-1`/`DP-2` são um chute. Rode `hyprctl monitors` no primeiro boot e corrija
> `monitor_main` e `monitor_side` no topo do arquivo. Existe um terceiro bloco `hl.monitor`
> genérico como rede de segurança. Se o retrato subir de cabeça pra baixo, troque
> `transform = 1` por `3`.

## Atalhos

| Tecla | Ação |
|:--|:--|
| <kbd>Super</kbd> <kbd>Espaço</kbd> | Hub do Quickshell |
| <kbd>Super</kbd> <kbd>R</kbd> | Drawer de workspaces |
| <kbd>Super</kbd> <kbd>Q</kbd> | Terminal |
| <kbd>Super</kbd> <kbd>E</kbd> | Arquivos |
| <kbd>Super</kbd> <kbd>B</kbd> | Navegador |
| <kbd>Super</kbd> <kbd>X</kbd> | Fechar janela |
| <kbd>Super</kbd> <kbd>F</kbd> | Flutuar |
| <kbd>Super</kbd> <kbd>M</kbd> | Tela cheia |
| <kbd>Super</kbd> <kbd>G</kbd> | Agrupar |
| <kbd>Super</kbd> <kbd>P</kbd> | Conta-gotas |
| <kbd>Super</kbd> <kbd>H</kbd> | Workspace especial |
| <kbd>Alt</kbd> <kbd>F4</kbd> | Menu de energia |
| <kbd>Print</kbd> | Recorte de tela |
| <kbd>Super</kbd> <kbd>Print</kbd> | Tela inteira |

## O que este repo versiona

Só arquivo de **texto e editável**: `.lua` `.qml` `.js` `.sh` `.conf` `.css` `.rasi` `.jsonc` `.glsl` `.svg`.

Fora do versionamento (ver `.gitignore`), baixado pelo `install.sh` direto do upstream:

- `.config/quickshell/bin/` — 30 MB de binários pré-compilados
- wallpapers, ícones de clima, backgrounds do hyprlock
- fonte Typewriter Variable, cursores Saturnian, temas GTK e do sddm

O [surface-dots](https://github.com/snes19xx/surface-dots) **não declara licença**. Por isso
binários e mídia não são redistribuídos aqui: são buscados do repositório original na instalação.
Pelo mesmo motivo este repo não declara licença própria sobre código derivado dele.

## Ressalvas

- **Geometria**: o surface-dots foi desenhado para tela 3:2 de alta densidade. Em 1440p e 1080p
  retrato alguns elementos do Quickshell saem desalinhados. Ajuste em `.config/quickshell/config.js`.
- **RedM não tem cliente Linux.** O launcher Enhanced depende do WebView2 e não sobe em
  Wine/Proton. O `install.sh` baixa o instalador oficial e cria um prefixo, mas é provável que
  não abra. RDR2 pela Steam roda normalmente via Proton.
- Pacotes citados no README do surface-dots que **não existem** com esse nome:
  `hyprland-plugins`, `colorreload-gtk-module`, `pulseaudio-utils` (o `pactl` vem do `libpulse`).

## Mudanças do ecossistema

Coisas que mudaram e invalidam tutorial antigo:

| Antes | Agora |
|:--|:--|
| `hyprland.conf` em hyprlang | `hyprland.lua` em **Lua**, desde o Hyprland 0.55 |
| `swww` | `awww` — mesmo projeto, declara `provides`/`replaces` |
| `rofi-wayland` | absorvido pelo `rofi` 2.0 no repo oficial |
| `p7zip` | `7zip` |
| `hyprland-qtutils` | `hyprland-guiutils` |

## Repositórios relacionados

- [eualexandrerrr/myarch](https://github.com/eualexandrerrr/myarch) — instalador do Arch, gera o pendrive que instala esta máquina

## Créditos

- Rice base — [snes19xx/surface-dots](https://github.com/snes19xx/surface-dots)
- [Quickshell](https://quickshell.outfoxxed.me) — outfoxxed
- [Hyprland](https://hypr.land) — vaxerski

<div align="center">
<sub>Branch <code>backup/i3-x11-2023</code> guarda o rice antigo de i3 + polybar.</sub>
</div>
