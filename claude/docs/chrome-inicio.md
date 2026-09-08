# Chrome: pagina inicial e workspace

## Onde fica

`inicio/.local/share/inicio/index.html` -- pacote stow proprio, cai em
`~/.local/share/inicio/index.html`. HTML e CSS puros, sem build e sem rede: fonte Inter e
JetBrainsMono do sistema, tema Catppuccin Mocha, relogio, saudacao por hora, campo que busca
no Google e doze atalhos.

Os atalhos nao foram chutados: sairam do `History` do proprio perfil do Chrome, ordenados por
`visit_count` (YouTube, Discord, GitHub, Michigan Admin, Live Console, CentralCart, Gmail,
CFXBot, MeuEscolar, RedM, App Store Connect, Claude).

## Como o Chrome e obrigado a abrir nela

Politica gerenciada em `/etc/opt/chrome/policies/managed/inicio.json`, escrita pela etapa
`chrome` do `setup.sh`:

```
~/.dotfiles/setup.sh chrome
```

Ela grava `HomepageLocation`, `NewTabPageLocation` e `RestoreOnStartup: 4` apontando para o
`file://`. Como `/etc` **nao** sobrevive ao format, a etapa precisa rodar de novo depois de
reinstalar -- por isso ela esta no `setup.sh` e nao foi feita na mao.

O Chrome so le a politica ao subir: depois de mudar, feche todas as janelas dele.

## Workspace

Desde 08/09/2026 o Chrome mora na **workspace 1** (ver `hyprland.md`), e o `eventos.lua`
garante que ele nunca fique fechado: sumiu a ultima janela, ele volta sozinho na pagina
inicial, com carencia de 10 s e trava no `hyprland.shutdown`.
