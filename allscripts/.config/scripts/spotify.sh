#!/usr/bin/env bash

title=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 1 "title" | cut -b 44- | cut -d '"' -f 1 | egrep -v ^$)
artist=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 2 "artist" | cut -b 20- | cut -d '"' -f 2 | egrep -v ^$ | egrep -v array | egrep -v artist)
text=$(echo $artist '-' $title)

echo -e '{"text":"'$text"\", \"class\":\""$class"\"}"
