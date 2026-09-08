# Se algo quebrar no format

Ordem de suspeita:

1. `Hyprland --verify-config` (roda sem subir sessao, diz `config ok`) e, ja logado,
   `hyprctl configerrors` -- linha invalida e ignorada em silencio, a sessao sobe torta
2. `cat ~/.local/state/dotfiles/install.log` diz qual etapa do install falhou
3. estado velho em `/home` (ver tabela de particoes)
4. `ls -la ~/.config | grep '\->'` mostra o que esta linkado e pra onde; link que aponta pra
   `links/`, `stow/`, `plasma/` ou `kwin/` e resto de esquema antigo -- apagar
5. `hyprctl monitors` pra ver se os nomes dos conectores batem com o `monitores.lua`

## Tela preta ao logar

Sessao errada no SDDM. Tem que ser **Hyprland (uwsm)**, nao "Hyprland" puro -- ver
`claude/docs/hyprland.md`. Conferir com
`grep Session /etc/sddm.conf.d/10-dotfiles.conf` (esperado: `hyprland-uwsm.desktop`).

## RicePanel nao sobe

`systemctl --user status ricepanel.service`. Se estiver inativo, quase sempre e o
`graphical-session.target` que nao ativou -- de novo, sessao sem uwsm.

## Sem barra

`waybar` nao roda em TTY. Dentro da sessao: `pkill waybar; uwsm app -- waybar` e ler o erro
que ela cospe (JSON invalido no `config.jsonc` derruba ela inteira).

Repo remoto: `github.com/eualexandrerrr/dotfiles`, branch `main`.

## Apps sem configuracao, Chrome deslogado

Olhar `ls -d ~/.config.bak-* ~/.claude.bak-*` **antes** de qualquer coisa. Se existirem, a
config nao se perdeu: ela foi movida. Era o bug do `segredos/restaurar.sh` (ver
`particoes-e-format.md`); o backup mais antigo e o bom. Fechar os apps, trocar o diretorio
de volta e rodar `setup.sh links recarregar`.

## Sem barra, Alt+Tab vazio, sem notificacao -- tudo junto

Sintoma coletivo de conector renumerado. Nada disso e config errada: os wrappers de `bin/`
resolvem o monitor pela marca, entao o que falhou foi a marca nao bater. Conferir com
`bin/monitor.sh principal` -- se sair vazio, comparar `hyprctl monitors -j` com o
`hypr/.config/hypr/telas.lua`.

## Boot cai em modo de emergencia: "Failed to start File System Check"

Aconteceu em 08/09/2026 com o `/home` (`nvme0n1p3`, label Files) depois de um desligamento
no botao de power. O `systemd-fsck` do boot roda `fsck -a`: ele conserta o trivial, mas se
recusa a mexer em bitmap de bloco/inode divergente e sai com codigo 4. Dai `home.mount`
falha, `local-fs.target` falha e a sessao nunca sobe -- o `hyprland.lua` "cannot open" e
consequencia, nao causa: sem `/home` nao existe `~/.config/hypr/`.

Reparo, com a particao desmontada (emergencia ja deixa ela assim; se nao, bootar pela ISO):

```
e2fsck -fn /dev/nvme0n1p3   # so olha
e2fsck -fy /dev/nvme0n1p3   # repara
```

Rodar de novo depois: se os cinco passos passarem sem apontar erro, ficou limpo.

A etapa `configure_resiliencia_boot` do `install.sh` previne a repeticao com tres camadas:

- `fsck.repair=yes` na cmdline -- o boot passa a rodar `fsck -y` e conserta sozinho em vez
  de cair em emergencia. E a unica das tres que resolve o sintoma exato acima.
- `kernel.sysrq = 1` em `/etc/sysctl.d/99-sysrq.conf` -- com a sessao travada, **REISUB**
  (Alt+SysRq, uma tecla por vez, ~1s entre elas) sincroniza e desmonta antes de reiniciar.
  Segurar o botao de power e o que suja o filesystem; REISUB nao suja.
- `tune2fs -e remount-ro` nas ext4 -- ao primeiro erro o kernel remonta somente-leitura em
  vez de continuar escrevendo por cima da corrupcao.

Conferir se estao valendo: `grep -o fsck.repair=yes /proc/cmdline`, `cat /proc/sys/kernel/sysrq`
(quer `1`) e `sudo tune2fs -l /dev/nvme0n1p3 | grep -i "errors behavior"` (quer `Remount read-only`).

Se o erro voltar **depois** do reparo, nao e desligamento sujo: e UUID errado no `/etc/fstab`
ou o disco indo embora. Comparar `lsblk -f` com o `fstab` e olhar `sudo smartctl -a /dev/nvme0n1`.

## Compartilhar tela parou de funcionar do nada

Quase sempre e o `xdg-desktop-portal` orfao. Ele abre uma conexao com o PipeWire no
inicio da sessao e nao reconecta se o PipeWire reiniciar por baixo dele -- no log aparece
`Caught PipeWire error: connection error` e o screencast fica morto ate o fim da sessao.
Acontece sempre que alguem roda `systemctl --user restart pipewire`. Conserto:

```
systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal
```

Ordem importa: o `-hyprland` primeiro, o generico depois.
