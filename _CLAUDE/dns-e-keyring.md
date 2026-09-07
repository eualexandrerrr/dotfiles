# DNS e keyring

O DNS do roteador levava 161 ms sem cache contra 23-26 ms dos publicos -- era a lentidao da
conexao. `bin/dns-rapido.sh` mede com subdominio aleatorio (dominio popular responde do
cache e engana), escolhe os dois mais rapidos de operadores diferentes e aplica no
NetworkManager, com `ipv6.ignore-auto-dns` pro DNS IPv6 do provedor nao anular a escolha.
Roda a cada login (`exec-once` do `hyprland.conf`), sem sudo: o polkit ja deixa a sessao
local mexer na conexao. Log em `~/dns-rapido.log`.

## Keyring: nao instalar nenhum

No KDE, o KWallet ficava desligado por quatro caminhos (`Enabled=false` nao segurava: ele
voltava pelo PAM, pelo autostart e pela ativacao D-Bus). Com o KDE fora, todos os quatro
sumiram junto -- e **o estado desejado virou o padrao natural**.

O efeito que importa continua igual: **sem keyring, o Chrome usa o backend `basic`**
(cookies `v10`), entao o perfil sobrevive ao format sem depender da senha de login. Instalar
`gnome-keyring` passaria os cookies pra `v11` e criaria essa dependencia -- por isso ele
**nao esta** no `packages.txt`, e nao deve entrar por conveniencia de nenhum app.

Se algum programa reclamar de Secret Service, a resposta e configurar o programa, nao
instalar um keyring.

O `ricepanel.service` ja sobe o Electron com `--password-store=basic` pelo mesmo motivo.

A waybar e o RicePanel nunca dividem tela: o painel e do monitor vertical (workspace 9), a
barra so do `DP-1` (`"output": ["DP-1"]` no `config.jsonc`).
