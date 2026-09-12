#!/usr/bin/env bash
# Shell NAnDoroid (na-ive/nandoroid-shell) por cima do Hyprland, configurado como desktop de
# janelas: tudo flutuante, sem workspace nenhum.
#
#   ~/.dotfiles/bin/nandoroid.sh          clona/atualiza, copia as configs e escreve a do Hyprland
#   ~/.dotfiles/bin/nandoroid.sh estado   diz o que existe e o que falta
#
# O instalador oficial deles e interativo (escolhe caminho, pergunta sobre fontes, terminal,
# canal de update) e por isso nao serve pra uma instalacao automatizada. Aqui o repo e
# clonado direto e so os arquivos que importam sao copiados; os pacotes vem do
# packages/nandoroid.txt, que o install.sh ja instalou antes desta etapa.
#
# A config do Hyprland deles e em Lua, nao no formato antigo. O hyprland.lua gerado aqui
# carrega os modulos deles na ordem original e acrescenta o configs/janelas.lua por ultimo,
# que e o unico arquivo nosso: e dele que sai o comportamento de janela solta.
set -uo pipefail

REPO="${NANDOROID_REPO:-https://github.com/na-ive/nandoroid-shell.git}"
DIR="$HOME/Apps/desktop/nandoroid-shell"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

log()  { printf '\n==> %s\n' "$*"; }
ok()   { printf '  ok %s\n' "$*"; }
warn() { printf '  !! %s\n' "$*"; }
die()  { printf '  erro: %s\n' "$*" >&2; exit 1; }

clonar_ou_atualizar() {
    if [[ -d "$DIR/.git" ]]; then
        git -C "$DIR" pull --ff-only >/dev/null 2>&1 && ok "$DIR atualizado" \
            || warn "git pull nao aplicou, seguindo com o que esta no disco"
        return 0
    fi
    mkdir -p "$(dirname "$DIR")"
    git clone --depth 1 "$REPO" "$DIR" || die "git clone de $REPO falhou"
    ok "$DIR clonado"
}

copiar_configs() {
    [[ -d "$DIR/dotfiles/.config/quickshell/nandoroid" ]] || die "o repo nao tem dotfiles/.config/quickshell/nandoroid"

    mkdir -p "$CFG/quickshell" "$CFG/hypr/configs" "$CFG/hypr/hyprlock"

    # O shell e os templates de cor. cp -r por cima nao apaga o que o usuario salvou nas
    # configuracoes do proprio shell, que grava em arquivo separado.
    cp -r "$DIR/dotfiles/.config/quickshell/nandoroid" "$CFG/quickshell/"
    cp -r "$DIR/dotfiles/.config/matugen" "$CFG/"
    cp -r "$DIR/dotfiles/.config/hypr/nandoroid" "$CFG/hypr/"
    ok "shell, matugen e os binds do nandoroid em $CFG"

    # Base do Hyprland: os modulos deles, menos o keybinds, que tem os atalhos de workspace.
    local f
    for f in theme.lua hypridle.conf hyprlock.conf; do
        [[ -f "$DIR/extras/hypr/$f" ]] && cp "$DIR/extras/hypr/$f" "$CFG/hypr/$f"
    done
    cp -r "$DIR/extras/hypr/hyprlock/." "$CFG/hypr/hyprlock/" 2>/dev/null
    for f in env execs general rules keybinds; do
        [[ -f "$DIR/extras/hypr/configs/$f.lua" ]] && cp "$DIR/extras/hypr/configs/$f.lua" "$CFG/hypr/configs/$f.lua"
    done
    ok "base do Hyprland copiada"

    # O starship.toml deles nao entra: esse arquivo e versionado neste repo, no pacote zsh.
    if [[ -f "$DIR/extras/kitty/kitty.conf" && ! -f "$CFG/kitty/kitty.conf" ]]; then
        mkdir -p "$CFG/kitty"
        cp "$DIR/extras/kitty/kitty.conf" "$CFG/kitty/kitty.conf"
        ok "kitty.conf deles (nao havia um aqui)"
    fi
}

escrever_config_janelas() {
    cat > "$CFG/hypr/configs/janelas.lua" <<'LUA'
-- Gerado por ~/.dotfiles/bin/nandoroid.sh -- reescrito a cada execucao, nao edite aqui.
--
-- O Hyprland e tiling e o NAnDoroid assume isso. Aqui ele vira um desktop de janelas: toda
-- janela nasce flutuante e centralizada, e nao existe workspace nenhum pra trocar.

-- --- Toda janela flutuante ---
-- Vem depois do rules.lua deles de proposito: as regras de dialogo e de painel ja passaram,
-- e esta aqui pega o resto sem desfazer aquelas.
hl.window_rule({ match = { class = "^(.*)$" }, float = 1, center = 1 })

-- Sem gaps: com tudo flutuante eles so empurrariam a janela pra dentro da tela.
hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        layout = "dwindle"
    }
})

-- --- Fim dos workspaces ---
-- O keybinds.lua deles cria SUPER+1..0 e SUPER+SHIFT+1..0. Sem tirar isso, um toque em
-- SUPER+2 leva pra um workspace vazio e parece que a sessao sumiu.
for i = 1, 9 do
    hl.unbind("SUPER + " .. tostring(i))
    hl.unbind("SUPER + SHIFT + " .. tostring(i))
end
hl.unbind("SUPER + 0")
hl.unbind("SUPER + SHIFT + 0")

-- Mover janela por direcao tambem sai: em layout flutuante quem move e o mouse, e o bind
-- atrapalha o uso normal das setas.
hl.unbind("SUPER + SHIFT + Left")
hl.unbind("SUPER + SHIFT + Right")
hl.unbind("SUPER + SHIFT + Up")
hl.unbind("SUPER + SHIFT + Down")

-- Split e pseudotile sao conceito de tiling, nao existe janela pra dividir aqui.
hl.unbind("SUPER + P")
hl.unbind("SUPER + J")

-- --- Alternar janelas ---
-- cyclenext e bringactivetotop nao tem dispatcher proprio na API Lua, entao vao por hyprctl.
-- Os dois num --batch so: dois hl.bind na mesma tecla e o segundo pode simplesmente
-- substituir o primeiro, e ai a janela ganharia foco sem vir pra frente.
hl.bind("ALT + Tab", hl.dsp.exec_cmd("hyprctl --batch 'dispatch cyclenext ; dispatch bringactivetotop'"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("hyprctl --batch 'dispatch cyclenext prev ; dispatch bringactivetotop'"))

-- Maximizar e restaurar. Os dois estao no keybinds.lua deles como foco por direcao, que em
-- janela flutuante nao serve pra nada -- por isso o unbind antes.
hl.unbind("SUPER + Up")
hl.unbind("SUPER + Down")
hl.bind("SUPER + Up", hl.dsp.window.fullscreen("maximize"))
hl.bind("SUPER + Down", hl.dsp.window.float({ action = "toggle" }))
LUA
    ok "$CFG/hypr/configs/janelas.lua"

    cat > "$CFG/hypr/hyprland.lua" <<'LUA'
-- Gerado por ~/.dotfiles/bin/nandoroid.sh -- reescrito a cada execucao, nao edite aqui.
-- Pra configuracao propria, crie configs/local.lua: ele e carregado por ultimo, se existir.

require("configs/env")
require("configs/execs")
require("configs/general")
require("configs/rules")
require("configs/keybinds")

require("nandoroid/nandoroid")
require("nandoroid/user_persistence")

-- Depois do nandoroid: e ele quem desfaz e refaz binds, e o que vale aqui e a ultima palavra.
require("configs/janelas")

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1"
})

pcall(require, "configs/local")
LUA
    ok "$CFG/hypr/hyprland.lua"
}

instalar() {
    command -v hyprctl >/dev/null 2>&1 || die "hyprland nao instalado -- veja packages/nandoroid.txt"
    command -v quickshell >/dev/null 2>&1 || warn "quickshell ausente: o shell nao sobe ate instalar quickshell-git do AUR"
    command -v matugen >/dev/null 2>&1 || warn "matugen ausente: o tema nao segue a cor do papel de parede"

    log "shell NAnDoroid"
    clonar_ou_atualizar
    copiar_configs
    escrever_config_janelas
    ok "pronto -- entre na sessao Hyprland e o shell sobe junto"
}

estado() {
    printf 'repo       %s\n' "$([[ -d $DIR/.git ]] && echo "$DIR" || echo 'FALTA clonar')"
    printf 'quickshell %s\n' "$(command -v quickshell || echo FALTA)"
    printf 'matugen    %s\n' "$(command -v matugen || echo FALTA)"
    printf 'shell      %s\n' "$([[ -d $CFG/quickshell/nandoroid ]] && echo "$CFG/quickshell/nandoroid" || echo FALTA)"
    printf 'hyprland   %s\n' "$([[ -f $CFG/hypr/hyprland.lua ]] && echo "$CFG/hypr/hyprland.lua" || echo FALTA)"
}

case "${1:-instalar}" in
    instalar) instalar ;;
    estado)   estado ;;
    *) die "uso: nandoroid.sh [instalar|estado]" ;;
esac
