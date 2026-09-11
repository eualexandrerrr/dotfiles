[English](README.md)

# dotfiles

Pós-instalação da máquina de desenvolvimento: **Arch Linux + KDE Plasma** em Wayland, com
passthrough da RTX 3090 para uma VM Windows. Cada configuração no seu pacote, linkada pelo
GNU Stow.

O desktop é o Plasma **de fábrica**, de propósito: painel, lançador, notificações, captura e
configuração de tela são os nativos. O que este repo acrescenta é o que o Plasma não faz --
passthrough de GPU, tuning de sistema, pacotes e credenciais.

```
git clone https://github.com/eualexandrerrr/dotfiles ~/.dotfiles
bash ~/.dotfiles/install.sh
```

São três scripts, e só. Todos idempotentes:

| | o quê | quando |
|---|---|---|
| `install.sh` | pacotes, driver, kernel, serviços, SDDM | mexeu no `packages.txt` |
| `setup.sh` | configura tudo, VM inclusa — sem rede | mexeu numa config |
| `reload.sh` | recarrega a sessão que já está de pé | algo saiu do lugar agora |

Etapas do `setup.sh`: `links home perfil arquivos sistema vm ddcutil energia atalhos audio dns console chrome claude notificacoes servicos`.

---

## O que eu uso

| Função | Programa |
|---|---|
| Desktop | `plasma-meta` (painel, KRunner, Klipper, powerdevil) |
| Arquivos | `dolphin` |
| Captura | `spectacle` (tela, recorte, anotação e vídeo) |
| Terminal | `ghostty` + zsh com `starship`, `atuin`, `fzf`, `zoxide` |
| Editor | `micro` (terminal) · RCode (gráfico) |

---

## As quatro técnicas que sustentam tudo

**1. Monitor por marca, nunca por conector.** Trocar a placa-mãe renumera as portas, e regra
presa a `DP-1` passa a valer para a tela errada. Nenhum arquivo versionado guarda conector: a
marca mora em `screens.conf` e é resolvida na hora por `bin/monitor.sh`, que lê o EDID direto
de `/sys/class/drm`. Sem depender de compositor, funciona igual dentro da sessão, numa tty ou
num `ExecCondition=` de unit do systemd.

**2. O ambiente da sessão fica no `plasma-workspace/env/`.** O Plasma faz `source` de tudo
que estiver em `~/.config/plasma-workspace/env/` antes de subir a sessão. É lá que
`GTK_IM_MODULE=simple` conserta acento em app GTK no teclado ABNT2, e é lá que o driver de
vídeo é escolhido **lendo qual `card` pertence a qual GPU** -- fixar `nvidia` com as telas na
AMD tira a aceleração de vídeo.

**3. Stow com `--no-folding --restow`.** Sem o `--no-folding` o stow linka o diretório
inteiro e os apps passam a gravar dentro do repo. Pacote é a pasta com entrada começando em
ponto na raiz (`.config`, `.zshrc`); pasta sem isso é ferramenta.

**4. O perfil do Chrome não pode depender de keyring.** Com o backend `basic` os cookies são
`v10`, autossuficientes: o perfil sobrevive ao format sem depender de a senha de login
continuar a mesma. No `v11` a chave passa a morar no keyring, e como o login aqui é
automático ninguém digita a senha que o destrava — seria acordar deslogado de tudo.

Até 09/2026 isso se garantia não instalando keyring nenhum. O `plasma-meta` trouxe o
`kwallet-pam` como dependência e o `pam_kwallet` entra sozinho no `/etc/pam.d/sddm`, então
agora existe um. Quem segura a garantia é o `--password-store=basic` no
`chrome/.config/chrome-flags.conf`. `gnome-keyring` continua fora do `packages.txt`.

---

## Atalhos

Os do Plasma, de fábrica — `Meta` abre o menu, `Meta+Espaço` o KRunner, `Print` o Spectacle,
`Meta+L` bloqueia. Trocar qualquer um é em **Configurações do sistema > Atalhos**, não em
arquivo deste repo.

---

## Hardware

![Máquina montada](docs/img/maquina.jpg)

| Peça | Modelo |
|---|---|
| CPU | Ryzen 7 5700X (8c/16t, sem vídeo integrado) |
| Placa-mãe | ASUS TUF Gaming B550M-PLUS — **sem wifi e sem bluetooth** |
| RAM | 64 GB DDR4 dual channel (4x16 GB) |
| GPU da VM | Gainward RTX 3090 24 GB — slot `PCIEX16_1` (topo, direto na CPU), **por riser** |
| GPU do host | PCYes Radeon RX 550 4 GB — slot `PCIEX16_2` (base), direto no slot |
| SSD | Corsair MP700 ELITE 932 GB, M.2 único |
| Fonte | 850 W Gold |
| Gabinete | PCYes Forcefield Mini Black Vulcan (GPU até 310 mm) |
| Monitores | ASUS XG27ACS 1440p180 (principal) · LG UltraGear 1080p144 (em pé) |

**Quem desenha o Linux é a RX 550.** A 3090 fica presa no `vfio-pci` e vai inteira para a VM
Windows.

A **3090 é que sai por riser** PCIe 3.0 x16 de 20 cm com plugue de 90°, e fica **fora do
gabinete** — ela tem 2,7 slots de cooler e não cabe junto com a outra placa. Riser com placa
desse peso pede apoio: nunca pendurada só pelo conector, que vira alavanca. A RX 550 vai
**direto no slot de baixo**, sem riser e sem alimentação extra: puxa os 75 W do próprio slot.

![Placa-mãe e a 3090](docs/img/placas.jpg)

A 3090 fica sozinha no **grupo IOMMU 16** com o áudio dela, então o passthrough não precisa de
ACS override. A RX 550 não serve para isso: o slot de baixo pendura no chipset, atrás da mesma
bridge do grupo 15, que leva USB, SATA e a Ethernet junto.

---

## Gabarito dos cabos

São 2 cabos DisplayPort, 2 HDMI e 1 de rede. O ASUS recebe **duas** entradas e alterna pelo
botão: no dia a dia fica no HDMI (Linux), e para jogar troca para DP (Windows nativo). **A
sessão não cai em nenhum dos dois casos.**

![Ligação dos cabos entre as duas GPUs e os dois monitores](docs/img/cabos.png)

| Cabo | De | Para | Serve para |
|---|---|---|---|
| DisplayPort | RTX 3090 | ASUS XG27ACS · entrada **DP** | Windows nativo, 2560x1440@180 |
| HDMI | RX 550 | ASUS XG27ACS · entrada **HDMI** | Linux no dia a dia, 2560x1440@144 |
| DisplayPort | RX 550 | LG UltraGear (girado) | RicePanel, 1920x1080@144 |
| Dummy plug | RTX 3090 · DP livre | — | mantém display ativo na VM |
| Rede | LAN 2.5G da placa-mãe | roteador | **único caminho: não há wifi** |

**Vídeo primário na BIOS: `PCIEX16_2`** (a RX 550), em Advanced › Onboard Devices
Configuration. É onde vive o Linux e o menu do systemd-boot — a entrada de recuperação só
serve se aparecer na tela que você usa todo dia.

**Por que o Linux não chega aos 180 Hz:** 1440p@180 pede ~19,3 Gbps. A DP 1.4 dá 25,9 e
passa; a HDMI 2.0b da RX 550 dá 18 e não passa. Foi decisão consciente para deixar a DP na
3090 — no Windows o resultado é idêntico. O `bin/apply-screens.sh` pede o teto que o cabo
aguenta, `2560x1440@144`, e reaplica de tempos em tempos porque o KWin esquece sozinho
depois de apagar a tela por inatividade.

O dummy plug não é só para o caso de faltar cabo: com o ASUS ligado nas duas placas e a
entrada dele no HDMI, o monitor pode derrubar o hot-plug detect da DP, e aí o Windows para de
gerar frame no meio do jogo.

A VM tem documentação própria em [`vm/README.md`](vm/README.md).

---

## Quando o desktop não sobe

| Comando | O que faz |
|---|---|
| `dot config` / `dot reload` | roda o `setup.sh` / recarrega telas, áudio, painel e KWin |
| `dot status` | confere binários do Plasma, sddm, autologin, serviços e as telas |
| `dot telas` | GPUs, driver de cada `card`, saídas conectadas, papéis do `screens.conf` |
| `dot erros` / `dot log` | avisos da última instalação / log inteiro (`-f` acompanha) |
| `dot instalar` / `dot zero` | `git pull` + reinstala / apaga tudo e clona do zero |

Log em `~/.local/state/dotfiles/install.log`. Se nem isso resolver — compositor que não sobe
deixa você numa tty, e tty sem rede não tem saída — o caminho é o pendrive: **opção 4** do
menu do live reinstala os dotfiles sem formatar nada.

### Pegadinhas

- O shell é zsh: `for p in $var` não faz word splitting. Use array ou `bash -c`.
- `pacman -Q` mente sobre pacote instalado nesta máquina. Use `command -v` para binário e
  `pacman -Si` para saber se existe nos repos.

## Créditos

O pacote `plasma/` vendoriza a variante escura do [tema Win11OS KDE](https://github.com/yeyushengfan258/Win11OS-kde)
de [yeyushengfan258](https://github.com/yeyushengfan258), licença GPLv3 (mantida em
`vendor/win11os/`). Só entraram a decoração de janela Aurorae, o esquema de cores, o
estilo Kvantum e o tema de desktop/splash do look-and-feel da variante dark; o tema de
ícones e o de cursor que o pacote referencia são downloads separados da KDE Store e não
fazem parte deste repositório, por isso `bin/apply-theme-win11os-dark.sh` nunca mexe nessas
duas chaves. O `.kvconfig` vendorizado tem uma mudança deliberada em relação ao original:
`translucent_windows`, `blurring` e `popup_blurring` viraram `false` (janela e menu opacos
em vez do efeito vidro padrão do tema).

O tema de ícones e o de cursor que faltam no pacote Win11OS entram da fonte original de
cada um:

- [Tela-icon-theme](https://github.com/vinceliuice/Tela-icon-theme) (`Tela-dracula-dark`,
  mais a base `Tela-dracula` de que ele herda) de
  [vinceliuice](https://github.com/vinceliuice), GPLv3, créditos em `vendor/tela-icons/`.
- [Bibata_Cursor](https://github.com/ful1e5/Bibata_Cursor) (`Bibata-Modern-Ice`, pacote
  pré-compilado da release) de [ful1e5](https://github.com/ful1e5), GPLv3, créditos em
  `vendor/bibata-cursor/`.
