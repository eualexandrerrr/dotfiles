# Home enxuta

Ele nao quer as pastas padrao do Linux. A home fica assim, e so assim:

```
~/Claude          central de conhecimento (repo privado eualexandrerrr/Claude)
~/Obisidian       vault Cerebro (repo privado, o nome tem o typo mesmo)
~/Downloads       unico XDG que sobrevive: destino do navegador
~/<Projeto>       cada projeto no topo: MichiganRoleplay, MeuEscolarApp, Utils...
```

Projeto novo vai na **raiz da home**, nunca numa pasta `Projetos/` intermediaria -- os
caminhos em `~/.claude.json` ja seguem isso.

Duas pecas sustentam: o pacote `xdg` do stow linka o `user-dirs.dirs` (tudo aponta pro
proprio `$HOME`, menos Downloads) e o `user-dirs.conf` com `enabled=False`, que impede o
`xdg-user-dirs-update` de recriar a cada login. A etapa `home_enxuta()` do install remove
o que ja tiver nascido -- **so se estiver vazio**, senao avisa e mantem.

