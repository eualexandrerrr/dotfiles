# DNS e KWallet

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

