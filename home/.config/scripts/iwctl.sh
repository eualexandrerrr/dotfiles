#!/usr/bin/env bash
# github.com/mamutal91

if [ ! -z "$1" ]; then
    iwctl station wlan0 connect "$1" > /dev/null;
fi

# Connect successful, no need to scan available network
if [ "$?" -eq 0 ] && [ ! -z "$1" ]; then
    echo "Connect successful!";
    exit 1;
fi

iwctl station wlan0 scan;

spinstr='|/-\'
printf "Scaning network "
while [[ -z $(iwctl station wlan0 show | grep 'Scanning' | grep 'no') ]]; do
    # processing bar: http://fitnr.com/showing-a-bash-spinner.html
    temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep .3
    printf "\b\b\b\b\b\b"
done

if [ -z "$1" ]; then
    iwctl station wlan0 get-networks;
else
    iwctl station wlan0 get-networks > /dev/null && \
    iwctl station wlan0 connect "$1"
    if [ "$?" -eq 0 ]; then
        echo;
        echo "Connect successful!"
    fi
fi
