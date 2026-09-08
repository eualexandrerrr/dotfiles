# VM w11 — Windows 11 com passthrough da RTX 3090

Não fica em `links/`: o `install.sh` symlinka `links/config/*` para `~/.config/`, e
`~/.config/libvirt` é o diretório do libvirt **de sessão do usuário**. Esta VM vive no
libvirt **de sistema** (`qemu:///system`), então um symlink ali só criaria confusão entre
os dois. Aqui é fonte de verdade versionada; aplicar é explícito.

## Instalar o Windows (`w11 instalar`)

Perfil `janela` + ISO do Windows + `~/vms/autounattend.iso` (o `autounattend.xml` do MyWinISO
com `MYWINISO_PERFIL=vm-jogo` injetado no primeiro logon). Disco em SATA, vídeo `vga` e rede `e1000e` na instalação — o Windows não traz driver virtio pra
nenhum dos três (o vídeo virtio congela a tela na última imagem da UEFI, parecendo travamento; volta pra virtio depois do viostor
instalado). Três injeções no XML, feitas pelo `autounattend-vm.sh`: o perfil `vm-jogo`, a cópia do
arquivo pra `X:\` e a chave `HKLM\System\Setup\UnattendFile` — o Ventoy faz as duas últimas
sozinho, um pendrive comum não, e o `instala.vbs` lê só a chave. Além disso o disco leva
`<serial>6479A7AABAC014A3</serial>`, o serial do MP700 — é assim que o `instala.vbs` aceita o
disco; e o `vfio-ativar.sh` só roda com a segunda GPU montada, senão o host fica sem tela.

## Looking Glass (`vm/glass`)

Com a RX 550 no host, o perfil `3090` não fica mais sem tela: o Windows renderiza na 3090,
copia o frame pra `/dev/shm/looking-glass` (ivshmem, 64 MB) e o `vm/glass` desenha numa janela
do Hyprland. Os 64 MB bastam pra 2560x1440 (`w*h*4*2 + 10 MB` ≈ 40 MB); 4K pediria 128.

A 3090 leva um **dummy plug** numa saída livre. Não é só pelo caso de ficar sem cabo: com o
ASUS ligado nas duas placas e a entrada dele no HDMI, o monitor pode derrubar o hot-plug
detect do DP, e aí o Windows para de gerar frame no meio do jogo. Com o dummy plug há sempre
um display ativo. Isso dispensa o Looking Glass IDD. Teclado e mouse vão por SPICE (sem display). Cliente B7 do AUR; o host pro guest está
em `~/vms/looking-glass-host-B7.zip` (a versão tem que ser a mesma dos dois lados). O
`preparar.sh` cria o shmem com dono certo por tmpfiles.

## Dois perfis, um domínio

`w11-3090.xml` é o passthrough (a 3090 inteira vai pra VM; o host continua desenhando na
RX 550). `w11-janela.xml` é vídeo emulado + SPICE numa janela, sem 3D: serve para
instalar/ajustar o Windows, **não roda RedM**.
O script `w11` faz o `define` do perfil escolhido e liga: `w11 janela`, `w11 3090`, `w11 perfil`, `w11 desligar`.

Os hooks do libvirt olham o XML que recebem no stdin e só agem se houver `hostdev` PCI.

**Os hooks encolheram na virada pra duas GPUs.** A versão antiga era single-GPU: parava o
Plasma, fazia `loginctl terminate-user`, derrubava o display manager e descarregava a
nvidia. Com a RX 550 desenhando o host nada disso é necessário — e seria destrutivo. Hoje o
`start.sh` só trava a suspensão e **aborta se o `amdgpu` não estiver em uso**, que é a única
coisa capaz de deixar o PC sem tela. O `stop.sh` só solta a trava: a 3090 volta pro
`vfio-pci`, não pro host.

## Restaurar

```sh
sudo virsh -c qemu:///system define ~/.dotfiles/vm/w11-3090.xml
```

O disco é `~/vms/win.raw` (raw, 200 GB, `falloc`): fica em `/home`, que sobrevive ao format. O
`vm/preparar.sh` cria, dá acesso ao `libvirt-qemu` (ACL) e instala os hooks.

## O que está configurado, e por quê

| | |
|:--|:--|
| 12 vCPUs fixadas nos núcleos 2-7 | os pares HT ficam juntos; núcleos 0-1 sobram para o host |
| `emulatorpin` e `iothreadpin` em 0-1 | o I/O do QEMU não rouba tempo do jogo |
| 16 GB | o host tem 31 GB; deixa ~15 GB. Já houve OOM com 20 GB |
| sem hugepages estáticas | o kernel já roda `transparent_hugepage=always`; reservar fixo prejudicaria o host com a VM desligada |
| `memballoon` desligado | ballooning atrapalha jogo |
| `io=native` + iothread dedicada | disco |
| Hyper-V completo + `topoext` + `cache passthrough` | `topoext` é obrigatório: sem ele a topologia 6c/2t em AMD derruba o guest |
| `hostdev`: 3090 + áudio HDMI + teclado + mouse USB | no passthrough o host fica sem tela, então a entrada vai junto |
| sem `<graphics>` e sem `<video>` | a tela é o monitor físico ligado na 3090 |

## Pré-requisitos na máquina

- `amd_iommu=on iommu=pt` no `arch.conf` (o `arch-fallback.conf` fica sem, de propósito, como rota de recuperação)
- Hooks do libvirt em `/etc/libvirt/hooks/qemu.d/w11/` — fonte em `eualexandrerrr/RedMLinux`, `plano-b-passthrough/install-hooks.sh`
- Grupo IOMMU 16 tem só a 3090 e o áudio dela: isolamento limpo, sem ACS override

## Em qual monitor o Windows aparece

Nenhum: **a 3090 não recebe cabo de vídeo**. O monitor 2560x1440 fica no DisplayPort da
RX 550, com o Hyprland, e o Windows aparece numa janela pelo Looking Glass. A 3090 só
entrega frame pra memória compartilhada.

O monitor vertical fica desligado até haver cabo. Enquanto isso o `ricepanel.service` tem
`ExecCondition=bin/monitor.sh vertical` e é **pulado limpo** quando a tela não existe —
sem isso ele subiria em fullscreen por cima do monitor principal.

## A sessão não cai mais

Com duas GPUs **a sessão do Hyprland não é derrubada**: ligar a VM não fecha nada, e o
Alt-Tab entre Linux e Windows funciona pela janela do Looking Glass. Isso aposenta a
mecânica de salvar e reabrir aplicativos:

- `salvar_apps()` no script `w11` e o `vm/reabrir-apps.sh` viram código morto. Ficam por
  enquanto — saem quando o passthrough estiver comprovadamente de pé.
- O login automático do `sddm` continua valendo pra ligar o PC, não mais pra "voltar da VM".
