# Fluxo do install e o que conferir

```
bash ~/.dotfiles/install.sh
```

15 etapas. Rodando de TTY (caso do format), a 15 diz "sem sessao do Plasma agora, o
layout entra no proximo login" -- **isso e o caminho certo**, nao erro. No primeiro login o
autostart chama `kde/layout-once.sh`, que faz nesta ordem: monitores, wallpaper, tema,
reinicia o plasmashell, painel. So grava a marca se nenhuma etapa falhar; se falhar, tenta
de novo no login seguinte.

A ordem dentro do `layout-once.sh` importa e ja mordeu uma vez: o `layan.sh` aplica o
look-and-feel do Layan, que **traz a decoracao Aurorae junto e sobrescreve o Klassy**. Como
ele roda depois do `setup kde`, o `klassy.sh` chamado la dentro nao sobrevivia -- o format
devolvia a decoracao do Layan e os botoes de janela voltavam ao padrao. Por isso o
`klassy.sh` e chamado de novo, logo depois do `layan.sh`, e tem que continuar sendo o
ultimo a mexer em `org.kde.kdecoration2`.

As etapas `icones` e `audio` tambem nao rodavam em lugar nenhum: nao estao no `install.sh`
nem estavam na chamada do `layout-once.sh`, so existiam pra quem rodasse o `setup.sh` na
mao. Entraram na primeira linha do layout-once. O `dns` ja vinha pelo autostart proprio e o
`login` pelo `install.sh`.

Depois de logar, a unica coisa a olhar:

```
cat ~/kde-layout-once.log
```

Rodando de dentro do Plasma, a etapa 15 aplica na hora, sem deslogar.

Tempos: primeira rodada paga `mkinitcpio` (~25s) e a compilacao da bandeja em C++ (~30s).
Da segunda em diante as duas sao puladas quando nada mudou; a bandeja compara sha256 do
fonte, nao mtime, porque `git clone` carimba tudo com a hora do clone.

