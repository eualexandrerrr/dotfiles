#!/usr/bin/env bash
# Pós-instalação do Arch: pacotes, NVIDIA, KDE Plasma, serviços e symlinks deste repo.
# Idempotente: pode rodar de novo a qualquer hora.
#
#   SKIP_NVIDIA=1 ./install.sh    força pular driver e parâmetros de kernel
#   (sem a variável, detecta pelo PCI: sem placa NVIDIA = pula sozinho)

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/eualexandrerrr/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
# Sem SKIP_NVIDIA na chamada, decide pelo hardware: vendor 0x10de em algum device PCI = NVIDIA.
if [[ -z ${SKIP_NVIDIA:-} ]]; then
    if grep -qsx 0x10de /sys/bus/pci/devices/*/vendor 2>/dev/null; then SKIP_NVIDIA=0; else SKIP_NVIDIA=1; fi
fi

KERNEL_PARAMS=(nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1)
NVIDIA_MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

RED=$'\e[1;31m'; GRN=$'\e[1;32m'; YEL=$'\e[1;33m'; BLU=$'\e[1;34m'; END=$'\e[0m'

LOGFILE="${LOGFILE:-$HOME/dotfiles-install.log}"
T0=$SECONDS
STEP=0
TOTAL_STEPS=14
[[ ${SKIP_NVIDIA:-0} == 1 ]] && TOTAL_STEPS=12
WARNS=()
OFICIAL_PEDIDOS=0; OFICIAL_NOVOS=(); OFICIAL_FALTANDO=()
AUR_OK=(); AUR_JA=(); AUR_FALHA=()
SERV_OK=(); SERV_FALHA=()
CLAUDE_VER="nao instalado"
WM_DIR="$HOME/.local/src/KDE-Windows-Modern"
WM_REPO="https://github.com/Jeysef/KDE-Windows-Modern.git"
WM_OK=(); WM_FALHA=()
LINKS=0

elapsed() { local s=$((SECONDS - T0)); printf '%02d:%02d' $((s/60)) $((s%60)); }
log()  { STEP=$((STEP+1)); printf '\n%s==>%s [%d/%d] %s %s(%s)%s\n' "$BLU" "$END" "$STEP" "$TOTAL_STEPS" "$*" "$YEL" "$(elapsed)" "$END"; }
ok()   { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
warn() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*"; WARNS+=("[etapa $STEP] $*"); }
die()  { printf '\n%serro:%s %s\n' "$RED" "$END" "$*" >&2; printf '%sparou na etapa %d/%d apos %s. Log completo: %s%s\n' "$RED" "$STEP" "$TOTAL_STEPS" "$(elapsed)" "$LOGFILE" "$END" >&2; exit 1; }
on_err() { local rc=$? line=$1 cmd=$2; [[ $rc -eq 0 ]] && return; printf '\n%serro na linha %d (saida %d):%s %s\n' "$RED" "$line" "$rc" "$END" "$cmd" >&2; printf '%setapa %d/%d, %s decorridos. Log: %s%s\n' "$RED" "$STEP" "$TOTAL_STEPS" "$(elapsed)" "$LOGFILE" "$END" >&2; }
trap 'on_err $LINENO "$BASH_COMMAND"' ERR

exec > >(tee -a "$LOGFILE") 2>&1
printf '%s==>%s dotfiles install.sh iniciado em %s, log em %s\n' "$BLU" "$END" "$(date '+%d/%m/%Y %H:%M:%S')" "$LOGFILE"

need_sudo() {
    sudo -v || die "sudo obrigatorio"
    while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
}

preflight() {
    [[ $EUID -ne 0 ]] || die "nao rode como root, o script usa sudo quando precisa"
    command -v pacman >/dev/null 2>&1 || die "isso aqui e so pra Arch e derivados"
    command -v systemctl >/dev/null 2>&1 || die "systemd nao encontrado"
    need_sudo
    ok "ambiente validado"
}

pkgfile() {
    local f
    for f in "$DOTFILES_DIR/packages.txt" "$(dirname "$(readlink -f "$0")")/packages.txt" "./packages.txt"; do
        [[ -f $f ]] && { printf '%s' "$f"; return 0; }
    done
    die "packages.txt nao encontrado"
}

read_section() {
    local file="$1" want="$2"
    awk -v want="$want" '
        /^\[/ { sec = substr($0, 2, length($0) - 2); next }
        /^[[:space:]]*$/ { next }
        /^#/ { next }
        sec ~ want { print }
    ' "$file"
}

# pacman 6.1 entrega ParallelDownloads ATIVO (valor 5). Um sed ancorado em ^# nao
# casa nesse caso e falha calado. Cobre os tres estados: comentada, ativa, ausente.
set_pacman_option() {
    local key="$1" value="$2"
    if grep -qE "^#?${key}" /etc/pacman.conf; then
        sudo sed -i -E "s|^#?${key}.*|${key} = ${value}|" /etc/pacman.conf
    else
        sudo sed -i "/^\[options\]/a ${key} = ${value}" /etc/pacman.conf
    fi
}

enable_multilib() {
    log "pacman: multilib, downloads paralelos, cor"
    if grep -qE '^\[multilib\]' /etc/pacman.conf; then
        ok "multilib ja ativo"
    else
        sudo cp /etc/pacman.conf "/etc/pacman.conf.bak-$(date +%Y%m%d%H%M%S)"
        printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' | sudo tee -a /etc/pacman.conf >/dev/null
        ok "multilib adicionado"
    fi
    set_pacman_option ParallelDownloads 10
    grep -qE '^Color' /etc/pacman.conf || sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
    sudo pacman -Syy --noconfirm
}

sync_system() {
    log "atualizando o sistema"
    sudo pacman -Syu --noconfirm --needed
    sudo pacman -S --noconfirm --needed archlinux-keyring base-devel git
    ok "sistema atualizado"
}

install_official() {
    local file pkgs
    file="$(pkgfile)"
    mapfile -t pkgs < <(read_section "$file" '^repo-oficial')
    if [[ $SKIP_NVIDIA == 1 ]]; then
        mapfile -t pkgs < <(printf '%s\n' "${pkgs[@]}" | grep -vE '^(nvidia|lib32-nvidia|libva-nvidia|egl-wayland)')
    fi
    [[ ${#pkgs[@]} -gt 0 ]] || die "nenhum pacote oficial lido de $file"
    log "instalando ${#pkgs[@]} pacotes dos repos oficiais"
    OFICIAL_PEDIDOS=${#pkgs[@]}
    local antes depois p
    antes="$(pacman -Qq | sort)"
    local ja=0
    for p in "${pkgs[@]}"; do pacman -Qq "$p" >/dev/null 2>&1 && ja=$((ja+1)); done
    printf '  ja presentes: %d, a instalar: %d\n' "$ja" "$((OFICIAL_PEDIDOS-ja))"
    if ! sudo pacman -S --noconfirm --needed "${pkgs[@]}"; then
        warn "pacman falhou na transacao unica (provavel nome de pacote invalido), tentando um por um"
        for p in "${pkgs[@]}"; do
            pacman -Qq "$p" >/dev/null 2>&1 && continue
            sudo pacman -S --noconfirm --needed "$p" >/dev/null 2>&1 && ok "$p" || warn "$p nao existe nos repos ou falhou"
        done
    fi
    depois="$(pacman -Qq | sort)"
    mapfile -t OFICIAL_NOVOS < <(comm -13 <(printf '%s\n' "$antes") <(printf '%s\n' "$depois"))
    for p in "${pkgs[@]}"; do pacman -Qq "$p" >/dev/null 2>&1 || OFICIAL_FALTANDO+=("$p"); done
    ok "${#OFICIAL_NOVOS[@]} pacotes novos entraram (com dependencias), $ja ja estavam"
    if (( ${#OFICIAL_FALTANDO[@]} )); then
        warn "oficiais que NAO instalaram: ${OFICIAL_FALTANDO[*]}"
    else
        ok "todos os ${OFICIAL_PEDIDOS} pacotes oficiais pedidos estao presentes"
    fi
}

bootstrap_paru() {
    log "instalando paru"
    if paru --version >/dev/null 2>&1; then
        ok "paru ja instalado: $(paru --version | head -1)"
        return 0
    fi
    if pacman -Qq paru-bin >/dev/null 2>&1; then
        warn "paru-bin instalado mas nao roda (libalpm desatualizado), trocando pelo paru compilado"
        sudo pacman -Rns --noconfirm paru-bin
    fi
    sudo pacman -S --noconfirm --needed rust
    local build
    build="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/paru.git "$build/paru"
    ( cd "$build/paru" && makepkg -si --noconfirm --needed )
    rm -rf "$build"
    paru --version >/dev/null 2>&1 || die "paru nao roda apos o build"
    ok "paru instalado: $(paru --version | head -1)"
}

install_aur() {
    local file pkgs p
    file="$(pkgfile)"
    mapfile -t pkgs < <(read_section "$file" '^aur$' | grep -vxE 'paru|paru-bin')
    [[ ${#pkgs[@]} -gt 0 ]] || { warn "nenhum pacote AUR na lista"; return 0; }
    log "instalando ${#pkgs[@]} pacotes do AUR"
    printf '  lista: %s\n' "${pkgs[*]}"
    local i=0 n=${#pkgs[@]} t
    for p in "${pkgs[@]}"; do
        i=$((i+1)); t=$SECONDS
        printf '%s  --%s [%d/%d] %s\n' "$BLU" "$END" "$i" "$n" "$p"
        if paru -Qq "$p" >/dev/null 2>&1; then
            ok "$p ja instalado"
            AUR_JA+=("$p")
        elif paru -S --noconfirm --needed --skipreview "$p"; then
            ok "$p instalado em $(( (SECONDS-t)/60 ))m$(( (SECONDS-t)%60 ))s"
            AUR_OK+=("$p")
        else
            warn "$p falhou, seguindo"
            AUR_FALHA+=("$p")
        fi
    done
    ok "AUR: ${#AUR_OK[@]} instalados, ${#AUR_JA[@]} ja estavam, ${#AUR_FALHA[@]} falharam"
    if (( ${#AUR_FALHA[@]} )); then
        warn "AUR que nao instalaram: ${AUR_FALHA[*]}"
        warn "depois rode: paru -S --needed ${AUR_FALHA[*]}"
    fi
}

install_node_tools() {
    log "node, npm global sem sudo e Claude Code"
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
    mkdir -p "$NPM_CONFIG_PREFIX/bin"
    npm config set prefix "$NPM_CONFIG_PREFIX" >/dev/null 2>&1 || true
    ok "node $(node --version 2>/dev/null || echo ?) / npm $(npm --version 2>/dev/null || echo ?), prefix global em $NPM_CONFIG_PREFIX"
    if command -v claude >/dev/null 2>&1; then
        ok "claude ja presente (via AUR ou npm)"
    else
        printf '  claude-code do AUR nao entrou, instalando via npm\n'
        npm install -g @anthropic-ai/claude-code && ok "@anthropic-ai/claude-code instalado via npm" || warn "npm install -g @anthropic-ai/claude-code falhou"
    fi
    if command -v claude >/dev/null 2>&1; then
        CLAUDE_VER="$(claude --version 2>/dev/null | head -1 || echo instalado)"
        ok "claude: $CLAUDE_VER ($(command -v claude))"
    else
        warn "claude nao ficou disponivel; depois rode: npm install -g @anthropic-ai/claude-code"
    fi
}

add_kernel_params() {
    log "gravando parametros de kernel da nvidia"
    local applied=0 p entry

    if sudo test -d /boot/loader/entries && command -v bootctl >/dev/null 2>&1; then
        while IFS= read -r entry; do
            sudo grep -qE '^options ' "$entry" || continue
            for p in "${KERNEL_PARAMS[@]}"; do
                sudo grep -qF -- "$p" "$entry" || sudo sed -i "s|^options .*|& $p|" "$entry"
            done
            applied=1
            ok "systemd-boot: $(basename "$entry") com os parametros"
        done < <(sudo find /boot/loader/entries -maxdepth 1 -name '*.conf' 2>/dev/null)
    fi

    if sudo test -f /etc/kernel/cmdline; then
        for p in "${KERNEL_PARAMS[@]}"; do
            sudo grep -qF -- "$p" /etc/kernel/cmdline || printf ' %s' "$p" | sudo tee -a /etc/kernel/cmdline >/dev/null
        done
        applied=1
        ok "/etc/kernel/cmdline atualizado"
    fi

    if [[ -f /etc/default/grub ]]; then
        for p in "${KERNEL_PARAMS[@]}"; do
            grep -qF -- "$p" /etc/default/grub || \
                sudo sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\)\"|\1 $p\"|" /etc/default/grub
        done
        if command -v grub-mkconfig >/dev/null 2>&1 && [[ -d /boot/grub ]]; then
            sudo grub-mkconfig -o /boot/grub/grub.cfg
            applied=1
            ok "GRUB regerado"
        fi
    fi

    [[ $applied -eq 1 ]] || warn "nenhum bootloader reconhecido, adicione na mao: ${KERNEL_PARAMS[*]}"
}

configure_nvidia() {
    if [[ $SKIP_NVIDIA == 1 ]]; then
        warn "SKIP_NVIDIA=1: driver e parametros de kernel pulados"
        return 0
    fi
    log "configurando driver nvidia"

    printf 'options nvidia_drm modeset=1\noptions nvidia NVreg_PreserveVideoMemoryAllocations=1\n' \
        | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
    ok "/etc/modprobe.d/nvidia.conf"

    printf 'blacklist nouveau\noptions nouveau modeset=0\n' \
        | sudo tee /etc/modprobe.d/blacklist-nouveau.conf >/dev/null
    ok "nouveau bloqueado"

    local current missing=() m
    current="$(grep -E '^MODULES=' /etc/mkinitcpio.conf || printf 'MODULES=()')"
    for m in "${NVIDIA_MODULES[@]}"; do
        grep -qE "^MODULES=.*\b${m}\b" /etc/mkinitcpio.conf || missing+=("$m")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        sudo cp /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak-$(date +%Y%m%d%H%M%S)"
        local inner
        inner="$(printf '%s' "$current" | sed -E 's/^MODULES=\(//; s/\)$//')"
        inner="$(printf '%s %s' "$inner" "${missing[*]}" | sed -E 's/^ +//; s/ +/ /g')"
        sudo sed -i "s|^MODULES=.*|MODULES=($inner)|" /etc/mkinitcpio.conf
        ok "mkinitcpio MODULES: ${missing[*]}"
    else
        ok "mkinitcpio ja tem os modulos"
    fi

    add_kernel_params
    sudo mkinitcpio -P

    local unit
    for unit in nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service; do
        sudo systemctl enable "$unit" >/dev/null 2>&1 || true
    done
    ok "driver nvidia configurado"
}

enable_services() {
    log "habilitando servicos"
    local unit
    for unit in NetworkManager.service sddm.service power-profiles-daemon.service ananicy-cpp.service reflector.timer; do
        if sudo systemctl enable "$unit" >/dev/null 2>&1; then ok "$unit"; SERV_OK+=("$unit"); else warn "$unit nao habilitado"; SERV_FALHA+=("$unit"); fi
    done

    local sock
    for sock in docker.socket libvirtd.socket; do
        if sudo systemctl enable "$sock" >/dev/null 2>&1; then
            ok "$sock"
        else
            warn "$sock nao habilitado, provavelmente nao instalado"
        fi
    done

    if command -v mariadb-install-db >/dev/null 2>&1; then
        if [[ ! -d /var/lib/mysql/mysql ]]; then
            if sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql >/dev/null 2>&1; then
                ok "mariadb inicializado"
            else
                warn "mariadb-install-db falhou, seguindo"
            fi
        fi
        sudo systemctl enable mariadb.service >/dev/null 2>&1 && ok "mariadb.service" || warn "mariadb.service nao habilitado"
    else
        warn "mariadb nao instalado, pulando a inicializacao do banco"
    fi

    local grp
    for grp in docker libvirt video input; do
        getent group "$grp" >/dev/null 2>&1 || continue
        id -nG "$USER" | tr ' ' '\n' | grep -qx "$grp" || { sudo usermod -aG "$grp" "$USER"; ok "usuario adicionado ao grupo $grp"; }
    done

    systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service >/dev/null 2>&1 || true

    # Desktop ligado na tomada: perfil de energia em desempenho, sempre.
    if command -v powerprofilesctl >/dev/null 2>&1; then
        sudo mkdir -p /var/lib/power-profiles-daemon
        printf '[State]\nProfile=performance\n' | sudo tee /var/lib/power-profiles-daemon/state.ini >/dev/null
        ok "perfil de energia: performance (aplicado no proximo boot)"
    fi
    ok "servicos prontos"
}

fetch_dotfiles() {
    log "obtendo dotfiles"
    if [[ -d $DOTFILES_DIR/.git ]]; then
        git -C "$DOTFILES_DIR" fetch --all --prune
        git -C "$DOTFILES_DIR" checkout "$DOTFILES_BRANCH"
        git -C "$DOTFILES_DIR" pull --ff-only origin "$DOTFILES_BRANCH" || warn "pull nao aplicado, arvore local divergente"
        ok "dotfiles atualizados em $DOTFILES_DIR"
    else
        git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
        ok "dotfiles clonados em $DOTFILES_DIR"
    fi
}

backup_conflict() {
    local target="$1"
    [[ -e $target || -L $target ]] || return 0
    [[ -L $target && "$(readlink -f "$target")" == "$(readlink -f "$DOTFILES_DIR")"* ]] && return 0
    local stamp
    stamp="$(date +%Y%m%d%H%M%S)"
    mv "$target" "$target.bak-$stamp"
    warn "$(basename "$target") existia, movido para $(basename "$target").bak-$stamp"
}

link_dotfiles() {
    log "criando symlinks"
    mkdir -p "$HOME/.config"

    local src name target
    for src in "$DOTFILES_DIR"/.config/*; do
        [[ -e $src ]] || continue
        name="$(basename "$src")"
        target="$HOME/.config/$name"
        backup_conflict "$target"
        ln -sfn "$src" "$target"
        LINKS=$((LINKS+1))
        ok ".config/$name"
    done

    shopt -s dotglob nullglob
    for src in "$DOTFILES_DIR"/home/*; do
        [[ -f $src ]] || continue
        name="$(basename "$src")"
        target="$HOME/$name"
        backup_conflict "$target"
        ln -sfn "$src" "$target"
        LINKS=$((LINKS+1))
        # shellcheck disable=SC2088
        ok "~/$name"
    done
    shopt -u dotglob nullglob

    # Lancadores de atalho global. Vao um a um, nao o diretorio inteiro: o KDE e o
    # Chrome tambem escrevem .desktop em ~/.local/share/applications, e um symlink de
    # diretorio faria essas gravacoes caírem dentro do repo.
    if [[ -d "$DOTFILES_DIR/local/share/applications" ]]; then
        mkdir -p "$HOME/.local/share/applications"
        for src in "$DOTFILES_DIR"/local/share/applications/*.desktop; do
            [[ -f $src ]] || continue
            name="$(basename "$src")"
            target="$HOME/.local/share/applications/$name"
            backup_conflict "$target"
            ln -sfn "$src" "$target"
            LINKS=$((LINKS+1))
            # shellcheck disable=SC2088
            ok "~/.local/share/applications/$name"
        done
        # Sem reconstruir o sycoca o KService nao acha o .desktop novo, e o atalho
        # global fica apontando pra um lancador que o KDE diz nao existir.
        kbuildsycoca6 >/dev/null 2>&1 || true
    fi

    ok "$LINKS symlinks aplicados"
}

configure_sddm() {
    log "configurando sddm (greeter Wayland com kwin, tema breeze)"
    sudo mkdir -p /etc/sddm.conf.d
    cat <<'EOF' | sudo tee /etc/sddm.conf.d/10-dotfiles.conf >/dev/null
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1

[Theme]
Current=breeze
EOF
    ok "/etc/sddm.conf.d/10-dotfiles.conf"
}

configure_kde_defaults() {
    log "padroes do KDE a partir de scripts/kde-settings.conf"
    mkdir -p "$HOME/.config"
    if ! command -v kwriteconfig6 >/dev/null 2>&1; then
        warn "kwriteconfig6 nao encontrado, ajuste teclado, terminal e tema nas Configuracoes do Sistema"
        return 0
    fi
    local conf="$DOTFILES_DIR/scripts/kde-settings.conf"
    local aplicar="$DOTFILES_DIR/scripts/kde-apply.sh"
    if [[ -f $conf ]]; then
        # Fonte unica: tudo que voce ajustou na GUI e capturou com scripts/kde-capture.sh.
        # Teclado (repeticao), mouse (aceleracao), tema, icones, terminal padrao, bordas.
        DOTFILES_DIR="$DOTFILES_DIR" bash "$aplicar" "$conf" \
            && ok "kde-settings.conf aplicado" \
            || warn "kde-apply.sh terminou com erro, confira as Configuracoes do Sistema"
    else
        warn "$conf ausente, aplicando so o minimo (teclado br, terminal ghostty, Breeze Dark)"
        kwriteconfig6 --file kxkbrc --group Layout --key LayoutList br
        kwriteconfig6 --file kxkbrc --group Layout --key Use true
        kwriteconfig6 --file kdeglobals --group General --key TerminalApplication ghostty
        kwriteconfig6 --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop
        kwriteconfig6 --file kdeglobals --group General --key ColorScheme BreezeDark
        kwriteconfig6 --file plasmarc --group Theme --key name breeze-dark
    fi
    ok "layout estilo Windows 11 sera aplicado no primeiro login por scripts/kde-layout-once.sh"
}

install_windows_modern() {
    log "tema Windows Modern (Win11 pro Plasma 6): temas, icones, applets, layout"
    mkdir -p "$(dirname "$WM_DIR")"
    if [[ -d $WM_DIR/.git ]]; then
        git -C "$WM_DIR" pull -q --ff-only || warn "pull do Windows-Modern nao aplicado"
        ok "repo atualizado em $WM_DIR"
    else
        git clone --depth 1 "$WM_REPO" "$WM_DIR" || { warn "clone do Windows-Modern falhou, tema pulado"; return 0; }
        ok "repo clonado em $WM_DIR"
    fi
    local shim
    shim="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nexec sudo "$@"\n' > "$shim/pkexec"
    chmod +x "$shim/pkexec"
    local comp t
    for comp in themes icons showdesk startmenu digitalclock sessionlock systray icontasks layout lookfeel; do
        t=$SECONDS
        printf '%s  --%s %s\n' "$BLU" "$END" "$comp"
        if PATH="$shim:$PATH" WM_BATCH=1 bash "$WM_DIR/scripts/install-$comp.sh"; then
            ok "$comp em $(( SECONDS-t ))s"
            WM_OK+=("$comp")
        else
            warn "componente $comp do Windows-Modern falhou"
            WM_FALHA+=("$comp")
        fi
    done
    rm -rf "$shim"
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum-dark
    kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.windowsmodern.dark
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSize Tiny
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false
    ok "Windows Modern: ${#WM_OK[@]} componentes ok, ${#WM_FALHA[@]} falharam; tema e layout sao aplicados no primeiro login (scripts/kde-layout-once.sh)"
}

summary() {
    local cor=$GRN titulo="instalacao concluida sem pendencias"
    if (( ${#OFICIAL_FALTANDO[@]} + ${#AUR_FALHA[@]} + ${#SERV_FALHA[@]} + ${#WM_FALHA[@]} )); then cor=$YEL; titulo="instalacao concluida COM pendencias"; fi
    printf '\n%s========================================================%s\n' "$cor" "$END"
    printf '%s  %s em %s%s\n' "$cor" "$titulo" "$(elapsed)" "$END"
    printf '%s========================================================%s\n\n' "$cor" "$END"
    printf 'dotfiles:   %s (branch %s), %d symlinks\n' "$DOTFILES_DIR" "$DOTFILES_BRANCH" "$LINKS"
    printf 'desktop:    KDE Plasma (Wayland) via sddm\n'
    if [[ $SKIP_NVIDIA == 1 ]]; then
        printf 'driver:     pulado (sem placa NVIDIA ou SKIP_NVIDIA=1)\n'
    else
        printf 'driver:     nvidia-open-dkms + %s\n' "${KERNEL_PARAMS[*]}"
    fi
    printf 'oficiais:   %d pedidos, %d pacotes novos no sistema, %d faltando\n' "$OFICIAL_PEDIDOS" "${#OFICIAL_NOVOS[@]}" "${#OFICIAL_FALTANDO[@]}"
    printf 'AUR:        %d instalados, %d ja estavam, %d falharam\n' "${#AUR_OK[@]}" "${#AUR_JA[@]}" "${#AUR_FALHA[@]}"
    printf 'servicos:   %d habilitados, %d falharam\n' "${#SERV_OK[@]}" "${#SERV_FALHA[@]}"
    printf 'claude:     %s\n' "$CLAUDE_VER"
    printf 'win-modern: %d componentes ok, %d falharam\n' "${#WM_OK[@]}" "${#WM_FALHA[@]}"
    printf 'log:        %s\n\n' "$LOGFILE"
    if (( ${#OFICIAL_FALTANDO[@]} )); then printf '%s  oficiais faltando:%s %s\n' "$RED" "$END" "${OFICIAL_FALTANDO[*]}"; fi
    if (( ${#AUR_FALHA[@]} )); then printf '%s  AUR que falharam:%s %s\n  refazer: paru -S --needed %s\n' "$RED" "$END" "${AUR_FALHA[*]}" "${AUR_FALHA[*]}"; fi
    if (( ${#SERV_FALHA[@]} )); then printf '%s  servicos nao habilitados:%s %s\n' "$RED" "$END" "${SERV_FALHA[*]}"; fi
    if (( ${#WM_FALHA[@]} )); then printf '%s  Windows Modern que falharam:%s %s\n  refazer: cd %s && ./install.sh <componente>\n' "$RED" "$END" "${WM_FALHA[*]}" "$WM_DIR"; fi
    if (( ${#WARNS[@]} )); then
        printf '\n%s  avisos durante a instalacao (%d):%s\n' "$YEL" "${#WARNS[@]}" "$END"
        printf '   - %s\n' "${WARNS[@]}"
    fi
    printf '\n'
    if [[ $SKIP_NVIDIA != 1 ]]; then
        printf '%s  ->%s confira depois do boot: cat /sys/module/nvidia_drm/parameters/modeset (tem que dar Y)\n' "$YEL" "$END"
    fi
    printf '%s  ->%s reinicie para carregar o kernel novo, o initramfs e os grupos do usuario\n' "$YEL" "$END"
    printf 'RedM em Wine (so dev): https://github.com/eualexandrerrr/RedMLinux (linux/setup-wine-redm.sh)\n'
}

main() {
    preflight
    enable_multilib
    sync_system
    install_official
    bootstrap_paru
    install_aur
    install_node_tools
    configure_nvidia
    enable_services
    fetch_dotfiles
    link_dotfiles
    configure_sddm
    configure_kde_defaults
    install_windows_modern
    summary
}

main "$@"
