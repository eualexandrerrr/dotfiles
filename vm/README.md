# VM w11 — Windows 11 com passthrough da RTX 3090

Não fica em `links/`: o `install.sh` symlinka `links/config/*` para `~/.config/`, e
`~/.config/libvirt` é o diretório do libvirt **de sessão do usuário**. Esta VM vive no
libvirt **de sistema** (`qemu:///system`), então um symlink ali só criaria confusão entre
os dois. Aqui é fonte de verdade versionada; aplicar é explícito.

## Dois perfis, um domínio

`w11-3090.xml` é o passthrough (tela no monitor da 3090, host sem tela). `w11-janela.xml` é vídeo
emulado + SPICE numa janela do KDE, sem 3D: serve para instalar/ajustar o Windows, **não roda RedM**.
O script `w11` faz o `define` do perfil escolhido e liga: `w11 janela`, `w11 3090`, `w11 perfil`, `w11 desligar`.

Os hooks do libvirt olham o XML que recebem no stdin e só mexem na GPU se houver `hostdev` PCI.
Sem essa checagem (versão antiga dos hooks) o perfil janela também derruba a tela do host.

## Restaurar

```sh
sudo virsh -c qemu:///system define ~/.dotfiles/vm/w11-3090.xml
```

O disco (`/var/lib/libvirt/images/w11.qcow2`) **não** está versionado — são centenas de GB.
Recriar vazio: `sudo qemu-img create -f qcow2 /var/lib/libvirt/images/w11.qcow2 200G`.

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

Os dois monitores estão na mesma 3090 (`DP-1` = ASUS XG27ACS, `DP-2` = LG UltraGear).
No passthrough a placa inteira vai para a VM, então o **Windows** recebe as duas telas e
escolhe sozinho qual é a principal — trocar os cabos não decide isso, e ainda embaralharia
o layout do KDE, que é gravado por saída.

Ajuste **dentro do Windows**, uma vez só (fica gravado no registro dele):
Configurações → Sistema → Vídeo → clicar no ASUS → **"Tornar este meu vídeo principal"**.
Melhor ainda: **"Mostrar somente em 1"** (o ASUS), assim o LG fica preto e o RedM não tem
como abrir na tela errada nem o mouse escapar para ela.

## A volta para o KDE

O `sddm` está com **login automático** (`install.sh`, `configure_sddm`): a volta cai direto
no Plasma, sem senha. `Relogin=false` limita isso à primeira subida do sddm — ligar o PC e
voltar da VM. Sair da sessão na mão ainda cai no greeter com senha, e `Meta+L` continua
bloqueando normalmente.

Os apps, esses **morrem mesmo**: para soltar a 3090 o hook precisa derrubar a sessão
(`loginctl terminate-user`), e com uma GPU só não há como o host continuar desenhando.
O restore nativo do Plasma não resolve — em Wayland o `ksmserver` salva zero clientes
(no 6.7.4, `saveCurrentSession` grava `count=0`), porque não existe o protocolo de
gerenciamento de sessão que havia no X11.

Então o `w11 3090` anota a lista antes de ligar, a partir dos scopes do systemd
(`app-<desktop-id>-<pid>.scope`, que é como o Plasma lança cada aplicativo), em
`~/.local/state/w11-apps`. No login de volta, `vm/reabrir-apps.sh` (autostart do KDE)
reabre cada um e consome a lista — num boot normal o arquivo não existe e ele sai calado.
Os apps reabrem vazios do ponto de vista do Plasma; quem restaura conteúdo é cada um por
si (o Chrome com "continuar de onde parou", o VS Code com as janelas anteriores).

## Limitação conhecida

Com **uma GPU só** não há Alt-Tab entre Linux e VM: enquanto a VM roda, o host fica sem
placa para desenhar. Alternar exige uma segunda GPU (mesmo básica) e o Looking Glass.
Ver `plano-c-vypr` no RedMLinux.
