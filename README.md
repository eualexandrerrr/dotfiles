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
| Login | `sddm` com greeter em `kwin_wayland`, tema Breeze; login automatico (`Relogin=false`: so ao ligar o PC e na volta da VM w11) |
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
| Segundo monitor | `widget-claude` em tela cheia, do repo [Utils](https://github.com/eualexandrerrr/Utils) — ver [Monitores](#monitores) |

Barra, painéis, wallpaper e disposição de monitores continuam sendo do próprio Plasma e
não são versionados: o KDE grava dezenas de arquivos em `~/.config` com estado misturado à
configuração (posição de janela, hash de tema, UUID de desktop virtual), e commitar isso
vira ruído que conflita a cada login.

O que **é** versionado são as decisões: teclado, mouse, tema, ícones, terminal padrão,
bordas de janela. Ficam em `kde/settings.conf`, uma chave por linha, geradas por
curadoria — ver [Configuração do KDE](#configuração-do-kde).

## Estrutura

```
dotfiles
├── kde                       tudo do KDE
│   ├── settings.conf         311 chaves (gerado pelo capture, não editar)
│   ├── capture.sh            lê o KDE vivo e regrava o settings.conf
│   ├── apply.sh              aplica o settings.conf via kwriteconfig6
│   ├── layout-once.sh        primeiro login: tema, painel, layout
│   ├── layout.js             layout do painel (script do Plasma)
│   ├── painel-ajustar.sh     repõe as decisões do painel (idempotente)
│   ├── tema-instalar.sh      instala o Windows Modern a partir do vendor
│   └── sessao-teste.sh       Plasma inteiro numa janela, pra testar sem risco
├── bin                       comandos
│   ├── recorte-clipboard.sh  Shift+Print: região da tela → área de transferência
│   ├── nvidia-desempenho.sh  GPU em performance máxima no login
│   └── mcp-restaurar.sh      recria os 8 MCP do Claude Code no ~/.claude.json
├── links                     o que vira symlink no $HOME
│   ├── home                  .zshrc, .zprofile
│   ├── config                → ~/.config: autostart, ghostty
│   └── local                 → ~/.local/share: lançador do Shift+Print
├── vendor
│   └── windows-modern        o tema, versionado aqui (ver PROVENIENCIA.md)
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
~/.config/kdeglobals          -> links/config/kdeglobals
~/.config/kwinrc                 kcminputrc  kxkbrc  plasmarc  dolphinrc
~/.config/kglobalshortcutsrc     kwinrulesrc  plasma-localerc  plasmanotifyrc
~/.config/powermanagementprofilesrc
~/.local/share/dolphin/view_properties/global/.directory
```

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

### Dolphin em Detalhes

`ViewMode=1` (`0` ícones, `1` detalhes, `2` colunas) no
`~/.local/share/dolphin/view_properties/global/.directory`. Vale para todas as pastas
porque o `GlobalViewProps` do Dolphin já é `true` por padrão.

É um arquivo **fora do `~/.config`** — o primeiro do repo — e foi por causa dele que o
`kde-capture.sh` e o `kde-apply.sh` passaram a aceitar caminho relativo ao `$HOME`. O
`Timestamp` e o `Version` que o Dolphin grava junto ficam de fora: são estado, e o
`IGNORAR_CHAVE` os derruba. Verificado numa sessão de teste com `HOME` virgem que só o
`ViewMode` basta — o `kde-apply.sh` cria o arquivo e o Dolphin abre em Detalhes.

### Barra de tarefas

```bash
kde/painel-ajustar.sh    # repõe tudo; rode quando o painel voltar ao padrão
```

O painel volta ao padrão **toda vez que um look-and-feel é aplicado**, então isso é um
script idempotente e não uma configuração de uma vez só.

| Decisão | Onde | Valor |
|:--|:--|:--|
| prévia das janelas agrupadas | `plasmarc` `[PlasmaToolTips] Delay` | `0.15` s (padrão `0.7`) |
| alto-falante no ícone de quem toca som | applet, `indicateAudioStreams` | `false` |
| ícones fixados | applet, `launchers` | dolphin, chrome, ghostty, discord, steam |
| flutuante e translúcido | `plasmashellrc` | ver acima |
| prévia grande → lista compacta | applet, `showToolTips` | `false` |

Alt+Tab e animações em geral:

| Decisão | Onde | Valor |
|:--|:--|:--|
| espera antes do Alt+Tab aparecer | `kwinrc` `[TabBox] DelayTime` | `0` ms (padrão `90`) |
| duração das animações do KDE | `kdeglobals` `[KDE] AnimationDurationFactor` | `0.5` (padrão `1.0`) |

A miniatura da prévia é `Kirigami.Units.gridUnit * 16`, derivada da fonte — **não existe**
ajuste de tamanho. `showToolTips=false` é a única alternativa menor que o applet oferece:
troca as miniaturas lado a lado por uma lista de títulos.

A config de applet é escrita pela API de script do Plasma, não pelo `kde-settings.conf`:
ela mora no `plasma-org.kde.plasma.desktop-appletsrc` com o **número do applet** no meio
do caminho, e esse número muda a cada painel recriado.

#### O badge de não lidas

O número de mensagens não lidas usa a LauncherEntry API do Unity, que o Plasma expõe em
`com.canonical.Unity`. Ele **só aparece em aplicativo fixado** — sem o launcher a contagem
não tem onde grudar. Verificado emitindo o sinal na mão:

```bash
gdbus emit --session --object-path /com/canonical/unity/launcherentry/discord \
  --signal com.canonical.Unity.LauncherEntry.Update \
  "application://discord.desktop" "{'count': <int64 7>, 'count-visible': <true>}"
```

Sem o Discord fixado não aparece nada; fixado, o `7` aparece na hora. Por isso os
`launchers` estão no `painel-ajustar.sh`. Se mesmo fixado o número não vier, o que falta é
a opção dentro do próprio Discord — ela é estado da conta dele, não dá pra versionar aqui.

### As três camadas de configuração

Vale entender porque nem tudo que o tema define aparece no `kde-settings.conf`:

| Camada | Arquivo | Quem escreve |
|:--|:--|:--|
| padrões do tema | `~/.config/kdedefaults/kdeglobals` | `plasma-apply-lookandfeel` |
| decisões deste repo | `~/.config/kdeglobals` | `kde-apply.sh` — **vence** |

Por isso `ColorScheme` e `widgetStyle` não estão no `kde-settings.conf`: quem os fornece é
o tema. O que está lá são os desvios, como `Icons=Tela-dark` sobrepondo o
`Icons=windows-modern` que o tema pede — e é justamente por causa desse desvio que o tema
de ícones do Windows Modern não foi vendorado.

O `kde-capture.sh` lê os arquivos crus, então só enxerga a camada de cima. É o
comportamento certo: o repo versiona decisão, não o que o tema já traz.

## Testar sem arriscar a sessão

```bash
kde/sessao-teste.sh              # sobe um Plasma dentro de uma janela
kde/sessao-teste.sh dentro bash ~/.dotfiles/kde/apply.sh
kde/sessao-teste.sh dentro spectacle -f -b -n -o /tmp/print.png
kde/sessao-teste.sh parar
```

O isolamento é triplo, e cada parte tem motivo:

| Isolado | Por quê |
|:--|:--|
| `HOME` próprio | o Plasma grava dezenas de arquivos em `~/.config`; sem isso o teste sobrescreveria a sessão real |
| D-Bus próprio, em socket de caminho fixo | pra falar com a sessão de fora. O `dbus-run-session` sorteia o endereço e o `/proc/PID/environ` nem sempre é legível, então não serve |
| socket Wayland nomeado | pra rodar app dentro da sessão e tirar print **dela** |

O repo entra por symlink, então editar aqui e testar lá é imediato. Prova de que o
isolamento é real — painel da sessão de teste contra o da sessão de verdade:

```
teste:  opacity=adaptive     altura=46    (padrão do Plasma, HOME virgem)
host:   opacity=translucent  altura=48    (o kde-settings.conf deste repo)
```

### O que dá e o que não dá pra recarregar

| Camada | Como | Perde janela? |
|:--|:--|:--|
| `plasmashell` — painel, widgets, bandeja | `systemctl --user restart plasma-plasmashell.service` | **não** |
| KWin — bordas, efeitos, decoração, teclado | `qdbus6 org.kde.KWin /KWin reconfigure` | **não** |
| KWin de verdade (atalho de comando novo, `Exec` de lançador) | só deslogando | — |

No Wayland o KWin **é** o servidor gráfico: todo cliente está conectado nele, então
reiniciá-lo derruba tudo que estiver aberto. É justamente pra isso que existe a sessão
aninhada.

## Idioma

```
kdeglobals      [Locale] Language = pt_BR
plasma-localerc [Translations] LANGUAGE = pt_BR
plasma-localerc [Formats] LANG = pt_BR.UTF-8
```

As duas primeiras chaves **não existiam**: o KDE vinha só herdando o `LANG` do sistema, e a
preferência de idioma nunca ficava declarada. Só o `[Formats]` estava lá, e ele cuida de
data e número, não de tradução.

Isso não é o que deixa parte da interface em inglês. As traduções estão instaladas — 414
catálogos `pt_BR` em `/usr/share/locale` e o `qt6-translations`. O que sobra em inglês tem
duas origens:

| Origem | Situação |
|:--|:--|
| applets do Windows Modern | chamam `i18n()`, mas **não declaram domínio** de tradução e não trazem catálogo: 76 strings (55 no relógio, 21 no menu iniciar) |
| apps de terceiros | ghostty, Discord, Chrome, VS Code — não têm `pt_BR`, e não há o que fazer daqui |

O caso dos applets é o único que dá para resolver: seria escrever os catálogos e
vendorá-los junto do tema.

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
| capturar / aplicar config do KDE | os dois lados do `kde-settings.conf` |
| restaurar os 8 MCP | `mcp-restaurar.sh` + `claude mcp list` |
| conferir sintaxe dos scripts | `bash -n` em tudo |
| gerar a ISO | `sudo ./archiso/build.sh` do myarch |
| espelho do Drive | retomar o download e ver progresso |

`shellcheck` e `shfmt` estão no `packages.txt` porque as extensões recomendadas
(`timonwong.shellcheck`, `foxundermoon.shell-format`) precisam dos binários. Antes de
commitar script:

```bash
shellcheck -x -S warning install.sh kde/*.sh bin/*.sh
```

## Monitores

Dois monitores: principal 2560x1440 paisagem à direita, secundário 1920x1080 em retrato à esquerda.
Configure em **Configurações do Sistema → Tela e Monitor** no primeiro boot; o `kscreen` guarda
a disposição por combinação de monitores em `~/.local/share/kscreen/`.

### O segundo monitor é o painel

O monitor vertical não é área de trabalho: ele é ocupado em tela cheia pelo **widget-claude** —
cota do Claude Code, erros do Sentry, anotações do Discord, os dois consoles do txAdmin, relógio
e temperaturas. Mora no repo [Utils](https://github.com/eualexandrerrr/Utils), pasta
`widget-claude`, e sobe junto com a sessão gráfica.

```bash
git clone https://github.com/eualexandrerrr/Utils.git
Utils/widget-claude/linux/instalar.sh
```

#### Sem notificação

O painel avisa por notificação do sistema em quatro pontos — erro novo no Sentry, anotação
nova no Discord e dois casos no `main.js` —, todos com `urgency: critical`. Ver o erro no
próprio painel já basta; o popup por cima da tela não.

```ini
# links/config/plasmanotifyrc
[Applications][widget-claude]
ShowPopups=false
```

**Só a chave não resolve.** Sem um `.desktop` o KDE não consegue resolver a identidade do
aplicativo e ignora a regra — medido: com a chave posta e sem `.desktop`, a notificação
apareceu do mesmo jeito. Por isso existe `links/local/share/applications/widget-claude.desktop`,
que serve só para isso, e é `NoDisplay` porque quem sobe o painel é a unit do systemd.

Com os dois no lugar, testado nos três estados: notificação do `widget-claude` **não**
aparece, e uma de outro aplicativo qualquer continua aparecendo.

#### Fora da barra de tarefas

O painel ocupa o monitor inteiro e não é uma janela que se alterna — não faz sentido
ocupar espaço no gerenciador de tarefas. O Electron dele já pede `skipTaskbar: true`, mas
no XWayland isso **não chega ao compositor**: medido com `xprop`, a janela subia sem
`_NET_WM_STATE` nenhum.

Quem resolve é uma regra de janela do KWin, em `kwinrulesrc` — versionada como qualquer
outra chave:

```ini
[widget-claude-sem-barra]
wmclass=widget-claude       # classe própria, não pega outros apps Electron
wmclassmatch=1              # 1 = exata
skiptaskbar=true
skiptaskbarrule=2           # 2 = Force
```

Vale sem reiniciar o painel: um `qdbus6 org.kde.KWin /KWin reconfigure` e a janela já
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
