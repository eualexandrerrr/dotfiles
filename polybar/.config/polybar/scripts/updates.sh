#!/usr/bin/env bash

icon="$HOME/.config/assets/icons/pacman.png"

get_total_updates() { updates=$(checkupdates 2> /dev/null | wc -l); }

while true; do
    get_total_updates

    # notify user of updates
    if hash dunstify &> /dev/null; then
        if ((updates > 50)); then
            dunstify -u critical -i $icon \
                "You really need to update!!" "$updates New packages"
    elif     ((updates > 25)); then
            dunstify -u normal -i $icon \
                "You should update soon" "$updates New packages"
    elif     ((updates > 2)); then
            dunstify -u low -i $icon \
                "$updates New packages"
    fi
  fi

    # when there are updates available
    # every 10 seconds another check for updates is done
    while ((updates > 0)); do
        if ((updates == 1)); then
            echo "$updates"
    elif     ((updates > 1)); then
            echo "$updates"
    else
            echo "None"
    fi
        sleep 10
        get_total_updates
  done

    # when no updates are available, use a longer loop, this saves on CPU
    # and network uptime, only checking once every 30 min for new updates
    while ((updates == 0)); do
        echo "None"
        sleep 1800
        get_total_updates
  done
done
