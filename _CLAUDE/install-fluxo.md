# Fluxo do install e o que conferir

```
bash ~/.dotfiles/install.sh
```

15 etapas. Rodando de TTY (caso do format), a 15 diz "sem sessao do Plasma agora, o
layout entra no proximo login" -- **isso e o caminho certo**, nao erro. No primeiro login o
autostart chama `kde/layout-once.sh`, que faz nesta ordem: monitores, wallpaper, tema,
reinicia o plasmashell, painel. So grava a marca se nenhuma etapa falhar; se falhar, tenta
de novo no login seguinte.

Depois de logar, a unica coisa a olhar:

```
cat ~/kde-layout-once.log
```

Rodando de dentro do Plasma, a etapa 15 aplica na hora, sem deslogar.

Tempos: primeira rodada paga `mkinitcpio` (~25s) e a compilacao da bandeja em C++ (~30s).
Da segunda em diante as duas sao puladas quando nada mudou; a bandeja compara sha256 do
fonte, nao mtime, porque `git clone` carimba tudo com a hora do clone.

