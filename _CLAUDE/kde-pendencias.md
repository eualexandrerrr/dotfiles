# Pendencias conhecidas do KDE

- **Dolphin nao persiste modo de visao**: Ctrl+3 (detalhes) funciona ao vivo, mas o Dolphin
  desta maquina nao grava view_properties (global nem por pasta, symlink ou arquivo real,
  fechando por SIGTERM/janela/Ctrl+Q; permissoes ok; sem `[$i]`). O `.directory` global e lido
  para tudo MENOS `ViewMode`. Nao insistir em tentativa e erro; olhar o codigo do Dolphin.
- O cursor `Windows-modern-dark-cursors` do tema nunca existiu no disco; usamos Fluent-dark.
- Menu iniciar do Windows Modern: Locais vem de `rightColumnItems` (config do plasmoid), nao
  dos XDG dirs -- mudar XDG nao muda o menu.

