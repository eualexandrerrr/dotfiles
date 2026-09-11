#!/usr/bin/env bash
# Pós-instalação do Arch: pacotes, NVIDIA, desktop, serviços e os pacotes stow deste repo.
# Idempotente: pode rodar de novo a qualquer hora.
#
#   SKIP_NVIDIA=1 ./install.sh    força pular driver e parâmetros de kernel
#   (sem a variável, detecta pelo PCI: sem placa NVIDIA = pula sozinho)
#
#   ./install.sh --de=gnome       instala esse desktop sem perguntar (ou DE=gnome ./install.sh)
#   (sem isso, pergunta; sem terminal interativo, assume kde)

set -uo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/eualexandrerrr/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

for arg in "$@"; do
    case "$arg" in
        --de=*) DE="${arg#--de=}" ;;
        *) printf 'uso: %s [--de=kde|gnome|xfce|hyprland]\n' "$0" >&2; exit 1 ;;
    esac
done
# Sem SKIP_NVIDIA na chamada, decide pelo hardware: vendor 0x10de em algum device PCI = NVIDIA.
if [[ -z ${SKIP_NVIDIA:-} ]]; then
    if grep -qsx 0x10de /sys/bus/pci/devices/*/vendor 2>/dev/null; then SKIP_NVIDIA=0; else SKIP_NVIDIA=1; fi
fi

KERNEL_PARAMS=(nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1)
NVIDIA_MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

RED=$'\e[1;31m'; GRN=$'\e[1;32m'; YEL=$'\e[1;33m'; BLU=$'\e[1;34m'; END=$'\e[0m'

LOGDIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
mkdir -p "$LOGDIR"
LOGFILE="${LOGFILE:-$LOGDIR/install.log}"
# Desktop escolhido. Fica no state do usuario, nao no repo: e escolha desta maquina, e o
# repo e publico. O setup.sh e o dot status leem daqui pra saber o que aplicar.
DEFILE="$LOGDIR/de"
T0=$SECONDS
STEP=0
TOTAL_STEPS=20
[[ ${SKIP_NVIDIA:-0} == 1 ]] && TOTAL_STEPS=19
WARNS=()
ETAPAS_FALHA=()
OFICIAL_PEDIDOS=0; OFICIAL_NOVOS=(); OFICIAL_FALTANDO=()
AUR_OK=(); AUR_JA=(); AUR_FALHA=()
SERV_OK=(); SERV_FALHA=()
CLAUDE_VER="nao instalado"
LINKS=0

elapsed() { local s=$((SECONDS - T0)); printf '%02d:%02d' $((s/60)) $((s%60)); }
log()  { STEP=$((STEP+1)); printf '\n%s==>%s [%d/%d] %s %s(%s)%s\n' "$BLU" "$END" "$STEP" "$TOTAL_STEPS" "$*" "$YEL" "$(elapsed)" "$END"; }
ok()   { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
warn() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*"; WARNS+=("[etapa $STEP] $*"); }
die()  { printf '\n%serro:%s %s\n' "$RED" "$END" "$*" >&2; printf '%sparou na etapa %d/%d apos %s. Log completo: %s%s\n' "$RED" "$STEP" "$TOTAL_STEPS" "$(elapsed)" "$LOGFILE" "$END" >&2; exit 1; }
etapa() {
    local fn="$1" rc=0
    "$fn" || rc=$?
    if (( rc )); then
        printf '%s  !!%s etapa %s falhou (saida %d), seguindo para a proxima\n' "$RED" "$END" "$fn" "$rc" >&2
        WARNS+=("[etapa $STEP] $fn falhou")
        ETAPAS_FALHA+=("$fn")
    fi
    return 0
}

exec > >(tee -a "$LOGFILE") 2>&1
printf '%s==>%s dotfiles install.sh iniciado em %s, log em %s\n' "$BLU" "$END" "$(date '+%d/%m/%Y %H:%M:%S')" "$LOGFILE"

need_sudo() {
    sudo -v || die "sudo obrigatorio"
    while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
}

# ---------------------------------------------------------------- desktop escolhido
# Tudo que muda de um desktop pro outro mora nesta tabela: nome da sessao do DM, o DM em si
# e os binarios que provam que ele subiu. Adicionar um desktop novo e acrescentar uma linha
# aqui e um packages/<nome>.txt -- nada mais no script sabe nome de desktop.
DES_VALIDOS=(kde gnome xfce hyprland)

de_sessao() {
    case "$1" in
        kde)      printf 'plasma'    ;;
        gnome)    printf 'gnome'     ;;
        xfce)     printf 'xfce'      ;;
        hyprland) printf 'hyprland'  ;;
    esac
}

de_dm() {
    case "$1" in
        gnome) printf 'gdm'  ;;
        *)     printf 'sddm' ;;
    esac
}

de_binarios() {
    case "$1" in
        kde)      printf 'startplasma-wayland plasmashell systemsettings' ;;
        gnome)    printf 'gnome-shell nautilus'                           ;;
        xfce)     printf 'xfce4-session thunar'                           ;;
        hyprland) printf 'Hyprland waybar'                                ;;
    esac
}

de_valido() {
    local d
    for d in "${DES_VALIDOS[@]}"; do [[ $1 == "$d" ]] && return 0; done
    return 1
}

# Ordem: --de=<nome> > variavel DE > escolha gravada da ultima vez > pergunta > kde.
# So pergunta com terminal interativo: a ISO do myarch roda este script sem ninguem na
# frente, e prompt sem tty penduraria a instalacao inteira.
escolher_de() {
    if [[ -n ${DE:-} ]]; then
        de_valido "$DE" || die "desktop invalido: $DE (use: ${DES_VALIDOS[*]})"
    elif [[ -f $DEFILE ]] && de_valido "$(<"$DEFILE")"; then
        DE="$(<"$DEFILE")"
        ok "desktop ja escolhido antes: $DE"
    elif [[ -t 0 ]]; then
        printf '%s\n' "${BLU}==>${END} qual desktop instalar?"
        local escolha
        select escolha in "${DES_VALIDOS[@]}"; do
            [[ -n $escolha ]] && { DE="$escolha"; break; }
            printf '%s\n' "  escolha um numero de 1 a ${#DES_VALIDOS[@]}"
        done
    else
        DE=kde
        warn "sem terminal interativo, assumindo desktop $DE"
    fi

    printf '%s\n' "$DE" > "$DEFILE"
    ok "desktop: $DE (sessao $(de_sessao "$DE").desktop, login por $(de_dm "$DE"))"
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

# Lista do desktop escolhido, ao lado do packages.txt da base. Silencioso se nao existir:
# quem instala um DE sem lista propria so leva a base.
defile() {
    local base; base="$(dirname "$(pkgfile)")"
    local f="$base/packages/$DE.txt"
    [[ -f $f ]] && printf '%s' "$f"
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
    log "pacman: downloads paralelos, cor"
    # multilib nao entra mais: era so pros lib32-* de Wine, Steam e Proton, que sairam do
    # host junto com os jogos. Se ja estiver ativo de uma instalacao antiga, fica -- nao
    # custa nada e tirar repo de pacman.conf de terceiro nao e papel deste script.
    set_pacman_option ParallelDownloads 10
    grep -qE '^Color' /etc/pacman.conf || sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
    sudo pacman -Syy --noconfirm
}

sync_system() {
    log "atualizando o sistema"
    sudo pacman -Syu --noconfirm --needed || warn "pacman -Syu falhou, seguindo com o que ja esta no disco"
    sudo pacman -S --noconfirm --needed archlinux-keyring base-devel git stow \
        || die "sem git e stow nao da pra clonar nem linkar os dotfiles"
    ok "sistema atualizado, git e stow presentes"
}

install_official() {
    local file defile pkgs
    file="$(pkgfile)"
    defile="$(defile)"
    mapfile -t pkgs < <(read_section "$file" '^repo-oficial'
                        [[ -n $defile ]] && read_section "$defile" '^repo-oficial')
    if [[ $SKIP_NVIDIA == 1 ]]; then
        mapfile -t pkgs < <(printf '%s\n' "${pkgs[@]}" | grep -vE '^(nvidia|lib32-nvidia|libva-nvidia|egl-wayland)')
    fi
    [[ ${#pkgs[@]} -gt 0 ]] || die "nenhum pacote oficial lido de $file"
    log "instalando ${#pkgs[@]} pacotes dos repos oficiais"
    OFICIAL_PEDIDOS=${#pkgs[@]}
    local antes depois p
    antes="$(pacman -Qq | sort)"
    local ja=0
    local instalados
    instalados="$(pacman -Qq)"
    for p in "${pkgs[@]}"; do grep -qx "$p" <<<"$instalados" && ja=$((ja+1)); done
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
    instalados="$(pacman -Qq)"
    for p in "${pkgs[@]}"; do grep -qx "$p" <<<"$instalados" || OFICIAL_FALTANDO+=("$p"); done
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
    sudo pacman -S --noconfirm --needed rust || { warn "rust nao instalou, paru fica de fora"; return 1; }
    local build
    build="$(mktemp -d)"
    if ! git clone --depth 1 https://aur.archlinux.org/paru.git "$build/paru"; then
        rm -rf "$build"
        warn "clone do paru falhou, pacotes do AUR ficam de fora"
        return 1
    fi
    ( cd "$build/paru" && makepkg -si --noconfirm --needed ) || warn "build do paru falhou"
    rm -rf "$build"
    paru --version >/dev/null 2>&1 || { warn "paru nao roda apos o build, pacotes do AUR ficam de fora"; return 1; }
    ok "paru instalado: $(paru --version | head -1)"
}

install_aur() {
    local file defile pkgs p
    command -v paru >/dev/null 2>&1 || { log "AUR"; warn "paru ausente, etapa do AUR pulada"; return 1; }
    file="$(pkgfile)"
    defile="$(defile)"
    mapfile -t pkgs < <({ read_section "$file" '^aur$'
                          [[ -n $defile ]] && read_section "$defile" '^aur$'; } | grep -vxE 'paru|paru-bin')
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

install_android_sdk() {
    log "Android SDK e AVDs de desenvolvimento"
    if [[ ! -x "$DOTFILES_DIR/bin/android-sdk.sh" ]]; then
        warn "bin/android-sdk.sh nao encontrado; pulando"
        return
    fi
    bash "$DOTFILES_DIR/bin/android-sdk.sh" tudo || warn "android-sdk.sh terminou com aviso -- rode na mao depois"
}

add_kernel_params() {
    local params=("$@")
    [[ ${#params[@]} -eq 0 ]] && params=("${KERNEL_PARAMS[@]}")
    log "gravando parametros de kernel: ${params[*]}"
    bash "$DOTFILES_DIR/bin/kernel-params.sh" "${params[@]}" \
        || warn "parametros de kernel nao gravados"
}

configure_resiliencia_boot() {
    log "resiliencia de boot: fsck automatico, sysrq e ext4 remount-ro"

    add_kernel_params fsck.repair=yes

    printf 'kernel.sysrq = 1\n' | sudo tee /etc/sysctl.d/99-sysrq.conf >/dev/null \
        && sudo sysctl --system >/dev/null 2>&1
    ok "sysrq completo habilitado (REISUB no lugar do botao de power)"

    local dev
    while read -r dev; do
        [[ -b $dev ]] || continue
        sudo tune2fs -e remount-ro "$dev" >/dev/null 2>&1 \
            && ok "$dev: erro de ext4 agora remonta somente-leitura" \
            || warn "tune2fs falhou em $dev"
    done < <(findmnt -no SOURCE,FSTYPE | awk '$2=="ext4"{print $1}' | sort -u)
}

configure_nvidia() {
    if [[ $SKIP_NVIDIA == 1 ]]; then
        warn "SKIP_NVIDIA=1: driver e parametros de kernel pulados"
        return 0
    fi
    log "configurando driver nvidia"

    local mudou=0

    escrever_se_diferente() {
        local destino="$1" conteudo="$2"
        if sudo test -f "$destino" && printf '%s' "$conteudo" | sudo cmp -s - "$destino"; then
            return 1
        fi
        printf '%s' "$conteudo" | sudo tee "$destino" >/dev/null
        return 0
    }

    if escrever_se_diferente /etc/modprobe.d/nvidia.conf \
        'options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
'; then
        mudou=1
        ok "/etc/modprobe.d/nvidia.conf"
    else
        ok "/etc/modprobe.d/nvidia.conf ja correto"
    fi

    if escrever_se_diferente /etc/modprobe.d/blacklist-nouveau.conf \
        'blacklist nouveau
options nouveau modeset=0
'; then
        mudou=1
        ok "nouveau bloqueado"
    else
        ok "nouveau ja bloqueado"
    fi

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
        mudou=1
        ok "mkinitcpio MODULES: ${missing[*]}"
    else
        ok "mkinitcpio ja tem os modulos"
    fi

    add_kernel_params

    # mkinitcpio -P leva ~25s e e a etapa mais cara do script. So vale rodar quando algo
    # que entra na imagem mudou, ou quando a imagem esta mais velha que o kernel (upgrade
    # de pacote que ainda nao foi refletido).
    local img="/boot/initramfs-linux-zen.img" kern="/usr/lib/modules"
    if [[ $mudou -eq 0 ]] && sudo test -f "$img" && [[ -z "$(find "$kern" -maxdepth 1 -newer "$img" -print -quit 2>/dev/null)" ]]; then
        ok "initramfs em dia, mkinitcpio pulado"
    else
        sudo mkinitcpio -P || warn "mkinitcpio -P falhou, refaca na mao depois"
    fi

    local unit
    for unit in nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service; do
        sudo systemctl enable "$unit" >/dev/null 2>&1 || true
    done
    ok "driver nvidia configurado"
}

enable_services() {
    log "habilitando servicos"
    local unit
    # fstrim mantem o TRIM do NVMe, paccache poda o cache do pacman e o resolved e quem o
    # bin/dns-fastest.sh alimenta -- os tres estavam ligados na mao e sumiriam no format.
    for unit in NetworkManager.service "$(de_dm "$DE").service" ananicy-cpp.service reflector.timer rtkit-daemon.service \
                fstrim.timer paccache.timer systemd-resolved.service; do
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

    # input: dono dos /dev/input/event*. E o que deixa a trava de teclado do
    # painel do segundo monitor pegar o teclado por EVIOCGRAB sem virar root.
    local grp
    for grp in docker libvirt video input; do
        getent group "$grp" >/dev/null 2>&1 || continue
        id -nG "$USER" | tr ' ' '\n' | grep -qx "$grp" || { sudo usermod -aG "$grp" "$USER"; ok "usuario adicionado ao grupo $grp"; }
    done

    systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service >/dev/null 2>&1 || true
    ok "servicos prontos"
}

fetch_dotfiles() {
    log "obtendo dotfiles"
    if [[ -d $DOTFILES_DIR/.git ]]; then
        git -C "$DOTFILES_DIR" fetch --quiet origin "$DOTFILES_BRANCH"
        git -C "$DOTFILES_DIR" checkout --quiet "$DOTFILES_BRANCH"
        git -C "$DOTFILES_DIR" pull --ff-only origin "$DOTFILES_BRANCH" || warn "pull nao aplicado, arvore local divergente"
        ok "dotfiles atualizados em $DOTFILES_DIR"
    else
        git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR" \
            || die "clone de $DOTFILES_REPO falhou, sem os dotfiles nao ha o que configurar"
        ok "dotfiles clonados em $DOTFILES_DIR"
    fi
}

backup_conflict() {
    # Limpa o caminho de um link que o stow vai criar. Tres casos:
    #   symlink pro repo que ainda resolve -> e o proprio stow, deixa
    #   symlink pro repo que nao resolve   -> resto de esquema antigo (links/, stow/), remove
    #   arquivo real ou link pra fora      -> backup com carimbo
    # Sobe pelos diretorios pais tambem: ~/.config/ghostty era symlink de DIRETORIO no
    # esquema antigo, e o stow precisa dele como diretorio de verdade pra por o link dentro.
    local target="$1" repo
    repo="$(readlink -f "$DOTFILES_DIR")"

    local caminho="$target"
    while [[ $caminho != "$HOME" && $caminho == "$HOME"/* ]]; do
        if [[ -L $caminho ]]; then
            local alvo
            alvo="$(readlink "$caminho")"
            [[ $alvo != /* ]] && alvo="$(dirname "$caminho")/$alvo"
            alvo="$(readlink -m "$alvo")"
            if [[ $alvo == "$repo"/* ]]; then
                if [[ -e $alvo ]]; then
                    return 0
                fi
                rm -f "$caminho"
                ok "$(basename "$caminho") era link de esquema antigo, removido"
            else
                local stamp
                stamp="$(date +%Y%m%d%H%M%S)"
                mv "$caminho" "$caminho.bak-$stamp"
                warn "$(basename "$caminho") era link pra fora do repo, movido para .bak-$stamp"
            fi
        elif [[ -f $caminho ]]; then
            local stamp
            stamp="$(date +%Y%m%d%H%M%S)"
            mv "$caminho" "$caminho.bak-$stamp"
            warn "$(basename "$caminho") existia, movido para $(basename "$caminho").bak-$stamp"
        fi
        caminho="$(dirname "$caminho")"
    done
}

link_dotfiles() {
    log "linkando com stow"
    command -v stow >/dev/null 2>&1 || die "stow nao instalado (esta no packages.txt, a etapa 3 deveria ter trazido)"
    local stowdir="$DOTFILES_DIR"

    # Os pacotes ficam na raiz do repo, um por programa, e espelham o $HOME: zsh/.zshrc vira
    # ~/.zshrc, git/.gitconfig vira ~/.gitconfig. O que distingue um pacote de uma
    # pasta de ferramenta (bin, vm, wallpaper, perfil) e ter uma entrada com ponto na
    # raiz -- .config, .local, .zshrc -- porque isso e o que o stow vai espelhar.
    #
    # --no-folding e obrigatorio: sem ele o stow linka o DIRETORIO inteiro quando ele nao
    # existe no destino, e ai ~/.local/share/applications viraria um symlink pro repo -- o
    # Chrome e os apps escrevem la, e essas gravacoes cairiam dentro do git. Com --no-folding
    # ele cria os diretorios de verdade e linka so os arquivos, que e o comportamento antigo.
    #
    # -R (restow) desfaz e refaz: arquivo que saiu do repo perde o link, arquivo novo ganha.
    local pkg nome
    for pkg in "$stowdir"/*/; do
        nome="$(basename "$pkg")"
        [[ $nome == .git ]] && continue
        find "$pkg" -mindepth 1 -maxdepth 1 -name '.*' -print -quit 2>/dev/null | grep -q . || continue
        # Backup de qualquer arquivo real que esteja no caminho de um link deste pacote.
        # O stow se recusa a sobrescrever, entao isso tem que vir antes.
        while IFS= read -r -d '' src; do
            local rel="${src#"$pkg"}"
            backup_conflict "$HOME/$rel"
        done < <(find "$pkg" -type f -print0)

        if stow --no-folding --restow --target="$HOME" --dir="$stowdir" "$nome" 2>"$LOGFILE.stow"; then
            local n
            n="$(find "$pkg" -type f | wc -l)"
            LINKS=$((LINKS+n))
            ok "$nome ($n arquivos)"
        else
            warn "stow falhou em $nome: $(tr '\n' ' ' <"$LOGFILE.stow")"
        fi
    done
    rm -f "$LOGFILE.stow"

    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
    ok "$LINKS arquivos linkados"
}

home_enxuta() {
    log "home enxuta: so Downloads e as pastas de trabalho"
    DOTFILES_DIR="$DOTFILES_DIR" bash "$DOTFILES_DIR/setup.sh" home \
        && ok "pastas padrao do XDG fora" \
        || warn "alguma pasta padrao nao estava vazia, confira o aviso acima"
}

restaurar_segredos() {
    log "credenciais do secret-keys"
    local script="$DOTFILES_DIR/secrets/restore.sh"
    [[ -f $script ]] || { warn "$script ausente, credenciais nao restauradas"; return 0; }

    # Nunca fatal: sem pendrive, sem rede ou sem repo privado a instalacao segue. O
    # restaurar.sh ja sai com 0 nesses casos e explica o motivo.
    DOTFILES_DIR="$DOTFILES_DIR" bash "$script" || true
}

clonar_central() {
    log "central de conhecimento (repo privado Claude)"
    local destino="$HOME/Claude"
    local repo="${CLAUDE_REPO:-git@github.com:eualexandrerrr/Claude.git}"

    if [[ -d $destino/.git ]]; then
        ok "$destino ja clonado"
        return 0
    fi

    # Nunca fatal: sem chave SSH a instalacao segue e a etapa claude do setup.sh avisa
    # sozinha. O que nao pode e este repositorio, que e publico, guardar o conteudo dela.
    if git clone --quiet "$repo" "$destino" 2>/dev/null; then
        ok "$destino clonado"
    else
        warn "sem acesso a $repo -- depois rode: git clone $repo $destino"
    fi
}

sessao_wayland() {
    # Cada DE instala o proprio .desktop de sessao; nao ha nada pra escrever a mao aqui.
    printf '%s.desktop' "$(de_sessao "$DE")"
}




configure_login() {
    local dm sessao
    dm="$(de_dm "$DE")"
    sessao="$(sessao_wayland)"
    log "configurando $dm (sessao $sessao, login automatico)"

    # XFCE e X11, o resto e Wayland -- por isso procura nos dois diretorios de sessao.
    [[ -f /usr/share/wayland-sessions/$sessao || -f /usr/share/xsessions/$sessao ]] \
        || warn "$DE nao esta instalado, o $dm nao vai ter sessao pra subir"

    if [[ $dm == gdm ]]; then
        # O gdm nao tem conf.d: o autologin mora no custom.conf dele, em formato ini.
        sudo mkdir -p /etc/gdm
        cat <<EOF | sudo tee /etc/gdm/custom.conf >/dev/null
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=$USER
EOF
        ok "/etc/gdm/custom.conf (login automatico de $USER)"
        return 0
    fi

    sudo mkdir -p /etc/sddm.conf.d
    # Login automatico. Relogin=false faz valer so na PRIMEIRA subida do sddm, que sao
    # exatamente os dois casos desejados: ligar o PC, e a volta da VM w11 (o hook para e
    # sobe o display-manager de novo). Sair da sessao na mao cai no greeter, com senha.
    # O disco nao e criptografado, entao isso nao troca seguranca por conveniencia:
    # quem tem o gabinete ja tinha os dados. Bloquear a tela (Meta+L) continua pedindo senha.
    # Heredoc sem aspas de proposito: o $USER precisa expandir aqui.
    cat <<EOF | sudo tee /etc/sddm.conf.d/10-dotfiles.conf >/dev/null
[General]
DisplayServer=$([[ $DE == xfce ]] && printf x11 || printf wayland)
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Autologin]
User=$USER
Session=$sessao
Relogin=false

EOF
    ok "/etc/sddm.conf.d/10-dotfiles.conf (login automatico de $USER em $sessao)"
}


install_maestro() {
    log "maestro cli"
    local sh="$DOTFILES_DIR/bin/maestro.sh"
    [[ -f $sh ]] || { warn "bin/maestro.sh ausente, pulando"; return 1; }
    if bash "$sh"; then
        ok "maestro pronto"
    else
        warn "maestro nao entrou; depois rode: bash ~/.dotfiles/bin/maestro.sh"
        return 1
    fi
}

install_vencord() {
    log "vencord (fork eualexandrerrr/Vencord) injetado no Discord"
    local sh="$DOTFILES_DIR/bin/vencord.sh"
    [[ -f $sh ]] || { warn "bin/vencord.sh ausente, pulando"; return 1; }
    if bash "$sh"; then
        ok "vencord injetado"
    else
        warn "vencord nao injetou; depois rode: bash ~/.dotfiles/bin/vencord.sh"
        return 1
    fi
}


summary() {
    local cor=$GRN titulo="instalacao concluida sem pendencias"
    if (( ${#OFICIAL_FALTANDO[@]} + ${#AUR_FALHA[@]} + ${#SERV_FALHA[@]} + ${#ETAPAS_FALHA[@]} )); then cor=$YEL; titulo="instalacao concluida COM pendencias"; fi
    printf '\n%s========================================================%s\n' "$cor" "$END"
    printf '%s  %s em %s%s\n' "$cor" "$titulo" "$(elapsed)" "$END"
    printf '%s========================================================%s\n\n' "$cor" "$END"
    printf 'dotfiles:   %s (branch %s), %d arquivos via stow\n' "$DOTFILES_DIR" "$DOTFILES_BRANCH" "$LINKS"
    printf 'desktop:    %s via %s\n' "$DE" "$(de_dm "$DE")"
    if [[ $SKIP_NVIDIA == 1 ]]; then
        printf 'driver:     pulado (sem placa NVIDIA ou SKIP_NVIDIA=1)\n'
    else
        printf 'driver:     nvidia-open-dkms + %s\n' "${KERNEL_PARAMS[*]}"
    fi
    printf 'oficiais:   %d pedidos, %d pacotes novos no sistema, %d faltando\n' "$OFICIAL_PEDIDOS" "${#OFICIAL_NOVOS[@]}" "${#OFICIAL_FALTANDO[@]}"
    printf 'AUR:        %d instalados, %d ja estavam, %d falharam\n' "${#AUR_OK[@]}" "${#AUR_JA[@]}" "${#AUR_FALHA[@]}"
    printf 'servicos:   %d habilitados, %d falharam\n' "${#SERV_OK[@]}" "${#SERV_FALHA[@]}"
    printf 'claude:     %s\n' "$CLAUDE_VER"
    if [[ $DE == kde ]]; then
        printf 'shell:      Plasma padrao: painel, KRunner, Klipper e Spectacle nativos\n'
    else
        printf 'shell:      %s de fabrica -- este repo nao versiona config de %s\n' "$DE" "$DE"
    fi
    printf 'log:        %s\n\n' "$LOGFILE"
    if (( ${#OFICIAL_FALTANDO[@]} )); then printf '%s  oficiais faltando:%s %s\n' "$RED" "$END" "${OFICIAL_FALTANDO[*]}"; fi
    if (( ${#AUR_FALHA[@]} )); then printf '%s  AUR que falharam:%s %s\n  refazer: paru -S --needed %s\n' "$RED" "$END" "${AUR_FALHA[*]}" "${AUR_FALHA[*]}"; fi
    if (( ${#SERV_FALHA[@]} )); then printf '%s  servicos nao habilitados:%s %s\n' "$RED" "$END" "${SERV_FALHA[*]}"; fi
    if (( ${#ETAPAS_FALHA[@]} )); then printf '%s  etapas que falharam:%s %s\n' "$RED" "$END" "${ETAPAS_FALHA[*]}"; fi
    if (( ${#WARNS[@]} )); then
        printf '\n%s  avisos durante a instalacao (%d):%s\n' "$YEL" "${#WARNS[@]}" "$END"
        printf '   - %s\n' "${WARNS[@]}"
    fi
    printf '\n'
    if [[ $SKIP_NVIDIA != 1 ]]; then
        printf '%s  ->%s confira depois do boot: cat /sys/module/nvidia_drm/parameters/modeset (tem que dar Y)\n' "$YEL" "$END"
    fi
    printf '%s  ->%s reinicie para carregar o kernel novo, o initramfs e os grupos do usuario\n' "$YEL" "$END"
    printf '%s  ->%s no %s a sessao e "%s"; trocar de desktop: ./install.sh --de=<nome>\n' "$YEL" "$END" "$(de_dm "$DE")" "$(sessao_wayland)"
    printf '%s  ->%s dot status confere o desktop, dot erros mostra os avisos, dot instalar roda isto de novo\n' "$YEL" "$END"
    printf '%s  ->%s se o desktop nao subir: pendrive, opcao 4 do menu do live reinstala sem formatar\n' "$YEL" "$END"
}

verificar() {
    log "conferindo o que precisa estar de pe pro desktop subir"
    local faltou=0
    local bin dm conf
    dm="$(de_dm "$DE")"
    for bin in $(de_binarios "$DE") stow; do
        command -v "$bin" >/dev/null 2>&1 || { printf '%s  !!%s %s nao instalado\n' "$RED" "$END" "$bin"; WARNS+=("$bin ausente"); faltou=1; }
    done

    # Conferir e avisar nao serve de nada aqui: se o DM nao esta habilitado o proximo boot
    # cai na tty, e quem le o aviso ja esta sem desktop. Entao tenta habilitar na hora. O
    # enable dentro de chroot as vezes nao pega (a opcao 4 do myarch passa por aqui), e e
    # justamente nesse caso que o usuario nao tem como perceber antes de reiniciar.
    if systemctl is-enabled "$dm.service" >/dev/null 2>&1; then
        ok "$dm habilitado"
    elif sudo systemctl enable "$dm.service" >/dev/null 2>&1; then
        ok "$dm nao estava habilitado, habilitado agora"
    else
        printf '%s  !!%s %s nao habilitado e nao consegui habilitar, o boot cai na tty\n' "$RED" "$END" "$dm"
        WARNS+=("$dm nao habilitado")
        faltou=1
    fi

    [[ $dm == gdm ]] && conf=/etc/gdm/custom.conf || conf=/etc/sddm.conf.d/10-dotfiles.conf
    [[ -f $conf ]] \
        && ok "autologin configurado" \
        || { warn "$conf ausente"; faltou=1; }

    if (( faltou )); then
        printf '%s  ->%s detalhes: dot erros    conferir de novo: dot status    reinstalar: dot instalar\n' "$YEL" "$END"
        return 1
    fi
    ok "tudo que o desktop precisa esta no lugar"
    return 0
}

main() {
    preflight
    escolher_de
    etapa enable_multilib
    etapa sync_system
    etapa fetch_dotfiles
    etapa link_dotfiles
    etapa install_official
    etapa bootstrap_paru
    etapa install_aur
    etapa install_node_tools
    etapa install_android_sdk
    etapa install_maestro
    etapa install_vencord
    etapa configure_nvidia
    etapa configure_resiliencia_boot
    etapa enable_services
    etapa link_dotfiles
    etapa home_enxuta
    etapa restaurar_segredos
    etapa clonar_central
    etapa configure_login
    etapa verificar
    summary
}

main "$@"
