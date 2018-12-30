#!/bin/bash
# github.com/mamutal91

get_icon() {
    case $1 in
        01d) icon="x";;
        01n) icon="x";;
        02d) icon="x";;
        02n) icon="x";;
        03*) icon="x";;
        04*) icon="x";;
        09d) icon="x";;
        09n) icon="x";;
        10d) icon="x";;
        10n) icon="X";;
        11d) icon="X";;
        11n) icon="x";;
        13d) icon="x";;
        13n) icon="X";;
        50d) icon="X";;
        50n) icon="X";;
        *) icon="X";
    esac

    echo $icon
}

KEY="cde33c9a5643013ffdf5d4320d55bc41"
CITY="Linhares"
UNITS="metric"
SYMBOL="°"

API="https://api.openweathermap.org/data/2.5"

if [ ! -z $CITY ]; then
    if [ "$CITY" -eq "$CITY" ] 2>/dev/null; then
        CITY_PARAM="id=$CITY"
    else
        CITY_PARAM="q=$CITY"
    fi

    weather=$(curl -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
    # weather=$(curl -sf "$API/forecast?appid=$KEY&$CITY_PARAM&units=$UNITS&cnt=1")
else
    location=$(curl -sf https://location.services.mozilla.com/v1/geolocate?key=geoclue)

    if [ ! -z "$location" ]; then
        location_lat="$(echo "$location" | jq '.location.lat')"
        location_lon="$(echo "$location" | jq '.location.lng')"

        weather=$(curl -sf "$API/weather?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS")
    fi
fi

if [ ! -z "$weather" ]; then
    weather_desc=$(echo "$weather" | jq -r ".weather[0].description")
    weather_temp=$(echo "$weather" | jq ".main.temp" | cut -d "." -f 1)
    weather_icon=$(echo "$weather" | jq -r ".weather[0].icon")

    echo "$(get_icon "$weather_icon")" "$weather_desc", "$weather_temp$SYMBOL"
fi