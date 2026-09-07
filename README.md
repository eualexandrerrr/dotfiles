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
hypr/.config/hypr/hyprland.conf    raiz: exec-once, env, visual, input
hypr/.config/hypr/monitores.conf   disposição das telas e workspaces
hypr/.config/hypr/atalhos.conf     todos os bind
hypr/.config/hypr/regras.conf      windowrule e layerrule
hypr/.config/hypr/hypridle.conf    inatividade
hypr/.config/hypr/hyprlock.conf    tela de bloqueio
waybar/.config/waybar/             config.jsonc + style.css
mako/.config/mako/config           notificações
fuzzel/.config/fuzzel/fuzzel.ini   lançador
wlogout/.config/wlogout/           menu de encerrar
```

O `hyprland.conf` faz `source` dos três primeiros. Mexer em atalho é mexer só no
`atalhos.conf`. Depois de editar:

```
bash ~/.dotfiles/setup.sh recarregar    # hyprctl reload + waybar + mako
hyprctl configerrors                    # linha inválida é ignorada em silêncio
```

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
| `Alt+Tab` | alternar janelas |
| `Print` | captura do monitor focado |
| `Shift+Print` / `Meta+Shift+S` | recorte direto pro clipboard |
| `Meta+Shift+A` | recorte com anotação (satty) |
| `Meta+Shift+R` | gravar tela (liga/desliga) |
| `Meta+I` / `Meta+Shift+I` | tema GTK / monitores |

`Shift+Print`, `Meta+Shift+S`, `Meta+L`, `Alt+Tab` e `Meta+setas` vieram do KDE de
propósito — memória muscular.

---

## Monitores

ASUS XG27ACS 2560x1440@180 (principal, `DP-1`) e LG UltraGear 1920x1080@144 em pé
(`DP-2`), este ocupado em tela cheia pelo RicePanel. O vertical girado ocupa 1080 de
largura, por isso o principal começa em x=1080; o y=240 centraliza os 1440 dele nos 1920
do vertical.

```
monitor = DP-1, 2560x1440@180.00, 1080x240, 1
monitor = DP-2, 1920x1080@143.98, 0x0, 1, transform, 1
monitor = , preferred, auto, 1
```

O `bin/wallpaper.sh` lê a geometria por `hyprctl monitors -j` e **desconta o transform**
antes de decidir retrato × paisagem: a imagem em pé vai pro monitor em pé, a paisagem pros
outros. As duas imagens são as mesmas do MyWinISO, pro Windows e o Arch não terem cara
diferente.

Para arrastar em vez de editar, `nwg-displays` — mas ele grava em
`~/.config/hypr/monitors.conf`, **nome diferente do nosso**; copie o resultado pro
`monitores.conf` do repo, senão a mudança fica fora do git.

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

- Linha inválida no `hyprland.conf` **não derruba a sessão**: o Hyprland ignora e segue.
  `hyprctl configerrors` é o que conta.
- `hyprctl reload` não recarrega a waybar — é processo separado; o `setup.sh recarregar`
  manda `SIGUSR2` nela. JSON inválido no `config.jsonc` derruba a barra inteira.
- `transform, 1` é 90°. Se a tela vertical sair de cabeça pra baixo, o valor certo é `3`.
- Em NVIDIA, `no_hardware_cursors = true` evita cursor invisível ou piscando.
- O shell é zsh: `for p in $var` não faz word splitting. Use array ou `bash -c`.
- `pacman -Q` mente sobre pacote instalado nesta máquina; use `command -v` para binário e
  `pacman -Si` para saber se um pacote existe nos repos.

---

## Histórico

Até 07/09/2026 este repo era KDE Plasma, com painel, Layan, Klassy, Windows-Modern e um
`layout-once.sh` que aplicava tudo por D-Bus no primeiro login. Isso saiu inteiro na
migração para Hyprland: pacotes, configs, scripts e vendor. O que sobreviveu foram as
decisões que não eram do Plasma — wallpaper por geometria, DNS medido, sono mascarado,
ausência de keyring e o RicePanel no monitor vertical.
