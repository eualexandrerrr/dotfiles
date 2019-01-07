#!/bin/bash
# github.com/mamutal91

SLEEP_TIME=5   # Default time between checks.
SAFE_PERCENT=30  # Still safe at this level.
DANGER_PERCENT=15  # Warn when battery at this level.
CRITICAL_PERCENT=5  # Hibernate when battery at this level.

NAGBAR_PID=0
export DISPLAY=:0.0

function launchNagBar
{
    i3-nagbar -m 'Battery low!' -b 'Hibernate!' 'pm-hibernate' >/dev/null 2>&1 &
    NAGBAR_PID=$!
}

function killNagBar
{
    if [[ $NAGBAR_PID -ne 0 ]]; then
        ps -p $NAGBAR_PID | grep "i3-nagbar"
        if [[ $? -eq 0 ]]; then
            kill $NAGBAR_PID
        fi
        NAGBAR_PID=0
    fi
}


while [ true ]; do

    killNagBar

    if [[ -n $(acpi -b | grep -i discharging) ]]; then
        rem_bat=$(acpi -b | grep -Eo "[0-9]+%" | grep -Eo "[0-9]+")

        if [[ $rem_bat -gt $SAFE_PERCENT ]]; then
            SLEEP_TIME=10
        else
            SLEEP_TIME=5
            if [[ $rem_bat -le $DANGER_PERCENT ]]; then
                SLEEP_TIME=2
                launchNagBar
            fi
            if [[ $rem_bat -le $CRITICAL_PERCENT ]]; then
                SLEEP_TIME=1
                pm-hibernate
            fi
        fi
    else
        SLEEP_TIME=10
    fi

    sleep ${SLEEP_TIME}m

done