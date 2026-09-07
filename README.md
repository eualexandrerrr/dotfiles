<div align="center">

# dotfiles

**Arch Linux · Hyprland (Wayland) · NVIDIA**

Pós-instalação de uma máquina com RTX 3090: pacotes, driver, Hyprland, serviços e os
poucos arquivos de configuração que valem versionar.

[![Arch](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat-square&logo=hyprland&logoColor=black)](https://hypr.land/)
[![NVIDIA](https://img.shields.io/badge/nvidia--open--dkms-76B900?style=flat-square&logo=nvidia&logoColor=white)](https://wiki.archlinux.org/title/NVIDIA)

</div>

---

## Stack

| Camada | Programa |
|:--|:--|
| Desktop | Hyprland em Wayland, janelas flutuantes; barra `waybar`, notificacao `mako`, lancador `wofi` |
| Login | `sddm` com greeter em `weston`; login automatico (`Relogin=false`: so ao ligar o PC e na volta da VM w11) |
| Terminal | `ghostty` |
| Shell | `zsh` + `starship` + `zsh-autosuggestions` + `zsh-syntax-highlighting` |
| Arquivos, imagens, PDF, prints | `dolphin`, `gwenview`, `okular`, `hyprshot` |
| Ícones | [Tela](https://github.com/vinceliuice/Tela-icon-theme) (`tela-icon-theme`, AUR), variante `Tela-dark` |
| Cursor | [Capitaine](https://github.com/keeferrourke/capitaine-cursors) (`capitaine-cursors`, repo oficial), setado por `XCURSOR_THEME` no `hyprland.conf` |
| Fora de propósito | Wi-Fi no live, Firefox (Chrome cobre), LibreOffice, Telegram, OBS. `pacman -S` traz de volta |
| Kernel e driver | `linux-zen`, `nvidia-open-dkms`, `nvidia_drm.modeset=1` |
| Desempenho | `power-profiles-daemon` em `performance`, `ananicy-cpp` com as regras do CachyOS |
| Jogos e Wine | `steam`, `lutris`, `wine`, `winetricks`, `gamescope`, `mangohud` |
| VMs | `qemu-full`, `libvirt`, `virt-manager` (plano B do RedM) |
| Agente no terminal | `claude-code` (AUR) |
| Segundo monitor | `widget-claude` em tela cheia, do repo [Utils](https://github.com/eualexandrerrr/Utils) — ver [Monitores](#monitores) |

Tudo do Hyprland é arquivo de texto e vai versionado inteiro: compositor, barra,
notificação, lançador e bloqueio de tela ficam em `links/config`, sem estado misturado
à configuração e sem nada que se reescreva sozinho no logout.

## Estrutura

```
dotfiles
├── bin                       comandos
│   ├── recorte-clipboard.sh  Shift+Print: região da tela → área de transferência
│   ├── nvidia-desempenho.sh  GPU em performance máxima no login
│   └── mcp-restaurar.sh      recria os 8 MCP do Claude Code no ~/.claude.json
├── links                     o que vira symlink no $HOME
│   ├── home                  .zshrc, .zprofile
│   ├── config                → ~/.config: hypr, waybar, mako, wofi, ghostty, autostart
│   └── local                 → ~/.local/share: lançador do Shift+Print
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
7. `sddm` em Wayland com greeter `weston` e login automático do usuário

Reinicie no fim.

```bash
cat /sys/module/nvidia_drm/parameters/modeset   # tem que retornar Y
```

Sem placa NVIDIA no PCI (VM, outra máquina) o driver é pulado sozinho. Pra forçar:

```bash
SKIP_NVIDIA=1 ./install.sh
```

## Energia

Desktop na tomada: nada de suspender por inatividade. O `hypridle` cuida disso em
`links/config/hypr/hypridle.conf`, com dois listeners: bloqueio em 10 min e DPMS em
15 min. Suspensão automática não existe — o listener não está lá.

O perfil do `power-profiles-daemon` fica em `performance`, escrito pelo instalador em
`/var/lib/power-profiles-daemon/state.ini`.

## MCP do Claude Code

```bash
~/.dotfiles/bin/mcp-restaurar.sh   # grava os 8 servidores no ~/.claude.json
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
| restaurar os 8 MCP | `mcp-restaurar.sh` + `claude mcp list` |
| conferir sintaxe dos scripts | `bash -n` em tudo |
| gerar a ISO | `sudo ./archiso/build.sh` do myarch |
| espelho do Drive | retomar o download e ver progresso |

`shellcheck` e `shfmt` estão no `packages.txt` porque as extensões recomendadas
(`timonwong.shellcheck`, `foxundermoon.shell-format`) precisam dos binários. Antes de
commitar script:

```bash
shellcheck -x -S warning install.sh bin/*.sh
```
aberta ganha o `_NET_WM_STATE_SKIP_TASKBAR`.


O instalador confere as dependências, resolve o Electron e escreve
`~/.config/systemd/user/widget-claude.service`. O `Restart=on-failure` da unit faz o papel do
watchdog que existia no Windows: queda volta sozinha, e fechar pelo X do painel é saída limpa —
fica fechado até alguém mandar subir.

```bash
systemctl --user status widget-claude
tail -f <pasta>/widget.log
```

Duas coisas que só valem aqui e custaram tempo pra descobrir:

- **`--ozone-platform=x11` vai na linha de comando**, no `ExecStart` da unit. Não adianta ligar
  por `app.commandLine` dentro do app: o Chromium escolhe a plataforma antes de rodar o `main.js`
  e o switch é ignorado em silêncio. Sem a flag a janela nasce como cliente Wayland, o `setBounds`
  não vale nada e o painel some atrás das outras janelas em vez de ocupar o monitor vertical.
- **`electron` do pacman, não o do npm.** O binário que o npm baixa vem sem o setuid do
  `chrome-sandbox`.

## Ressalvas

- **`--skipreview` no `paru`.** Os pacotes do AUR são instalados sem exibir o `PKGBUILD`. AUR é
  conteúdo enviado por usuário rodando com as permissões do `makepkg`. Sem isso o script pararia
  em cada um dos 12. Pra conferir uma receita antes: `paru -G <pacote>` e ler à mão.
- **RedM no Linux é só pra desenvolvimento.** O client oficial não roda em Wine (anticheat). O client
  custom em insecure mode, o servidor local sem `svadhesive` e o plano B com GPU passthrough estão em
  [RedMLinux](https://github.com/eualexandrerrr/RedMLinux). Este repo só instala `wine`/`winetricks`.
- **O roteador engole consultas AAAA.** Domínio sem registro IPv6 (`sentry.io`, `discord.com`)
  trava 15-20 s no `getaddrinfo`, porque o `192.168.1.1` não responde nem o "não tem" — quem
  pergunta fica esperando o timeout. O `fetch` do Node desiste antes (10 s), então o painel mostra
  Sentry e Discord vazios enquanto o `curl` resolve na hora. Domínio **com** AAAA (`api.anthropic.com`)
  não sofre. O painel contorna usando o `net.fetch` do Electron, que aguenta a espera em vez de
  desistir — mas cada consulta ainda custa os 15 s. A correção de verdade é um resolvedor que
  responda NODATA: o `systemd-resolved`, que o `nsswitch.conf` já prefere (`hosts: ... resolve ...`),
  está desabilitado.
- Credenciais e variáveis de ambiente ficam em `dotfiles-private` (privado); o `.zshrc` carrega
  `~/.dotfiles-private/env.sh` se existir.

## Histórico

- 07/09/2026: volta pro Hyprland, agora com waybar em vez de quickshell. KDE Plasma e o tema
  Windows Modern saíram do repo inteiros (`kde/`, `vendor/windows-modern`, as chaves de
  `~/.config` do Plasma); a pilha do KDE está no histórico do git (`git log --before=2026-09-07`).
- Até 09/2026 o repo era Hyprland + Quickshell (nandoroid-shell). Trocado por KDE Plasma; a pilha
  antiga está no histórico do git (`git log --before=2026-09-05`).
- Branch `backup/i3-x11-2023` guarda o rice de i3 + polybar.
- 05/09/2026: MCP do Claude Code restaurados do backup do Windows via `bin/mcp-restaurar.sh`.
- 05/09/2026: configuração do KDE passou a ser versionada em `kde/settings.conf`,
  com `kde-capture.sh` / `kde-apply.sh` fazendo o ida e volta com a GUI.
- 05/09/2026: o widget-claude (painel do segundo monitor, do repo `Utils`) foi portado do Windows
  pro Linux e passou a subir por unit do systemd — ver [Monitores](#monitores).
- 05/09/2026: `powermanagementprofilesrc` entrou no espelhamento — o PC não suspende, não
  apaga e não escurece a tela por inatividade. Ver [Energia](#energia).
- 05/09/2026: `kitty` trocado por `ghostty` (terminal padrão do KDE, `TERMINAL` no `.zshrc`,
  lançador do painel e `terminfo` do live ISO do myarch).
