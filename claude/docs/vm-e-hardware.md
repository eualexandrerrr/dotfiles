# VM w11 e hardware

## VM w11 (07/09, host ainda com uma GPU)

Host preparado: libvirtd, hooks do RedMLinux (vendorados em `vm/hooks-redmlinux`), disco
`~/vms/win.raw` e ISOs em `~/vms`. `w11 instalar` sobe o Windows com video emulado e o
MyWinISO no perfil vm-jogo (serial do MP700 no disco virtual, perfil injetado no
autounattend). O `vm/vfio-ativar.sh` prende a 3090 no vfio e **so pode rodar com a RX 550
montada** -- ele aborta com uma GPU so. Depois disso, kernel-nvidia e configure_nvidia() saem.

## Hardware

| Peca | Modelo |
|:--|:--|
| CPU | Ryzen 7 5700X, sem video integrado |
| Placa-mae | ASUS TUF Gaming B550M-PLUS (x16 Gen4 CPU + x16 Gen3 em x4 chipset, 2 M.2, LAN 2.5G) |
| RAM | 32 GB DDR4 dual channel (4 slots, ate 128 GB) |
| GPU da VM | Gainward RTX 3090 24GB, cooler de 2,7 slots |
| GPU do host | PCYes Radeon RX 550 4GB |
| Riser | PCIe 3.0 x16, 20cm, plugue 90 graus |
| Fonte | 850W Gold, montada atras |
| SSD | Corsair MP700 ELITE 932GB, unico M.2 |
| Gabinete | PCYes Forcefield Mini Black Vulcan, mini tower, GPU ate 310mm |

Plano da fase seguinte (nao agora): 3090 no x16 de cima presa no `vfio-pci` por id
(`10de:2204,10de:1aef`, endereco hoje `0000:0A:00.0`), RX 550 no x16 de baixo via riser
(a 3090 de 2,7 slots tampa esse slot fisicamente), dois monitores na RX 550, `amdgpu` no
host, Looking Glass pra ver o RedM numa janela do Hyprland. Nessa hora `kernel-nvidia` sai do
`packages.txt`, `configure_nvidia()` sai do install e entra o bind do vfio. Os XMLs em `vm/`
ja existem e vao precisar dos IDs/enderecos novos.


## Estado em 07/09/2026: etapa 3 do plano feita, esperando o riser

A placa-mae virou **ASUS TUF Gaming B550M-PLUS** (BIOS 3636, AGESA ComboV2PI_1.2.0.F), com
SVM, IOMMU, NX e Above 4G ligados e fTPM desligado. O riser PCIe 3.0 x16 de 20 cm com plugue
de 90 graus chega em 08/09; so com ele a **PCYes RX 550** entra no slot de baixo, porque a
3090 de 2,7 slots cobre esse slot fisicamente.

**A 3090 mudou de endereco:** era `0000:0a:00.0/.1` na Gigabyte B450M, hoje e
`0000:07:00.0/.1`. Todo o repo ja foi corrigido.

**Grupo IOMMU 16 tem so a 3090 e o audio dela.** Isolamento limpo, **sem ACS override e sem
trocar de slot** -- essa era a etapa capaz de matar o projeto, e ela passou. Conferir com:

```
for g in /sys/kernel/iommu_groups/*/devices/*; do echo "$(echo $g | cut -d/ -f5) $(basename $g)"; done | sort -n
```

### O que ja esta pronto (nao depende do riser)

- `vm/w11-3090.xml`: `hostdev` em `0x07`
- hooks reescritos pra duas GPUs: nao derrubam mais sessao, display manager nem nvidia, e
  **abortam se o `amdgpu` nao estiver em uso** -- a unica falha capaz de deixar o PC sem tela
- `vm/vfio-ativar.sh`: alem de exigir duas GPUs, exige `amdgpu` em uso (placa enumerada sem
  driver, num riser mal encaixado, passava na guarda velha), imprime o que conferir antes de
  reiniciar e **cria a entrada `Arch Linux (zen, sem vfio)`** no systemd-boot
- `ricepanel.service` com `ExecCondition` no `bin/monitor.sh vertical`

### A rota de recuperacao que nao existia

O `vm/README.md` dizia que o `arch-fallback.conf` ficava sem os parametros da nvidia, de
proposito, como rota de fuga. **Era falso:** os dois arquivos eram identicos, entao os dois
bootariam sem tela do mesmo jeito. Quem resolve e `module_blacklist=vfio_pci`, que vale mesmo
com o modulo dentro do initramfs -- e agora e o que a entrada `sem vfio` carrega.

### Ordem das proximas etapas

1. Montar a RX 550 no riser -> `lspci -nnk` tem que mostrar **duas** GPUs e `amdgpu` em uso
2. Cabo DP do ASUS na RX 550, boot, `hyprctl monitors` -- a 3090 ainda no driver nvidia.
   **Ponto de nao-retorno:** so seguir com o Hyprland desenhando na AMD
3. (feito) XMLs e hooks
4. `vm/vfio-ativar.sh`, conferir os tres itens que ele imprime, so entao reiniciar.
   Sucesso = `lspci -nnk -s 07:00.0` com `Kernel driver in use: vfio-pci`
5. `w11 janela`: instalar Windows, virtio e o `looking-glass-host-setup.exe` **antes** de
   tentar o perfil 3090 -- depurar Windows sem tela e sofrimento
6. Passthrough + Looking Glass

### O que sai do repo, e so depois da etapa 4 provada

`kernel-nvidia` (`packages.txt:30`), `configure_nvidia()` (`install.sh:295`), o autostart
`nvidia-desempenho.sh`, o `custom/gpu` da waybar (chama `nvidia-smi`) e as `hl.env` de
`LIBVA_DRIVER_NAME`/`__GLX_VENDOR_LIBRARY_NAME`/`NVD_BACKEND` -- essas ultimas saem ja na
etapa 2, porque com o host em amdgpu apontar pra nvidia quebra a aceleracao de video.

**Nao remover antes:** e o caminho de volta. O `nvidia-open-dkms` vale manter instalado por
semanas mesmo com o vfio ativo -- o `softdep` impede que ele carregue, e tirar o
`/etc/modprobe.d/vfio.conf` + `mkinitcpio -P` devolve a 3090 pro host.

### Pinagem de CPU: confere, nao mexer

No 5700X, `core N = CPU N e N+8`. O XML pina `(2,10) (3,11) (4,12) (5,13) (6,14) (7,15)` --
pares HT juntos, nucleos 2-7 -- com `emulatorpin 0,8` e `iothreadpin 1,9`. Dois nucleos
fisicos pro host bastam: ele so desenha o Hyprland numa RX 550 e roda o cliente Looking
Glass. `<topology cores="6" threads="2">` bate com as 12 vcpus. 16 GB de 31 GB (ja houve OOM
com 20).

### Topologia dos cabos (definida em 07/09/2026, com a compra do 2o HDMI e do dummy plug)

```
ASUS XG27ACS <--HDMI-- RX 550     Linux, entrada do dia a dia
ASUS XG27ACS <--DP---- RTX 3090   Windows nativo 1440p180
LG UltraGear <--HDMI-- RX 550     Linux, RicePanel
RTX 3090     <--dummy plug numa saida livre (3x DP + 1x HDMI, sobra porta)
```

O ASUS recebe **duas** entradas e alterna pelo botao. No dia a dia fica no HDMI; pra jogar,
ou `vm/glass -F` sem sair do Hyprland, ou troca pra DP e ve o Windows nativo. A sessao nao
cai em nenhum dos dois casos.

**Video primario na BIOS: a RX 550** (slot de baixo, `PCIEX16_2`). E onde vive o Linux e o
menu do systemd-boot -- a entrada `Arch Linux (zen, sem vfio)` so serve se aparecer na
entrada que ele usa todo dia. Opcao em Advanced > Onboard Devices Configuration > Primary
Video Device.

### Dummy plug: por que, mesmo com o ASUS ligado na 3090

Monitor com duas entradas costuma **derrubar o hot-plug detect da entrada nao selecionada**.
Com o ASUS no HDMI (Linux), a 3090 pode deixar de enxergar display -- e o Windows para de
gerar frame, congelando o Looking Glass no meio do jogo. O dummy plug numa saida livre
garante um display sempre ativo, independente da entrada escolhida.

Ele tambem **aposenta a duvida do Looking Glass IDD**, que era a unica incognita tecnica que
sobrava: o IDD nao vem no `~/vms/looking-glass-host-B7.zip` (so o `looking-glass-host-setup.exe`),
seria download a parte e teria que casar a versao B7. Com dummy plug nada disso importa.

O dummy plug comprado e **DisplayPort 4K** (R$ 32,85, anuncia 4K@60 e 1080p@120). Isso
importa pro shmem: 2560x1440 pede ~40 MB (`w*h*4*2 + 10 MB`), mas se o Windows adotar o EDID
4K do dummy vai pra ~76 MB e o Looking Glass reclamaria de memoria insuficiente. O XML foi
de 64 para **128 MB**, que cobre ate 4K com folga -- e /dev/shm so ocupa RAM enquanto a VM
roda, entao 64 MB a mais nao custam nada num host de 31 GB.

**Com o ASUS e o dummy ligados ao mesmo tempo, o Windows enxerga dois monitores.** Definir o
ASUS como principal no Windows uma vez (Configuracoes > Sistema > Video), senao o RedM pode
abrir no display fantasma do dummy e a janela some da tela.

### Por que a RX 550 nao pode ser a placa da VM

Cogitado e descartado por dois motivos independentes. O slot de baixo pendura no chipset
B550, atras da mesma bridge do **grupo IOMMU 15** -- que ja tem USB 3.1, SATA e a Ethernet
RTL8125. Passar a RX 550 levaria disco, teclado e rede junto; contornar exigiria ACS
override, ou seja, furar o isolamento que o IOMMU existe pra dar. E a RX 550 4GB de 2017 nao
roda RedM em servidor de RP cheio. So a 3090, que sai direto da CPU no grupo 16, e isolavel
nesta placa-mae.
