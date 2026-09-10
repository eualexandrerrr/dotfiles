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

`install.sh` é idempotente. `setup.sh` reconfigura e recarrega em segundos, sem rede:

| | o quê | quando |
|---|---|---|
| `install.sh` | pacotes, driver, serviços, SDDM | mexeu no `packages.txt` |
| `setup.sh` | configura e recarrega | mexeu numa config |

Etapas: `links home perfil energia audio dns console chrome claude`.

---

## O que eu uso

| Função | Programa |
|---|---|
| Desktop | `plasma-meta` (painel, KRunner, Klipper, powerdevil) |
| Arquivos | `dolphin` (GUI) · `yazi` (terminal) |
| Captura | `spectacle` (tela, recorte, anotação e vídeo) |
| Terminal | `ghostty` + zsh com `starship`, `atuin`, `fzf`, `zoxide` |

---

## As quatro técnicas que sustentam tudo

**1. Monitor por marca, nunca por conector.** Trocar a placa-mãe renumera as portas, e regra
presa a `DP-1` passa a valer para a tela errada. Nenhum arquivo versionado guarda conector: a
marca mora em `telas.conf` e é resolvida na hora por `bin/monitor.sh`, que lê o EDID direto
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

**4. Nenhum keyring instalado.** Sem keyring o Chrome usa o backend `basic` (cookies `v10`) e
o perfil sobrevive ao format sem depender da senha de login. `gnome-keyring` passaria para
`v11` e criaria essa dependência — por isso não está no `packages.txt` e não deve entrar por
conveniência de app nenhum.

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
| HDMI | RX 550 | ASUS XG27ACS · entrada **HDMI** | Linux no dia a dia, 2560x1440@120 |
| DisplayPort | RX 550 | LG UltraGear (girado) | RicePanel, 1920x1080@144 |
| Dummy plug | RTX 3090 · DP livre | — | mantém display ativo na VM |
| Rede | LAN 2.5G da placa-mãe | roteador | **único caminho: não há wifi** |

**Vídeo primário na BIOS: `PCIEX16_2`** (a RX 550), em Advanced › Onboard Devices
Configuration. É onde vive o Linux e o menu do systemd-boot — a entrada de recuperação só
serve se aparecer na tela que você usa todo dia.

**Por que o Linux fica em 120 Hz:** 1440p@180 pede ~19,3 Gbps. A DP 1.4 dá 25,9 e passa; a
HDMI 2.0b da RX 550 dá 18 e não passa. Foi decisão consciente para deixar a DP na 3090 — no
Windows o resultado é idêntico. Por isso o `monitores.lua` pede `@120` no principal, e
`mode = "highrr"` **não** resolve: ele maximiza a taxa e não a resolução, e derruba a tela
para 1024x768@180.

O dummy plug não é só para o caso de faltar cabo: com o ASUS ligado nas duas placas e a
entrada dele no HDMI, o monitor pode derrubar o hot-plug detect da DP, e aí o Windows para de
gerar frame no meio do jogo.

A VM tem documentação própria em [`vm/README.md`](vm/README.md).

---

## Quando o desktop não sobe

| Comando | O que faz |
|---|---|
| `dot status` | confere binários do Plasma, sddm, autologin, serviços e as telas |
| `dot telas` | GPUs, driver de cada `card`, saídas conectadas, papéis do `telas.conf` |
| `dot erros` / `dot log` | avisos da última instalação / log inteiro (`-f` acompanha) |
| `dot instalar` / `dot zero` | `git pull` + reinstala / apaga tudo e clona do zero |

Log em `~/.local/state/dotfiles/install.log`. Se nem isso resolver — compositor que não sobe
deixa você numa tty, e tty sem rede não tem saída — o caminho é o pendrive: **opção 4** do
menu do live reinstala os dotfiles sem formatar nada.

### Pegadinhas

- O shell é zsh: `for p in $var` não faz word splitting. Use array ou `bash -c`.
- `pacman -Q` mente sobre pacote instalado nesta máquina. Use `command -v` para binário e
  `pacman -Si` para saber se existe nos repos.
