# Plano B: Windows 11 em VM KVM com a RTX 3090 inteira (single GPU passthrough)

Se o client custom não subir sob Wine (ou o ROS não aceitar a licença), o RedM oficial roda numa VM Windows que
recebe a 3090 física. Enquanto a VM está ligada o Arch fica sem tela (a única GPU está na VM); ao desligar a VM,
os hooks devolvem a GPU e o SDDM volta. Zero hardware novo. Performance ~95% do nativo.

Base: [QaidVoid/Complete-Single-GPU-Passthrough](https://github.com/QaidVoid/Complete-Single-GPU-Passthrough) e o
vídeo [Single GPU Passthrough (Arch-based distros) Tutorial 2026](https://www.youtube.com/watch?v=h7rYSFBjyr4) (PlayF0R3v3R, 19/05/2026),
adaptados pra **esta máquina**: Gigabyte B450M GAMING, Ryzen 7 5700X (sem iGPU), RTX 3090, 32 GB, systemd-boot
(myarch), nvidia-open-dkms, **KDE Plasma Wayland + SDDM**.

## 0-bis. ATUALIZAÇÃO 05/09/2026: a seção 0 abaixo ficou obsoleta

O Windows foi formatado. O NVMe hoje é `nvme0n1p1` (ESP 1 GiB) + `nvme0n1p2` (ext4, todo o resto),
com **468 GB livres**. Não há mais partição para preservar nem motivo para encolher nada: a VM usa uma
**imagem de disco** em `/var/lib/libvirt/images/`, que é o que o `win11-redm.xml` já espera. Toda a
seção 0 (encolher C:, BitLocker, ESP compartilhada, `--target-partition` no myarch) deixa de valer.

O que falta para o plano B agora é só: ISO do Windows 11, criar a imagem e instalar.

### Preparado nesta máquina (05/09/2026)

| Item | Estado |
|:--|:--|
| IOMMU no BIOS | ✔ ativo (`AMD-Vi` no dmesg) |
| `amd_iommu=on iommu=pt` | ✔ na entrada `arch.conf`; o `arch-fallback.conf` ficou **sem** os parâmetros, de propósito, como rota de recuperação. Backup em `arch.conf.bak-pre-iommu`. **Exige reboot** |
| Grupo IOMMU da 3090 | ✔ **grupo 16 com a 3090 (`0a:00.0`) e o áudio dela (`0a:00.1`), mais nada** — isolamento limpo, sem precisar de ACS override |
| Hooks do libvirt | ✔ instalados em `/etc/libvirt/hooks/qemu.d/win11-redm/` |
| `libvirtd` | ✔ ativo e habilitado; rede `default` iniciada com autostart |
| OVMF (`edk2-ovmf`), `/dev/kvm`, usuário no grupo `libvirt` | ✔ |
| Imagem de disco + Windows instalado | ✖ falta |

No `win11-redm.xml`, trocar os `bus="0xXX"` dos dois `<hostdev>` por `bus="0x0a"` (endereços reais
desta máquina: `0000:0a:00.0` e `0000:0a:00.1`).

## 0. Antes de tudo: layout de disco sem perder o Windows

Um NVMe só (932 GB, Windows em `nvme0n1p3`, 263 GB livres em 04/09/2026). O `myarch` apaga o disco inteiro, então a
ordem que preserva o Windows como rede de segurança é:

1. **Windows:** encolher C: em ~200 GB (Gerenciamento de Disco → Diminuir Volume). Antes, `manage-bde -status C:`;
   se BitLocker estiver ligado, salvar a chave de recuperação, porque desligar Secure Boot muda a medição do TPM.
2. **BIOS (B450M GAMING, F64):** Secure Boot Disabled, CSM Disabled, **IOMMU Enabled**, **SVM Mode Enabled**,
   Resizable BAR **Disabled** (quebra passthrough da 3090 com tela preta), Fast Boot desligado pra ver o pendrive.
3. **Arch no espaço livre**, não no disco inteiro. O `myarch` de hoje não faz isso (recusa dual boot no mesmo disco);
   ou instalar na mão seguindo o mesmo layout dele (ESP compartilhada com o Windows + btrfs com `@ @home @log @pkg @snapshots`),
   ou dar ao `myarch` um modo `--target-partition`. A ESP do Windows (100 MB) é pequena pra dois kernels: criar uma
   ESP nova de 1 GiB no espaço livre e apontar o systemd-boot pra ela.
4. Windows continua bootável pela firmware (F12). Só depois de tudo validado é que se apaga o Windows e expande o btrfs.

Testar Linux **antes de formatar**, sem pendrive novo: esse dual boot é exatamente isso. WSL2 e Hyper-V não servem
pra validar o jogo: WSL2 não tem Vulkan real pra NVIDIA (só Dozen, experimental) e o Hyper-V não passa GPU pra
guest Linux. Servem só pra testar o FXServer Linux e os scripts do `server/`.

## 1. IOMMU no kernel (systemd-boot)

`/boot/loader/entries/arch.conf` (o myarch grava `KERNEL_PARAMS` em `options`):

```
options root=UUID=... rootflags=subvol=@ nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 rw quiet amd_iommu=on iommu=pt
```

Reboot e conferir:

```bash
sudo dmesg | grep -iE 'AMD-Vi|IOMMU'          # "AMD-Vi: ... IOMMU performance counters" / "Interrupt remapping enabled"
./iommu-groups.sh                              # 3090 (10de:2204) e o áudio dela (10de:1aef) no MESMO grupo, sozinhos
```

No B450 o slot PCIEX16 vem da CPU e costuma cair num grupo próprio com o áudio HDMI. Os slots x1 e o resto passam
pelo chipset e ficam agrupados juntos (USB, SATA, LAN): não importa, ficam no host. Se a 3090 aparecer no mesmo grupo
que USB/SATA, aí precisa do kernel `linux-zen` (tem ACS override) ou `pcie_acs_override=downstream,multifunction`.

## 2. Pacotes e serviços

`dotfiles/packages.txt` já lista `libvirt qemu-full virt-manager dnsmasq`. Falta:

```bash
sudo pacman -S --needed edk2-ovmf swtpm looking-glass   # OVMF (UEFI), TPM 2.0 pro Win11, LG só se um dia vier 2ª GPU
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt,kvm,input alexandre
sudo virsh net-start default && sudo virsh net-autostart default
```

## 3. VM

`virt-manager` → nova VM → ISO do Windows 11 → **Customize before install**:

| Seção | Valor |
|:--|:--|
| Overview | Chipset **Q35**, Firmware **UEFI x86_64: OVMF_CODE.secboot.4m.fd** |
| CPUs | **host-passthrough**, topologia 1 socket × 6 cores × 2 threads (12 vCPU; host fica com 4 threads) |
| Memória | 20480 MB (deixa 12 GB pro host) |
| Disco | raw 200 GB em `/var/lib/libvirt/images/win11-redm.img`, barramento **VirtIO**, cache none, io native. Em btrfs: `chattr +C` na pasta ANTES de criar o arquivo |
| NIC | virtio |
| TPM | Emulated, CRB, 2.0 (Win11 exige) |
| CDROM 2 | `virtio-win.iso` (drivers de disco e rede) |
| Remover | Display Spice, Video QXL, Channel spice, Sound ich9, Tablet, USB Redirector |

Instalar o Windows (Load Driver → `virtio-win\amd64\w11` pro disco), instalar `virtio-win-guest-tools`, depois desligar.

Editar o XML: `virsh edit win11-redm`, base em [`win11-redm.xml`](win11-redm.xml). Pontos que importam:

```xml
<features>
  <hyperv mode="custom"> ... <vendor_id state="on" value="AuthenticAMD"/> </hyperv>
  <kvm><hidden state="on"/></kvm>          <!-- driver NVIDIA e anticheats não enxergam o hypervisor -->
  <ioapic driver="kvm"/>
</features>
<cpu mode="host-passthrough" check="none" migratable="off">
  <topology sockets="1" dies="1" cores="6" threads="2"/>
  <cache mode="passthrough"/>
  <feature policy="require" name="topoext"/>   <!-- SMT do Ryzen visível no guest -->
</cpu>
<cputune>  <!-- 5700X: core N = threads N e N+8. VM leva cores 2-7; host fica com 0,1 -->
  <vcpupin vcpu="0" cpuset="2"/>  <vcpupin vcpu="1" cpuset="10"/>
  <vcpupin vcpu="2" cpuset="3"/>  <vcpupin vcpu="3" cpuset="11"/>
  <vcpupin vcpu="4" cpuset="4"/>  <vcpupin vcpu="5" cpuset="12"/>
  <vcpupin vcpu="6" cpuset="5"/>  <vcpupin vcpu="7" cpuset="13"/>
  <vcpupin vcpu="8" cpuset="6"/>  <vcpupin vcpu="9" cpuset="14"/>
  <vcpupin vcpu="10" cpuset="7"/> <vcpupin vcpu="11" cpuset="15"/>
  <emulatorpin cpuset="0-1,8-9"/>
</cputune>
```

Adicionar hardware → **PCI Host Device**: a 3090 (`0000:XX:00.0`) **e** o áudio HDMI dela (`0000:XX:00.1`). O endereço
sai do `iommu-groups.sh`. Teclado e mouse: **USB Host Device** (simples) ou evdev (`install-hooks.sh` gera o trecho).

Áudio do jogo: a 3090 tem saída HDMI/DP → o monitor com alto-falante recebe direto. Ou PipeWire via JACK (QaidVoid, seção Audio).

## 4. Hooks (o coração do single GPU)

`install-hooks.sh` detecta a 3090, grava `/etc/libvirt/hooks/qemu` (dispatcher) e os scripts em
`/etc/libvirt/hooks/qemu.d/win11-redm/{prepare/begin/start.sh,release/end/stop.sh}` já com o PCI ID e o usuário.

O que `start.sh` faz, nessa ordem: para a sessão Plasma do usuário (KDE Wayland segura a GPU mesmo com o SDDM parado,
issue #31 do QaidVoid) → para `display-manager` → espera o SDDM soltar → desliga vtcon e o framebuffer EFI →
`modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia` → `virsh nodedev-detach` da GPU e do áudio → `modprobe vfio-pci`.
`stop.sh` faz o inverso e sobe o SDDM.

Testar os hooks **antes** de ligar a VM, por SSH de outro aparelho (celular com Termux serve):

```bash
sudo /etc/libvirt/hooks/qemu.d/win11-redm/prepare/begin/start.sh   # tela apaga; via SSH: lspci -k -s XX:00.0 → Kernel driver in use: vfio-pci
sudo /etc/libvirt/hooks/qemu.d/win11-redm/release/end/stop.sh      # SDDM volta
```

## 5. Dentro da VM

Driver NVIDIA normal, Steam, RDR2, RedM **oficial** (com adhesive, entra em qualquer servidor). Cfx não bloqueia VM;
o `<kvm hidden>` + `vendor_id` bastam. Servidor local: o FXServer roda **no Arch** (nativo); a VM conecta no IP da
bridge `virbr0` (192.168.122.1:30120) ou em `sv_lan 1` via `connect 192.168.122.1`.

## 6. Problemas conhecidos e saídas

| Sintoma | Causa | Saída |
|:--|:--|:--|
| Tela preta ao ligar a VM, VM não sobe | Resizable BAR ligado ou vBIOS não carregou | ReBAR off na BIOS; se persistir, dump do vBIOS (`GPU-Z` no Windows) e `<rom file=.../3090.rom/>` no hostdev |
| `modprobe -r nvidia_drm` falha: "in use" | Plasma/kwin ou fbcon ainda segurando | O `start.sh` já mata `plasma*` do usuário e desliga vtcon; se persistir, `nvidia_drm.fbdev=0` na cmdline |
| Ao desligar a VM o SDDM não volta | reset bug da GPU / módulo não recarregou | `stop.sh` tem retry; SSH e `systemctl start display-manager`; último recurso: reboot |
| Erro 43 no driver NVIDIA dentro da VM | hypervisor visível | `<kvm hidden>` + `vendor_id` (já no XML) |
| Áudio picotado | latência do JACK | HDMI direto pelo monitor, ou `PIPEWIRE_LATENCY=1024/48000` |
| Stutter | SMT não visível / sem pinning | `topoext` + `cputune` do XML; hugepages opcionais |

## 7. E se um dia vier uma segunda GPU

Não é o plano, mas fica registrado: o PCIEX1_1 do B450M GAMING fica **acima** do PCIEX16, longe do cooler da 3090.
Uma GT 710/1030 x1 lá vira GPU do host, e aí Looking Glass mostra a VM em janela no KDE. PCIe 2.0 x1 limita o Looking
Glass a ~1080p60; mais que isso, ligar o monitor direto na 3090 e usar a GPU fraca só pro desktop.
