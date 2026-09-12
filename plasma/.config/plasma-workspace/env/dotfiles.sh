#!/bin/sh
# O Plasma faz source de tudo que estiver em ~/.config/plasma-workspace/env/ no inicio da
# sessao. O conteudo em si nao mora mais aqui: quem gera e a etapa `graficos` do setup.sh,
# em ~/.config/environment.d/50-dotfiles.conf, que vale nos quatro desktops. Este arquivo
# so garante o mesmo env quando a sessao do Plasma nasce fora do systemd --user, que e o
# unico caso em que o environment.d nao e lido.

_dotfiles_env="${XDG_CONFIG_HOME:-$HOME/.config}/environment.d/50-dotfiles.conf"
if [ -r "$_dotfiles_env" ]; then
    set -a
    . "$_dotfiles_env"
    set +a
fi
unset _dotfiles_env
