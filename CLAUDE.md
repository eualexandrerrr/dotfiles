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

| Particao | FS | Montagem | Sobrevive? | Consequencia |
|:--|:--|:--|:--|:--|
| EFI | FAT32 | `/boot` | nao | recriada |
| ROOT | ext4 | `/` | nao | Arch limpo a cada format |
| HOME | ext4 | `/home` | **sim** | `~/.config` e `~/.local` **persistem** |
| Files | NTFS | `/mnt/dados` | **sim** | o `D:` do Windows, dados dele |

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

A imagem da VM Windows vai em `/home` tambem (`~/vms/win.raw`, raw pre-alocado), pelo mesmo
motivo: sobrevive ao format e o ext4 tem journal. NTFS via ntfs3 foi descartado pra isso.

## Estrutura do repo

Pacotes do stow na raiz, um por programa, espelhando o `$HOME`. Ferramenta em pasta propria.
O `install.sh` distingue sozinho: pacote e a pasta que tem entrada com ponto na raiz.

```
zsh ghostty kwin plasma dolphin powerdevil autostart apps git   <- pacotes, viram links no $HOME
kde        scripts e decisoes do Plasma (settings.conf, monitores.conf, layout-once...)
bin        comandos
vm         VM Windows com passthrough (XML do libvirt, hooks)
vendor     tema Windows Modern, versionado
wallpaper  paisagem (principal) e retrato (vertical)
```

Stow roda com `--no-folding --restow`. O `--no-folding` e obrigatorio: sem ele o stow linka
diretorio inteiro e o KDE/Chrome gravam dentro do repo.

O desktop e **KDE Plasma e so**. Hyprland entrou e saiu hoje; nao volta como sessao
alternativa nem como nada.

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

Dois **2560x1440**. Principal em paisagem a direita; secundario em pe a esquerda, ocupado em
tela cheia pelo `widget-claude` (painel de widgets, repo `Utils`). O vertical girado ocupa
1440 de largura, por isso o principal comeca em x=1440.

`kde/monitores.conf`, casado por **nome de conector** porque os dois sao iguais e resolucao
nao separa:

```
DP-2|2560x1440|left|0,0|1|nao
DP-1|2560x1440|normal|1440,581|1|sim
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

## Hardware

| Peca | Modelo |
|:--|:--|
| CPU | Ryzen 7 5700X, sem video integrado |
| Placa atual | Gigabyte B450M Gaming (1 x16 + 2 x1) |
| Placa nova (chega amanha) | ASUS TUF Gaming B550M-PLUS (x16 Gen4 CPU + x16 Gen3 em x4 chipset) |
| GPU | Gainward RTX 3090 24GB, cooler de 2,7 slots |
| GPU do host (chega amanha) | PCYes Radeon RX 550 4GB |
| Riser (chega amanha) | PCIe 3.0 x16, 20cm, plugue 90 graus |
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
