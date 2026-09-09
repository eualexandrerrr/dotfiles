# VM w11 — Windows 11 com passthrough da RTX 3090

Não fica em `links/`: o `install.sh` symlinka `links/config/*` para `~/.config/`, e
`~/.config/libvirt` é o diretório do libvirt **de sessão do usuário**. Esta VM vive no
libvirt **de sistema** (`qemu:///system`), então um symlink ali só criaria confusão entre
os dois. Aqui é fonte de verdade versionada; aplicar é explícito.

## O hardware

Placa-mãe **ASUS TUF Gaming B550M-PLUS** (BIOS 3636, AGESA ComboV2PI_1.2.0.F), com SVM,
IOMMU, NX e Above 4G ligados e fTPM desligado. Ryzen 7 5700X, 31 GB.

| Slot | Placa | Papel |
|:--|:--|:--|
| `PCIEX16_1`, topo, via riser | **RTX 3090** | vai inteira pra VM |
| `PCIEX16_2`, base, direto no slot | **PCYes RX 550** | desenha o Linux |

A 3090 sai direto da CPU e fica sozinha no **grupo IOMMU 16** com o áudio dela — isolamento
limpo, **sem ACS override**. Confirmado em 07/09/2026, depois da troca de placa-mãe:

```sh
for g in /sys/kernel/iommu_groups/*/devices/*; do echo "$(echo $g | cut -d/ -f5) $(basename $g)"; done | sort -n
```

O endereço PCI dela **mudou com a placa-mãe**: era `0000:0a:00.0/.1` na Gigabyte B450M, hoje
é `0000:07:00.0/.1`. É o que os dois `<hostdev>` do `w11-3090.xml` apontam.

**Quem sai por riser é a 3090**, PCIe 3.0 x16 de 20 cm com plugue de 90°: ela tem 2,7 slots
de cooler e, montada no slot, cobre o de baixo fisicamente. Por isso fica **fora do
gabinete**, apoiada — riser com placa desse peso nunca pendurado só pelo conector, que vira
alavanca, e nunca sobre o saco antiestático, que é condutivo por fora.

A RX 550 vai **direto no `PCIEX16_2`**, sem riser. Alimentação ela não usa: puxa os 75 W do
próprio slot.

### Por que a RX 550 não pode ser a placa da VM

Cogitado e descartado por dois motivos independentes. O slot de baixo pendura no chipset
B550, atrás da mesma bridge do **grupo IOMMU 15** — que já tem USB 3.1, SATA e a Ethernet
RTL8125. Passar a RX 550 levaria disco, teclado e rede junto; contornar exigiria ACS
override, ou seja, furar o isolamento que o IOMMU existe pra dar. E uma RX 550 4 GB de 2017
não roda RedM em servidor de RP cheio.

## Topologia dos cabos

Portas reais: a 3090 tem 3× DP + 1× HDMI, a RX 550 tem 1× DP + 1× HDMI, e cada monitor tem
1× DP + 1× HDMI. Com 2 cabos HDMI e 2 DP só existem dois arranjos. **Escolhido em
07/09/2026: a 3090 no DisplayPort.**

```
ASUS XG27ACS <--DP---- RTX 3090   Windows nativo, 1440p180
ASUS XG27ACS <--HDMI-- RX 550     Linux, entrada do dia a dia, 144 Hz
LG UltraGear <--DP---- RX 550     Linux, RicePanel
RTX 3090     <--dummy plug numa das 2 DP que sobram
```

Sobra um cabo HDMI de reserva. O ASUS recebe **duas** entradas e alterna pelo botão: no dia
a dia fica no HDMI; pra jogar, ou `vm/glass -F` sem sair do Hyprland, ou troca pra DP e vê o
Windows nativo. **A sessão não cai em nenhum dos dois casos.**

**Vídeo primário na BIOS: a RX 550** (`PCIEX16_2`), em Advanced › Onboard Devices
Configuration › Primary Video Device. É onde vive o Linux e o menu do systemd-boot — a
entrada de recuperação só serve se aparecer na entrada que ele usa todo dia.

### O custo da escolha: 144 Hz no Linux

2560×1440@180 pede ~19,3 Gbps. O DP 1.4 dá 25,9 e passa sem DSC; a **HDMI 2.0b da RX 550 dá
18** e não passa. Pela HDMI o principal fica em **144 Hz**. O outro arranjo (RX 550 no DP,
3090 na HDMI 2.1 de 48 Gbps) daria 180 nos dois lados, mas a preferência foi por DP na 3090
e no Windows o resultado é idêntico.

Por isso, **na etapa 2 o `monitores.lua` muda de `2560x1440@180.00` para `@144`**, quando a
RX 550 assumir o principal. E `mode = "highrr"` **não** resolve isso: ele maximiza a taxa e
não a resolução, e derrubou a tela pra 1024x768@180 (testado em 07/09/2026). Resolução e
taxa sempre explícitas ali.

## Ordem de montagem

A ordem importa: em cada passo, ou o cabo está onde a BIOS manda a imagem, ou você acabou de
mudar sabendo por quê. **Nunca fique adivinhando onde a tela foi parar.**

1. **Montar a 3090 no riser e a RX 550 direto no slot de baixo.** Máquina desligada e fora
   da tomada. Cabos de vídeo como
   estão, ainda tudo na 3090.
2. **BIOS: vídeo primário → `PCIEX16_2`.** A tela apaga ao salvar; é o esperado, o POST foi
   pra outra placa. Desligue no botão.
3. **Passar os três cabos** conforme a topologia, mais o dummy plug numa DP livre da 3090.
4. **Ligar com o ASUS na entrada HDMI.** Tem que aparecer o POST, o menu do systemd-boot e o
   Hyprland. *Se você vê o menu de boot, a rota de recuperação existe; sem isso não siga.*
5. **Provar que o host está na AMD:** `lspci -nnk | grep -A3 -iE 'vga|3d'` — duas placas, a
   RX 550 com `Kernel driver in use: amdgpu`, a 3090 ainda em `nvidia`. **Ponto de
   não-retorno:** enquanto o Hyprland não estiver desenhando pela AMD, o passthrough não
   começa. Aqui também troca o modo do monitor pra `@144`.
6. **`vm/vfio-ativar.sh`.** Ele confere as guardas sozinho, imprime os três itens a verificar
   e cria a entrada de recuperação. Reiniciar só depois que os três baterem. Sucesso =
   `lspci -nnk -s 07:00.0` com `Kernel driver in use: vfio-pci`.
7. **`w11 janela`:** instalar Windows, virtio e o `looking-glass-host-setup.exe` **antes** de
   tentar o perfil 3090 — depurar Windows sem tela é sofrimento. O `virtio-win-guest-tools`
   só deixa o `viostor` no DriverStore: **o serviço de boot só nasce quando o Windows enxerga
   um disco virtio de verdade.** Sem isso o perfil 3090 dá `INACCESSIBLE_BOOT_DEVICE (0x7B)`.
   Suba uma vez ainda em SATA com um segundo disco `bus="virtio"` qualquer: o PnP registra o
   `viostor` como `BOOT_START` e aí o boot em `vda` funciona.
8. **`w11 3090`** + `vm/glass`.

Se em qualquer passo a tela sumir, o monitor está na entrada errada ou a BIOS postou na outra
placa. Troque a entrada no botão antes de concluir que algo quebrou — é quase sempre isso.

## Dois perfis, um domínio

`w11-3090.xml` é o passthrough (a 3090 inteira vai pra VM; o host continua desenhando na
RX 550). `w11-janela.xml` é vídeo emulado + SPICE numa janela, sem 3D: serve para
instalar/ajustar o Windows, **não roda RedM**. O script `w11` faz o `define` do perfil
escolhido e liga: `w11 janela`, `w11 3090`, `w11 perfil`, `w11 desligar`.

Os hooks do libvirt olham o XML que recebem no stdin e só agem se houver `hostdev` PCI.

**Os hooks encolheram na virada pra duas GPUs.** A versão antiga era single-GPU: parava o
Plasma, fazia `loginctl terminate-user`, derrubava o display manager e descarregava a
nvidia. Com a RX 550 desenhando o host nada disso é necessário — e seria destrutivo. Hoje o
`start.sh` só trava a suspensão e **aborta se o `amdgpu` não estiver em uso**, que é a única
coisa capaz de deixar o PC sem tela. O `stop.sh` só solta a trava: a 3090 volta pro
`vfio-pci`, não pro host.

## A sessão não cai mais

Com duas GPUs **a sessão do Hyprland não é derrubada**: ligar a VM não fecha nada, e o
Alt-Tab entre Linux e Windows funciona pela janela do Looking Glass. Isso aposenta a
mecânica de salvar e reabrir aplicativos:

- `salvar_apps()` no script `w11` e o `vm/reabrir-apps.sh` viram código morto. Ficam por
  enquanto — saem quando o passthrough estiver comprovadamente de pé.
- O login automático do `sddm` continua valendo pra ligar o PC, não mais pra "voltar da VM".

## Alta resolução sem dummy plug: o IDD

Sem um display de verdade na 3090, o Windows só oferece o que o EDID anuncia — e o ASUS, com
a entrada no HDMI, entrega um EDID reduzido que para em 1920x1080. O Looking Glass ficava em
1280x960. O **Indirect Display Driver** resolve criando um display virtual dentro do Windows,
independente de cabo, EDID e de qual entrada o monitor está usando.

**O IDD não existe no B7 estável.** Só nas builds de desenvolvimento. Por isso
`~/vms/lg-dev/` guarda a build `B7-826-236efcb1`: o cliente compilado (`client/build/`) e o
`looking-glass-idd-setup.exe`. O `vm/glass` usa esse cliente quando ele existe e cai no
pacote do sistema quando não — cliente e IDD **têm que ser da mesma build**.

Para o Windows aceitar o driver foram precisos três passos, nesta ordem:

1. `bcdedit /set testsigning on` — sozinho **não** basta, e o Secure Boot já estava desligado.
2. Instalar a cadeia da Sectigo. A raiz USERTrust já estava no store, faltava a intermediária
   `Sectigo Public Code Signing CA E36`, e sem ela a validação dava `0x800b0109`.
3. Confiar na **HostFission** (a empresa do autor, que assina o driver) em `TrustedPublisher`.
   Sem isso o log diz `Driver package signer is unknown` e a instalação silenciosa recusa,
   porque não há prompt para confirmar.

Depois: `LGIddInstall.exe install LGIdd LGInput` e um reboot. O `/S` do instalador só copia
os arquivos — quem registra o driver é o `LGIddInstall`.

## Looking Glass (`vm/glass`)

O Windows renderiza na 3090, copia o frame pra `/dev/shm/looking-glass` (ivshmem, **128 MB**)
e o `vm/glass` desenha numa janela do Hyprland. 2560×1440 pede ~40 MB (`w*h*4*2 + 10 MB`); os
128 MB cobrem até 4K, que é o que o EDID do dummy plug anuncia — foi por isso que subiu de 64.

Teclado e mouse vão por SPICE (sem display); Scroll Lock solta o mouse. Cliente B7 do AUR; o
host pro guest está em `~/vms/looking-glass-host-B7.zip` (a versão tem que ser a mesma dos
dois lados). O `preparar.sh` cria o shmem com dono certo por tmpfiles.

**O dummy plug** vai numa DP livre da 3090. Não é só pelo caso de ficar sem cabo: com o ASUS
ligado nas duas placas e a entrada dele no HDMI, o monitor pode derrubar o hot-plug detect do
DP, e aí o Windows para de gerar frame no meio do jogo. Com ele há sempre um display ativo.
Isso dispensa o Looking Glass IDD, que seria download à parte e teria que casar a versão B7 —
o `looking-glass-host-B7.zip` traz só o `looking-glass-host-setup.exe`.

**Com o ASUS e o dummy ligados, o Windows enxerga dois monitores.** Marcar o ASUS como
principal uma vez, em Configurações › Sistema › Vídeo — senão o RedM pode abrir no display
fantasma do dummy e você não vê nada, parecendo travamento.

## Instalar o Windows (`w11 instalar`)

Perfil `janela` + ISO do Windows + `~/vms/autounattend.iso` (o `autounattend.xml` do MyWinISO
com `MYWINISO_PERFIL=vm-jogo` injetado no primeiro logon). Disco em SATA, vídeo `vga` e rede
`e1000e` na instalação — o Windows não traz driver virtio pra nenhum dos três (o vídeo virtio
congela a tela na última imagem da UEFI, parecendo travamento; volta pra virtio depois do
viostor instalado). Três injeções no XML, feitas pelo `autounattend-vm.sh`: o perfil
`vm-jogo`, a cópia do arquivo pra `X:\` e a chave `HKLM\System\Setup\UnattendFile` — o Ventoy
faz as duas últimas sozinho, um pendrive comum não, e o `instala.vbs` lê só a chave. Além
disso o disco leva `<serial>6479A7AABAC014A3</serial>`, o serial do MP700 — é assim que o
`instala.vbs` aceita o disco.

## Restaurar

```sh
sudo virsh -c qemu:///system define ~/.dotfiles/vm/w11-3090.xml
```

O disco é `~/vms/win.raw` (raw, 200 GB, `falloc`): fica em `/home`, que sobrevive ao format.
Windows ocupa ~40 GB e o RedM com cache de assets passa fácil de 100 GB. O `vm/preparar.sh`
cria, dá acesso ao `libvirt-qemu` (ACL) e instala os hooks.

## O que está configurado, e por quê

| | |
|:--|:--|
| 12 vCPUs fixadas nos núcleos 2-7 | no 5700X `core N = CPU N e N+8`, então os pares HT ficam juntos: `(2,10) (3,11) (4,12) (5,13) (6,14) (7,15)` |
| `emulatorpin 0,8` e `iothreadpin 1,9` | o I/O do QEMU não rouba tempo do jogo; dois núcleos físicos bastam pro host, que só desenha o Hyprland e o cliente Looking Glass |
| 16 GB | o host tem 31 GB; deixa ~15 GB. Já houve OOM com 20 GB |
| sem hugepages estáticas | o kernel já roda `transparent_hugepage=always`; reservar fixo prejudicaria o host com a VM desligada |
| `memballoon` desligado | ballooning atrapalha jogo |
| `io=native` + iothread dedicada | disco |
| Hyper-V completo + `topoext` + `cache passthrough` | `topoext` é obrigatório: sem ele a topologia 6c/2t em AMD derruba o guest |
| `hostdev`: só a 3090 e o áudio HDMI dela | teclado e mouse **saíram** do passthrough USB: iam inteiros pra VM e deixavam o host sem entrada a cada boot dela. A entrada vem por SPICE pelo Looking Glass, e Scroll Lock devolve o mouse |
| `shmem` 128 MB + SPICE sem display + `<video>` none | a tela é a janela do Looking Glass |

## Operar a VM sem tela nem teclado

Os três XMLs têm o canal `org.qemu.guest_agent.0`. Com o `qemu-ga` instalado no guest (vem
no virtio-win-guest-tools), dá para rodar comando dentro do Windows pelo host:

```sh
sudo virsh -c qemu:///system qemu-agent-command w11 \
  '{"execute":"guest-exec","arguments":{"path":"powershell.exe","arg":["-Command","..."],"capture-output":true}}'
```

É o caminho quando o monitor está desligado ou o teclado já foi para a VM: `virsh screenshot`
mostra a tela do perfil `janela`, e o agente executa o resto. Sem ele sobra `virsh send-key`,
que entrega **keycode**, não caractere -- o guest está em ABNT2, então `:` é
`KEY_LEFTSHIFT KEY_SLASH` e `\` é `KEY_102ND`.

**O SPICE precisa escutar em TCP.** Com `<listen type="none"/>` o Looking Glass morre em
`Failed to connect to spice server`: o cliente fala SPICE por 127.0.0.1:5900 para levar
teclado e mouse. Por isso o perfil 3090 usa `port="5900" autoport="no"` com listen em
`127.0.0.1`.

## Jogar RDR2/RedM na VM: as três coisas que faltavam

**1. Sem placa de som o RAGE nem abre.** O perfil `w11-3090.xml` tinha só
`<audio type="none">` e nenhum `<sound>`. O RDR2 morre em
`RAGE error: ERR_AUD_MIXER_INIT — Failed to initialize audio`. Agora o perfil traz
`<sound model="ich9" />` com backend **PipeWire**, e som de verdade sai no host.

O QEMU roda como `libvirt-qemu`, que não entra em `/run/user/1000` (modo 0700). Quem abre a
porta é `systemd-user/.config/systemd/user/vm-audio-acl.service`: um `oneshot` no
`graphical-session.target` que dá ACL de `x` na pasta e `rw` no socket, e desfaz no stop.
Sem esse serviço a VM não inicia — o QEMU não consegue conectar no PipeWire.

Som não faz hot-plug: `attach-device` responde *anexo ativo do dispositivo 'sound' não é
suportado*. Tem que desligar a VM.

**2. Resizable BAR de 32 GB não cabe no MMIO padrão do OVMF.** A 3090 anuncia
`BAR 1: current size: 32GB` (`lspci -vvs 07:00.0`). O firmware da VM não tem janela de 64 bits
para mapear isso, o driver reporta os 24 GB mas o Vulkan não aloca nada, e o RedM cai em
`VK_ERROR_OUT_OF_DEVICE_MEMORY` logo depois de escolher a GPU certa:

```
Render/ GPU Name: NVIDIA GeForce RTX 3090
Render/ Error: Failed to allocate memory for Vulkan. VkResult: VK_ERROR_OUT_OF_DEVICE_MEMORY
```

A cura é abrir a janela no OVMF, pelo `qemu:commandline` do XML:

```xml
<qemu:commandline>
  <qemu:arg value="-fw_cfg" />
  <qemu:arg value="opt/ovmf/X-PciMmio64Mb,string=131072" />
</qemu:commandline>
```

**65536 (64 GB) não bastou** para um BAR de 32 GB; 131072 (128 GB) resolveu. O `<domain>`
precisa do namespace `xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0"`.

**3. Matar o jogo à força quebra o próximo Vulkan.** Depois de `Stop-Process -Force`, a
alocação de device fica presa e o lançamento seguinte volta a dar `VK_ERROR_OUT_OF_DEVICE_MEMORY`
sem reiniciar a VM. Para reconectar, não relance o processo: abra o console com **F8** e digite
`connect <ip>:<porta>`. De dentro da VM o servidor do host **não** é `localhost` — é o gateway
da rede `default`, `192.168.122.1`.

Duas coisas mais que ajudam, e já estão aplicadas: **MSI** ligado na 3090 e no áudio dela
(`MessageSignaledInterruptProperties\MSISupported = 1` sob `Enum\PCI\VEN_10DE*`), e plano de
energia **Alto desempenho** no Windows. No host, os hooks de `prepare/begin` e `release/end`
põem o governor em `performance` enquanto a VM roda e devolvem `powersave` quando ela desliga.

## Fazer a VM parecer nativa

Depois que o jogo abriu, ele ainda não parecia fluido e o mouse fugia para o outro
monitor no meio da partida. Eram quatro coisas independentes.

### 1. A tela virtual nascia a 60 Hz

**Esta é a que explica "não parece a 3090".** O display do IDD é criado com
`2560x1440@60` e o Windows guarda a última taxa que usou, então o RDR2 rodava travado
em 60 fps por mais rápida que fosse a placa. O monitor faz 119,998.

`vm/guest-tela.sh` lê a taxa do `hyprctl`, escreve em
`HKLM\SOFTWARE\LookingGlass\IDD\ExtraMode` no formato `LARGURAxALTURA@TAXA*` (o `*`
marca o modo preferido), recria o IDD e aplica o modo. O `vm/jogar` chama ele antes de
abrir a janela; quando a taxa já bate, sai sem fazer nada.

Casar a taxa **exata** não é preciosismo: o manual do Looking Glass manda usar
`119.970` em vez de `120` porque os dois relógios correm soltos, e a diferença vira
uma serra no tempo de espera do frame.

**As APIs de vídeo do `user32` não existem na sessão 0**, que é onde o
`qemu-guest-agent` roda. `EnumDisplaySettings` volta falso lá e não adianta insistir.
A troca vai por uma tarefa agendada com `LogonType Interactive`, que cai na sessão do
console. E, no PowerShell, `$null` num parâmetro `string` de P/Invoke chega como string
vazia, não como `NULL` — para o nome do dispositivo é preciso `[NullString]::Value`,
senão toda chamada falha em silêncio.

`vm/guest.sh` é a parte reaproveitável: `guest_exec` e `guest_put` falam com o Windows
pelo agente, sem tela e sem RDP. O script vai por arquivo porque o `guest-exec` tem
limite de tamanho e um `Add-Type` inteiro não cabe na linha de comando.

### 2. O frame passava pela CPU

O `ivshmem` apontava para um arquivo em `/dev/shm`. Trocado pelo **kvmfr**, um módulo
de kernel que expõe a mesma memória como `/dev/kvmfr0` e deixa o cliente importar o
frame direto na GPU. O log passa a dizer `Using DMA buffer support`.

`vm/kvmfr.sh` compila o módulo pelo DKMS a partir do mesmo fonte do cliente dev, grava
`static_size_mb=128`, a regra de udev e o `/dev/kvmfr0` na `cgroup_device_acl` do
`qemu.conf` — sem essa última linha o QEMU não abre o dispositivo e a VM não sobe.

**Se a VM subir antes do módulo carregar**, o QEMU cria `/dev/kvmfr0` como arquivo
comum. Desligue a VM, apague o arquivo, carregue o módulo e confira que ele voltou como
dispositivo de caractere (`crw-`).

### 3. O mouse não ficava dentro do jogo

O cliente não tinha arquivo de configuração nenhum, então rodava só com os padrões e
nunca prendia o ponteiro. `looking-glass/.config/looking-glass/client.ini` liga
`input:captureOnFocus` e `input:autoCapture`: com a janela em foco o ponteiro fica
travado nela e não escapa mais para a outra tela.

E `input:grabKeyboard` fica **desligado** de propósito. Ligado, o cliente pede o
inibidor de atalhos do Wayland e o Hyprland entrega o teclado inteiro — aí `SUPER+3` e
`Alt+Tab` morrem e só o Scroll Lock tira você de lá. Desligado, o compositor continua
dono dos atalhos dele e sair do jogo para o RCode é uma tecla, como em qualquer janela.
O Windows perde só as combinações que o Hyprland usa.

### 4. O compositor redesenhava o que não precisava

- `general:allow_tearing` ligado e `immediate` na regra da janela do Looking Glass.
- Blur, sombra, arredondamento e borda fora dessa janela, para o compositor poder
  mandar o buffer direto para a tela.
- `misc:vrr = 2`, taxa variável só em tela cheia.
- `cursor:no_hardware_cursors` de volta para `false`. Estava ligado por causa do host
  NVIDIA que não existe mais; na AMD ele obrigava uma recomposição inteira a cada
  movimento do mouse.

### 5. AVIC

`options kvm_amd avic=1` em `/etc/modprobe.d/kvm.conf`, escrito pelo `preparar.sh`. O
AVIC entrega interrupção direto ao vCPU sem sair para o hipervisor. O perfil já trazia
`<avic state="on"/>` no bloco `hyperv`, que é o que deixa o SynIC conviver com ele.

Para conferir que não ficou inibido, com a VM subindo:

```sh
sudo bash -c 'cd /sys/kernel/tracing; echo kvm:kvm_apicv_inhibit_changed > set_event; echo 1 > tracing_on'
```

A última linha tem que terminar em `inhibits=0x0`. O IOMMU AVIC (interrupção de
dispositivo) **não** existe nesta placa-mãe: o bit `GASup` de
`/sys/class/iommu/ivhd*/amd-iommu/features` vem zerado.

## Pré-requisitos na máquina

- `amd_iommu=on iommu=pt` no `arch.conf`
- Hooks do libvirt em `/etc/libvirt/hooks/qemu.d/w11/`, instalados pelo `preparar.sh`
- Grupo IOMMU 16 com só a 3090 e o áudio dela

### A rota de recuperação que não existia

A versão antiga deste arquivo dizia que o `arch-fallback.conf` ficava sem os parâmetros da
nvidia, de propósito, como rota de fuga. **Era falso:** os dois arquivos são idênticos, então
os dois bootariam sem tela do mesmo jeito. Quem resolve é `module_blacklist=vfio_pci`, que
vale mesmo com o módulo dentro do initramfs — e é o que a entrada **`Arch Linux (zen, sem
vfio)`** carrega. Ela é criada pelo `vfio-ativar.sh`, junto com o vfio, na hora certa.

## O que sai do repo, e só depois do vfio provado

| Item | Quando |
|:--|:--|
| `hl.env` `LIBVA_DRIVER_NAME` / `__GLX_VENDOR_LIBRARY_NAME` / `NVD_BACKEND` | etapa 5 — com o host em amdgpu, apontar pra nvidia quebra a aceleração de vídeo |
| `kernel-nvidia` (`packages.txt:30`) | depois da etapa 6 provada |
| `configure_nvidia()` (`install.sh:295`) | idem |
| autostart `nvidia-performance.sh` | idem |
| `custom/gpu` da waybar (chama `nvidia-smi`) | idem |

**Não remover antes:** é o caminho de volta. O `nvidia-open-dkms` vale manter instalado por
semanas mesmo com o vfio ativo — o `softdep` impede que ele carregue, e tirar o
`/etc/modprobe.d/vfio.conf` + `mkinitcpio -P` devolve a 3090 pro host.

## Pegadinhas

- **`bin/monitor.sh` sai != 0** quando a tela não está presente. É o que o `ExecCondition` do
  `ricepanel.service` usa: com o vertical desligado a unit é pulada limpa, senão o painel
  subiria em fullscreen por cima do monitor principal.
- **A guarda do `vfio-ativar.sh` exige `amdgpu` em uso**, não só duas GPUs contadas. Uma
  RX 550 enumerada e sem driver passava na guarda velha e deixaria o host sem tela no boot
  seguinte.
- **O `start.sh` do hook aborta pela mesma razão**, se o `amdgpu` não estiver desenhando.
