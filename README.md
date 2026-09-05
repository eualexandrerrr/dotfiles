<div align="center">

# dotfiles

**Arch Linux · KDE Plasma (Wayland) · NVIDIA**

Pós-instalação de uma máquina com RTX 3090: pacotes, driver, KDE, serviços e os
poucos arquivos de configuração que valem versionar.

[![Arch](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![KDE](https://img.shields.io/badge/KDE_Plasma-1D99F3?style=flat-square&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![NVIDIA](https://img.shields.io/badge/nvidia--open--dkms-76B900?style=flat-square&logo=nvidia&logoColor=white)](https://wiki.archlinux.org/title/NVIDIA)

</div>

---

## Stack

| Camada | Programa |
|:--|:--|
| Desktop | KDE Plasma 6 em Wayland (`plasma-desktop`, sem `plasma-meta`) |
| Login | `sddm` com greeter em `kwin_wayland`, tema Breeze |
| Terminal | `ghostty` (registrado como terminal padrão do KDE) |
| Shell | `zsh` + `starship` + `zsh-autosuggestions` + `zsh-syntax-highlighting` |
| Arquivos, imagens, PDF, prints | `dolphin`, `gwenview`, `okular`, `spectacle` |
| Ícones | [Tela](https://github.com/vinceliuice/Tela-icon-theme) (`tela-icon-theme`, AUR), variante `Tela-dark` setada no `kdeglobals` |
| Cursor | [Capitaine](https://github.com/keeferrourke/capitaine-cursors) (`capitaine-cursors`, repo oficial), variante clara `capitaine-cursors-white` no `kcminputrc` |
| Fora de propósito | Wi-Fi no live, Firefox (Chrome cobre), LibreOffice, Telegram, OBS. `pacman -S` traz de volta |
| Bluetooth | sem uso, mas o `bluez-qt` **é obrigatório** — ver [Bandeja do sistema](#bandeja-do-sistema). O `bluetooth.service` fica desabilitado |
| Kernel e driver | `linux-zen`, `nvidia-open-dkms`, `nvidia_drm.modeset=1` |
| Desempenho | `power-profiles-daemon` em `performance`, `ananicy-cpp` com as regras do CachyOS, GPU em "Prefer maximum performance" no login |
| Jogos e Wine | `steam`, `lutris`, `wine`, `winetricks`, `gamescope`, `mangohud` |
| VMs | `qemu-full`, `libvirt`, `virt-manager` (plano B do RedM) |
| Agente no terminal | `claude-code` (AUR) |

Barra, painéis, wallpaper e disposição de monitores continuam sendo do próprio Plasma e
não são versionados: o KDE grava dezenas de arquivos em `~/.config` com estado misturado à
configuração (posição de janela, hash de tema, UUID de desktop virtual), e commitar isso
vira ruído que conflita a cada login.

O que **é** versionado são as decisões: teclado, mouse, tema, ícones, terminal padrão,
bordas de janela. Ficam em `scripts/kde-settings.conf`, uma chave por linha, geradas por
curadoria — ver [Configuração do KDE](#configuração-do-kde).

## Estrutura

```
dotfiles
├── .config
│   ├── autostart
│   │   ├── nvidia-desempenho.desktop
│   │   └── kde-layout-once.desktop
│   └── ghostty
│       └── config
├── home
│   ├── .zshrc
│   └── .zprofile
├── local
│   └── share
│       └── applications
│           └── spectacle-regiao-clipboard.desktop   lançador do Shift+Print
├── scripts
│   ├── mcp-restaurar.sh      recria os 8 MCP do Claude Code no ~/.claude.json
│   ├── kde-settings.conf     decisões do KDE, uma chave por linha (gerado, não editar)
│   ├── kde-capture.sh        lê o KDE vivo e regrava o kde-settings.conf
│   ├── kde-apply.sh          aplica o kde-settings.conf via kwriteconfig6
│   ├── kde-layout-once.sh    primeiro login: tema Windows Modern, painel, layout
│   └── kde-layout.js         layout do painel (script do Plasma)
├── install.sh                pós-instalação, idempotente
└── packages.txt              pacotes por seção; [repo-oficial:*] vai pro pacman, [aur] pro paru
```

## Instalação

Depois do [myarch](https://github.com/eualexandrerrr/myarch), logado como usuário:

```bash
cd ~/.dotfiles
./install.sh
```

Em ordem:

1. `multilib`, `ParallelDownloads`, `Color` no `pacman.conf`, e `pacman -Syu`
2. Pacotes do `packages.txt` (repos oficiais)
3. `paru` e os pacotes do AUR
4. NVIDIA: `modprobe.d`, módulos no `mkinitcpio`, parâmetros de kernel, `mkinitcpio -P`
5. Serviços: `NetworkManager`, `sddm`, `power-profiles-daemon` (perfil `performance`), `ananicy-cpp`, `reflector.timer`, `docker.socket`, `libvirtd.socket`, `mariadb`; grupos do usuário
6. Symlinks de `.config/*` e `home/*` (o que existir no destino vira `.bak-<data>`)
7. `sddm` em Wayland com `kwin`, tema Breeze
8. Padrões do KDE: `scripts/kde-apply.sh` grava tudo que está no `kde-settings.conf`

Reinicie no fim.

```bash
cat /sys/module/nvidia_drm/parameters/modeset   # tem que retornar Y
```

Sem placa NVIDIA no PCI (VM, outra máquina) o driver é pulado sozinho. Pra forçar:

```bash
SKIP_NVIDIA=1 ./install.sh
```

## Configuração do KDE

Nada de editar `~/.config` na mão. O ciclo é: **mexer na GUI → capturar → commitar**.

```bash
# ajuste o que quiser em Configurações do Sistema, depois:
~/.dotfiles/scripts/kde-capture.sh
git -C ~/.dotfiles diff          # confira o que mudou
git -C ~/.dotfiles commit -am "kde: ..."
```

Em outra máquina (ou depois de reinstalar), o `install.sh` chama sozinho:

```bash
~/.dotfiles/scripts/kde-apply.sh   # aplica e recarrega o kwin, sem precisar deslogar
```

O `kde-capture.sh` não copia o `~/.config` inteiro: a lista `GRUPOS` dentro dele é a
curadoria de quais `arquivo:grupo` valem versionar, e `IGNORAR_CHAVE` derruba o que é
estado (`ColorSchemeHash`, `Id_*`, contadores). Pra versionar mais coisa, acrescente o par
`arquivo:grupo` nessa lista e rode o capture de novo.

O que está coberto hoje:

| Arquivo | Grupo | O que é |
|:--|:--|:--|
| `kcminputrc` | `Keyboard` | repetição de teclas: **300 ms** de atraso, **50 Hz** (padrão do Plasma é 600 ms / 25 Hz) |
| `kcminputrc` | `Libinput[...]` | aceleração do ponteiro e fator de rolagem, por dispositivo |
| `kxkbrc` | `Layout` | teclado `br` (ABNT2) |
| `kdeglobals` | `General` | terminal padrão `ghostty`, navegador `google-chrome` |
| `kdeglobals` | `Icons`, `KDE` | ícones `Tela-dark`, estilo `kvantum-dark`, look-and-feel Windows Modern |
| `kwinrc` | `Windows`, `org.kde.kdecoration2` | maximizada sem borda, borda `Tiny`, decoração Aurorae |
| `plasmarc` | `Theme` | tema Plasma `breeze-dark` |
| `kglobalshortcutsrc` | `services` | atalhos globais de aplicativo: `Ctrl+Alt+T` no ghostty, `Shift+Print` no recorte |

### Capturas de tela

O app é o `spectacle`, que já vem no `packages.txt`.

| Tecla | O que faz |
|:--|:--|
| `Print` | abre a janela do Spectacle (padrão do Plasma, intocado) |
| `Shift+Print` | **recorta uma região e copia a imagem pro clipboard**, sem abrir janela |
| `Meta+Shift+Print` | recorte que abre a janela do Spectacle (padrão do Plasma) |

O `Shift+Print` chama `local/share/applications/spectacle-regiao-clipboard.desktop`:

```
Exec=/usr/bin/spectacle --region --background --copy-image --nonotify
```

O `--copy-image` é obrigatório e **não** tem equivalente em arquivo de configuração. O
`spectaclerc` tem `clipboardGroup=PostScreenshotCopyImage`, que a interface do Spectacle
apresenta como *"depois de capturar: copiar a imagem"*, mas ele não é honrado no caminho
do atalho: medido com marcador no clipboard, `spectacle -f -b -n` deixa o clipboard
intacto e grava um arquivo, enquanto `spectacle -f -b -c -n` põe a imagem lá. Por isso o
lançador próprio, e não o reaproveitamento da ação `RectangularRegionScreenShot` do
Spectacle — o `Exec` dela é fixo em `spectacle -r`, sem `-b` e sem `-c`.

`Shift+Print` era *"capturar a área de trabalho inteira"* no padrão do Plasma; a liberação
é a linha `FullScreenScreenShot|none` no `kde-settings.conf`.

> **Atalho novo só passa a valer no login seguinte.** Nesta versão o KWin absorveu o
> kglobalaccel, e ele lê o `kglobalshortcutsrc` e resolve o `Exec` de cada lançador uma vez
> só, quando sobe. Testado: `setForeignShortcut` no D-Bus não cria componente novo,
> `kbuildsycoca6` e `reconfigure` não fazem reler, e sobrepor o `.desktop` em
> `~/.local/share/applications` não muda o `Exec` já resolvido. No Wayland o KWin não pode
> ser reiniciado sem derrubar a sessão, então o caminho é deslogar e logar.

### Barra de tarefas

Flutuante e translúcida, ajustado pelo `scripts/kde-layout-once.sh` no primeiro login:

| Chave | Valor | O que é |
|:--|:--|:--|
| `floating` | `1` | descolada das bordas, cantos arredondados |
| `panelOpacity` | `2` | `0` adaptativo, `1` opaco, **`2` translúcido** |

As duas ficam no `~/.config/plasmashellrc`, em `[PlasmaViews][Panel <id>]`, e o
plasmashell só as lê quando sobe. O acrílico atrás do translúcido vem do `blurEnabled`
do KWin, que já é ligado por padrão.

Não dá pra fazer isso pela API de script do Plasma, que é o jeito natural já que o painel
inteiro nasce de um script: o setter de `opacity` **não grava nada** (mandar `adaptive`
não muda nem o valor vivo nem o arquivo) e o de `floating` só vale até o plasmashell
reiniciar. Era por isso que a barra voltava a ficar colada mesmo com o script anunciando
*"painel flutuante ativado"* no log.

```bash
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
  'print(panels()[0].opacity + " " + panels()[0].floating);'   # translucent true
```

### Bandeja do sistema

A bandeja do painel é o applet `org.kde.windowsmodern.systemtray`, compilado do
[KDE-Windows-Modern](https://github.com/Jeysef/KDE-Windows-Modern) pelo `install.sh`.

Ele importa `org.kde.bluezqt` sem guarda nenhuma, em
`components/BluetoothToggle.qml`. Sem esse módulo QML o applet **inteiro** não sobe e o
painel mostra *"Ocorreu um erro ao carregar System Tray"* — some a rede, o volume, a
bateria, tudo. O erro aparece assim no journal:

```
error when loading applet "org.kde.windowsmodern.systemtray"
  ActionPanel.qml:39:9: Type Components.BluetoothToggle unavailable
  components/BluetoothToggle.qml:4:1: module "org.kde.bluezqt" is not installed
```

Por isso o `bluez-qt` está no `packages.txt` mesmo com o Bluetooth fora de propósito
nesta máquina. Ele puxa o `bluez` como dependência, mas o `install.sh` não habilita o
`bluetooth.service` — fica instalado e parado.

```bash
journalctl --user -b | grep "error when loading applet"   # deve vir vazio
systemctl is-enabled bluetooth.service                    # disabled
```

## MCP do Claude Code

```bash
~/.dotfiles/scripts/mcp-restaurar.sh   # grava os 8 servidores no ~/.claude.json
claude mcp list                        # conferir
```

Os caminhos vieram do Windows (`AppData\Roaming\npm\node_modules\...`) e viraram
`npx -y <pacote>`: nada global pra instalar, o npx resolve e cacheia. Precisa de `node`,
`maestro` (AUR, já no `packages.txt`) e `jdk17-openjdk` — todos já entram no `install.sh`.

| MCP | Comando |
|:--|:--|
| `chrome-devtools` | `npx -y chrome-devtools-mcp@latest` |
| `playwright` | `npx -y @playwright/mcp@latest` com perfil em `~/Apps/_CLAUDE/.secrets/perfil-navegador` |
| `firecrawl` | HTTP, URL vem de `FIRECRAWL_MCP_URL` (**chave de API**, mora no `dotfiles-private`) |
| `obsidian` | `npx -y obsidian-mcp serve` no vault `~/Apps/_CLAUDE/Obsidian/Cérebro` |
| `whatsapp` | `npx -y @kaptionai/mcp-extension` |
| `n8n` | `npx -y n8n-mcp` |
| `shadcn` | `npx -y shadcn@latest mcp` |
| `maestro` | `maestro mcp` com `JAVA_HOME=/usr/lib/jvm/java-17-openjdk` |

Sem o `FIRECRAWL_MCP_URL` exportado, o script pula o firecrawl e grava os outros 7.

## Workspace do VS Code

`~/Downloads/Workspaces/arch.code-workspace` abre `dotfiles` e `myarch` lado a lado, com
terminal integrado em `zsh` e as tarefas prontas (`Ctrl+Shift+P` → *Run Task*):

| Tarefa | O que faz |
|:--|:--|
| pós-instalação completa | `./install.sh` |
| capturar / aplicar config do KDE | os dois lados do `kde-settings.conf` |
| restaurar os 8 MCP | `mcp-restaurar.sh` + `claude mcp list` |
| conferir sintaxe dos scripts | `bash -n` em tudo |
| gerar a ISO | `sudo ./archiso/build.sh` do myarch |
| espelho do Drive | retomar o download e ver progresso |

`shellcheck` e `shfmt` estão no `packages.txt` porque as extensões recomendadas
(`timonwong.shellcheck`, `foxundermoon.shell-format`) precisam dos binários. Antes de
commitar script:

```bash
shellcheck -x -S warning install.sh scripts/*.sh
```

## Monitores

Dois monitores: principal 2560x1440 paisagem à direita, secundário 1920x1080 em retrato à esquerda.
Configure em **Configurações do Sistema → Tela e Monitor** no primeiro boot; o `kscreen` guarda
a disposição por combinação de monitores em `~/.local/share/kscreen/`.

## Ressalvas

- **`--skipreview` no `paru`.** Os pacotes do AUR são instalados sem exibir o `PKGBUILD`. AUR é
  conteúdo enviado por usuário rodando com as permissões do `makepkg`. Sem isso o script pararia
  em cada um dos 12. Pra conferir uma receita antes: `paru -G <pacote>` e ler à mão.
- **RedM no Linux é só pra desenvolvimento.** O client oficial não roda em Wine (anticheat). O client
  custom em insecure mode, o servidor local sem `svadhesive` e o plano B com GPU passthrough estão em
  [RedMLinux](https://github.com/eualexandrerrr/RedMLinux). Este repo só instala `wine`/`winetricks`.
- Credenciais e variáveis de ambiente ficam em `dotfiles-private` (privado); o `.zshrc` carrega
  `~/.dotfiles-private/env.sh` se existir.

## Histórico

- Até 09/2026 o repo era Hyprland + Quickshell (nandoroid-shell). Trocado por KDE Plasma; a pilha
  antiga está no histórico do git (`git log --before=2026-09-05`).
- Branch `backup/i3-x11-2023` guarda o rice de i3 + polybar.
- 05/09/2026: MCP do Claude Code restaurados do backup do Windows via `scripts/mcp-restaurar.sh`.
- 05/09/2026: configuração do KDE passou a ser versionada em `scripts/kde-settings.conf`,
  com `kde-capture.sh` / `kde-apply.sh` fazendo o ida e volta com a GUI.
- 05/09/2026: `kitty` trocado por `ghostty` (terminal padrão do KDE, `TERMINAL` no `.zshrc`,
  lançador do painel e `terminfo` do live ISO do myarch).
