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

log()  { printf '%s==>%s %s\n' "$BLU" "$END" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
warn() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*"; }
die()  { printf '%serro:%s %s\n' "$RED" "$END" "$*" >&2; exit 1; }

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
    sudo pacman -Syy --noconfirm >/dev/null
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
    sudo pacman -S --noconfirm --needed "${pkgs[@]}"
    ok "pacotes oficiais instalados"
}

bootstrap_paru() {
    log "instalando paru"
    if command -v paru >/dev/null 2>&1; then
        ok "paru ja instalado: $(paru --version | head -1)"
        return 0
    fi
    local build
    build="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$build/paru-bin"
    ( cd "$build/paru-bin" && makepkg -si --noconfirm --needed )
    rm -rf "$build"
    command -v paru >/dev/null 2>&1 || die "paru nao ficou disponivel apos o build"
    ok "paru instalado"
}

install_aur() {
    local file pkgs p
    file="$(pkgfile)"
    mapfile -t pkgs < <(read_section "$file" '^aur$' | grep -vx paru-bin)
    [[ ${#pkgs[@]} -gt 0 ]] || { warn "nenhum pacote AUR na lista"; return 0; }
    log "instalando ${#pkgs[@]} pacotes do AUR"
    for p in "${pkgs[@]}"; do
        if paru -Qq "$p" >/dev/null 2>&1; then
            ok "$p ja instalado"
        elif paru -S --noconfirm --needed --skipreview "$p"; then
            ok "$p instalado"
        else
            warn "$p falhou, seguindo"
        fi
    done
}

add_kernel_params() {
    log "gravando parametros de kernel da nvidia"
    local applied=0 p entry

    if [[ -d /boot/loader/entries ]] && command -v bootctl >/dev/null 2>&1; then
        shopt -s nullglob
        for entry in /boot/loader/entries/*.conf; do
            grep -qE '^options ' "$entry" || continue
            for p in "${KERNEL_PARAMS[@]}"; do
                grep -qF -- "$p" "$entry" || sudo sed -i "s|^options .*|& $p|" "$entry"
            done
            applied=1
            ok "systemd-boot: $(basename "$entry")"
        done
        shopt -u nullglob
    fi

    if [[ -f /etc/kernel/cmdline ]]; then
        for p in "${KERNEL_PARAMS[@]}"; do
            grep -qF -- "$p" /etc/kernel/cmdline || printf ' %s' "$p" | sudo tee -a /etc/kernel/cmdline >/dev/null
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
        sudo systemctl enable "$unit" >/dev/null 2>&1 && ok "$unit" || warn "$unit nao habilitado"
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
        sudo systemctl start power-profiles-daemon.service >/dev/null 2>&1 || true
        powerprofilesctl set performance >/dev/null 2>&1 && ok "perfil de energia: performance" || warn "power-profiles-daemon nao respondeu, ajuste no primeiro login"
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
        ok ".config/$name"
    done

    shopt -s dotglob nullglob
    for src in "$DOTFILES_DIR"/home/*; do
        [[ -f $src ]] || continue
        name="$(basename "$src")"
        target="$HOME/$name"
        backup_conflict "$target"
        ln -sfn "$src" "$target"
        ok "~/$name"
    done
    shopt -u dotglob nullglob

    ok "symlinks aplicados"
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
    log "padroes do KDE: teclado ABNT2, kitty como terminal, icones Tela, cursor Capitaine"
    mkdir -p "$HOME/.config"
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file kxkbrc --group Layout --key LayoutList br
        kwriteconfig6 --file kxkbrc --group Layout --key Use true
        kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
        kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop
        if [[ -d /usr/share/icons/Tela-dark ]]; then
            kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-dark
            ok "icones Tela-dark"
        fi
        if [[ -d /usr/share/icons/capitaine-cursors-white ]]; then
            kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme capitaine-cursors-white
            kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 24
            ok "cursor capitaine-cursors-white"
        fi
        ok "kxkbrc e kdeglobals"
    else
        warn "kwriteconfig6 nao encontrado, ajuste teclado e terminal padrao nas Configuracoes do Sistema"
    fi
}

summary() {
    printf '\n%s================================%s\n' "$GRN" "$END"
    printf '%s  instalacao concluida%s\n' "$GRN" "$END"
    printf '%s================================%s\n\n' "$GRN" "$END"
    printf 'dotfiles:  %s (branch %s)\n' "$DOTFILES_DIR" "$DOTFILES_BRANCH"
    printf 'desktop:   KDE Plasma (Wayland) via sddm\n'
    if [[ $SKIP_NVIDIA == 1 ]]; then
        printf 'driver:    pulado (SKIP_NVIDIA=1)\n\n'
    else
        printf 'driver:    nvidia-open-dkms + %s\n\n' "${KERNEL_PARAMS[*]}"
        warn "confira depois do boot: cat /sys/module/nvidia_drm/parameters/modeset (tem que dar Y)"
    fi
    warn "reinicie para carregar o kernel novo, o initramfs e os grupos do usuario"
    printf 'RedM em Wine (so dev): https://github.com/eualexandrerrr/RedMLinux (linux/setup-wine-redm.sh)\n'
}

main() {
    preflight
    enable_multilib
    sync_system
    install_official
    bootstrap_paru
    install_aur
    configure_nvidia
    enable_services
    fetch_dotfiles
    link_dotfiles
    configure_sddm
    configure_kde_defaults
    summary
}

main "$@"
