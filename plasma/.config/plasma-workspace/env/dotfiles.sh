#!/bin/sh
# O Plasma faz source de tudo que estiver em ~/.config/plasma-workspace/env/ no inicio da
# sessao. Herdeiro do antigo uwsm/env: o AQ_DRM_DEVICES ficou pra tras porque era do
# aquamarine (Hyprland); o resto continua valendo igual.

# GTK 4.20 parou de fazer compose e dead key sozinho no Wayland quando nao existe IME
# instalado: quem tem que resolver acento agora e o metodo de entrada. Sem isso o ghostty
# e qualquer outro app GTK engolem ' ` ^ ~ e nao sai letra acentuada. `simple` traz de
# volta a implementacao antiga do proprio GTK, que basta para o teclado ABNT2.
GTK_IM_MODULE=simple
export GTK_IM_MODULE

# O Spotify nao olha o LANG: sem LANGUAGE ele abre em ingles mesmo com pt_BR.UTF-8, e a
# flag --language=pt-BR do spotify-launcher perde para a preferencia salva no app.
LANGUAGE=pt_BR:pt
export LANGUAGE

# Quem desenha o desktop e a RX 550, entao o VA-API tem que ir pro radeonsi. Fixar nvidia
# aqui joga app Electron pra swiftshader (CPU). Se a AMD sair da maquina, o else assume.
_desenha=""
_amd_pci=""
for _drv in /sys/class/drm/card*/device/driver; do
    [ -e "$_drv" ] || continue
    case "$(basename "$(readlink -f "$_drv")")" in
        amdgpu)
            _desenha=amdgpu
            _amd_pci="$(basename "$(readlink -f "${_drv%/driver}")")"
            break
            ;;
    esac
done

if [ "$_desenha" = amdgpu ]; then
    LIBVA_DRIVER_NAME=radeonsi
    export LIBVA_DRIVER_NAME
else
    LIBVA_DRIVER_NAME=nvidia
    __GLX_VENDOR_LIBRARY_NAME=nvidia
    NVD_BACKEND=direct
    export LIBVA_DRIVER_NAME __GLX_VENDOR_LIBRARY_NAME NVD_BACKEND
fi

# Sem isto o KWin escolhe a 3090 como placa de render e compoe o desktop inteiro nela, so
# pra copiar quadro a quadro pela PCIe ate a AMD, que e quem tem os monitores -- a 1440p@144
# mais uma 1080x1920@144 girada. Era o "KDE arrastado" de 11/09/2026: `supportInformation`
# dizia `OpenGL renderer string: NVIDIA GeForce RTX 3090`. Fixando so a AMD, o KWin tambem
# deixa de enxergar as saidas do dummy plug da 3090, que entravam como tela de verdade.
# Caminho por by-path porque cardN troca de numero entre boots. Sem AMD, nao fixa nada.
if [ -n "$_amd_pci" ] && [ -e "/dev/dri/by-path/pci-$_amd_pci-card" ]; then
    KWIN_DRM_DEVICES="$(readlink -f "/dev/dri/by-path/pci-$_amd_pci-card")"
    export KWIN_DRM_DEVICES
fi

unset _drv _desenha _amd_pci
