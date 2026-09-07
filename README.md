<div align="center">

# dotfiles

**Arch Linux · KDE Plasma (Wayland) · duas GPUs**

Pós-instalação de uma máquina de desenvolvimento com duas GPUs: a RX 550 desenha o Linux,
a RTX 3090 vai inteira pra uma VM Windows por passthrough e roda o RedM numa janela do KDE.
Pacotes, driver, KDE, serviços e os poucos arquivos de configuração que valem versionar —
cada um no seu pacote, linkado pelo GNU Stow.

[![Arch](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![KDE](https://img.shields.io/badge/KDE_Plasma-1D99F3?style=flat-square&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![AMD](https://img.shields.io/badge/RX_550_amdgpu-ED1C24?style=flat-square&logo=amd&logoColor=white)](https://wiki.archlinux.org/title/AMDGPU)
[![NVIDIA](https://img.shields.io/badge/RTX_3090_vfio-76B900?style=flat-square&logo=nvidia&logoColor=white)](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
[![Stow](https://img.shields.io/badge/GNU_Stow-A42E2B?style=flat-square&logo=gnu&logoColor=white)](https://www.gnu.org/software/stow/)

</div>

---

## Hardware

| Peça | Modelo | Papel |
|:--|:--|:--|
| CPU | AMD Ryzen 7 5700X, 8c/16t, sem vídeo integrado | 2 núcleos pro host, 6 pinados na VM |
| Placa-mãe | ASUS TUF Gaming B550M-PLUS (mATX, AM4, B550) | x16 Gen4 pela CPU + x16 Gen3 (em x4) pelo chipset; 2 M.2, LAN 2.5G |
| RAM | 32 GB DDR4, dual channel (4 slots, até 128 GB) | 8 GB pro host, o resto pra VM |
| GPU do host | PCYes Radeon RX 550 4GB GDDR5 | `amdgpu` do kernel, desenha o KDE nos dois monitores |
| GPU da VM | Gainward RTX 3090 24GB, cooler de 2,7 slots | presa no `vfio-pci` desde o boot, nunca toca o host |
| Riser | cabo PCIe 3.0 x16, 20 cm, plugue 90° | a 3090 tampa o slot de baixo; a RX 550 sai por ele |
| Fonte | 850 W, 80 Plus Gold | montada atrás da bandeja |
| SSD | Corsair MP700 ELITE, 932 GB, NVMe | Gen4 x4 pela CPU; Arch em `/`, imagem da VM em `/home` |
| Gabinete | PCYes Forcefield Mini Black Vulcan | mini tower, GPU até 310 mm |
| Monitores | ASUS XG27ACS 2560x1440@180Hz + LG UltraGear **1920x1080@144Hz** | o ASUS em paisagem à direita; o LG em pé à esquerda, com o RicePanel |

### Por que duas GPUs

O client do RedM não passa pelo anticheat em Wine. A saída é uma VM Windows com GPU real,
e uma GPU passada por `vfio` some do host: o Linux precisa de outra placa pra ter tela.

Com as duas, os dois monitores ficam no KDE o tempo inteiro. O jogo renderiza na 3090 dentro
da VM, o Looking Glass copia o frame pra memória compartilhada e o cliente desenha numa
janela comum — alt tab, workspace, tudo como qualquer aplicativo. A 3090 não tem cabo de
vídeo nenhum; ela só entrega frame.

O slot de baixo da B550M-PLUS fica fisicamente coberto pela 3090 de 2,7 slots, por isso a
RX 550 sai por um cabo riser de 20 cm e fica fixada fora dos brackets, embaixo da placa-mãe.

## Stack

| Camada | Programa |
|:--|:--|
| Desktop | KDE Plasma 6 em Wayland (`plasma-desktop`, sem `plasma-meta`) |
| Login | `sddm` com greeter em `kwin_wayland`, tema Breeze; login automatico (`Relogin=false`: so ao ligar o PC e na volta da VM w11) |
| Terminal | `ghostty` (registrado como terminal padrão do KDE) |
| Shell | `zsh` + `starship` + `zsh-autosuggestions` + `zsh-syntax-highlighting` |
| Arquivos, imagens, PDF, prints | `dolphin`, `gwenview`, `okular`, `spectacle` |
| Ícones | [Tela](https://github.com/vinceliuice/Tela-icon-theme) (`tela-icon-theme`, AUR), variante `Tela-dark` setada no `kdeglobals` |
| Cursor | [Capitaine](https://github.com/keeferrourke/capitaine-cursors) (`capitaine-cursors`, repo oficial), variante clara `capitaine-cursors-white` no `kcminputrc` |
| Fora de propósito | Wi-Fi no live, Firefox (Chrome cobre), LibreOffice, Telegram, OBS, Wine e Steam no host. `pacman -S` traz de volta |
| Bluetooth | sem uso, mas o `bluez-qt` **é obrigatório** — ver [Bandeja do sistema](#bandeja-do-sistema). O `bluetooth.service` fica desabilitado |
| Kernel e driver | `linux-zen`; host em `amdgpu` (kernel), 3090 em `vfio-pci` por id no cmdline |
| Desempenho | `power-profiles-daemon` em `performance`, `ananicy-cpp` com as regras do CachyOS, GPU em "Prefer maximum performance" no login |
| Jogos | dentro da VM Windows com GPU passthrough — ver `vm/` |
| VMs | `qemu-full`, `libvirt`, `virt-manager` |
| Agente no terminal | `claude-code` (AUR) |
| Segundo monitor | `RicePanel` em tela cheia (`~/Apps/desktop/RicePanel`) — ver [Monitores](#monitores) |

Barra, painéis, wallpaper e disposição de monitores continuam sendo do próprio Plasma e
não são versionados: o KDE grava dezenas de arquivos em `~/.config` com estado misturado à
configuração (posição de janela, hash de tema, UUID de desktop virtual), e commitar isso
vira ruído que conflita a cada login.

O que **é** versionado são as decisões: teclado, mouse, tema, ícones, terminal padrão,
bordas de janela. Ficam em `kde/settings.conf`, uma chave por linha, geradas por
curadoria — ver [Configuração do KDE](#configuração-do-kde).

## Estrutura

Uma pasta por programa, na raiz. Cada pacote espelha o `$HOME` a partir da própria raiz e o
GNU Stow linka; o que não é pacote é ferramenta (`bin`, `kde`, `vm`, `vendor`, `wallpaper`).
O install distingue os dois sozinho: pacote é a pasta que tem uma entrada com ponto na raiz.

```
dotfiles
├── zsh                       .zshrc, .zprofile
├── ghostty                   .config/ghostty/config
├── kwin                      .config/kwinrc, kwinrulesrc
├── plasma                    .config/plasmarc, kdeglobals, kglobalshortcutsrc, kcminputrc,
│                             kxkbrc, plasma-localerc, plasmanotifyrc, e o .mo do menu
├── dolphin                   dolphinrc, view_properties global e o layout dos painéis
├── powerdevil                .config/powerdevilrc, powermanagementprofilesrc
├── autostart                 .config/autostart/*.desktop
├── apps                      .local/share/applications/*.desktop
├── git                       .gitconfig: identidade e o gh como credential helper
├── xdg                       user-dirs: home sem as pastas padrão do Linux
├── systemd-user              units do usuário (RicePanel no monitor vertical)
├── dbus                      sobrepõe a ativação do kwallet/ksecretd por /bin/false
├── perfil                    avatar.png: foto do perfil (KDE e tela de login)
├── sddm                      kwinoutputconfig.json: greeter só no monitor principal
│
├── kde                       scripts e decisões do Plasma
│   ├── settings.conf         311 chaves (gerado pelo capture, não editar)
│   ├── monitores.conf        disposição das telas, casada por conector
│   ├── capture.sh            lê o KDE vivo e regrava o settings.conf
│   ├── apply.sh              aplica o settings.conf via kwriteconfig6
│   ├── monitores.sh          aplica o monitores.conf (--capturar grava a sessão atual)
│   ├── wallpaper.sh          retrato no monitor em pé, paisagem no outro
│   ├── layout-once.sh        primeiro login: chama o setup.sh e instala o tema
│   ├── energia.sh            nunca dormir; monitores apagam em 5 min
│   ├── audio.sh              saída analógica 80% padrão, HDMI 50%, mic 80%
│   ├── login.sh              tela de login: wallpaper, foto e só o monitor principal
│   ├── layout.js             layout do painel (script do Plasma)
│   ├── painel-ajustar.sh     repõe as decisões do painel (idempotente)
│   ├── tema-instalar.sh      instala o Windows Modern a partir do vendor
│   └── sessao-teste.sh       Plasma inteiro numa janela, pra testar sem risco
├── setup.sh                  reconfigura e recarrega (sem instalar nada)
├── segredos                  credenciais cifradas (ver Credenciais)
│   ├── lista.txt             o que entra no pacote, um caminho por linha
│   ├── guardar.sh            coleta do $HOME, cifra e grava no dotfiles-private
│   ├── restaurar.sh          decifra e repõe no $HOME (etapa 12 do install)
│   └── comum.sh              monta o pendrive e acha a chave
├── bin                       comandos
│   ├── recorte-clipboard.sh  Shift+Print: região da tela → área de transferência
│   ├── nvidia-desempenho.sh  GPU em performance máxima no login
│   ├── dns-rapido.sh         mede os resolvedores e aplica o mais rápido
│   └── mcp-restaurar.sh      recria os 8 MCP do Claude Code no ~/.claude.json
├── vm                        VM Windows com a 3090 em passthrough (XML do libvirt e hooks)
├── vendor
│   └── windows-modern        o tema, versionado aqui (ver PROVENIENCIA.md)
├── wallpaper                 as duas imagens, paisagem e retrato
├── install.sh                pós-instalação, idempotente
└── packages.txt              pacotes por seção; [repo-oficial:*] vai pro pacman, [aur] pro paru
```

### Como o stow linka

```bash
cd ~/.dotfiles && stow --no-folding --restow --target="$HOME" zsh ghostty kwin plasma dolphin powerdevil autostart apps
```

É isso que o `install.sh` roda, pacote a pacote. Duas flags que não são opcionais:

**`--no-folding`.** Sem ela, quando `~/.config/ghostty` não existe o stow linka o diretório
inteiro, e aí tudo que qualquer programa gravar ali cai dentro do repo. O KDE e o Chrome
escrevem em `~/.local/share/applications` — um link de diretório ali faria o `git status`
sujar sozinho. Com `--no-folding` ele cria os diretórios de verdade e linka só os arquivos.

**`--restow`.** Desfaz e refaz: arquivo que saiu do repo perde o link, arquivo novo ganha.
É o que deixa o install idempotente.

Adicionar um programa: cria `<nome>/` na raiz com a árvore que ele espera no `$HOME`, roda o
install. Nada mais a registrar.

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
7. `sddm` em Wayland com `kwin`, tema Breeze e login automático do usuário
8. Padrões do KDE: `kde/apply.sh` grava tudo que está no `kde-settings.conf`

Reinicie no fim.

```bash
cat /sys/module/nvidia_drm/parameters/modeset   # tem que retornar Y
```

Sem placa NVIDIA no PCI (VM, outra máquina) o driver é pulado sozinho. Pra forçar:

```bash
SKIP_NVIDIA=1 ./install.sh
```

## Espelhamento ao vivo

Onze arquivos do KDE são **symlink pra dentro do repo**: mexeu na interface gráfica, já
está versionado, sem passo intermediário.

```
~/.config/kdeglobals          -> plasma/.config/kdeglobals
~/.config/kwinrc              -> kwin/.config/kwinrc
~/.config/dolphinrc           -> dolphin/.config/dolphinrc
~/.config/powerdevilrc        -> powerdevil/.config/powerdevilrc
```

e assim por diante, cada arquivo no pacote do programa dono dele.

Isso funciona porque o KConfig **grava através do symlink** em vez de substituir o
arquivo. Verificado: uma chave escrita com `kwriteconfig6` apareceu no arquivo do repo e o
link continuou link.

O preço é conhecido e aceito: o repo passa a carregar os arquivos inteiros, não só as
decisões. O `kdeglobals` tem 121 chaves e só 24 são escolha sua — o resto é
`ColorSchemeHash`, as 84 chaves da paleta e geometria de diálogo. Espere `git status` sujo
depois de mexer no tema, e leia o diff antes de commitar.

O `plasma-org.kde.plasma.desktop-appletsrc` ficou **de fora** de propósito: as 96 chaves
dele são indexadas pelo número do applet, que muda a cada painel recriado. Quem cuida
dele é o `kde/painel-ajustar.sh`.

### O que sobra do settings.conf

Nada, na prática. Com os onze arquivos espelhados, o `apply.sh` não tem o que fazer:

```
kde-apply: 0 chaves aplicadas, 311 puladas por ja estarem espelhadas
```

O `apply.sh` agora **pula arquivo espelhado** — sem isso ele escreveria o `settings.conf`
por cima do que você acabou de mudar na GUI, desfazendo o ajuste. O `settings.conf` segue
sendo gerado pelo `capture.sh` e continua servindo de leitura das decisões num arquivo só,
mas já não é o mecanismo.

## Energia

Desktop na tomada: **nada de suspender, apagar a tela ou escurecer por inatividade**. O
`powerdevil` 6.7 guarda isso em `powermanagementprofilesrc`, um grupo por perfil e chaves
soltas dentro dele — o formato antigo de subgrupo (`[AC][SuspendSession]`, `suspendType`)
foi migrado no Plasma 6 e não vale mais.

```ini
[AC]
autoSuspendAction=0        # PowerButtonAction::NoAction (1 dorme, 2 hiberna, 8 desliga)
dimDisplayWhenIdle=false
turnOffDisplayWhenIdle=false
```

Não é só "timeout alto": lido no fonte do `powerdevil`, `autoSuspendAction=0` faz o
`SuspendSession::loadAction` sair antes de registrar qualquer timeout de ociosidade, e
`turnOffDisplayWhenIdle=false` descarrega a ação de DPMS inteira — inclusive o timeout
separado que valeria com a sessão já bloqueada (`turnOffDisplayIdleTimeoutWhenLockedSec`).

Só o grupo `[AC]`: sem bateria na máquina, é o único perfil que o `powerdevil` carrega, e
assim o arquivo indo pra um notebook não deixa a bateria correndo solta.

Aplica sem deslogar:

```bash
qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement reparseConfiguration
```

O **bloqueio de tela** é outro mecanismo (`kscreenlockerrc`, 5 min de padrão) e ficou como
estava — o que muda é que, com o DPMS fora, a tela agora fica acesa mostrando o bloqueio
em vez de apagar.

## Configuração do KDE

Nada de editar `~/.config` na mão. O ciclo é: **mexer na GUI → capturar → commitar**.

```bash
# ajuste o que quiser em Configurações do Sistema, depois:
~/.dotfiles/kde/capture.sh
git -C ~/.dotfiles diff          # confira o que mudou
git -C ~/.dotfiles commit -am "kde: ..."
```

Em outra máquina (ou depois de reinstalar), o `install.sh` chama sozinho:

```bash
~/.dotfiles/kde/apply.sh   # aplica e recarrega o kwin, sem precisar deslogar
```

### O que fica de fora, e por quê

A curadoria recusa tanto quanto aceita. Os casos e o motivo, todos verificados no arquivo:

| Grupo | Por que não entra |
|:--|:--|
| `kdeglobals` `[Colors:*]`, `[ColorEffects:*]`, `[WM]` | 84 chaves da paleta, escritas ao aplicar o esquema de cores. É o tema, não decisão sua |
| `kwinrc` `[Desktops]` | `Id_1` é UUID, e `Number`/`Rows` já caem no `IGNORAR_CHAVE` — capturaria nada |
| `kwinrc` `[Tiling][uuid][uuid]` | indexado por UUID de tela e de desktop; não transfere pra outra máquina |
| `dolphinrc` `[General]` | só `Version` e `ViewPropsTimestamp`, ambos já ignorados |
| `spectaclerc` `[ImageSave]` | `lastImageSaveLocation` é estado puro — chegou a apontar pra um `/tmp` |
| `gwenviewrc` | `Recent Files`, geometria de janela: estado |

O `kde-capture.sh` não copia o `~/.config` inteiro: a lista `GRUPOS` dentro dele é a
curadoria de quais `arquivo:grupo` valem versionar, e `IGNORAR_CHAVE` derruba o que é
estado (`ColorSchemeHash`, `Id_*`, contadores). Pra versionar mais coisa, acrescente o par
`arquivo:grupo` nessa lista e rode o capture de novo.

O que está coberto hoje:

| Arquivo | Grupo | O que é |
|:--|:--|:--|
| `kcminputrc` | `Keyboard` | repetição de teclas: **200 ms** de atraso, **50 Hz** (padrão do Plasma é 600 ms / 25 Hz) |
| `kcminputrc` | `Libinput[...]` | aceleração do ponteiro e fator de rolagem, por dispositivo |
| `kxkbrc` | `Layout` | teclado `br` (ABNT2) |
| `kdeglobals` | `Locale` | idioma da interface, `pt_BR` |
| `plasma-localerc` | **todos** | idioma e formatos regionais |
| `kdeglobals` | `General` | terminal padrão `ghostty`, navegador `google-chrome` |
| `kdeglobals` | `Icons`, `KDE` | ícones `Tela-dark`, estilo `kvantum-dark`, look-and-feel Windows Modern |
| `kwinrc` | `Windows`, `org.kde.kdecoration2` | maximizada sem borda, borda `Tiny`, decoração Aurorae |
| `plasmarc` | `Theme` | tema Plasma `breeze-dark` |
| `kglobalshortcutsrc` | **todos** | o mapa de teclas inteiro: `kwin` (janelas), `plasmashell`, `ksmserver` (desligar/bloquear), `kmix` (volume), `org_kde_powerdevil` (brilho) e os lançadores em `services` |
| `.local/share/dolphin/.../.directory` | `Dolphin` | `ViewMode=1`: pastas abrem em **Detalhes** |
| `kwinrulesrc` | **todos** | regras de janela; hoje uma só, o painel do segundo monitor fora da barra |

### Capturas de tela

O app é o `spectacle`, que já vem no `packages.txt`.

| Tecla | O que faz |
|:--|:--|
| `Print` | abre a janela do Spectacle (padrão do Plasma, intocado) |
| `Shift+Print` | **recorta uma região e copia a imagem pro clipboard**, sem abrir janela |
| `Meta+Shift+Print` | recorte que abre a janela do Spectacle (padrão do Plasma) |

O `Shift+Print` chama `bin/recorte-clipboard.sh`, por um lançador próprio em
`local/share/applications/`. O script captura num arquivo temporário e passa a imagem pelo
`wl-copy`.

Nem `--copy-image` nem configuração resolvem, e as duas coisas foram medidas:

| Comando | Clipboard |
|:--|:--|
| `spectacle -f -b -n` (só o `spectaclerc`) | **intacto** — grava arquivo |
| `spectacle -f -b -c -n` (com `--copy-image`) | recebe, e **perde** ao sair |
| `spectacle -f -b -n -o arq` + `wl-copy` | recebe e **mantém** |

O `clipboardGroup` do `spectaclerc` não é honrado no caminho do atalho. E mesmo o
`--copy-image` não basta: no Wayland o conteúdo do clipboard pertence ao processo que
copiou, e o `spectacle -b` sai assim que copia. Com ele vivo o clipboard tem `image/png` e
mais 30 tipos; depois que sai sobra só `application/x-kde-onlyReplaceEmpty`. O Klipper não
assume a posse da imagem nem com `IgnoreImages=false` (testado). O `wl-copy` bifurca e
continua servindo o clipboard depois que o script termina.

O `wl-clipboard` é dependência dura disso — e também é como o Claude Code lê imagem do
clipboard no Linux (`xclip ... || wl-paste`), então sem ele o `Ctrl+V` de screenshot no
terminal não cola nada.

Não dá pra reaproveitar a ação `RectangularRegionScreenShot` do Spectacle: o `Exec` dela é
fixo em `spectacle -r`, sem `-b` e sem `-c`.

`Shift+Print` era *"capturar a área de trabalho inteira"* no padrão do Plasma; a liberação
é a linha `FullScreenScreenShot|none` no `kde-settings.conf`.

> **Atalho novo só passa a valer no login seguinte.** Nesta versão o KWin absorveu o
> kglobalaccel, e ele lê o `kglobalshortcutsrc` e resolve o `Exec` de cada lançador uma vez
> só, quando sobe. Testado: `setForeignShortcut` no D-Bus não cria componente novo,
> `kbuildsycoca6` e `reconfigure` não fazem reler, e sobrepor o `.desktop` em
> `~/.local/share/applications` não muda o `Exec` já resolvido. No Wayland o KWin não pode
> ser reiniciado sem derrubar a sessão, então o caminho é deslogar e logar.

### Barra de tarefas

Flutuante e translúcida, ajustado pelo `kde/layout-once.sh` no primeiro login:

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

A bandeja do painel é o applet `org.kde.windowsmodern.systemtray`, compilado pelo
`kde/tema-instalar.sh` a partir do fonte em `vendor/windows-modern/src` — é o
único componente do tema que não é arquivo puro.

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

## O tema mora no repo

O Windows Modern **não é clonado nem instalado pelo script do upstream**: os arquivos estão
em `vendor/windows-modern`, e o `kde/tema-instalar.sh` copia de lá.

```bash
kde/tema-instalar.sh                # copia, compila a bandeja e aplica
kde/tema-instalar.sh --sem-aplicar  # só os arquivos (é o que o install.sh chama)
```

O clone raso do tema são 122 MB e o instalador dele mexe em dez componentes com `pkexec`.
Vendorado são **6,2 MB** e a pós-instalação passa a funcionar sem rede depois do `pacman`.
O que ficou de fora e por quê está em
[`vendor/windows-modern/PROVENIENCIA.md`](vendor/windows-modern/PROVENIENCIA.md), junto do
commit exato de onde veio. Licença GPL-3.0, com `LICENSE` e `ATTRIBUTION.md` no mesmo
diretório.

Um único componente é C++ — a bandeja do sistema. Vai o fonte (680 KB) e o `install.sh`
compila com `cmake`; as dependências de build já estão no `packages.txt`.

### Home enxuta

A home tem as pastas de trabalho e mais nada:

```
~/Apps  ~/Claude  ~/Obisidian  ~/MichiganRoleplay  ~/Workspaces  ~/Downloads  ...
```

Sem `Documentos`, `Imagens`, `Modelos`, `Músicas`, `Público`, `Vídeos` nem `Área de
trabalho`. Só apagá-las não resolve: o pacote `xdg-user-dirs` as recria **a cada login**.
Por isso o pacote `xdg` do stow linka o `user-dirs.dirs` (tudo aponta pro próprio `$HOME`,
menos Downloads) e o `user-dirs.conf` com `enabled=False`, que desliga o recriador. A etapa
`home` do `setup.sh` remove o que já tiver nascido — **só se estiver vazio**, senão avisa.

Duas armadilhas que só aparecem depois:

- **`XDG_DESKTOP_DIR` não pode ser o `$HOME`.** Se for, a Vista de Pasta do Plasma
  transforma a área de trabalho numa vitrine de todas as pastas de projeto. Aponta pra
  `~/.local/share/desktop`, escondida e vazia. O `user-dirs.dirs` sozinho não basta: os
  containments que já existem guardam a própria `url`, então o `painel-ajustar.sh` reaponta.
- **Os Locais do Dolphin** continuam listando as pastas removidas, apontando pra lugar que
  não existe. A limpeza entra na mesma etapa `home`.

Os logs dos dotfiles ficam em `~/.local/state/dotfiles/`, não soltos na home.

## Dolphin

Visão em **detalhes**, colunas na ordem do Explorer (Nome, Modificado, Tipo, Tamanho),
pastas primeiro, duplo clique, sem preview de imagem no ícone de pasta
(`directorythumbnail` fora) e **pastas amarelas**.

Duas armadilhas: o `ViewMode` só vale se o `Timestamp` do `.directory` for mais novo que o
`ViewPropsTimestamp` do `dolphinrc`; e os ícones de 16/22/24px do Tela são monocromáticos,
então a pasta só sai amarela com `PreviewSize` acima de 24 (usa o `scalable`, colorido).
O `kde/icones.sh` recolore o que o `Tela-yellow-dark` deixou azul.

## Sem KWallet

A carteira do KDE fica **desligada**. Só o `kwalletrc` com `Enabled=false` não bastava: o
`kwalletd6` e o `ksecretd` voltavam sozinhos, por três caminhos diferentes.

| Caminho | Como é fechado |
|:--|:--|
| `kwalletrc` | `Enabled=false` |
| PAM, no login | `systemd-user/.../plasma-kwallet-pam.service` — unit no-op que sobrepõe a do sistema |
| autostart | `autostart/.../pam_kwallet_init.desktop` com `Hidden=true` |
| ativação D-Bus | `dbus/.local/share/dbus-1/services/*.service` apontando pra `/bin/false` |

Os quatro arquivos de D-Bus (`org.kde.kwalletd6`, `org.kde.secretservicecompat`,
`org.kde.secretprompter` e o portal `org.freedesktop.impl.portal.desktop.kwallet`) são
sobrescritos em `~/.local/share`, que tem precedência sobre `/usr/share` — e sobrevive a
update do pacote. Além de não querer o
prompt, isso tem um efeito que vale saber: sem keyring no sistema, o Chrome cifra os cookies
com o backend `basic` (chave embutida, prefixo `v10`) em vez de `v11`. Na prática o perfil
fica autossuficiente — sobrevive a uma reinstalação e **não** depende da senha de login
continuar a mesma. Ligar o KWallet passaria os cookies pra `v11` e criaria essa dependência.

## Energia: esta máquina nunca dorme

Nunca suspende, nunca hiberna, nunca desliga sozinha. A única coisa que a inatividade faz é
**apagar os monitores em 5 minutos**.

Três camadas, porque só o KDE não bastaria:

| Camada | O que faz | Onde |
|:--|:--|:--|
| PowerDevil | `autoSuspendAction=0`, tela apaga em 300 s | `powerdevil/.config/powerdevilrc` |
| systemd | `sleep`, `suspend`, `hibernate`, `hybrid-sleep` e `suspend-then-hibernate` mascarados | `kde/energia.sh` |
| logind | `IdleAction=ignore` | `/etc/systemd/logind.conf.d/99-nunca-dormir.conf` |

Só a primeira camada não seguraria: qualquer `systemctl suspend` — de um script, de um
aplicativo, de um atalho — passaria por cima do KDE. Com os alvos mascarados, a resposta
vira `Call to Suspend failed: Access denied`.

O arquivo do logind fica em `logind.conf.d/`, não no `logind.conf`, porque o principal é do
pacote e volta ao original a cada update.

## DNS: sempre o mais rápido

A conexão parecia lenta e o culpado era o DNS do roteador. Medindo **sem cache** (subdomínio
aleatório, que força resolução de verdade):

| Resolvedor | Sem cache |
|:--|--:|
| OpenDNS | 23 ms |
| Cloudflare | 25 ms |
| Google | 26 ms |
| Quad9 | 39 ms |
| **Roteador (192.168.1.1)** | **161 ms** |

Perguntar `google.com` pro roteador responde em 6 ms — mas é cache. O que trava a navegação
é o domínio que ele ainda não tem, e aí são ~160 ms antes do primeiro byte.

```bash
dns-rapido.sh              # mede e aplica
dns-rapido.sh --medir      # só mede
dns-rapido.sh --restaurar  # volta pro DNS do DHCP
```

Escolhe os dois mais rápidos **de operadores diferentes**, pra um não cair junto com o
outro. Também põe `ipv6.ignore-auto-dns` — sem isso o DNS IPv6 do provedor continua na
lista e é consultado, anulando a escolha.

Roda **a cada logon**, pelo `autostart/.config/autostart/dns-rapido.desktop`. Não precisa de
sudo: o polkit já deixa a sessão local mexer na conexão do NetworkManager.

Os logs dos dotfiles ficam todos em `~/.local/state/dotfiles/` — nada de `.log` solto na
home, que é justamente o que a home enxuta não quer.

## Tela de login e foto do perfil

A mesma `perfil/avatar.png` do [MyWinISO](https://github.com/eualexandrerrr/MyWinISO) — o
rosto é o mesmo nos dois sistemas. Vai pra dois lugares, porque cada um lê de um:

| Onde | Arquivo |
|:--|:--|
| KDE (menu, tela de bloqueio) | `/var/lib/AccountsService/icons/$USER` + `users/$USER` |
| Resto (SDDM, apps genéricos) | `~/.face.icon` |

O greeter usa o Breeze com o wallpaper do monitor principal, por `theme.conf.user` — o
`theme.conf` do pacote volta a cada update, o `.user` não.

O greeter roda um **kwin próprio**, com config separada da sua sessão. Sem dizer nada a ele,
o formulário de login escolhe o monitor sozinho e às vezes cai no vertical.

O `sddm/kwinoutputconfig.json` deixa só o DP-1 ligado. Ele foi **gerado a partir do
`~/.config/kwinoutputconfig.json` da sessão real**, não escrito à mão: o formato é um array
com as seções `outputs` (cada saída, casada por `edidHash`) e `setups` (quem fica ligado e
onde). Um JSON de formato próprio o kwin ignora em silêncio — foi o que aconteceu na
primeira tentativa.

Pra regerar depois de trocar de monitor:

```bash
~/.dotfiles/setup.sh login
```

## Monitores

Dois monitores 2560x1440: principal em paisagem à direita, secundário em pé à esquerda.
Aplicado automaticamente por `kde/monitores.sh`, que roda dentro do `layout-once.sh` — antes do
wallpaper, porque o `wallpaper.sh` decide retrato x paisagem pela geometria de cada tela.

O `~/.local/share/kscreen/` **não** é versionado: o `kscreen` grava um arquivo por combinação de
monitores, com nome derivado do hash dos EDIDs conectados. Trocar de porta, de cabo ou de placa
muda o hash e o arquivo antigo deixa de valer. O que é versionado é a decisão, em
`kde/monitores.conf`, casada por **nome de conector** — os dois monitores são iguais e
resolução sozinha não separa um do outro.

```
# chave|resolucao|rotacao|posicao|escala|primario
DP-2|1920x1080|left|0,0|1|nao
DP-1|2560x1440|normal|1080,240|1|sim
```

A chave é o nome do conector, ou `*` pra "a próxima saída livre com essa resolução nativa".
Como os dois monitores são iguais, resolução sozinha não separa — por isso o nome. Se trocar
de placa e os nomes mudarem, `kscreen-doctor -o` lista os novos.

O LG é **1920x1080@144 nativo** — ele aceita 2560x1440, mas escalado e a 75 Hz. Girado ele
ocupa 1080 de largura, por isso o principal começa em x=1080; o `y` 240 centra o ASUS
(1440 de altura) no vão do LG em pé (1920). Rodar à mão: `bash ~/.dotfiles/kde/monitores.sh`.

Não edite o conf à mão: arraste as telas em Configurações do Sistema → Tela e depois grave o
resultado com `bash ~/.dotfiles/kde/monitores.sh --capturar`. Posição, rotação, escala e
primário saem exatamente como estão na sessão.

O `kscreen-doctor` sai com código 0 mesmo recusando um modo, então o `monitores.sh` confere a
geometria depois de aplicar e só reporta sucesso se ela bater com o conf.

## Credenciais

Segredo não mora neste repo — ele é público. Mora no **`dotfiles-private`**, e mesmo lá vai
cifrado: o GitHub só enxerga bytes.

```
dotfiles-private/
├── segredos.tar.age    cifrado para a chave do pendrive
└── chave.txt.age       a própria chave, cifrada por senha (recuperação)
```

A chave privada fica **só no pendrive do Ventoy**, em `dotfiles/chave.txt` — o mesmo pendrive
que carrega o MyArchISO. Posse física: quem não tem o pendrive não abre o pacote, mesmo com
acesso total à conta do GitHub.

```
guardar:    bash ~/.dotfiles/segredos/guardar.sh     # com o pendrive espetado
restaurar:  bash ~/.dotfiles/segredos/restaurar.sh   # o install.sh já chama sozinho
```

O `restaurar.sh` **nunca derruba a instalação**: sem pendrive, sem rede ou sem repo privado
ele avisa e sai com 0. Se o pendrive não estiver lá mas o repo sim, cai na recuperação por
senha (`chave.txt.age`) — que é o que te salva se perder o pendrive. Perder os dois é perder
os segredos; guarde a senha no gerenciador.

O que entra está em `segredos/lista.txt`; o que não existir na hora é ignorado. Arquivo que
já existe no destino vira `.bak-<carimbo>` antes de ser substituído, e as permissões são
refeitas (`.ssh` 700, arquivos 600).

O `chave.txt` no pendrive fica com modo 755 porque exfat não guarda bit de permissão. É
inerente ao modelo: a proteção ali é ter o pendrive na mão, não a permissão do arquivo.

### O segundo monitor é o painel

O monitor vertical não é área de trabalho: ele é ocupado em tela cheia pelo **RicePanel** —
cota do Claude Code, erros do Sentry, anotações do Discord, os dois consoles do txAdmin, relógio
e temperaturas. Mora no repo [Utils](https://github.com/eualexandrerrr/Utils), pasta
`RicePanel`, e sobe junto com a sessão gráfica.

```bash
git clone https://github.com/eualexandrerrr/Utils.git
Apps/desktop/RicePanel
```

#### Sem notificação

O painel avisa por notificação do sistema em quatro pontos — erro novo no Sentry, anotação
nova no Discord e dois casos no `main.js` —, todos com `urgency: critical`. Ver o erro no
próprio painel já basta; o popup por cima da tela não.

```ini
# plasma/.config/plasmanotifyrc
[Applications][ricepanel]
ShowPopups=false
```

**Só a chave não resolve.** Sem um `.desktop` o KDE não consegue resolver a identidade do
aplicativo e ignora a regra — medido: com a chave posta e sem `.desktop`, a notificação
apareceu do mesmo jeito. Por isso existe `apps/.local/share/applications/RicePanel.desktop`,
que serve só para isso, e é `NoDisplay` porque quem sobe o painel é a unit do systemd.

Com os dois no lugar, testado nos três estados: notificação do `RicePanel` **não**
aparece, e uma de outro aplicativo qualquer continua aparecendo.

#### Fora da barra de tarefas

O painel ocupa o monitor inteiro e não é uma janela que se alterna — não faz sentido
ocupar espaço no gerenciador de tarefas. O Electron dele já pede `skipTaskbar: true`, mas
no XWayland isso **não chega ao compositor**: medido com `xprop`, a janela subia sem
`_NET_WM_STATE` nenhum.

Quem resolve é uma regra de janela do KWin, em `kwinrulesrc` — versionada como qualquer
outra chave:

```ini
[RicePanel-sem-barra]
wmclass=RicePanel       # classe própria, não pega outros apps Electron
wmclassmatch=1              # 1 = exata
skiptaskbar=true
skiptaskbarrule=2           # 2 = Force
```

Vale sem reiniciar o painel: um `qdbus6 org.kde.KWin /KWin reconfigure` e a janela já
aberta ganha o `_NET_WM_STATE_SKIP_TASKBAR`.


O instalador confere as dependências, resolve o Electron e escreve
`~/.config/systemd/user/RicePanel.service`. O `Restart=on-failure` da unit faz o papel do
watchdog que existia no Windows: queda volta sozinha, e fechar pelo X do painel é saída limpa —
fica fechado até alguém mandar subir.

```bash
systemctl --user status RicePanel
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
- **Jogo roda na VM, não no host.** Wine, Proton, Lutris e Steam saíram do repo: o client do RedM
  não passa pelo anticheat em Wine, e o caminho escolhido é a VM Windows com a 3090 em passthrough.
  Ver `vm/` e [RedMLinux](https://github.com/eualexandrerrr/RedMLinux).
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

- 07/09/2026: disposição dos monitores passou a ser aplicada sozinha, por `kde/monitores.sh` +
  `kde/monitores.conf`, casando por resolução em vez de nome de conector. Antes era passo manual
  em Configurações do Sistema.
- 07/09/2026: install mais rápido. As duas etapas caras passaram a ser condicionais: o
  `mkinitcpio -P` (~25 s) só roda quando algo que entra na imagem mudou ou quando a imagem
  está mais velha que os módulos, e a bandeja em C++ (~30 s) passou a comparar hash do fonte
  em vez de mtime — um `git clone` novo carimbava os arquivos com a hora do clone e forçava
  recompilação toda vez. O `fetch --all --prune` virou fetch só do branch, e os 316
  `pacman -Qq <pacote>` viraram uma listagem só.
- 07/09/2026: o `install.sh` ganhou a etapa `aplicar_layout`, que roda o `layout-once.sh` na
  hora quando existe sessão do Plasma viva. Rodando de um TTY ele detecta que o `plasmashell`
  não responde e deixa pro autostart, como antes.
- 07/09/2026: rodar o `install.sh` de novo agora apaga `~/.config/.kde-layout-aplicado`. A marca
  mora fora do repo, então `rm -rf ~/.dotfiles` não a levava junto e o `layout-once.sh` saía na
  primeira linha — reinstalar deixava o KDE pela metade sem erro nenhum na tela.
- 07/09/2026: `qt6-tools` entrou no `packages.txt`. O `qdbus6` vem dele e sete scripts do
  `kde/` dependem do binário; numa formatação limpa ele não existia, e painel, wallpaper e
  tema não eram aplicados no primeiro login. O `layout-once.sh` agora aborta se o `qdbus6`
  faltar ou o `plasmashell` não subir, e só grava a marca de aplicado se nenhuma etapa falhar.
- 07/09/2026: Wine, Proton, Lutris, Steam, gamescope, mangohud e winboat saíram do host. Jogo
  passa a ser assunto da VM Windows com a 3090 em passthrough.
- 07/09/2026: `lib32-mesa`, `lib32-nvidia-utils` e `lib32-vulkan-icd-loader` saíram, e o
  install parou de habilitar o `multilib`. Eram só pra aplicativo de 32 bits, que no host
  significava Wine, Steam e Proton — tudo já fora.
- 07/09/2026: `monitores.conf` ganhou chave por conector. O casamento por resolução pegava
  qualquer saída que *tivesse* o modo, e o 2K principal também tem 1920x1080 — os dois
  monitores caíam no mesmo DP-2. E os dois são 2560x1440 de fato, então resolução nunca ia
  separar; agora casa por nome, com `*` como curinga por resolução nativa.
- 07/09/2026: `links/` virou um pacote por programa na raiz do repo, linkado pelo GNU Stow com
  `--no-folding` — mesma regra de nunca linkar diretório, agora sem linker caseiro.
- 07/09/2026: o desktop é KDE Plasma e só. Nenhuma outra sessão entra no repo nem no SDDM.
- Até 09/2026 o repo era Hyprland + Quickshell (nandoroid-shell). Trocado por KDE Plasma; a pilha
  antiga está no histórico do git (`git log --before=2026-09-05`).
- Branch `backup/i3-x11-2023` guarda o rice de i3 + polybar.
- 05/09/2026: MCP do Claude Code restaurados do backup do Windows via `bin/mcp-restaurar.sh`.
- 05/09/2026: configuração do KDE passou a ser versionada em `kde/settings.conf`,
  com `kde-capture.sh` / `kde-apply.sh` fazendo o ida e volta com a GUI.
- 05/09/2026: o RicePanel (painel do segundo monitor, do repo `Utils`) foi portado do Windows
  pro Linux e passou a subir por unit do systemd — ver [Monitores](#monitores).
- 05/09/2026: `powermanagementprofilesrc` entrou no espelhamento — o PC não suspende, não
  apaga e não escurece a tela por inatividade. Ver [Energia](#energia).
- 05/09/2026: `kitty` trocado por `ghostty` (terminal padrão do KDE, `TERMINAL` no `.zshrc`,
  lançador do painel e `terminfo` do live ISO do myarch).
