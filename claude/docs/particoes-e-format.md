# Particoes: o que sobrevive ao format

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

O ponto que muda tudo: **`/home` sobrevive, entao a reinstalacao nunca e limpa.** Tudo que
ficou em `~/.config` e `~/.local/share` continua la, inclusive lixo do KDE de antes de
07/09/2026:

- symlinks do esquema antigo (`links/`, e agora tambem `plasma/`, `kwin/`, `powerdevil/`,
  `dolphin/`, `dbus/`) sobrevivem e o stow recusa -- o `backup_conflict()` reconhece link
  pro repo que nao resolve mais e remove
- `~/.config/plasma*`, `~/.config/kdeglobals`, `~/.local/share/kscreen/` e
  `~/.config/autostart/*kde*` sao restos inertes: nada os le mais, mas confundem quem for
  depurar. Podem ser apagados sem medo
- o Hyprland nao tem equivalente disso: a configuracao inteira e arquivo versionado, entao
  nao existe "estado que sobreviveu e venceu o repo"

Se algo parecer "sujo" depois do format, a suspeita numero um continua sendo estado velho em
`/home`, nao o repo.

O que sobrevive por estar em `/home`: o perfil do Chrome
(`~/.config/google-chrome`, 4,8 GB) com as sessoes logadas, o `~/.gitconfig` (pacote `git`),
o token do `gh` (`~/.config/gh/hosts.yml`) e as chaves ssh.

Os cookies do Chrome sao `v10`, ou seja, backend `basic`: chave embutida no proprio Chrome,
nao no keyring. Nao ha keyring nenhum nesta maquina, e isso e deliberado (ver `dns-e-keyring.md`). Consequencia pratica: o
perfil e autossuficiente, continua logado depois do format e **nao** depende da senha de
login continuar a mesma. Se um dia um keyring entrar em cena os cookies viram `v11` e passam
a depender dele -- ai essa garantia cai.

A imagem da VM Windows vai em `/home` tambem (`~/vms/win.raw`, raw pre-alocado), pelo mesmo
motivo: sobrevive ao format e o ext4 tem journal. NTFS via ntfs3 foi descartado pra isso.


## O `restaurar.sh` que comia a `~/.config` (corrigido em 07/09/2026)

Sintoma: depois do format, Chrome deslogado, Discord/RCode/Code/RicePanel sem config e o
`claude` sem projects nem plugins -- **com a `/home` intacta**, o que nao fazia sentido.

Causa: `segredos/restaurar.sh` extraia o `segredos.tar.age` num tmp e movia o **primeiro
nivel** do tar para o `$HOME`, com backup carimbado do que estivesse no caminho. Mas a
`lista.txt` tem caminhos aninhados (`.config/gh/hosts.yml`, `.claude/.credentials.json`),
entao o primeiro nivel do tar e `.config` e `.claude` -- pastas com **um arquivo dentro**.
Cada rodada do install renomeava a `~/.config` inteira para `.config.bak-<carimbo>` e punha
no lugar aquela casca. Rodou tres vezes (21:02, 21:15, 21:19), o que explicava a `.config`
"nova" que os apps recriaram do zero.

O script hoje extrai o tar **direto no `$HOME`**, arquivo por arquivo: diretorio existente
e mesclado, so os arquivos listados sao sobrescritos, e os substituidos vao para um tar
unico em `~/.local/state/dotfiles/segredos-anteriores-<carimbo>.tar.gz` em vez de espalhar
`.bak-` pela home. Ele tambem recusa o pacote se alguma entrada for caminho absoluto ou
tiver `..`.

**Regra que fica:** restaurar credencial e operacao de *arquivo*. Qualquer coisa que mova
diretorio no `$HOME` esta errada -- a `/home` sobrevive ao format justamente para nao
precisar disso.

Os `.bak-*`/`.pos-format-*` que sobrarem sao copias completas e ocupam GB. Conferir antes de
apagar: `du -sh ~/.config.* ~/.claude.* ~/.ssh.*`.
