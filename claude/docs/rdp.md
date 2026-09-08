# RDP: acesso ao servidor Windows

Cliente: **FreeRDP 3** (`freerdp`, binários `sdl-freerdp3`, `xfreerdp3`, `wlfreerdp3`) mais o
**Remmina** como GUI para quando quiser gerenciar vários hosts. Ambos no `packages.txt`,
seção `[repo-oficial:apps]`.

Servidor conferido em 08/09/2026: `191.96.81.142:3389`, Windows Server 2025 Standard
Evaluation, usuário `Administrator`. A 40120 do mesmo IP é a porta do RedM, não do RDP.

## Como conectar

```
~/.dotfiles/bin/rdp.sh                 # janela, resolução dinâmica
~/.dotfiles/bin/rdp.sh --tela-cheia    # /f
~/.dotfiles/bin/rdp.sh --editar        # abre o arquivo de credenciais no $EDITOR
```

Também aparece no lançador como "RDP Michigan" (`apps/.local/share/applications/rdp-michigan.desktop`).

O script escolhe o primeiro cliente que existir, nesta ordem: `sdl-freerdp3` (SDL3, Wayland
nativo, é o que roda hoje), `xfreerdp3` (Xwayland), `wlfreerdp3`. Force outro com
`RDP_CLIENTE=xfreerdp3 bin/rdp.sh`.

A janela nasce na **workspace 4**, a mesma do `virt-manager` e do `looking-glass-client`
(regra `vm-na-4` em `hypr/.config/hypr/regras.lua`), e entra na regra `sempre-solido` -- sem
a transparência global de 0.96, que embaralha texto de terminal remoto.

## Onde a senha mora

`~/.config/rdp/michigan.env`, pasta `700` e arquivo `600`, **fora do repo** -- o dotfiles é
público. Formato:

```
RDP_HOST=191.96.81.142
RDP_PORT=3389
RDP_USER=Administrator
RDP_PASS='...'
```

A senha nunca vai para a linha de comando: o script manda por `stdin` com `/from-stdin`, então
não aparece no `ps`. Por isso o `--testar` com `/auth-only` foi removido -- naquele modo o
FreeRDP exige a senha antes de ler o stdin e responde
`auth-only, but no password set`.

## Por que sobrevive ao format

Dois níveis:

1. `/home` é a partição `Files` e é preservada pelo instalador do myarch (ver
   `particoes-e-format.md`), então `~/.config/rdp` continua lá depois de reinstalar.
2. `.config/rdp` entrou no `segredos/lista.txt`, ou seja, o `segredos/guardar.sh` cifra a
   pasta com `age` dentro do `segredos.tar.age` no repo **privado**. É a rede de proteção
   para o caso de a `/home` se perder de vez. Rodar depois de mudar a senha:

```
~/.dotfiles/segredos/guardar.sh     # precisa do pendrive Ventoy com a chave
```

Não há keyring nesta máquina e isso é deliberado (`dns-e-keyring.md`), então o par
"arquivo 600 + backup cifrado com age" é o padrão da casa, não um atalho.

## Ruído esperado no log

```
[ERROR][com.winpr.sspi.Kerberos] - krb5_init_creds_get (Client 'Administrator@ATHENA.MIT.EDU' not found in Kerberos database
```

Cosmético. O `krb5.conf` padrão do Arch aponta para o realm de exemplo do MIT; o FreeRDP
tenta Kerberos, falha e cai para NTLM, que é o que o servidor usa. A conexão sobe normal.

O certificado é aceito por `/cert:tofu` (confia na primeira vez e grava a impressão digital em
`~/.config/freerdp/known_hosts`). Se a impressão mudar sem você ter reinstalado o servidor,
desconfie em vez de apagar o arquivo.
