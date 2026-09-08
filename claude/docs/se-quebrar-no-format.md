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
