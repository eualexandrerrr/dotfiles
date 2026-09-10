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
for _drv in /sys/class/drm/card*/device/driver; do
    [ -e "$_drv" ] || continue
    case "$(basename "$(readlink -f "$_drv")")" in
        amdgpu) _desenha=amdgpu; break ;;
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

unset _drv _desenha
