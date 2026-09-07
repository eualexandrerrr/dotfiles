# CLAUDE.md

Contexto pra continuar o trabalho neste repo. Leia inteiro antes de mexer.

## Quem e o que

Xande (`eualexandrerrr`), dev Lua/JS, dono do servidor MichiganRoleplay (RedM). Esta e a
maquina de desenvolvimento dele, Arch Linux com KDE Plasma em Wayland. O repo e a
pos-instalacao: pacotes, driver, KDE, servicos e os arquivos de configuracao que valem
versionar, cada um no seu pacote, linkado pelo GNU Stow.

Comunicacao em portugues do Brasil, direto, sem enrolacao. Ele odeia comentario em codigo
novo: mantem so os que ja existem, nunca adiciona. Em troubleshooting, um comando por vez
e espera o resultado antes do proximo. Commits e pushes saem no nome dele, sem co-autor e
sem mencionar Claude na mensagem.

## O que esta acontecendo agora

Ele vai **formatar** e reinstalar pelo instalador proprio (`github.com/eualexandrerrr/myarch`,
opcao 3 da ISO clona este repo e roda o `install.sh`). O objetivo e o KDE sair configurado
inteiro de primeira: tema, painel, wallpaper, monitores, tudo sem toque manual. Hoje ja
foram 14 commits corrigindo o que impedia isso; a lista esta no fim.

Amanha chega hardware novo (ver "Hardware") e a maquina vira duas GPUs com passthrough.
**Isso e a fase seguinte**, nao mexer ainda: o `kernel-nvidia` do `packages.txt` e o
`configure_nvidia()` do install continuam valendo ate a placa nova estar montada.

## Particoes: o que sobrevive ao format

O instalador do myarch preserva por rotulo GPT (`KEEP_LABELS="Files Alexandre HOME"`) e
apaga so o que nao esta na lista. Na pratica:

Conferido no disco em 07/09/2026 (`lsblk`, `/etc/fstab` e o `install.sh` do myarch):

| Particao | Rotulo | FS | Montagem | Sobrevive? |
|:--|:--|:--|:--|:--|
| nvme0n1p1 | EFI | FAT32 | `/boot` | nao, recriada |
| nvme0n1p2 | ROOT | ext4 | `/` (100 GB) | nao, Arch limpo a cada format |
| nvme0n1p3 | **Files** | ext4 | `/home` (830 GB) | **sim** |

Nao ha particao NTFS nem `/mnt/dados` nesta maquina. `Files` **e** a `/home`, ext4 -- o
myarch trata `Alexandre` e `HOME` como rotulos legados da mesma particao (linhas 21-22 do
install.sh dele). O `DADOS_LABEL="Files"` com `DADOS_MOUNT="/home"` e a preservada e montada
em `/mnt/home` antes do `genfstab`, entao entra no fstab novo sozinha.

O usuario novo nasce com o **mesmo UID/GID** (o myarch le o `stat -c %u` de `/home/Alexandre`
antes do `useradd`). Sem isso o home preservado apareceria como de outra pessoa.

O ponto que muda tudo: **`/home` sobrevive, entao a reinstalacao nunca e limpa do lado do
KDE.** Tudo que o Plasma gravou em `~/.config` e `~/.local/share` continua la. Isso e o
que fazia "reinstalei e o KDE ficou pela metade":

- a marca `~/.config/.kde-layout-aplicado` sobrevivia e o `layout-once.sh` saia na primeira
  linha sem aplicar nada -- corrigido, o `configure_kde_defaults()` apaga a marca
- symlinks do esquema antigo (`links/`) sobreviviam e o stow recusava -- corrigido, o
  `backup_conflict()` reconhece link pro repo que nao resolve mais e remove
- `~/.local/share/kscreen/` (disposicao dos monitores) sobrevive; o `monitores.sh` aplica por
  cima via `kscreen-doctor`, entao tende a vencer, mas se der estranho e daqui
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc` (estado do painel) sobrevive; quem
  cuida dele e o `kde/painel-ajustar.sh`, que e idempotente

Se algo de KDE parecer "sujo" depois do format, a suspeita numero um e estado velho em
`/home`, nao o repo.

O que sobrevive por estar em `/home`, alem do KDE: o perfil do Chrome
(`~/.config/google-chrome`, 4,8 GB) com as sessoes logadas, o `~/.gitconfig` (pacote `git`),
o token do `gh` (`~/.config/gh/hosts.yml`) e as chaves ssh.

Os cookies do Chrome sao `v10`, ou seja, backend `basic`: chave embutida no proprio Chrome,
nao no keyring. Nao ha kwalletd nem gnome-keyring nesta maquina. Consequencia pratica: o
perfil e autossuficiente, continua logado depois do format e **nao** depende da senha de
login continuar a mesma. Se um dia um keyring entrar em cena os cookies viram `v11` e passam
a depender dele -- ai essa garantia cai.

A imagem da VM Windows vai em `/home` tambem (`~/vms/win.raw`, raw pre-alocado), pelo mesmo
motivo: sobrevive ao format e o ext4 tem journal. NTFS via ntfs3 foi descartado pra isso.

## Estrutura do repo

Pacotes do stow na raiz, um por programa, espelhando o `$HOME`. Ferramenta em pasta propria.
O `install.sh` distingue sozinho: pacote e a pasta que tem entrada com ponto na raiz.

```
zsh ghostty kwin plasma dolphin powerdevil autostart apps git xdg   <- pacotes, viram links no $HOME
kde        scripts e decisoes do Plasma (settings.conf, monitores.conf, layout-once...)
segredos   credenciais cifradas com age; chave so no pendrive do Ventoy
bin        comandos
vm         VM Windows com passthrough (XML do libvirt, hooks)
vendor     tema Windows Modern, versionado
wallpaper  paisagem (principal) e retrato (vertical)
```

Stow roda com `--no-folding --restow`. O `--no-folding` e obrigatorio: sem ele o stow linka
diretorio inteiro e o KDE/Chrome gravam dentro do repo.

O desktop e **KDE Plasma e so**. Hyprland entrou e saiu hoje; nao volta como sessao
alternativa nem como nada.

## install.sh x setup.sh

`install.sh` instala (pacotes, driver, servicos, SDDM). `setup.sh` configura e recarrega,
sem rede e em segundos. Mexeu numa config? `setup.sh`. Mexeu no `packages.txt`? `install.sh`.

```
~/.dotfiles/setup.sh [etapa...]   # links home kde energia monitores wallpaper painel recarregar
```

O `install.sh` (etapa `home_enxuta`) e o `layout-once.sh` chamam o `setup.sh` em vez de
repetir as etapas. Etapa que falha vira aviso e as outras seguem.

## DNS e KWallet

O DNS do roteador levava 161 ms sem cache contra 23-26 ms dos publicos -- era a lentidao da
conexao. `bin/dns-rapido.sh` mede com subdominio aleatorio (dominio popular responde do
cache e engana), escolhe os dois mais rapidos de operadores diferentes e aplica no
NetworkManager, com `ipv6.ignore-auto-dns` pro DNS IPv6 do provedor nao anular a escolha.
Roda a cada logon (`autostart/.../dns-rapido.desktop`), sem sudo: o polkit ja deixa a
sessao local mexer na conexao. Log em `~/dns-rapido.log`.

KWallet fica desligado por quatro caminhos, porque o `Enabled=false` sozinho nao segura:
o `kwalletd6` e o `ksecretd` voltavam pelo PAM, pelo autostart e pela ativacao D-Bus. Os
`.service` de D-Bus sao sobrepostos em `~/.local/share` (precedencia sobre `/usr/share`). Efeito colateral que importa: sem keyring, o Chrome usa o backend
`basic` (cookies `v10`), entao o perfil sobrevive ao format sem depender da senha de login.
Ligar o KWallet passaria pra `v11` e criaria essa dependencia.

O painel nunca vai na tela vertical -- o `painel-ajustar.sh` remove por **geometria**
(altura > largura), nao por indice de tela, que muda quando o kscreen reordena as saidas.

## Pendencias conhecidas do KDE

- **Dolphin nao persiste modo de visao**: Ctrl+3 (detalhes) funciona ao vivo, mas o Dolphin
  desta maquina nao grava view_properties (global nem por pasta, symlink ou arquivo real,
  fechando por SIGTERM/janela/Ctrl+Q; permissoes ok; sem `[$i]`). O `.directory` global e lido
  para tudo MENOS `ViewMode`. Nao insistir em tentativa e erro; olhar o codigo do Dolphin.
- O cursor `Windows-modern-dark-cursors` do tema nunca existiu no disco; usamos Fluent-dark.
- Menu iniciar do Windows Modern: Locais vem de `rightColumnItems` (config do plasmoid), nao
  dos XDG dirs -- mudar XDG nao muda o menu.

## Energia: nunca dorme

Nunca suspende, nunca hiberna, nunca desliga sozinha -- so por pedido explicito. A unica
coisa que a inatividade faz e apagar os monitores em 5 min. Tres camadas (`kde/energia.sh`):
PowerDevil, alvos do systemd **mascarados** e `IdleAction=ignore` no logind. So a do KDE nao
seguraria um `systemctl suspend`; com os alvos mascarados ele responde "Access denied".

## Fluxo do install e o que conferir

```
bash ~/.dotfiles/install.sh
```

15 etapas. Rodando de TTY (caso do format), a 15 diz "sem sessao do Plasma agora, o
layout entra no proximo login" -- **isso e o caminho certo**, nao erro. No primeiro login o
autostart chama `kde/layout-once.sh`, que faz nesta ordem: monitores, wallpaper, tema,
reinicia o plasmashell, painel. So grava a marca se nenhuma etapa falhar; se falhar, tenta
de novo no login seguinte.

Depois de logar, a unica coisa a olhar:

```
cat ~/kde-layout-once.log
```

Rodando de dentro do Plasma, a etapa 15 aplica na hora, sem deslogar.

Tempos: primeira rodada paga `mkinitcpio` (~25s) e a compilacao da bandeja em C++ (~30s).
Da segunda em diante as duas sao puladas quando nada mudou; a bandeja compara sha256 do
fonte, nao mtime, porque `git clone` carimba tudo com a hora do clone.

## Monitores

ASUS XG27ACS **2560x1440@180** (principal) e LG UltraGear **1920x1080@144** (vertical).
O LG aceita 2560x1440, mas escalado e a 75 Hz -- sempre o modo nativo. Principal em paisagem a direita; secundario em pe a esquerda, ocupado em
tela cheia pelo `RicePanel` (`~/Apps/desktop/RicePanel`). O vertical girado ocupa
1080 de largura (1920 girado), por isso o principal comeca em x=1080.

`kde/monitores.conf`, casado por **nome de conector** porque os dois sao iguais e resolucao
nao separa:

```
DP-2|1920x1080|left|0,0|1|nao
DP-1|2560x1440|normal|1080,240|1|sim
```

Nomes confirmados na maquina: DP-2 e o LG UltraGear (o vertical), DP-1 e o ASUS XG27ACS
(o principal). `*` na primeira coluna e curinga por resolucao nativa, pra quando trocar de
placa e os nomes mudarem.

Nao editar o conf a mao: arrasta as telas em Configuracoes do Sistema e roda
`bash ~/.dotfiles/kde/monitores.sh --capturar`, que grava a sessao atual por cima do conf.

O `monitores.sh` roda **antes** do `wallpaper.sh` de proposito: o wallpaper decide retrato
x paisagem pela geometria de cada tela.

Nunca versionar `~/.local/share/kscreen/`: e um arquivo por combinacao de monitores, nome
derivado do hash dos EDIDs, quebra ao trocar cabo ou placa.

## Home enxuta

Ele nao quer as pastas padrao do Linux. A home fica assim, e so assim:

```
~/Claude          central de conhecimento (repo privado eualexandrerrr/Claude)
~/Obisidian       vault Cerebro (repo privado, o nome tem o typo mesmo)
~/Downloads       unico XDG que sobrevive: destino do navegador
~/<Projeto>       cada projeto no topo: MichiganRoleplay, MeuEscolarApp, Utils...
```

Projeto novo vai na **raiz da home**, nunca numa pasta `Projetos/` intermediaria -- os
caminhos em `~/.claude.json` ja seguem isso.

Duas pecas sustentam: o pacote `xdg` do stow linka o `user-dirs.dirs` (tudo aponta pro
proprio `$HOME`, menos Downloads) e o `user-dirs.conf` com `enabled=False`, que impede o
`xdg-user-dirs-update` de recriar a cada login. A etapa `home_enxuta()` do install remove
o que ja tiver nascido -- **so se estiver vazio**, senao avisa e mantem.

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
host, Looking Glass pra ver o RedM numa janela do KDE. Nessa hora `kernel-nvidia` sai do
`packages.txt`, `configure_nvidia()` sai do install e entra o bind do vfio. Os XMLs em `vm/`
ja existem e vao precisar dos IDs/enderecos novos.

## Commits de hoje, do mais velho pro mais novo

```
5d682834  kde: qt6-tools faltando derrubava painel, wallpaper e tema (causa raiz do KDE pela metade)
47b81371  install: reinstalar reaplica o layout (apaga a marca que sobrevivia em /home)
25438b9d  packages: hyprland-qtutils virou hyprland-guiutils
6013892b  install: aplica o layout na sessao atual, sem esperar o login
679794fa  install: mkinitcpio e bandeja C++ so rodam quando ha o que fazer
f3710038  monitores: disposicao aplicada sozinha por kscreen-doctor
76ac8c1b  stow: uma pasta por programa; Hyprland sai inteiro
5733315d  monitores: chave por conector; README com o hardware das duas GPUs
a558e5ae  pacotes do stow na raiz do repo
be27ffea  lib32 e multilib saem
488ae580  README: KDE Plasma e so
```

Antes desses, `87d8acbe` removeu o KDE e `e8093449` reverteu -- ele mudou de ideia, ficou
no KDE. `d9526f81` tirou Wine/Steam/jogos do host: jogo e assunto da VM.

## Se algo quebrar no format

Ordem de suspeita:

1. `~/kde-layout-once.log` diz qual etapa falhou
2. estado velho em `/home` (ver tabela de particoes)
3. `ls -la ~/.config | grep '\->'` mostra o que esta linkado e pra onde; link que aponta pra
   `links/` ou `stow/` e resto de esquema antigo
4. `kscreen-doctor -o` pra ver se os nomes dos conectores batem com o `monitores.conf`

Repo remoto: `github.com/eualexandrerrr/dotfiles`, branch `main`.
