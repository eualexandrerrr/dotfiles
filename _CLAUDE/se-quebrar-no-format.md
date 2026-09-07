# Se algo quebrar no format

Ordem de suspeita:

1. `~/kde-layout-once.log` diz qual etapa falhou
2. estado velho em `/home` (ver tabela de particoes)
3. `ls -la ~/.config | grep '\->'` mostra o que esta linkado e pra onde; link que aponta pra
   `links/` ou `stow/` e resto de esquema antigo
4. `kscreen-doctor -o` pra ver se os nomes dos conectores batem com o `monitores.conf`

Repo remoto: `github.com/eualexandrerrr/dotfiles`, branch `main`.

