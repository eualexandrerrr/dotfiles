#!/bin/bash
# github.com/mamutal91

# lock file location
export LOCK_FILE=/tmp/battery_state.lock

# check if another copy is running
if [[ -a $LOCK_FILE ]]; then

    pid=$(cat $LOCK_FILE | awk '{print $1}')
	ppid=$(cat $LOCK_FILE | awk '{print $2}')
	# validate contents of previous lock file
	vpid=${pid:-"0"}
	vppid=${ppid:-"0"}

    if (( $vpid < 2 || $vppid < 2 )); then
		# corrupt lock file $LOCK_FILE ... Exiting
		cp -f $LOCK_FILE ${LOCK_FILE}.`date +%Y%m%d%H%M%S`
		exit
	fi

    # check if ppid matches pid
	ps -f -p $pid --no-headers | grep $ppid >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
		# another copy of script running with process id $pid
		exit
	else
		# bogus lock file found, removing
		rm -f $LOCK_FILE >/dev/null
	fi

fi

pid=$$
ps -f -p $pid --no-headers | awk '{print $2,$3}' > $LOCK_FILE
# starting with process id $pid

# set Battery
BATTERY=$(ls /sys/class/power_supply/ | grep '^BAT')

# set full path
ACPI_PATH="/sys/class/power_supply/$BATTERY"

# get battery status
STAT=$(cat $ACPI_PATH/status)

# get remaining energy value
REM=`grep -P '(POWER_SUPPLY_CHARGE_NOW)|(POWER_SUPPLY_ENERGY_NOW)' $ACPI_PATH/uevent | cut -d= -f2`

# get full energy value
FULL=`grep -P '(POWER_SUPPLY_CHARGE_FULL_DESIGN)|(POWER_SUPPLY_ENERGY_FULL_DESIGN)' $ACPI_PATH/uevent | cut -d= -f2`

# get current energy value in percent
PERCENT=`echo $(( $REM * 100 / $FULL ))`

# set error message
MESSAGE="Bateria descarregando"

# set energy limit in percent, where warning should be displayed
LIMIT="30"

# show warning if energy limit in percent is less then user set limit and
# if battery is discharging
if [ $PERCENT -le "$(echo $LIMIT)" ] && [ "$STAT" == "Descarregando" ]; then
    DISPLAY=:0 notify-send $(echo $MESSAGE)"
fi