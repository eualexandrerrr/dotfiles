#!/usr/bin/env bash
# Vypr: uma aplicacao da VM Windows (RedM, o que for) como janela nativa do desktop Linux,
# frames por memoria compartilhada (IVSHMEM), sem RDP e sem codec. Fork em
# github.com/eualexandrerrr/Vypr (Unlicense; upstream Amzi-01/Vypr), branch `main` = nossos
# patches, `upstream` = espelho -- mesmo modelo dos forks do COSMIC.
#
#   vypr.sh            clona/atualiza o fork, compila, instala em ~/.local/bin, prepara o host
#   vypr.sh estado     o que esta instalado e o que falta
#   vypr.sh guest      manda o vypr-setup.exe pra dentro da VM ligada e abre ele la
#   vypr.sh rebase     traz o upstream e rebase os patches
#
# O que o instalador deles faria e que aqui mora em outro lugar: o <shmem name='vypr'> e a
# saida do tablet USB estao no vm/w11-3090.xml (o w11 redefine o dominio a cada partida, entao
# mexer no dominio vivo nao adianta); a regra tmpfiles do /dev/shm/vypr esta no
# vm/looking-glass.tmpfiles, instalada pelo vm/prepare.sh. O audio continua pelo pipewire
# do XML (o deles troca pra pulseaudio e poe o qemu rodando como o usuario; nao precisamos).
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
REPO="${VYPR_DIR:-$HOME/Apps/desktop/Vypr}"
RAMO="main"
ESPELHO="upstream"
BIN="$HOME/.local/bin"
ESTADO="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/vypr"
SHM=/dev/shm/vypr
SHM_MB=512
CHAVE="$HOME/.ssh/vypr-guest"
VM="${VM:-w11}"
GUEST_USER="${GUEST_USER:-Alexandre}"
SETUP_EXE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/vypr-setup.exe"
mkdir -p "$BIN" "$ESTADO" "$CONF/apps"

ok()   { printf '  ok %s\n' "$*"; }
warn() { printf '  !! %s\n' "$*"; }
v()    { virsh -c qemu:///system "$@"; }

sincronizar() {
    if [[ -d $REPO/.git ]]; then
        git -C "$REPO" fetch -q origin 2>/dev/null
        git -C "$REPO" checkout -q "$RAMO" 2>/dev/null
        git -C "$REPO" merge -q --ff-only "origin/$RAMO" 2>/dev/null
    else
        mkdir -p "$(dirname "$REPO")"
        git clone -q -b "$RAMO" git@github.com:eualexandrerrr/Vypr.git "$REPO" || { warn "clone do fork falhou"; return 1; }
        git -C "$REPO" remote add upstream https://github.com/Amzi-01/Vypr.git 2>/dev/null
    fi
}

compilar() {
    sincronizar || return 1
    local head marca="$ESTADO/fork-vypr.commit"
    head="$(git -C "$REPO" rev-parse HEAD)"
    if [[ -x $BIN/vyprd && -x $BIN/vypr-window && -x $BIN/vypr && -f $marca && $(<"$marca") == "$head" ]]; then
        ok "vypr ja esta no commit ${head:0:8}"
    else
        for dep in cmake ninja g++ ssh; do
            command -v "$dep" >/dev/null 2>&1 || { warn "$dep nao instalado (packages.txt: sdl3, ninja)"; return 1; }
        done
        pkg-config --exists sdl3 2>/dev/null || { warn "sdl3 nao instalado"; return 1; }
        printf '  compilando o vypr (%s)...\n' "${head:0:8}"
        if (cd "$REPO/host" && cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release >"$ESTADO/fork-vypr.log" 2>&1 \
                && cmake --build build >>"$ESTADO/fork-vypr.log" 2>&1); then
            install -Dm755 "$REPO/host/build/vyprd" "$BIN/vyprd"
            install -Dm755 "$REPO/host/build/vypr-window" "$BIN/vypr-window"
            install -Dm755 "$REPO/launcher/vypr" "$BIN/vypr"
            install -Dm644 "$REPO/launcher/vypr.png" "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/256x256/apps/vypr.png"
            printf '%s' "$head" >"$marca"
            ok "vyprd, vypr-window e vypr instalados em $BIN"
        else
            warn "build do vypr falhou -- veja $ESTADO/fork-vypr.log"
            return 1
        fi
    fi
}

# A regiao existe desde o boot pelo tmpfiles (vm/looking-glass.tmpfiles), mas nasce vazia:
# o launcher deles cresce ela antes de ligar a VM. Aqui garante o mesmo sem precisar do launcher.
regiao() {
    if [[ ! -e $SHM ]]; then
        install -m 0660 /dev/null "$SHM" 2>/dev/null && chgrp kvm "$SHM" 2>/dev/null
    fi
    [[ $(stat -c %s "$SHM" 2>/dev/null || echo 0) -ge $((SHM_MB * 1024 * 1024)) ]] || truncate -s "${SHM_MB}M" "$SHM"
    [[ -w $SHM ]] && ok "$SHM (${SHM_MB} MB)" || warn "$SHM nao gravavel"
}

chave() {
    if [[ ! -f $CHAVE ]]; then
        ssh-keygen -q -t ed25519 -f "$CHAVE" -N "" -C "vypr (host -> guest)" && ok "chave $CHAVE criada"
    else
        ok "chave $CHAVE"
    fi
}

# O IDD do Looking Glass pega o primeiro IVSHMEM que o Windows enumera -- ignora o
# shmDevice -- e escreve um contador a 1 kHz em cima da regiao do Vypr, que perde o cabecalho
# e o agente diz "none holding a vypr region" (12/09/2026). Enquanto o Vypr roda, o IDD fica
# desligado: a 3090 continua com display pelo dummy plug e pelo DP do ASUS. O hook pre-run do
# launcher (patch do fork) chama isto antes de cada sessao, porque o modo jogo e o
# guest-display.sh religam o IDD.
hook_pre_run() {
    mkdir -p "$CONF/hooks"
    cat >"$CONF/hooks/pre-run" <<'FIM'
#!/usr/bin/env bash
# Desliga o IDD do Looking Glass no guest antes da sessao do Vypr e poe a tela do guest na
# taxa do monitor daqui (ver vm/vypr.sh; 180 Hz no guest deu VK_ERROR_OUT_OF_DEVICE_MEMORY).
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
source "$DOTFILES_DIR/vm/guest.sh"
guest_ready 10 || exit 0
estado=$(guest_exec '(Get-PnpDevice -InstanceId "ROOT\DISPLAY\0000" -ErrorAction SilentlyContinue).Status' 2>/dev/null | tr -d '\r\n ')
if [[ $estado == OK ]]; then
    guest_exec 'Disable-PnpDevice -InstanceId "ROOT\DISPLAY\0000" -Confirm:$false -ErrorAction SilentlyContinue' >/dev/null 2>&1
    printf 'vypr: IDD do Looking Glass desligado no guest\n'
    sleep 3
fi
"$DOTFILES_DIR/vm/guest-display.sh" 2>&1 | sed 's/^/vypr: /'
FIM
    chmod +x "$CONF/hooks/pre-run"
    ok "hook pre-run (IDD do Looking Glass desligado antes da sessao)"
}

# O RedM no Vypr: entrada em apps/ com captura automatica (menu com cursor, jogo capturado) e
# a tarefa do guest que o launcher dispara. A tarefa limpa o cache do RedM antes (e o cache
# que gera o VK_ERROR_OUT_OF_DEVICE_MEMORY, ver vm/guest-game.sh) e ja conecta no servidor
# local (o host visto da VM e 192.168.122.1, nunca localhost); sem servidor no ar o RedM cai
# no menu normal.
app_redm() {
    local exe='D:\Jogos\RedM\RedM.exe' cache='D:\Jogos\RedM\RedM.app\data\cache'
    local servidor="${GAME_CONNECT:-192.168.122.1:30120}"
    mkdir -p "$CONF/apps"
    cat >"$CONF/apps/redm.conf" <<FIM
NAME="RedM"
TASK=vypr-redm
PROCESS=RedM.exe
CAPTURE=auto
MATCHES=("RedM" )
FIM
    # shellcheck source=guest.sh
    source "$DOTFILES_DIR/vm/guest.sh"
    guest_ready 10 || { warn "guest sem resposta, tarefa vypr-redm fica pra proxima"; return 0; }
    guest_exec "
\$dir = 'C:\\ProgramData\\dotfiles'
New-Item -ItemType Directory -Force -Path \$dir | Out-Null
@'
Remove-Item '$cache' -Recurse -Force -ErrorAction SilentlyContinue
Start-Process -FilePath '$exe' -ArgumentList 'redm://connect/$servidor'
'@ | Set-Content -Path \"\$dir\\vypr-redm.ps1\" -Encoding ASCII
\$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument \"-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \$dir\\vypr-redm.ps1\"
\$who = New-ScheduledTaskPrincipal -UserId '$GUEST_USER' -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName 'vypr-redm' -Action \$action -Principal \$who -Force | Out-Null
'ok'
" >/dev/null 2>&1 && ok "app redm: cache limpo e conectado em $servidor a cada abertura" || warn "tarefa vypr-redm nao registrada no guest"
}

configurar() {
    hook_pre_run
    app_redm
    if [[ ! -f $CONF/config ]]; then
        local ip
        ip="$(v net-dhcp-leases default 2>/dev/null | awk '/52:54:00:7b:68:56/ {split($5,a,"/"); print a[1]; exit}')"
        cat >"$CONF/config" <<FIM
# Escrito pelo vm/vypr.sh. GUEST vazio o launcher resolve pelo MAC da VM no libvirt.
VM=$VM
GUEST=$ip
GUEST_USER=$GUEST_USER
SHM_SIZE_MB=$SHM_MB
USE_PARSEC=1
SHUTDOWN_VM_ON_EXIT=0
SHUTDOWN_GRACE=60
FIM
        ok "$CONF/config escrito"
    else
        ok "$CONF/config"
    fi
}

instalar() {
    compilar || return 1
    regiao
    chave
    configurar
    grep -q "name=\"vypr\"" "$DOTFILES_DIR/vm/w11-3090.xml" && ok "shmem vypr no w11-3090.xml" || warn "w11-3090.xml sem o <shmem name='vypr'>"
    [[ -f $SETUP_EXE ]] || curl -fsSL -o "$SETUP_EXE" \
        "$(gh api repos/Amzi-01/Vypr/releases/latest --jq '.assets[] | select(.name=="vypr-setup.exe") | .browser_download_url' 2>/dev/null)" 2>/dev/null \
        && ok "vypr-setup.exe em $SETUP_EXE" || true
}

# O guest_put do guest.sh manda o arquivo inteiro num argumento so, e 1 MB de base64 estoura
# o limite de linha de comando do virsh: aqui vai em pedacos de 48 KB pelo mesmo handle.
guest_put_grande() {
    local origem="$1" destino="${2//\\//}" h pedaco
    h=$(_qga "{\"execute\":\"guest-file-open\",\"arguments\":{\"path\":\"$destino\",\"mode\":\"wb\"}}" \
        | python3 -c 'import sys,json;print(json.load(sys.stdin)["return"])') || return 1
    while IFS= read -r pedaco || [[ -n $pedaco ]]; do
        _qga "{\"execute\":\"guest-file-write\",\"arguments\":{\"handle\":$h,\"buf-b64\":\"$pedaco\"}}" >/dev/null || return 1
    done < <(base64 -w0 <"$origem" | fold -w 65536)
    _qga "{\"execute\":\"guest-file-close\",\"arguments\":{\"handle\":$h}}" >/dev/null
    ok "$(basename "$origem") copiado pra VM ($(stat -c %s "$origem") bytes)"
}

# Manda o instalador do lado Windows pra VM (ligada, com o guest-agent) e abre ele na sessao
# interativa do usuario: ele instala o agente, o driver IVSHMEM, o Parsec (driver do mouse) e
# autoriza a chave. Os prompts de driver so um humano clica -- pela janela do Looking Glass.
guest() {
    [[ -f $SETUP_EXE ]] || { warn "$SETUP_EXE nao existe, rode vypr.sh antes"; return 1; }
    [[ $(LC_ALL=C v domstate "$VM" 2>/dev/null) == running ]] || { warn "VM $VM nao esta ligada (vm/w11 3090)"; return 1; }
    # shellcheck source=guest.sh
    source "$DOTFILES_DIR/vm/guest.sh"
    guest_ready 60 || { warn "guest-agent nao respondeu"; return 1; }
    guest_put_grande "$SETUP_EXE" "C:/Users/$GUEST_USER/Downloads/vypr-setup.exe" || { warn "nao copiei o instalador pra VM"; return 1; }
    guest_put "$CHAVE.pub" "C:/Users/$GUEST_USER/Downloads/vypr-guest.pub"
    guest_exec "
\$acao = New-ScheduledTaskAction -Execute 'C:\\Users\\$GUEST_USER\\Downloads\\vypr-setup.exe'
\$who  = New-ScheduledTaskPrincipal -UserId '$GUEST_USER' -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName 'dotfiles-vypr-setup' -Action \$acao -Principal \$who -Force | Out-Null
Start-ScheduledTask -TaskName 'dotfiles-vypr-setup'
'aberto'
" | tail -1
    printf '  chave publica que o instalador pede (tambem em Downloads\\vypr-guest.pub na VM):\n    %s\n' "$(<"$CHAVE.pub")"
}

rebase() {
    [[ -d $REPO/.git ]] || { warn "fork nao clonado"; return 1; }
    git -C "$REPO" fetch -q upstream master
    local antes
    antes="$(git -C "$REPO" rev-list --count "upstream/master..$RAMO")"
    if [[ $(git -C "$REPO" rev-list --count "$RAMO..upstream/master") == 0 ]]; then
        ok "ja esta em cima do upstream ($antes patch(es))"; return 0
    fi
    if git -C "$REPO" rebase -q upstream/master "$RAMO" 2>/dev/null; then
        git -C "$REPO" branch -f "$ESPELHO" upstream/master
        git -C "$REPO" push -q origin "$ESPELHO" 2>/dev/null
        ok "rebaseado: $antes patch(es) em cima de $(git -C "$REPO" rev-parse --short upstream/master)"
    else
        git -C "$REPO" rebase --abort 2>/dev/null
        warn "rebase deu conflito, resolva a mao em $REPO"
    fi
}

estado() {
    printf 'binarios: %s\n' "$(for b in vyprd vypr-window vypr; do [[ -x $BIN/$b ]] && printf '%s ' "$b" || printf 'FALTA:%s ' "$b"; done)"
    printf 'regiao:   %s\n' "$([[ -e $SHM ]] && stat -c '%s bytes %U:%G %a' "$SHM" || echo 'nao existe')"
    printf 'config:   %s\n' "$([[ -f $CONF/config ]] && grep -v '^#' "$CONF/config" | tr '\n' ' ' || echo 'nao escrito')"
    printf 'VM:       %s\n' "$(LC_ALL=C v domstate "$VM" 2>/dev/null || echo 'nao definida')"
    [[ -d $REPO/.git ]] && printf 'fork:     %s patch(es) sobre o upstream\n' "$(git -C "$REPO" rev-list --count "upstream/master..$RAMO" 2>/dev/null || echo '?')"
    return 0
}

case "${1:-instalar}" in
    instalar) instalar ;;
    estado)   estado ;;
    guest)    guest ;;
    rebase)   rebase ;;
    *) printf 'uso: vypr.sh [instalar|estado|guest|rebase]\n' >&2; exit 2 ;;
esac
