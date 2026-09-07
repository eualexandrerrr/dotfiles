#!/usr/bin/env bash
# Android SDK e os AVDs de desenvolvimento, do zero, sem Android Studio e sem root.
#
#   ~/.dotfiles/bin/android-sdk.sh           instala o que falta e cria os AVDs
#   ~/.dotfiles/bin/android-sdk.sh avds      so recria os AVDs (nao baixa nada)
#   ~/.dotfiles/bin/android-sdk.sh estado    diz o que existe e o que falta
#
# O SDK fica em ~/Android/Sdk e os AVDs em ~/.android/avd. Nao mexe em nada de sistema:
# jdk17-openjdk, android-tools e android-udev vem do packages.txt.
#
# Duas armadilhas do cmdline-tools 16 que este script contorna:
#
#  - `avdmanager create avd -d <device>` morre com "Could not load devices from
#    <system-image>/devices.xml" porque o arquivo nao existe na imagem. Escrever um
#    devices.xml vazio de schema 8 nessa pasta resolve.
#  - com XDG_CONFIG_HOME definido, o avdmanager grava em $XDG_CONFIG_HOME/.android/avd,
#    enquanto adb e emulator leem ~/.android. O script move e reescreve o path= do .ini.
#
# O emulador tambem nao pergunta "custom hardware profile?" quando stdin nao e um tty,
# ele so desiste calado -- por isso a criacao roda dentro de um pty.
set -uo pipefail

SDK="${ANDROID_HOME:-$HOME/Android/Sdk}"
AVD_HOME="$HOME/.android/avd"
CLT_VERSAO="15859902"
IMAGEM="system-images;android-36;google_apis;x86_64"
PACOTES=("platform-tools" "emulator" "platforms;android-36" "build-tools;36.0.0" "$IMAGEM")
DEVICE="pixel_5"

# nome            porta   o que e
AVDS=(
    "Main_Debug   5554    principal, todo app usa este"
    "Main_Debug_2 5556    reserva, para rodar dois ao mesmo tempo"
)

# config.ini: emulador no padrao vem com 2 GB e 4 nucleos, e um dev build
# React Native / Expo (Hermes + Metro + Firebase + mapas) nao cabe nisso.
declare -A HARDWARE=(
    [hw.ramSize]=12288
    [hw.cpu.ncore]=8
    [vm.heapSize]=1024M
    [hw.gpu.enabled]=yes
    [hw.gpu.mode]=auto
    [hw.keyboard]=yes
    [showDeviceFrame]=no
    [disk.dataPartition.size]=8G
)

GRN=$'\e[32m'; YEL=$'\e[33m'; RED=$'\e[31m'; END=$'\e[0m'
ok()   { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
warn() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*"; }
die()  { printf '%serro:%s %s\n' "$RED" "$END" "$*" >&2; exit 1; }
log()  { printf '\n==> %s\n' "$*"; }

sdkmanager() { "$SDK/cmdline-tools/latest/bin/sdkmanager" "$@"; }
avdmanager() { "$SDK/cmdline-tools/latest/bin/avdmanager" "$@"; }

instalar_cmdline_tools() {
    [[ -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]] && { ok "cmdline-tools ja instalado"; return; }
    log "baixando cmdline-tools $CLT_VERSAO"
    command -v java >/dev/null 2>&1 || die "java nao encontrado -- instale jdk17-openjdk"
    local tmp; tmp="$(mktemp -d)"
    curl -fL --progress-bar -o "$tmp/clt.zip" \
        "https://dl.google.com/android/repository/commandlinetools-linux-${CLT_VERSAO}_latest.zip" \
        || die "download do cmdline-tools falhou"
    unzip -q -o "$tmp/clt.zip" -d "$tmp" || die "zip do cmdline-tools veio quebrado"
    mkdir -p "$SDK/cmdline-tools"
    rm -rf "$SDK/cmdline-tools/latest"
    mv "$tmp/cmdline-tools" "$SDK/cmdline-tools/latest"
    rm -rf "$tmp"
    ok "cmdline-tools em $SDK/cmdline-tools/latest"
}

instalar_pacotes() {
    log "licencas e pacotes do SDK (uns 5 GB, demora)"
    yes 2>/dev/null | sdkmanager --licenses >/dev/null 2>&1
    ok "licencas aceitas"
    sdkmanager --install "${PACOTES[@]}" 2>&1 | tail -1
    for p in emulator platform-tools; do
        [[ -d "$SDK/$p" ]] || die "$p nao chegou -- rode de novo"
    done
    ok "SDK em $SDK"
}

# O avdmanager procura devices.xml dentro da system image e falha se nao achar.
plantar_devices_xml() {
    local img="$SDK/system-images/android-36/google_apis/x86_64"
    [[ -d "$img" ]] || return 0
    [[ -f "$img/devices.xml" ]] && return 0
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<d:devices xmlns:d="http://schemas.android.com/sdk/devices/8"/>\n' \
        > "$img/devices.xml"
}

# O avdmanager pergunta pelo hardware profile e so aceita a resposta de um tty.
criar_avd() {
    local nome="$1"
    ANDROID_HOME="$SDK" ANDROID_SDK_ROOT="$SDK" python3 - "$nome" "$SDK" "$IMAGEM" "$DEVICE" <<'PY'
import os, pty, sys, time, select
nome, sdk, imagem, device = sys.argv[1:5]
am = os.path.join(sdk, 'cmdline-tools', 'latest', 'bin', 'avdmanager')
pid, fd = pty.fork()
if pid == 0:
    os.execv(am, [am, 'create', 'avd', '-n', nome, '-k', imagem, '-d', device, '--force'])
saida, respondeu, fim = b'', False, time.time() + 180
while time.time() < fim:
    r, _, _ = select.select([fd], [], [], 0.5)
    if r:
        try: d = os.read(fd, 65536)
        except OSError: break
        if not d: break
        saida += d
        if not respondeu and b'hardware profile' in saida:
            os.write(fd, b'no\n'); respondeu = True
    if os.waitpid(pid, os.WNOHANG)[0]: break
texto = saida.decode('utf-8', 'replace')
if 'Error:' in texto:
    print(texto.replace('\r', '').strip()[-400:], file=sys.stderr)
    sys.exit(1)
PY
}

# XDG_CONFIG_HOME faz o avdmanager gravar em outro lugar; adb e emulator leem ~/.android.
recolher_avd() {
    local nome="$1" origem="${XDG_CONFIG_HOME:-$HOME/.config}/.android/avd"
    [[ -d "$origem/$nome.avd" ]] || return 0
    mkdir -p "$AVD_HOME"
    rm -rf "${AVD_HOME:?}/$nome.avd"
    mv "$origem/$nome.avd" "$AVD_HOME/"
    sed "s|$origem|$AVD_HOME|" "$origem/$nome.ini" > "$AVD_HOME/$nome.ini"
    rm -f "$origem/$nome.ini"
    rmdir "$origem" "$(dirname "$origem")" 2>/dev/null
}

ajustar_hardware() {
    local nome="$1" arq="$AVD_HOME/$nome.avd/config.ini"
    [[ -f "$arq" ]] || { warn "$nome: config.ini nao apareceu"; return 1; }
    python3 - "$arq" "$nome" <<'PY'
import re, sys
arq, nome = sys.argv[1], sys.argv[2]
ajustes = {
    'hw.ramSize': '12288', 'hw.cpu.ncore': '8', 'vm.heapSize': '1024M',
    'hw.gpu.enabled': 'yes', 'hw.gpu.mode': 'auto', 'hw.keyboard': 'yes',
    'showDeviceFrame': 'no', 'disk.dataPartition.size': '8G',
}
fora, vistas = [], set()
for linha in open(arq).read().splitlines():
    m = re.match(r'^\s*([^=\s]+)\s*=\s*(.*)$', linha)
    if not m:
        fora.append(linha); continue
    chave, valor = m.group(1), m.group(2)
    if chave in vistas: continue
    vistas.add(chave)
    if chave == 'disk.dataPartition.path': continue
    if chave in ('avd.id', 'avd.name'): valor = nome
    if chave in ajustes: valor = ajustes[chave]
    fora.append(f'{chave}={valor}')
for chave, valor in ajustes.items():
    if chave not in vistas: fora.append(f'{chave}={valor}')
open(arq, 'w').write('\n'.join(fora) + '\n')
PY
}

fazer_avds() {
    log "AVDs"
    plantar_devices_xml
    local linha nome porta resto
    for linha in "${AVDS[@]}"; do
        read -r nome porta resto <<<"$linha"
        if [[ -d "$AVD_HOME/$nome.avd" ]]; then
            ajustar_hardware "$nome" && ok "$nome ja existe (porta $porta), hardware conferido"
            continue
        fi
        criar_avd "$nome" || { warn "$nome nao foi criado"; continue; }
        recolher_avd "$nome"
        ajustar_hardware "$nome" \
            && ok "$nome criado: Pixel 5, API 36, ${HARDWARE[hw.ramSize]} MB, ${HARDWARE[hw.cpu.ncore]} nucleos (porta $porta)"
    done
}

estado() {
    printf 'SDK      %s\n' "$([[ -d $SDK ]] && echo "$SDK" || echo 'FALTA')"
    printf 'java     %s\n' "$(java -version 2>&1 | head -1 || echo 'FALTA')"
    printf 'adb      %s\n' "$(command -v adb || echo 'FALTA')"
    printf 'emulator %s\n' "$([[ -x $SDK/emulator/emulator ]] && echo "$SDK/emulator/emulator" || echo 'FALTA')"
    printf 'kvm      %s\n' "$([[ -w /dev/kvm ]] && echo 'ok' || echo 'SEM PERMISSAO -- veja o grupo kvm')"
    printf 'AVDs     %s\n' "$("$SDK/emulator/emulator" -list-avds 2>/dev/null | tr '\n' ' ' || echo 'FALTA')"
}

case "${1:-tudo}" in
    estado) estado ;;
    avds)   fazer_avds; estado ;;
    tudo)
        instalar_cmdline_tools
        instalar_pacotes
        fazer_avds
        log "estado final"
        estado
        printf '\n  o RCode acha o SDK sozinho por ~/Android/Sdk; para o resto, o .zprofile exporta ANDROID_HOME\n'
        ;;
    *) die "uso: android-sdk.sh [tudo|avds|estado]" ;;
esac
