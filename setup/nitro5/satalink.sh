#!/usr/bin/env bash

echo 'ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"' | sudo tee /etc/udev/rules.d/hd_power_save.rules

echo 'SATA_LINKPWR_ON_AC="max_performance"
SATA_LINKPWR_ON_BAT="med_power_with_dipm"
RADEON_POWER_PROFILE_ON_AC="alto"
RADEON_POWER_PROFILE_ON_BAT="baixo"
RESTORE_DEVICE_STATE_ON_STARTUP="1"' | sudo tee /etc/tlp.conf

echo "[device]
wifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/nm.conf
