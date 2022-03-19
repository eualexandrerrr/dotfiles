#!/usr/bin/env bash

sudo sed -i 's/load-module module-suspend-on-idle/#load-module module-suspend-on-idle/' /etc/pulse/default.pa

echo "options snd_ac97_codec power_save=1" | sudo tee /etc/modprobe.d/audio_powersave.conf
