#!/usr/bin/env bash
# Alt+Tab igual ao do Windows 11: tocar e soltar ja pula pra ultima janela usada. Com
# `reverso`, anda pra tras (Alt+Shift+Tab).
#
# **E o modo `simple`, sem GUI, de proposito.** Com `hyprswitch gui ... && hyprswitch
# dispatch` existe uma corrida perdida: o `gui` abre a lista com a janela ATUAL selecionada
# e o `--close mod-key-release` confirma no release do Alt. Quem toca e solta rapido solta
# antes do `dispatch` avancar a selecao, a lista fecha na janela em que ja estava e a troca
# nunca acontece -- que era a queixa de "dou Alt+Tab e nao vai". O `simple` nao tem janela
# nem selecao: decide e troca em ~4 ms, entao nao ha o que perder a corrida.
#
# `--sort-recent` e a ordem de uso recente (MRU), a mesma do Windows: o alvo do primeiro
# Tab e sempre a janela anterior, nao a vizinha na tela.
set -uo pipefail

[[ ${1:-} == reverso ]] && exec hyprswitch simple --sort-recent true --reverse
exec hyprswitch simple --sort-recent true
