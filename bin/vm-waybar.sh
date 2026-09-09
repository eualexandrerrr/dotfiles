#!/usr/bin/env bash
# Indicador e menu de controle da VM w11 (Windows) para a waybar.
# Uso: sem argumento imprime o JSON; "menu" abre o fuzzel com as acoes.
set -uo pipefail

VM_DIR="$HOME/.dotfiles/vm"
ICONE_DESLIGADA=$''
ICONE_LIGADA=$''

menu() {
    local escolha
    escolha="$(printf '%s\n' "Ligar · 3090 (jogo)" "Ligar · janela (SPICE)" "Reiniciar" "Desligar" "Forçar desligar" \
        | fuzzel --dmenu --prompt "VM w11 > ")"
    case "$escolha" in
        "Ligar · 3090 (jogo)") exec "$VM_DIR/w11" 3090 ;;
        "Ligar · janela (SPICE)") exec "$VM_DIR/w11" janela ;;
        "Reiniciar") exec "$VM_DIR/w11" reiniciar ;;
        "Desligar") exec "$VM_DIR/w11" desligar ;;
        "Forçar desligar") exec "$VM_DIR/w11" forcar-desligar ;;
    esac
}

case "${1:-}" in
    menu) menu ;;
    *)
        info="$("$VM_DIR/w11" perfil 2>/dev/null)"
        if [[ $info == *"estado: running"* ]]; then
            [[ $info == perfil:\ 3090* ]] && detalhe="passthrough 3090" || detalhe="janela SPICE"
            printf '{"text":"%s","tooltip":"VM w11 rodando — %s — clique pro menu","class":"rodando"}\n' "$ICONE_LIGADA" "$detalhe"
        else
            printf '{"text":"%s","tooltip":"VM w11 desligada — clique pro menu","class":"desligada"}\n' "$ICONE_DESLIGADA"
        fi
        ;;
esac
