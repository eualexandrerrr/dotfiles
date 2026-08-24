<div align="center">

# dotfiles

**Arch Linux · Hyprland · Quickshell**

Configuração de desktop com RTX 3090. Hyprland em Lua, shell pelo
[nandoroid-shell](https://github.com/na-ive/nandoroid-shell).

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
| Shell, barra e painéis | [`nandoroid-shell`](https://github.com/na-ive/nandoroid-shell) sobre `quickshell` |
| Cores dinâmicas | `matugen` (Material You a partir do wallpaper) |
| Lançador | `fuzzel` |
| Terminal | `kitty` |
| Bloqueio e idle | `hyprlock` · `hypridle` |
| Login | `sddm` |
| Prompt | `starship` |
| Driver | `nvidia-open-dkms` |
| Agente no terminal | `claude-code` (AUR) |

## Estrutura

```
dotfiles
├── .config
│   ├── hypr
│   │   ├── hyprland.lua      monitores, env da nvidia, keybinds, regras
│   │   ├── hyprlock.conf     tela de bloqueio
│   │   └── hypridle.conf     timeouts de idle
│   └── kitty
│       ├── kitty.conf
│       └── current-theme.conf
├── home                      .zshrc, .zprofile
├── install.sh                pós-instalação do Arch
└── packages.txt              pacotes por repositório
```

## Como isto se encaixa com o nandoroid

O nandoroid **não toma conta do seu Hyprland**. Ele instala em
`~/.local/src/nandoroid-shell`, gera `~/.config/hypr/nandoroid/nandoroid.lua`
e espera que o seu config principal faça o `require`. Aqui isso já está feito:

```lua
pcall(require, "nandoroid/nandoroid")
```

O `pcall` é de propósito — se o nandoroid não estiver instalado ainda, o Hyprland
sobe do mesmo jeito em vez de morrer no boot.

Consequências práticas:

- **Monitores, keybinds e regras de janela são seus**, ficam neste repo
- **Barra, painéis, dashboard e tema são do nandoroid**, e atualizam pelo `update.sh` dele
- O `.gitignore` ignora `.config/hypr/nandoroid/` e `.config/matugen/`, que são gerados

Este repo **não redistribui código do nandoroid**. Ele é AGPL-3.0; copiar para cá
tornaria este repositório AGPL também. O `install.sh` clona do upstream.

## Instalação

```bash
sudo pacman -Sy git --noconfirm
git clone https://github.com/eualexandrerrr/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

O script é **idempotente**. Em ordem:

1. Habilita `multilib` e atualiza o sistema
2. Instala os pacotes de `packages.txt` do repositório oficial
3. Faz bootstrap do `paru` e instala os do AUR
4. Configura a NVIDIA: `modprobe.d`, módulos no `mkinitcpio`, parâmetros de kernel, `mkinitcpio -P`
5. Habilita serviços e adiciona seu usuário aos grupos
6. Cria os symlinks deste repo
7. Clona e roda o instalador do nandoroid — **essa parte é interativa**
8. Configura o sddm

Reinicie no fim.

```bash
cat /sys/module/nvidia_drm/parameters/modeset   # tem que retornar Y
```

Para atualizar só o shell depois:

```bash
cd ~/.local/src/nandoroid-shell && ./update.sh
```

## Monitores

Definido em `.config/hypr/hyprland.lua`:

| | Saída | Modo | Posição | Transform |
|:--|:--|:--|:--|:--|
| Secundário — retrato, esquerda | `DP-2` | 1920x1080 | `0x0` | `1` |
| Principal — paisagem, direita | `DP-1` | 2560x1440 | `1080x0` | — |

Workspaces 1–5 no principal, 6–10 no secundário.

> Os nomes `DP-1`/`DP-2` são um chute. Rode `hyprctl monitors` no primeiro boot e
> corrija `monitor_main` e `monitor_side` no topo do arquivo. Há um terceiro bloco
> `hl.monitor` genérico como rede de segurança. Se o retrato subir de cabeça pra
> baixo, troque `transform = 1` por `3`.

## Atalhos

| Tecla | Ação |
|:--|:--|
| <kbd>Super</kbd> <kbd>Enter</kbd> | Terminal |
| <kbd>Super</kbd> <kbd>E</kbd> | Arquivos |
| <kbd>Super</kbd> <kbd>B</kbd> | Navegador |
| <kbd>Super</kbd> <kbd>C</kbd> | Fechar janela |
| <kbd>Super</kbd> <kbd>V</kbd> | Flutuar |
| <kbd>Super</kbd> <kbd>F</kbd> | Tela cheia |
| <kbd>Super</kbd> <kbd>G</kbd> | Agrupar |
| <kbd>Super</kbd> <kbd>P</kbd> | Conta-gotas |
| <kbd>Super</kbd> <kbd>S</kbd> | Workspace especial |
| <kbd>Super</kbd> <kbd>L</kbd> | Bloquear |
| <kbd>Super</kbd> <kbd>1..0</kbd> | Trocar de workspace |
| <kbd>Super</kbd> <kbd>Shift</kbd> <kbd>1..0</kbd> | Mover janela pro workspace |
| <kbd>Print</kbd> | Recorte pro swappy |
| <kbd>Super</kbd> <kbd>Print</kbd> | Tela cheia pra área de transferência |
| <kbd>Super</kbd> <kbd>Shift</kbd> <kbd>Print</kbd> | Gravar região |
| <kbd>Alt</kbd> <kbd>F4</kbd> | Desligar |

Os painéis do nandoroid têm os atalhos próprios deles, documentados no repo do projeto.

## Mudanças do ecossistema

Coisas que mudaram e invalidam tutorial antigo:

| Antes | Agora |
|:--|:--|
| `hyprland.conf` em hyprlang | `hyprland.lua` em **Lua**, desde o Hyprland 0.55 |
| `swww` | `awww` — mesmo projeto, declara `provides`/`replaces` |
| `rofi-wayland` | absorvido pelo `rofi` 2.0 no repo oficial |
| `p7zip` | `7zip` |
| `hyprland-qtutils` | `hyprland-guiutils` |

Pacotes citados em READMEs de rice que **não existem** com esse nome:
`hyprland-plugins`, `colorreload-gtk-module`, `pulseaudio-utils` (`pactl` vem do `libpulse`).
O `dgop` também não está no AUR — quem instala é o próprio nandoroid.

## Ressalvas

- **`--skipreview` no `paru`.** O `install_aur` instala os pacotes do AUR sem exibir o
  `PKGBUILD` antes de compilar. AUR é conteúdo enviado por usuário: o que vem de lá é
  código de terceiro rodando com as permissões do `makepkg`. Sem o `--skipreview` o
  script pararia esperando confirmação em cada um dos 16, o que inviabiliza rodar sozinho.
  Se quiser conferir uma receita antes, o caminho é `paru -G <pacote>` e ler à mão.

- **RedM não tem cliente Linux.** O launcher Enhanced depende do WebView2 e não sobe em
  Wine/Proton. O `install.sh` baixa o instalador oficial e cria um prefixo, mas é provável
  que não abra. RDR2 pela Steam roda normalmente via Proton.
- O passo do nandoroid é **interativo** — ele faz perguntas sobre quais componentes injetar.

## Repositórios relacionados

- [eualexandrerrr/myarch](https://github.com/eualexandrerrr/myarch) — instalador do Arch, gera o pendrive
- `eualexandrerrr/dotfiles-private` — credenciais e variáveis de ambiente, privado

## Créditos

- [nandoroid-shell](https://github.com/na-ive/nandoroid-shell) — na-ive, AGPL-3.0
- [Quickshell](https://quickshell.outfoxxed.me) — outfoxxed
- [Hyprland](https://hypr.land) — vaxerski

<div align="center">
<sub>Branch <code>backup/i3-x11-2023</code> guarda o rice antigo de i3 + polybar.</sub>
</div>
