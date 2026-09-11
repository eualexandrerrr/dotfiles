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

etapa_links() {
    log "links do stow"
    command -v stow >/dev/null 2>&1 || { falha "stow nao instalado"; return; }
    local pkg nome n=0
    for pkg in "$DOTFILES_DIR"/*/; do
        nome="$(basename "$pkg")"
        [[ $nome == .git ]] && continue
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

    # O power.sh cuida do lado systemd; estas duas sao do Plasma e ficavam de fora.
    if command -v kwriteconfig6 >/dev/null 2>&1; then
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
        && ok "Dolphin, Chrome, Discord e RCode fixados, icone de audio desligado" \
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
    log "tema Win11Nord"
    "$DOTFILES_DIR/bin/apply-theme-win11nord.sh" \
        && ok "cores, decoracao de janela, Kvantum e splash do Win11Nord aplicados" \
        || falha "nao consegui aplicar o tema Win11Nord"
}

etapa_servicos() {
    log "servicos de usuario e restauracao da sessao"

    # Desligar e ligar o PC tem que cair no mesmo lugar. Sao duas metades:
    #  - o restore nativo do Plasma, que cobre app que fala o protocolo de sessao;
    #  - o session-apps.service, pros que nao falam (Chrome, Discord, Electron em geral),
    #    que guarda a lista de scopes ao sair e reabre no login.
    if command -v kwriteconfig6 >/dev/null 2>&1; then
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
    if [[ -f "$HOME/.config/kwinrulesrc" ]]; then
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
    /usr/bin/systemctl --user mask drkonqi-coredump-pickup.service >/dev/null 2>&1 \
        && ok "drkonqi-coredump-pickup mascarado" \
        || falha "nao consegui mascarar o drkonqi-coredump-pickup"
}

ETAPAS=(links home perfil arquivos sistema vm ddcutil energia atalhos audio dns console chrome claude notificacoes painel tema servicos)

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

TOTAL=${#pedidas[@]}
printf '%s==>%s setup dos dotfiles em %s\n' "$BLU" "$END" "$(date '+%d/%m/%Y %H:%M:%S')"
for p in "${pedidas[@]}"; do "etapa_$p"; done

printf '\n'
if (( ${#FALHAS[@]} )); then
    printf '%s%d aviso(s):%s\n' "$YEL" "${#FALHAS[@]}" "$END"
    printf '  - %s\n' "${FALHAS[@]}"
    exit 1
fi
printf '%ssetup completo, %d etapa(s).%s\n' "$GRN" "$TOTAL" "$END"
