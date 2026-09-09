#!/usr/bin/env bash
# Poe a GPU em "Prefer maximum performance" no login. Chamado pelo
# .config/autostart/nvidia-desempenho.desktop.
#
# Estava inline no Exec do .desktop, mas a spec do Desktop Entry trata aspas simples como
# caractere reservado fora de aspas duplas, e o arquivo nao passava no
# desktop-file-validate. Script separado resolve sem escapar nada.

command -v nvidia-settings >/dev/null 2>&1 || exit 0
nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1" >/dev/null 2>&1 || true
