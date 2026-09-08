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

