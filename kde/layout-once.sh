#!/usr/bin/env bash
# Primeiro login depois do install: roda o setup.sh e instala o tema. Grava a marca so se
# tudo passar; se falhar, tenta de novo no login seguinte.
marca="$HOME/.config/.kde-layout-aplicado"
[[ -e $marca ]] && exit 0
logdir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
mkdir -p "$logdir"
log="$logdir/layout-once.log"
exec > >(tee -a "$log") 2>&1
printf '== %s kde-layout-once\n' "$(date '+%d/%m/%Y %H:%M:%S')"

setup="$HOME/.dotfiles/setup.sh"
falhas=0

# Estas nao falam com o plasmashell, entao rodam antes do portao abaixo.
bash "$setup" links home kde energia monitores || falhas=$((falhas+1))

if ! command -v qdbus6 >/dev/null 2>&1; then
    printf 'qdbus6 ausente (pacote qt6-tools): painel, wallpaper e tema nao serao aplicados\n' >&2
    exit 1
fi

plasma_vivo=0
for _ in $(seq 1 90); do
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && { plasma_vivo=1; break; }
    sleep 1
done
if [[ $plasma_vivo -eq 0 ]]; then
    printf 'plasmashell nao respondeu em 90s, abortando sem marcar como aplicado\n' >&2
    exit 1
fi

bash "$setup" wallpaper || falhas=$((falhas+1))

# O tema vem de vendor/windows-modern; nada de clone nem da lib do upstream.
tema="$HOME/.dotfiles/kde/tema-instalar.sh"
if [[ -f $tema ]]; then
    printf 'aplicando Windows Modern (dark)\n'
    bash "$tema" || { printf 'tema-instalar.sh falhou\n'; falhas=$((falhas+1)); }
    sleep 2
    systemctl --user restart plasma-plasmashell.service || true
    for _ in $(seq 1 60); do
        qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && break
        sleep 1
    done
    sleep 3
else
    printf 'tema-instalar.sh ausente, caindo pro Breeze Dark\n'
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop >/dev/null 2>&1 || true
    plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
fi

# O look-and-feel do Windows Modern sobrescreve cores, tema do Plasma e decoracao; o Dream
# entra por cima dele, sempre depois.
bash "$HOME/.dotfiles/kde/layan.sh" || falhas=$((falhas+1))

# Depois do tema: o look-and-feel devolve o painel ao padrao toda vez que e aplicado.
bash "$setup" painel recarregar || falhas=$((falhas+1))

if [[ $falhas -eq 0 ]]; then
    touch "$marca"
else
    printf '%d etapa(s) falharam, sem marcar como aplicado: roda de novo no proximo login\n' "$falhas" >&2
fi
printf 'fim\n'
