#!/usr/bin/env bash

echo 'ACTION=="adicionar", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"' > /etc/udev/rules.d/hd_power_save.rules

cat <<  EOF > /etc/tlp.conf
SATA_LINKPWR_ON_AC="max_performance"
SATA_LINKPWR_ON_BAT="med_power_with_dipm"
RADEON_POWER_PROFILE_ON_AC="alto"
RADEON_POWER_PROFILE_ON_BAT="baixo"
RESTORE_DEVICE_STATE_ON_STARTUP="1"
EOF

cat <<  EOF >> /etc/NetworkManager/conf.d/nm.conf
[dispositivo]
wifi.backend=iwd
EOF
