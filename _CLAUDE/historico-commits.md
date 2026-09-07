# Commits de 07/09/2026, do mais velho pro mais novo

```
5d682834  kde: qt6-tools faltando derrubava painel, wallpaper e tema (causa raiz do KDE pela metade)
47b81371  install: reinstalar reaplica o layout (apaga a marca que sobrevivia em /home)
25438b9d  packages: hyprland-qtutils virou hyprland-guiutils
6013892b  install: aplica o layout na sessao atual, sem esperar o login
679794fa  install: mkinitcpio e bandeja C++ so rodam quando ha o que fazer
f3710038  monitores: disposicao aplicada sozinha por kscreen-doctor
76ac8c1b  stow: uma pasta por programa; Hyprland sai inteiro
5733315d  monitores: chave por conector; README com o hardware das duas GPUs
a558e5ae  pacotes do stow na raiz do repo
be27ffea  lib32 e multilib saem
488ae580  README: KDE Plasma e so
b44cd8f8  Alt+Tab com preview ao vivo (hyprexpose patchado), workspace com dono, atalhos do i3
```

O `b44cd8f8` juntou duas frentes de trabalho no mesmo dia e por isso e grande. Dele saiu a
pasta `pacotes/`: o hyprexpose e compilado aqui com patch proprio, nao vem do AUR.

Antes desses, `87d8acbe` removeu o KDE e `e8093449` reverteu -- ele mudou de ideia, ficou
no KDE. `d9526f81` tirou Wine/Steam/jogos do host: jogo e assunto da VM.

