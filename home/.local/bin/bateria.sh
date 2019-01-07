#!/bin/bash
# github.com/mamutal91

THRESHOLD=35 # percent

lock_path='/tmp/batmon.lock'

lockfile -r 0 $lock_path 2>/dev/null || exit

acpi_path=$(find /sys/class/power_supply/ -name 'BAT*' | head -1)
charge_now=$(cat "$acpi_path/charge_now")
charge_full=$(cat "$acpi_path/charge_full")
charge_status=$(cat "$acpi_path/status")
charge_percent=$(printf '%.0f' $(echo "$charge_now / $charge_full * 100" | bc -l))
message="Battery running critically low at $charge_percent%!"

if [[ $charge_status == 'Discharging' ]] && [[ $charge_percent -le $THRESHOLD ]]; then
  DISPLAY=:0 notify-send "Bateria descarregando."
fi

rm -f $lock_path