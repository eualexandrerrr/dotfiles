# dotfiles

Pós-instalação da máquina de desenvolvimento: Arch Linux, **Hyprland** em Wayland, NVIDIA,
e os arquivos de configuração que valem versionar — cada um no seu pacote, linkado pelo
GNU Stow.

```
git clone https://github.com/eualexandrerrr/dotfiles ~/.dotfiles
bash ~/.dotfiles/install.sh
```

O `install.sh` é idempotente: pode rodar de novo a qualquer hora. Sem placa NVIDIA ele pula
driver e parâmetros de kernel sozinho (ou force com `SKIP_NVIDIA=1`).

---

## install.sh × setup.sh

| | o quê | quando |
|---|---|---|
| `install.sh` | instala pacotes, driver, serviços, SDDM | mexeu no `packages.txt` |
| `setup.sh` | configura e recarrega, sem rede, em segundos | mexeu numa config |

```
~/.dotfiles/setup.sh                  # tudo
~/.dotfiles/setup.sh links wallpaper  # só as etapas citadas
~/.dotfiles/setup.sh --lista          # mostra as etapas
```

Etapas: `links home perfil tema energia audio dns wallpaper recarregar`.
Etapa que falha vira aviso; as outras seguem.

---

## A sessão

O SDDM abre a sessão **Hyprland (uwsm)** — `hyprland-uwsm.desktop`, não o `hyprland.desktop`
puro. O [uwsm](https://github.com/Vladimir-csp/uwsm) coloca o compositor dentro de units do
systemd, e é isso que faz o `graphical-session.target` existir de verdade. O
`ricepanel.service` depende dele; com Hyprland pelado o painel do monitor vertical não sobe.

Por isso todo app iniciado pela sessão usa `uwsm app -- <programa>`: cada um vira um scope
do systemd e morre junto com a sessão, em vez de virar processo órfão.

### Peças

| Função | Programa |
|---|---|
| Compositor | `hyprland` |
| Barra | `waybar` (topo, só no `DP-1`) |
| Lançador | `fuzzel` |
| Notificações | `mako` |
| Wallpaper | `awww` (o antigo `swww`, renomeado) |
| Inatividade / bloqueio | `hypridle` / `hyprlock` |
| Filtro noturno | `hyprsunset` |
| Autenticação gráfica | `hyprpolkitagent` |
| OSD de volume e brilho | `swayosd` |
| Histórico de clipboard | `cliphist` + `wl-clip-persist` |
| Encerrar sessão | `wlogout` |
| Arquivos | `thunar` (GUI) e `yazi` (terminal) |
| Captura | `grim` + `slurp` + `satty` |
| Imagens / PDF / vídeo | `imv` / `zathura` / `mpv` |

### Configuração

Tudo em arquivo de texto versionado — a razão prática de ter saído do Plasma, que misturava
configuração com estado em `~/.config` e obrigava a aplicar por D-Bus com o shell vivo.

```
hypr/.config/hypr/hyprland.lua     raiz: env, autostart, hl.config, animações
hypr/.config/hypr/monitores.lua    telas e workspaces
hypr/.config/hypr/atalhos.lua      todos os hl.bind
hypr/.config/hypr/regras.lua       hl.window_rule e hl.layer_rule
hypr/.config/hypr/hypridle.conf    inatividade (hypridle ainda usa hyprlang)
hypr/.config/hypr/hyprlock.conf    tela de bloqueio (idem)
waybar/.config/waybar/             config.jsonc + style.css
mako/.config/mako/config           notificações
fuzzel/.config/fuzzel/fuzzel.ini   lançador
wlogout/.config/wlogout/           menu de encerrar
```

O `hyprland.lua` faz `require` dos três primeiros. Mexer em atalho é mexer só no
`atalhos.lua`. Depois de editar:

```
Hyprland --verify-config                # obrigatório: diz "config ok" ou lista os erros
bash ~/.dotfiles/setup.sh recarregar    # hyprctl reload + waybar + mako
```

**A config é Lua, não hyprlang.** Desde o Hyprland 0.55 o formato `.conf` está deprecado; na
0.56 as `windowrule` em hyprlang falham inteiras. A referência offline casada com a versão
instalada é `/usr/share/hypr/stubs/hl.meta.lua` (todos os campos e dispatchers) — consultar
antes da wiki, que descreve a versão mais recente e não necessariamente a sua.

---

## Atalhos

| Tecla | Ação |
|---|---|
| `Meta+Return` | terminal (ghostty) |
| `Meta+R` / `Meta+Space` | lançador |
| `Meta+E` | arquivos |
| `Meta+B` | navegador |
| `Meta+Q` | fechar janela |
| `Meta+F` | tela cheia |
| `Meta+T` | flutuar |
| `Meta+V` | histórico de clipboard |
| `Meta+L` | bloquear |
| `Meta+Shift+E` | encerrar sessão |
| `Meta+1..9` | workspaces |
| `Meta+Shift+1..9` | mover janela para o workspace |
| `Meta+setas` | mover foco |
| `Meta+Shift+setas` | mover janela |
| `Meta+Alt+setas` | redimensionar |
| `Alt+Tab` | overview com preview ao vivo: segura o Alt, `Tab` avança, solta e entra |
| `Super+Tab` | alternar janelas |
| `Print` | captura do monitor focado |
| `Shift+Print` / `Meta+Shift+S` | recorte direto pro clipboard |
| `Meta+Shift+A` | recorte com anotação (satty) |
| `Meta+Shift+R` | gravar tela (liga/desliga) |
| `Meta+I` / `Meta+Shift+I` | tema GTK / monitores |
| `Ctrl+Shift+Home` | recarregar a sessão sem fechar nada |

`Shift+Print`, `Meta+Shift+S`, `Meta+L`, `Alt+Tab` e `Meta+setas` vieram do KDE de
propósito — memória muscular.

---

## Workspaces

Cada app tem a sua, por regra em `hypr/.config/hypr/regras.lua`, e a barra mostra o ícone
do app no lugar do número — clicar no ícone vai para a workspace.

| Workspace | App |
|---|---|
| 1 | Google Chrome |
| 2 | Discord (contador de menções aparece na barra) |
| 3 | RCode |
| 4 | VM (virt-manager e looking-glass) |
| 9 | RicePanel, na tela vertical — fora do `Alt+Tab` |

## Monitores

ASUS XG27ACS 2560x1440@180 (principal, `DP-1`) e LG UltraGear 1920x1080@144 em pé
(`DP-2`), este ocupado em tela cheia pelo RicePanel. O vertical girado ocupa 1080 de
largura, por isso o principal começa em x=1080; o y=240 centraliza os 1440 dele nos 1920
do vertical.

```lua
hl.monitor({ output = "DP-1", mode = "2560x1440@180.00", position = "1080x240", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080@143.98", position = "0x0", scale = 1, transform = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
```

O `bin/wallpaper.sh` lê a geometria por `hyprctl monitors -j` e **desconta o transform**
antes de decidir retrato × paisagem: a imagem em pé vai pro monitor em pé, a paisagem pros
outros. As duas imagens são as mesmas do MyWinISO, pro Windows e o Arch não terem cara
diferente.

Para arrastar em vez de editar, `nwg-displays` — mas ele grava em
`~/.config/hypr/monitors.conf`, em **hyprlang e com nome diferente do nosso**; leia os
números de lá e traduza pro `monitores.lua` do repo à mão, senão a mudança fica fora do git
e em formato deprecado.

---

## Energia

Nunca suspende, nunca hiberna. A única coisa que a inatividade faz é apagar os monitores em
5 minutos. Três camadas: `hypridle`, alvos de sono **mascarados** no systemd e
`IdleAction=ignore` no logind (as duas últimas em `bin/energia.sh`). Bloqueio automático
fica desligado; `Meta+L` bloqueia na hora, com senha.

---

## Keyring: não instalar nenhum

**Sem keyring, o Chrome usa o backend `basic`** (cookies `v10`), então o perfil sobrevive ao
format sem depender da senha de login. Instalar `gnome-keyring` passaria os cookies pra
`v11` e criaria essa dependência — por isso ele não está no `packages.txt` e não deve entrar
por conveniência de nenhum app. O `ricepanel.service` sobe o Electron com
`--password-store=basic` pelo mesmo motivo.

No KDE isso custava quatro bloqueios (o KWallet voltava pelo PAM, pelo autostart e pela
ativação D-Bus). Com o Plasma fora, o estado desejado virou o padrão natural.

---

## Estrutura

```
zsh ghostty git xdg apps systemd-user   pacotes stow, viram links no $HOME
hypr waybar mako fuzzel wlogout qt      pacotes da sessão
bin        wallpaper, captura, recorte, energia, audio, dns
segredos   credenciais cifradas com age; chave só no pendrive do Ventoy
vm         VM Windows com passthrough (XML do libvirt, hooks)
perfil     avatar, copiado pra ~/.face
wallpaper  paisagem (principal) e retrato (vertical)
workspaces .code-workspace copiados pra ~/Workspaces
```

Stow roda com `--no-folding --restow`. O `--no-folding` é obrigatório: sem ele o stow linka
o diretório inteiro e os apps passam a gravar dentro do repo.

Pacote é a pasta que tem entrada com ponto na raiz (`.config`, `.local`, `.zshrc`) — o
`install.sh` distingue sozinho. Pasta sem isso é ferramenta.

---

## Notas para quem for depurar

- Linha inválida **não derruba a sessão**: o Hyprland ignora e segue. Por isso
  `Hyprland --verify-config` antes de logar é obrigatório — ele roda sem subir sessão.
- `hyprctl reload` não recarrega a waybar — é processo separado; o `setup.sh recarregar`
  manda `SIGUSR2` nela. JSON inválido no `config.jsonc` derruba a barra inteira.
- `transform = 1` é 90°. Se a tela vertical sair de cabeça pra baixo, o valor certo é `3`.
- Em NVIDIA, `no_hardware_cursors = true` evita cursor invisível ou piscando.
- O shell é zsh: `for p in $var` não faz word splitting. Use array ou `bash -c`.
- `pacman -Q` mente sobre pacote instalado nesta máquina; use `command -v` para binário e
  `pacman -Si` para saber se um pacote existe nos repos.

---

## Créditos

O overview de workspaces do `Alt+Tab` é o **[hyprexpose](https://github.com/ThiagoAVicente/hyprexpose)**,
de ThiagoAVicente, sob licença MIT. Este repo usa uma **versão modificada**: o pacote
`pacotes/hyprexpose/` compila o upstream com o patch `0001-ignorar-monitores.patch`, que
adiciona a chave de configuração `ignore_monitors` — ausente no original — para deixar o
monitor vertical de fora do overview. Nada mais foi alterado.

O alternador de janelas do `Super+Tab` é o **[hyprswitch](https://github.com/egnrse/hyprswitch)**
(fork de [H3rmt/hyprshell](https://github.com/H3rmt/hyprshell)), MIT, usado sem modificação.

## Histórico

Até 07/09/2026 este repo era KDE Plasma, com painel, Layan, Klassy, Windows-Modern e um
`layout-once.sh` que aplicava tudo por D-Bus no primeiro login. Isso saiu inteiro na
migração para Hyprland: pacotes, configs, scripts e vendor. O que sobreviveu foram as
decisões que não eram do Plasma — wallpaper por geometria, DNS medido, sono mascarado,
ausência de keyring e o RicePanel no monitor vertical.
