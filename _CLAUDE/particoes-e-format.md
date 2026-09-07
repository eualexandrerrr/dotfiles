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

