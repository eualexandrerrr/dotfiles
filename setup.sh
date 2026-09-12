#!/usr/bin/env bash
# Reconfigura e recarrega os dotfiles. NAO instala pacote nenhum -- isso e o install.sh.
#
#   ~/.dotfiles/setup.sh                  tudo
#   ~/.dotfiles/setup.sh links chrome     so as etapas citadas
#   ~/.dotfiles/setup.sh --lista          mostra as etapas
#
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
export DOTFILES_DIR

GRN=$'\e[32m'; YEL=$'\e[33m'; BLU=$'\e[34m'; END=$'\e[0m'
FALHAS=()
N=0
TOTAL=0

log()   { N=$((N+1)); printf '\n%s==>%s [%d/%d] %s\n' "$BLU" "$END" "$N" "$TOTAL" "$*"; }
ok()    { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
falha() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*" >&2; FALHAS+=("$*"); }

# Desktop escolhido no install.sh. Sem o arquivo, kde: era o unico desktop que existia
# antes desta divisao, e e o unico com configuracao versionada aqui.
DEFILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/de"
DE="${DE:-}"
# `$( ... && <arquivo )` so redireciona, nao imprime nada: ate 11/09/2026 isso deixava o
# setup.sh achando que o desktop era kde em qualquer maquina, inclusive com gnome gravado.
[[ -z $DE && -f $DEFILE ]] && DE="$(<"$DEFILE")"
DE="${DE//[[:space:]]/}"
DE="${DE:-kde}"

# Etapas que so fazem sentido no Plasma: mexem em kwriteconfig6, plasmashell, KWin ou
# Aurorae. Em outro desktop elas nao falham -- sao puladas com aviso.
ETAPAS_KDE=(arquivos atalhos notificacoes painel tema)

etapa_e_de_kde() {
    local e
    for e in "${ETAPAS_KDE[@]}"; do [[ $1 == "$e" ]] && return 0; done
    return 1
}

etapa_links() {
    log "links do stow"
    command -v stow >/dev/null 2>&1 || { falha "stow nao instalado"; return; }
    local pkg nome n=0
    for pkg in "$DOTFILES_DIR"/*/; do
        nome="$(basename "$pkg")"
        [[ $nome == .git ]] && continue
        # plasma/ e config de KDE: linkar isso em GNOME/XFCE/Hyprland so suja a home.
        [[ $nome == plasma && $DE != kde ]] && continue
        find "$pkg" -mindepth 1 -maxdepth 1 -name '.*' -print -quit 2>/dev/null | grep -q . || continue
        if stow --no-folding --restow --target="$HOME" --dir="$DOTFILES_DIR" "$nome" 2>/dev/null; then
            n=$((n+1))
        else
            falha "stow recusou o pacote $nome"
        fi
    done
    ok "$n pacote(s) relinkado(s)"
}

etapa_home() {
    log "home enxuta"
    local removidas=0 d
    for d in Documentos Imagens Modelos "Músicas" "Público" "Vídeos" "Área de trabalho" \
             Documents Pictures Templates Music Public Videos Desktop; do
        [[ -d "$HOME/$d" ]] || continue
        [[ -f "$HOME/$d/.directory" && $(find "$HOME/$d" -mindepth 1 | wc -l) -eq 1 ]] && rm -f "$HOME/$d/.directory"
        rmdir "$HOME/$d" 2>/dev/null && removidas=$((removidas+1)) || falha "$d nao esta vazia, mantida"
    done
    mkdir -p "$HOME/Downloads" "$HOME/.local/share/desktop"

    ok "$removidas pasta(s) padrao removida(s)"
}

etapa_perfil() {
    log "avatar do usuario"
    local origem="$DOTFILES_DIR/profile/avatar.png"
    [[ -f $origem ]] || { falha "profile/avatar.png ausente"; return; }
    install -m 644 "$origem" "$HOME/.face"
    ok "~/.face (sddm e tela de bloqueio do Plasma)"
}

etapa_energia() {
    log "energia: nunca dormir, monitores em 5 min"
    bash "$DOTFILES_DIR/bin/power.sh" || falha "power.sh"

    # O power.sh cuida do lado systemd, que vale em qualquer desktop; daqui pra baixo e
    # Plasma (kscreenlocker e powerdevil), entao so roda no KDE.
    if [[ $DE == kde ]] && command -v kwriteconfig6 >/dev/null 2>&1; then
        # A tela nunca trava sozinha no meio do trabalho -- Meta+L continua travando a mao.
        kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
        kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume false
        ok "bloqueio automatico de tela desligado"

        if [[ -f $DOTFILES_DIR/state/powermanagementprofilesrc && \
              ! -f $HOME/.config/powermanagementprofilesrc ]]; then
            cp "$DOTFILES_DIR/state/powermanagementprofilesrc" "$HOME/.config/" \
                && ok "perfil de energia do Plasma restaurado"
        fi
    fi
}

etapa_atalhos() {
    log "atalhos de teclado do Plasma"
    # Nao entra no stow: o KDE reescreve o kglobalshortcutsrc sozinho quando um atalho muda,
    # e o symlink faria isso sujar o repo. O arquivo do repo e semente, nao espelho -- pra
    # atualizar a semente depois de mexer nos atalhos, copie a mao por cima do de plasma/estado.
    local semente="$DOTFILES_DIR/state/kglobalshortcutsrc"
    [[ -f $semente ]] || { falha "sem semente de atalhos no repo"; return; }

    if [[ -f $HOME/.config/kglobalshortcutsrc ]]; then
        ok "atalhos ja existem, semente do repo nao aplicada por cima"
    else
        cp "$semente" "$HOME/.config/kglobalshortcutsrc" \
            && ok "atalhos restaurados do repo" \
            || falha "nao consegui restaurar os atalhos"
    fi
}

etapa_audio() {
    log "audio: saida analogica 80%, HDMI 50%, mic 80%"
    bash "$DOTFILES_DIR/bin/audio.sh" || falha "audio.sh"
}

etapa_dns() {
    log "DNS mais rapido"
    local sh="$DOTFILES_DIR/bin/dns-fastest.sh"
    [[ -x $sh ]] || { falha "dns-fastest.sh ausente"; return; }
    bash "$sh" || falha "dns-fastest.sh"
}

etapa_chrome() {
    log "Chrome: handler de link"

    # Link vindo de fora (Discord, RCode, terminal) tem de cair como aba na janela que ja
    # existe. Sem declarar http/https aqui, cada app resolve o handler por conta e algum
    # deles acaba abrindo janela nova.
    if command -v xdg-mime >/dev/null 2>&1; then
        local esquema
        for esquema in x-scheme-handler/http x-scheme-handler/https x-scheme-handler/about x-scheme-handler/unknown text/html application/xhtml+xml; do
            xdg-mime default google-chrome.desktop "$esquema" 2>/dev/null
        done
        xdg-settings set default-web-browser google-chrome.desktop 2>/dev/null
        ok "links abrem em aba do Chrome"
    else
        falha "xdg-mime nao instalado"
    fi

    # A pagina inicial customizada saiu em 09/09/2026: a politica gerenciada some junto, senao
    # o Chrome continua forcando um file:// que nao existe mais.
    local politica="/etc/opt/chrome/policies/managed/inicio.json"
    if [[ -f $politica ]]; then
        sudo rm -f "$politica" && ok "politica de pagina inicial removida"
    fi

    # A politica que forcava o enhanced-h264ify saiu em 10/09/2026: prendia o YouTube em
    # H.264, que nao tem 1440p, e o video ficava upscalado num monitor de 1440p. Trocar
    # nitidez por CPU tem que ser escolha na hora, pelo popup da extensao -- nao politica.
    local extensoes="/etc/opt/chrome/policies/managed/extensoes.json"
    if [[ -f $extensoes ]]; then
        sudo rm -f "$extensoes" && ok "politica de extensoes removida (h264ify nao e mais forcado)"
    fi
}

# Extensao que nao existe no Open VSX: baixa o .vsix do marketplace da Microsoft (uso pessoal)
# pra ~/.cache/dotfiles/vsix e instala do arquivo. O cache sobrevive ao format.
vsix_marketplace() {
    local id="$1" pub="${1%%.*}" nome="${1#*.}" dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/vsix"
    mkdir -p "$dir"
    [[ -s $dir/$id.vsix ]] || curl -fsSL --compressed -o "$dir/$id.vsix" \
        "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$pub/vsextensions/$nome/latest/vspackage" 2>/dev/null \
        || { rm -f "$dir/$id.vsix"; return 1; }
    code --install-extension "$dir/$id.vsix" >/dev/null 2>&1
}

etapa_vscode() {
    log "VS Code: pacote code-rcode do fork, extensoes"

    # O editor e o Code - OSS compilado do fork privado eualexandrerrr/vscode (branch rcode),
    # como pacote code-rcode -- modelo dos forks do COSMIC, so que o produto e um pacote do
    # pacman em vez de um binario em ~/.local/bin. So recompila quando a branch mudou.
    bash "$DOTFILES_DIR/bin/vscode-build.sh" || falha "vscode-build.sh falhou"
    command -v code >/dev/null 2>&1 || { falha "code nao instalado, extensoes ficam pra depois"; return; }

    # settings.json e argv.json vem pelo stow (pacote vscode/). As extensoes vem do Open VSX,
    # uma por linha em vscode/extensions.txt; instala so o que falta.
    local instaladas faltam=0 ext
    instaladas="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    while IFS= read -r ext; do
        [[ -z $ext || $ext == \#* ]] && continue
        grep -qx "${ext,,}" <<<"$instaladas" && continue
        if code --install-extension "$ext" >/dev/null 2>&1 || vsix_marketplace "$ext"; then
            faltam=$((faltam+1))
        else
            falha "extensao $ext nao instalou (nem Open VSX, nem .vsix do marketplace)"
        fi
    done <"$DOTFILES_DIR/vscode/extensions.txt"
    ok "$faltam extensao(oes) instalada(s), o resto ja estava"

    # Um lancador por projeto no menu, abrindo o .code-workspace de ~/Workspaces.
    bash "$DOTFILES_DIR/bin/vscode-workspaces.sh" || falha "vscode-workspaces.sh falhou"
}

etapa_claude() {
    log "settings do Claude Code"
    # A pasta mora no repo PRIVADO ~/Claude, nunca aqui: skills, comandos e settings sao
    # material dele, e este repositorio e publico. Sem o clone, a etapa avisa e segue.
    local fonte="${CLAUDE_CENTRAL:-$HOME/Claude/maquina}"
    local base="$fonte/settings.json"
    local destino="$HOME/.claude/settings.json"
    if [[ ! -d $fonte ]]; then
        falha "$fonte nao existe -- git clone git@github.com:eualexandrerrr/Claude.git ~/Claude"
        return
    fi
    [[ -f $base ]] || { falha "$base nao existe"; return; }
    command -v jq >/dev/null 2>&1 || { falha "jq nao instalado"; return; }
    mkdir -p "$HOME/.claude"
    [[ -f $destino ]] || printf '{}\n' >"$destino"
    local tmp
    tmp="$(mktemp)"
    # Merge, nunca substituicao: o Claude Code grava escolhas dele nesse arquivo (tema,
    # modelo) e um cp por cima apagaria tudo isso a cada setup.
    if jq -s '.[0] * .[1]' "$destino" "$base" >"$tmp" && [[ -s $tmp ]]; then
        mv "$tmp" "$destino"
        ok "remote control ligado no boot, chaves do repo aplicadas"
    else
        rm -f "$tmp"
        falha "merge do settings.json do Claude falhou"
    fi

    # Autorais dele: memoria global, statusline, comandos e skills proprias. Nao entram no
    # stow porque o ~/.claude e escrito pelo proprio Claude Code o tempo todo -- um symlink
    # ali some no primeiro save atomico. Copia por cima, que e o que o repo manda.
    local item
    for item in CLAUDE.md statusline.js mcp-doctor.js commands skills bin docs; do
        [[ -e "$fonte/$item" ]] || continue
        cp -a "$fonte/$item" "$HOME/.claude/" 2>/dev/null \
            && ok "~/.claude/$item" \
            || falha "~/.claude/$item nao copiado"
    done
}

CONSOLE_TIRAR=(quiet nvidia_drm.fbdev=1 nvidia_drm.fbdev=0 loglevel=3 rd.udev.log_level=3)
CONSOLE_POR=(
    fbcon=nodefer
    vt.global_cursor_default=0
    systemd.show_status=yes
    systemd.status_unit_format=name
    vt.default_red=0x1e,0xf3,0xa6,0xf9,0x89,0xf5,0x94,0xba,0x58,0xf3,0xa6,0xf9,0x89,0xf5,0x94,0xa6
    vt.default_grn=0x1e,0x8b,0xe3,0xe2,0xb4,0xc2,0xe2,0xc2,0x5b,0x8b,0xe3,0xe2,0xb4,0xc2,0xe2,0xad
    vt.default_blu=0x2e,0xa8,0xa1,0xaf,0xfa,0xe7,0xd5,0xde,0x70,0xa8,0xa1,0xaf,0xfa,0xe7,0xd5,0xc8
)

console_cmdline() {
    local entry antes depois p n=0
    sudo test -d /boot/loader/entries || { falha "systemd-boot nao encontrado; ajuste a cmdline na mao"; return; }
    while IFS= read -r entry; do
        antes="$(sudo grep -m1 -E '^options ' "$entry" 2>/dev/null)"
        [[ -n $antes ]] || continue
        depois=" $antes "
        for p in "${CONSOLE_TIRAR[@]}"; do depois="${depois// $p / }"; done
        for p in "${CONSOLE_POR[@]}"; do [[ $depois == *" $p "* ]] || depois="$depois$p "; done
        depois="$(printf '%s' "$depois" | tr -s ' ')"
        depois="${depois# }"; depois="${depois% }"
        [[ $depois == "$antes" ]] && continue
        sudo cp -f "$entry" "$entry.bak"
        sudo awk -v nova="$depois" '/^options /{print nova; next}{print}' "$entry" \
            | sudo tee "$entry.novo" >/dev/null && sudo mv -f "$entry.novo" "$entry" \
            && n=$((n+1))
    done < <(sudo find /boot/loader/entries -maxdepth 1 -name '*.conf' 2>/dev/null)
    if (( n )); then
        ok "cmdline ajustada em $n entrada(s), backup em .bak (vale no proximo boot)"
    else
        ok "cmdline ja correta"
    fi
}

etapa_console() {
    log "console do boot"

    local fonte='' f
    for f in ter-132b ter-124b ter-118b; do
        compgen -G "/usr/share/kbd/consolefonts/$f.psf*" >/dev/null && { fonte=$f; break; }
    done
    if [[ -n $fonte ]]; then
        local keymap
        keymap="$(sed -n 's/^KEYMAP=//p' /etc/vconsole.conf 2>/dev/null | head -1)"
        printf 'KEYMAP=%s\nFONT=%s\n' "${keymap:-br-abnt2}" "$fonte" \
            | sudo tee /etc/vconsole.conf >/dev/null \
            && ok "fonte do console: $fonte" || falha "nao gravou /etc/vconsole.conf"
        sudo setfont "$fonte" 2>/dev/null
    else
        falha "terminus-font ausente; rode o install.sh pra ter fonte legivel no console"
    fi

    console_cmdline
}

etapa_arquivos() {
    log "Dolphin como gerenciador de arquivos, ghostty como terminal"

    # O KDE cai no konsole quando a chave nao existe (o fallback esta compilado na
    # libKF6KIOWidgets), e o konsole nao esta mais instalado -- sem isto o "abrir terminal"
    # do Dolphin e do KRunner nao abre nada.
    if command -v kwriteconfig6 >/dev/null 2>&1 && command -v ghostty >/dev/null 2>&1; then
        kwriteconfig6 --file kdeglobals --group General --key TerminalApplication ghostty
        kwriteconfig6 --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop
        ok "ghostty e o terminal padrao do Plasma"
    else
        falha "ghostty ou kwriteconfig6 ausente, terminal padrao nao configurado"
    fi

    # O Dolphin e o nativo do Plasma e ja se registra sozinho; isto so garante que nenhum
    # outro app tenha ficado como dono de inode/directory de instalacoes anteriores.
    if command -v xdg-mime >/dev/null 2>&1 && [[ -f /usr/share/applications/org.kde.dolphin.desktop ]]; then
        xdg-mime default org.kde.dolphin.desktop inode/directory 2>/dev/null \
            && ok "Dolphin e o padrao para abrir pasta" \
            || falha "nao consegui registrar o Dolphin em inode/directory"
    else
        falha "dolphin nao instalado"
    fi

    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file dolphinrc --group DetailsMode --key ExpandableFolders false \
            && ok "sem seta de expandir pasta no modo Detalhes" \
            || falha "nao consegui desligar as pastas expansiveis do Dolphin"
    fi
}

etapa_sistema() {
    log "tuning de sistema: zram, sysctl e desempenho maximo"

    # O RedM e a Proton mapeiam muita regiao de memoria; o padrao do kernel (65530) estoura e
    # o jogo morre com "out of memory" mesmo com RAM sobrando.
    printf 'vm.max_map_count = 2147483642\n' | sudo tee /etc/sysctl.d/99-jogos.conf >/dev/null \
        && ok "/etc/sysctl.d/99-jogos.conf (max_map_count pro RedM)"

    # O ananicy-cpp classifica o qemu como Heavy_CPU (nice 9, ionice 7): a VM do jogo perde
    # disputa de CPU pra qualquer aba do Chrome. Aqui a VM e o jogo: tipo Game (nice -5).
    sudo mkdir -p /etc/ananicy.d/99-dotfiles
    printf '{ "name": "qemu-system-x86_64", "type": "Game" }\n{ "name": "vyprd", "type": "Game" }\n{ "name": "vypr-window", "type": "Game" }\n' \
        | sudo tee /etc/ananicy.d/99-dotfiles/vm.rules >/dev/null \
        && ok "/etc/ananicy.d/99-dotfiles/vm.rules (qemu e Vypr como Game, nao Heavy_CPU)"

    # zram com zstd: metade da RAM, teto de 8 GB. Os valores de vm.* sao os recomendados
    # quando o swap e comprimido em RAM -- swappiness alto de proposito, porque paginar pro
    # zram custa CPU, nao disco.
    sudo mkdir -p /etc/systemd
    printf '[zram0]\nzram-size = min(ram / 2, 8192)\ncompression-algorithm = zstd\n' \
        | sudo tee /etc/systemd/zram-generator.conf >/dev/null \
        && ok "/etc/systemd/zram-generator.conf (zstd, min(ram/2, 8192))"

    printf 'vm.swappiness = 180\nvm.watermark_boost_factor = 0\nvm.watermark_scale_factor = 125\nvm.page-cluster = 0\n' \
        | sudo tee /etc/sysctl.d/99-zram.conf >/dev/null \
        && ok "/etc/sysctl.d/99-zram.conf"

    sudo sysctl --system >/dev/null 2>&1

    # Desempenho maximo o tempo todo: esta maquina nunca corre em bateria e o custo de manter
    # CPU e GPU no teto e so consumo. O tmpfiles roda a cada boot, depois que os drivers ja
    # criaram os arquivos em /sys -- por isso aqui, e nao num sysctl.
    printf '%s\n' \
        'w- /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor - - - - performance' \
        'w- /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference - - - - performance' \
        'w- /sys/class/drm/card*/device/power_dpm_force_performance_level - - - - high' \
        | sudo tee /etc/tmpfiles.d/99-desempenho.conf >/dev/null \
        && ok "/etc/tmpfiles.d/99-desempenho.conf (CPU e GPU no teto a cada boot)"
    sudo systemd-tmpfiles --create /etc/tmpfiles.d/99-desempenho.conf >/dev/null 2>&1

    # Sem isso o Xwayland nasce com teclado us e o ABNT2 some dentro de app X11 (RedM, Wine).
    if command -v localectl >/dev/null 2>&1; then
        sudo localectl set-x11-keymap br >/dev/null 2>&1 \
            && ok "layout br no X11 (/etc/X11/xorg.conf.d/00-keyboard.conf)" \
            || falha "localectl set-x11-keymap br falhou"
    fi
}

etapa_graficos() {
    log "GPU que desenha: variaveis da sessao e GPU primaria do mutter"

    local info
    info="$(bash "$DOTFILES_DIR/bin/render-gpu.sh")" || { falha "nenhuma GPU com monitor ligado"; return; }
    local GPU_DRIVER GPU_PCI GPU_CARD GPU_OUTRAS GPU_IDS
    eval "$info"

    # environment.d e lido pelo systemd --user, que e quem sobe a sessao no GNOME, no Plasma
    # e no Hyprland por uwsm -- e o unico lugar de env que vale nos quatro desktops. O
    # plasma-workspace/env/dotfiles.sh so faz source deste arquivo.
    local envdir="$HOME/.config/environment.d"
    mkdir -p "$envdir"
    {
        printf '# Gerado por setup.sh graficos -- nao editar a mao.\n'
        # GTK 4.20 parou de fazer dead key sozinho no Wayland sem IME instalado: sem isto o
        # ghostty e qualquer app GTK engolem ' ` ^ ~ e nao sai letra acentuada no ABNT2.
        printf 'GTK_IM_MODULE=simple\n'
        # O Spotify nao olha o LANG: sem LANGUAGE ele abre em ingles mesmo com pt_BR.UTF-8.
        printf 'LANGUAGE=pt_BR:pt\n'
        # O cosmic-comp so le o tema de cursor destas duas variaveis (na subida, entao vale
        # no login seguinte); Chrome, Electron e Xwayland leem as mesmas. Plasma e GNOME
        # ignoram e usam o proprio ajuste.
        printf 'XCURSOR_THEME=capitaine-cursors-light\nXCURSOR_SIZE=24\n'
        if [[ $GPU_DRIVER == nvidia ]]; then
            printf 'LIBVA_DRIVER_NAME=nvidia\n__GLX_VENDOR_LIBRARY_NAME=nvidia\nNVD_BACKEND=direct\n'
        else
            # Fixar nvidia com as telas na AMD joga app Electron pra swiftshader (CPU).
            printf 'LIBVA_DRIVER_NAME=radeonsi\n'
        fi
        # KWin e aquamarine escolhem a placa de render sozinhos e escolhiam a 3090, compondo
        # o desktop nela so pra copiar quadro a quadro pela PCIe ate quem tem os monitores.
        # Caminho por by-path porque cardN troca de numero entre boots.
        printf 'KWIN_DRM_DEVICES=%s\nAQ_DRM_DEVICES=%s\n' "$GPU_CARD" "$GPU_CARD"
        # O cosmic-comp escolhe a GPU de render sozinho e pega a Boot VGA, igual ao KWin e ao
        # mutter: em 12/09/2026 ele renderizava na 3090 e copiava pela PCIe pra AMD, e a tela
        # parecia travada mesmo com os dois monitores a 144 Hz. Aceita o caminho pci- direto.
        # Pelo par vendor:device, nao pelo `pci-...`: nesse formato o cosmic-comp 1.8 le o
        # symlink de by-path e tenta abrir o alvo relativo (`../renderD129`), que nao existe --
        # "failed to get node from path". Com o id ele nao resolve caminho nenhum.
        [[ -n ${GPU_IDS:-} ]] && printf 'COSMIC_RENDER_DEVICE=%s\n' "$GPU_IDS"
    } > "$envdir/50-dotfiles.conf"
    ok "~/.config/environment.d/50-dotfiles.conf (telas na $GPU_DRIVER, $GPU_PCI)"

    # O mutter nao tem variavel equivalente: ele elege a GPU primaria pela Boot VGA e pegava
    # a 3090, desenhando GNOME inteiro nos dummy plugs dela -- monitor real ficava na tela
    # azul, sem painel nem login. As duas tags valem tambem no gdm, que roda como outro
    # usuario e nao le environment.d nenhum.
    local regras="# Gerado por setup.sh graficos -- nao editar a mao.
SUBSYSTEM==\"drm\", KERNEL==\"card[0-9]*\", ENV{ID_PATH}==\"pci-$GPU_PCI\", TAG+=\"mutter-device-preferred-primary\""
    local outra
    for outra in ${GPU_OUTRAS:-}; do
        regras+="
SUBSYSTEM==\"drm\", KERNEL==\"card[0-9]*\", ENV{ID_PATH}==\"pci-$outra\", TAG+=\"mutter-device-ignore\""
    done
    printf '%s\n' "$regras" | sudo tee /etc/udev/rules.d/61-dotfiles-gpu.rules >/dev/null \
        && ok "/etc/udev/rules.d/61-dotfiles-gpu.rules (primaria do mutter na $GPU_DRIVER)" \
        || falha "nao consegui gravar a regra de udev da GPU primaria"
    sudo udevadm control --reload >/dev/null 2>&1
    sudo udevadm trigger --subsystem-match=drm >/dev/null 2>&1

    # Env gravado que so vale no proximo login nao serve: aplica tambem no systemd --user
    # desta sessao, pra todo app aberto daqui pra frente ja nascer com os valores certos.
    local linha
    while read -r linha; do
        [[ $linha == \#* || -z $linha ]] && continue
        /usr/bin/systemctl --user set-environment "$linha" 2>/dev/null
    done < "$envdir/50-dotfiles.conf"
    ok "variaveis aplicadas no systemd --user desta sessao"

    # O SDDM nao le environment.d: sessao que ele abre (todo desktop menos o GNOME, que usa
    # gdm) nasceria sem essas variaveis, e sem AQ_DRM_DEVICES o Hyprland desenha tambem na
    # 3090, trazendo os dummy plugs dela como tela. O /etc/environment o pam_env le sempre.
    local bloco_ini="# dotfiles: inicio (setup.sh graficos) -- nao editar a mao"
    local bloco_fim="# dotfiles: fim"
    local atual novo
    atual="$(sudo sed "/^$bloco_ini$/,/^$bloco_fim$/d" /etc/environment 2>/dev/null)"
    novo="$atual
$bloco_ini
$(grep -v '^#' "$envdir/50-dotfiles.conf")
$bloco_fim"
    printf '%s\n' "$novo" | sudo tee /etc/environment >/dev/null \
        && ok "/etc/environment (as mesmas variaveis pra sessao aberta pelo sddm)" \
        || falha "nao consegui gravar o /etc/environment"

    # Layout de tela: o mesmo script que a apply-screens.service roda no login. Aqui vale a
    # regra de sempre -- config que so aparece no proximo login nao esta entregue.
    bash "$DOTFILES_DIR/bin/apply-screens.sh" \
        && ok "layout de tela aplicado" \
        || falha "apply-screens.sh nao aplicou o layout"

    # A tela de login do gdm e outro mutter, com config propria: sem copiar isto, o login
    # nasce sem a rotacao e com a tela primaria trocada. O arquivo so existe depois que uma
    # sessao do GNOME aplicou o layout -- quem aplica e o bin/apply-screens.sh.
    #
    # O gdm novo nao tem mais usuario fixo `gdm`: o greeter roda com usuario dinamico e a
    # config dele mora em /var/lib/gdm/seat0/config. Por isso o dono sai do proprio diretorio,
    # e nao de um nome -- o uid muda de instalacao pra instalacao.
    local gdmcfg=""
    for gdmcfg in /var/lib/gdm/seat*/config /var/lib/gdm/.config; do
        [[ -d $gdmcfg ]] && break || gdmcfg=""
    done
    if [[ -f "$HOME/.config/monitors.xml" && -n $gdmcfg ]]; then
        local dono
        dono="$(sudo stat -c '%u:%g' "$gdmcfg")"
        sudo install -o "${dono%%:*}" -g "${dono##*:}" -m 644                 "$HOME/.config/monitors.xml" "$gdmcfg/monitors.xml" \
            && ok "$gdmcfg/monitors.xml (tela de login com o mesmo layout)" \
            || falha "nao consegui copiar o monitors.xml pro gdm"
    fi
}

etapa_wallpaper() {
    log "papel de parede nos dois monitores"
    bash "$DOTFILES_DIR/bin/apply-wallpaper.sh" \
        && ok "arte deitada no principal, em pe no girado (onde o desktop separa)" \
        || falha "apply-wallpaper.sh falhou"
}

etapa_cosmic() {
    log "COSMIC: barra, atalhos, teclado e os forks do painel"
    if [[ $DE != cosmic ]]; then
        ok "desktop e $DE, etapa do COSMIC pulada"
        return
    fi

    # Semente, nao espelho: o cosmic-settings e o proprio painel gravam nesses arquivos (fixar
    # um app pelo clique direito, por exemplo), entao symlink do stow nao serve. Copia por cima
    # so as chaves que o repo conhece; o resto de ~/.config/cosmic fica como esta. O `output`
    # do painel fica de fora de proposito: o conector muda de nome e quem cuida dele e o
    # bin/apply-screens.sh.
    local origem="$DOTFILES_DIR/state/cosmic" destino="${XDG_CONFIG_HOME:-$HOME/.config}/cosmic"
    local n=0 f rel
    while IFS= read -r -d '' f; do
        rel="${f#"$origem"/}"
        mkdir -p "$destino/$(dirname "$rel")"
        if ! cmp -s "$f" "$destino/$rel"; then
            # Atomico: o painel le a chave por inotify no instante que ela muda, e um cp
            # trunca antes de escrever -- ele leria o arquivo pela metade.
            cp "$f" "$destino/$rel.tmp" && mv "$destino/$rel.tmp" "$destino/$rel"
            n=$((n+1))
        fi
    done < <(find "$origem" -type f -print0)
    ok "$n chave(s) do COSMIC atualizada(s) em ~/.config/cosmic (as demais ja batiam)"

    # App GTK le o cursor do gsettings, nao do XCURSOR_THEME; o cosmic-settings-daemon replica
    # so o icon_theme pra la. Vale na hora.
    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.interface cursor-theme capitaine-cursors-light 2>/dev/null
        gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null
    fi

    # Nome dos apps sem "COSMIC" no fim e em portugues do Brasil, nao de Portugal.
    bash "$DOTFILES_DIR/bin/cosmic-app-names.sh" || falha "cosmic-app-names.sh falhou"

    # Os forks da org ReCosmicLabs, compilados e instalados em ~/.local/bin.
    bash "$DOTFILES_DIR/bin/cosmic-forks.sh" || falha "cosmic-forks.sh falhou"
}

etapa_vm() {
    log "VM w11: vfio, kvmfr, hooks e firmware"

    # Sem IOMMU nao existe passthrough: o vfio-pci ate prende a placa, mas nao ha grupo pra
    # entregar pra VM. Nao vem de graca em instalacao nova -- estava na cmdline desta maquina
    # so porque alguem pos na mao um dia. `transparent_hugepage=always` e o que deixa o XML
    # dispensar hugepage estatica (ver comentario no w11-3090.xml).
    local params=(transparent_hugepage=always)
    if grep -qi 'AuthenticAMD' /proc/cpuinfo; then
        params+=(amd_iommu=on iommu=pt)
    else
        params+=(intel_iommu=on iommu=pt)
    fi
    bash "$DOTFILES_DIR/bin/kernel-params.sh" "${params[@]}" \
        || falha "parametros de kernel do IOMMU nao gravados"

    # Saida de emergencia: a mesma entry, com o vfio_pci bloqueado. Sem ela, uma 3090 presa
    # no vfio com a VM quebrada deixa o host sem jeito de devolver a placa. O add_kernel_params
    # so acrescenta parametro em entry existente -- nunca cria esta, entao ela morre no format.
    if sudo test -d /boot/loader/entries && sudo test -f /boot/loader/entries/arch.conf; then
        if sudo test -f /boot/loader/entries/arch-sem-vfio.conf; then
            ok "entry 'sem vfio' ja existe"
        else
            sudo sed -e 's|^title \(.*\))[[:space:]]*$|title \1, sem vfio)|' \
                     -e 's|^title \([^(]*\)$|title \1 (sem vfio)|' \
                     -e 's|^options \(.*\) rw |options \1 rw module_blacklist=vfio_pci |' \
                /boot/loader/entries/arch.conf \
                | sudo tee /boot/loader/entries/arch-sem-vfio.conf >/dev/null \
                && ok "/boot/loader/entries/arch-sem-vfio.conf criada a partir da arch.conf"
        fi
    fi

    # prepare.sh ja e idempotente (so cria win.raw e baixa o virtio-win se faltarem) e ja
    # chama o kvmfr.sh sozinho, que faz o dkms, o modules-load.d e o cgroup_device_acl.
    DOTFILES_DIR="$DOTFILES_DIR" bash "$DOTFILES_DIR/vm/prepare.sh" || falha "vm/prepare.sh falhou"

    # O vfio-enable.sh roda mkinitcpio -P inteiro, que e lento: so vale a pena quando a 3090
    # ainda nao esta presa. Ele tem guarda propria e aborta sozinho se a RX 550 nao estiver
    # desenhando, entao rodar aqui nao arrisca deixar o host sem tela.
    if lspci -nnk -d 10de:2204: 2>/dev/null | grep -q 'Kernel driver in use: vfio-pci'; then
        ok "3090 ja esta no vfio-pci"
    elif [[ -f /etc/modprobe.d/vfio.conf ]] && grep -q '10de:2204' /etc/modprobe.d/vfio.conf; then
        ok "vfio ja configurado, falta reiniciar pra valer"
    else
        DOTFILES_DIR="$DOTFILES_DIR" bash "$DOTFILES_DIR/vm/vfio-enable.sh" \
            || falha "vfio-enable.sh abortou (confira se a RX 550 esta montada e desenhando)"
    fi

    # Vypr: app da VM como janela nativa (fork eualexandrerrr/Vypr), binarios em ~/.local/bin,
    # regiao /dev/shm/vypr, chave e config. O lado Windows e o `vm/vypr.sh guest`, uma vez.
    bash "$DOTFILES_DIR/vm/vypr.sh" || falha "vypr.sh falhou"
}

etapa_ddcutil() {
    log "i2c-dev pro ddcutil (troca de entrada do monitor)"
    if printf 'i2c-dev\n' | sudo cmp -s - /etc/modules-load.d/i2c-dev.conf 2>/dev/null; then
        ok "/etc/modules-load.d/i2c-dev.conf ja correto"
    else
        printf 'i2c-dev\n' | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
        sudo modprobe i2c-dev
        ok "/etc/modules-load.d/i2c-dev.conf"
    fi

    printf '%s\n' \
        '[Unit]' \
        'Description=ASUS na entrada HDMI (RX 550) no boot' \
        'After=systemd-modules-load.service systemd-udev-settle.service' \
        'Before=display-manager.service' \
        'StartLimitBurst=5' \
        '' \
        '[Service]' \
        'Type=oneshot' \
        'TimeoutStartSec=20' \
        'Restart=on-failure' \
        'RestartSec=3' \
        'ExecStart=/usr/bin/ddcutil --model XG27ACS setvcp 60 x11' \
        '' \
        '[Install]' \
        'WantedBy=multi-user.target' \
        | sudo tee /etc/systemd/system/monitor-hdmi.service >/dev/null \
        && sudo systemctl daemon-reload \
        && sudo systemctl enable monitor-hdmi.service >/dev/null 2>&1 \
        && ok "monitor-hdmi.service (ASUS abre no HDMI a cada boot)" \
        || falha "monitor-hdmi.service nao habilitado"
}

etapa_notificacoes() {
    log "notificacoes do Plasma"
    # Nao entra no stow: o Plasma grava neste arquivo sozinho toda vez que um app novo
    # notifica (`[Applications][x] Seen=true`), e pelo symlink isso sujava o repo a cada
    # sessao. Aqui so a chave que importa e gravada, o resto o Plasma administra.
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file plasmanotifyrc --group DoNotDisturb \
            --key NotificationSoundsMuted true \
            && ok "som de notificacao mudo" \
            || falha "nao consegui gravar o plasmanotifyrc"
    else
        falha "kwriteconfig6 nao instalado"
    fi
}

etapa_painel() {
    log "barra de tarefas: lancadores, icone de audio, badge de grupo e fonte"
    "$DOTFILES_DIR/bin/apply-launchers.sh" \
        && ok "Dolphin, Chrome, Discord e VS Code fixados, icone de audio desligado" \
        || falha "nao consegui ajustar a barra de tarefas"

    "$DOTFILES_DIR/bin/apply-task-group-icon.sh" \
        && ok "badge de + nas janelas agrupadas removido do tema" \
        || falha "nao consegui remover o badge de grupo do tema"

    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file plasmarc --group PlasmaToolTips --key Delay 1 \
            && ok "preview ao passar o mouse sem atraso" \
            || falha "nao consegui zerar o atraso do tooltip"

        # A miniatura de janela do hover no icone agrupado nao tem tamanho proprio pra
        # configurar -- escala com Kirigami.Units.gridUnit, que vem da fonte geral. Um ponto
        # a menos encolhe o preview (e o resto da interface, mais discreto).
        local fonte="Noto Sans,9,-1,5,50,0,0,0,0,0"
        kwriteconfig6 --file kdeglobals --group General --key font "$fonte"
        kwriteconfig6 --file kdeglobals --group General --key menuFont "$fonte"
        kwriteconfig6 --file kdeglobals --group General --key toolBarFont "$fonte" \
            && ok "fonte geral em 9pt, preview do hover menor" \
            || falha "nao consegui reduzir a fonte geral"
    fi
}

etapa_tema() {
    log "tema Win11OS-dark"
    "$DOTFILES_DIR/bin/apply-theme-win11os-dark.sh" \
        && ok "cores, decoracao, Kvantum, icones, cursor, GTK, splash e painel opaco" \
        || falha "nao consegui aplicar o tema Win11OS-dark"
}

etapa_servicos() {
    log "servicos de usuario e restauracao da sessao"

    # Desligar e ligar o PC tem que cair no mesmo lugar. Sao duas metades:
    #  - o restore nativo do Plasma, que cobre app que fala o protocolo de sessao;
    #  - o session-apps.service, pros que nao falam (Chrome, Discord, Electron em geral),
    #    que guarda a lista de scopes ao sair e reabre no login.
    if [[ $DE == kde ]] && command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file ksmserverrc --group General --key loginMode restorePreviousLogout \
            && ok "Plasma restaura a sessao anterior no login" \
            || falha "nao consegui gravar o ksmserverrc"
    fi

    /usr/bin/systemctl --user daemon-reload >/dev/null 2>&1 || true

    /usr/bin/systemctl --user enable vm-audio-acl.service >/dev/null 2>&1 \
        && ok "vm-audio-acl.service habilitado" \
        || falha "vm-audio-acl.service nao habilitado"

    # As duas entram por graphical-session.target: como .desktop de autostart nao davam
    # certo -- o gerador do systemd nao expande $HOME no Exec e as units falhavam todo boot.
    /usr/bin/systemctl --user enable apply-screens.service session-apps.service >/dev/null 2>&1 \
        && ok "apply-screens e session-apps ligadas na sessao grafica" \
        || falha "units de sessao grafica nao habilitadas"

    /usr/bin/systemctl --user enable session-apps.timer >/dev/null 2>&1 \
        && /usr/bin/systemctl --user start session-apps.timer >/dev/null 2>&1 \
        && ok "session-apps.timer habilitado" \
        || falha "session-apps.timer nao habilitado"

    /usr/bin/systemctl --user enable apply-screens.timer >/dev/null 2>&1 \
        && /usr/bin/systemctl --user start apply-screens.timer >/dev/null 2>&1 \
        && ok "apply-screens.timer habilitado" \
        || falha "apply-screens.timer nao habilitado"

    if [[ -d "$HOME/Apps/desktop/RicePanel" ]]; then
        /usr/bin/systemctl --user enable ricepanel.service >/dev/null 2>&1 \
            && ok "ricepanel.service habilitado" \
            || falha "ricepanel.service nao habilitado"
    else
        falha "~/Apps/desktop/RicePanel ausente, ricepanel.service nao habilitado"
    fi

    # No Wayland o cliente nao escolhe onde nasce: o setBounds({x,y}) do Electron e
    # aceito pelo app e ignorado pelo compositor -- o painel loga que foi pro vertical
    # e o KWin mantem ele no ASUS. No Hyprland o proprio app contornava por hyprctl,
    # que aqui nao existe. Entao quem prende e a regra de janela, do lado do KWin:
    # plasma/.config/kwinrulesrc, que a etapa `links` ja colocou no lugar. A geometria
    # e a mesma que o apply-screens.sh fixa no vertical (0,0 1080x1920), e a classe da
    # janela e "RicePanel" com maiuscula, apesar do --class=ricepanel -- dai o regex la.
    # Aqui so falta avisar o KWin, que le o arquivo uma vez e nao fica vigiando.
    if [[ $DE != kde ]]; then
        ok "regra de janela do RicePanel e do KWin, pulada em $DE"
    elif [[ -f "$HOME/.config/kwinrulesrc" ]]; then
        qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 \
            && ok "regra de janela do RicePanel recarregada no KWin" \
            || falha "KWin nao recarregou (sessao grafica de pe?)"
    else
        falha "~/.config/kwinrulesrc ausente, rode a etapa links"
    fi

    # Deploy da pasta [peds] do Michigan, 3x por dia. Depende do repo de deploy estar clonado.
    if [[ -x "$HOME/MichiganRoleplay/DeployFiles/autosync.sh" ]]; then
        /usr/bin/systemctl --user enable deploy-peds.timer >/dev/null 2>&1 \
            && /usr/bin/systemctl --user start deploy-peds.timer >/dev/null 2>&1 \
            && ok "deploy-peds.timer habilitado" \
            || falha "deploy-peds.timer nao habilitado"
    else
        falha "~/MichiganRoleplay/DeployFiles ausente, deploy-peds.timer nao habilitado"
    fi

    # O drkonqi fica 30 min esperando crash pendente e morre por timeout todo boot, sujando
    # o --failed. Mascarado: o DrKonqi continua abrindo quando um app trava na frente dele.
    # E unit do KDE: em outro desktop nem existe pra mascarar.
    if [[ $DE == kde ]]; then
        /usr/bin/systemctl --user mask drkonqi-coredump-pickup.service >/dev/null 2>&1 \
            && ok "drkonqi-coredump-pickup mascarado" \
            || falha "nao consegui mascarar o drkonqi-coredump-pickup"
    fi
}

ETAPAS=(links home perfil arquivos sistema graficos wallpaper cosmic vm ddcutil energia atalhos audio dns console chrome vscode claude notificacoes painel tema servicos)

if [[ ${1:-} == --lista ]]; then
    printf 'etapas: %s\n' "${ETAPAS[*]}"
    exit 0
fi

if (( $# )); then
    pedidas=("$@")
    for p in "${pedidas[@]}"; do
        declare -F "etapa_$p" >/dev/null || { printf 'etapa desconhecida: %s\n' "$p" >&2; printf 'validas: %s\n' "${ETAPAS[*]}" >&2; exit 1; }
    done
else
    pedidas=("${ETAPAS[@]}")
fi

# Tira as etapas de KDE da lista antes de contar, senao o [n/total] mente.
if [[ $DE != kde ]]; then
    puladas=()
    restantes=()
    for p in "${pedidas[@]}"; do
        if etapa_e_de_kde "$p"; then puladas+=("$p"); else restantes+=("$p"); fi
    done
    if (( ${#puladas[@]} )); then
        printf '%s  --%s desktop e %s: pulando etapa(s) de KDE: %s\n' "$YEL" "$END" "$DE" "${puladas[*]}"
    fi
    pedidas=("${restantes[@]}")
fi

TOTAL=${#pedidas[@]}
printf '%s==>%s setup dos dotfiles em %s (desktop: %s)\n' "$BLU" "$END" "$(date '+%d/%m/%Y %H:%M:%S')" "$DE"
for p in "${pedidas[@]}"; do "etapa_$p"; done

printf '\n'
if (( ${#FALHAS[@]} )); then
    printf '%s%d aviso(s):%s\n' "$YEL" "${#FALHAS[@]}" "$END"
    printf '  - %s\n' "${FALHAS[@]}"
    exit 1
fi
printf '%ssetup completo, %d etapa(s).%s\n' "$GRN" "$TOTAL" "$END"
