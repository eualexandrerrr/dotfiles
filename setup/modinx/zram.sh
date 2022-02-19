#!/usr/bin/env bash

cat << EOF > /etc/systemd/swap.conf
#  This file is part of systemd-swap.
#
# Entries in this file show the systemd-swap defaults as
# specified in /usr/share/systemd-swap/swap-default.conf
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See swap.conf(5) and /usr/share/systemd-swap/swap-default.conf for details.
zram_enabled=1
zswap_enabled=0
swapfc_enabled=0
zram_size=\$(( RAM_SIZE / 4 ))
EOF
