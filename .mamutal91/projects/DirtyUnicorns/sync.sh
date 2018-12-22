#!/bin/bash
# github.com/mamutal91

repo sync -f --force-sync

# Hardware Interfaces ( correção do hotspot )
rm -rf hardware/interfaces
git clone https://github.com/AOSiP/platform_hardware_interfaces.git -b pie hardware/interfaces

# Correção Telephony
rm -rf frameworks/opt/telephony
git clone https://github.com/AOSiP/platform_frameworks_opt_telephony.git -b pie frameworks/opt/telephony

# Tradução DU-Teaks
rm -rf packages/apps/DU-Tweaks/res/values-pt-rBR/du_strings.xml
mkdir -p packages/apps/DU-Tweaks/res/values-pt-rBR
cd packages/apps/DU-Tweaks/res/values-pt-rBR/
wget https://raw.githubusercontent.com/mamutal91/dotfiles/master/.mamutal91/projects/DirtyUnicorns/du_strings.xml
cd $DU