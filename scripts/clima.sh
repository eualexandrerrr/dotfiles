#!/bin/bash
# github.com/mamutal91

city="Linhares"
api_key="39214b9803f123f428d81d0e38c1af9c"
lang="pt"
unit="metric"
api="http://api.openweathermap.org/data/2.5/weather"
url="$api?q=$city&lang=$lang&APPID=$api_key&units=$unit"

weather=$(curl -s $url | jq -r '. | "\(.weather[].main)"')
temp=$(curl -s $url | jq -r '. | "\(.main.temp)"')
icons=$(curl -s $url | jq -r '. | "\(.weather[].icon)"')

case $icons in
  01d) icon=x;;
  01n) icon=a;;
  02d) icon=b;;
  02n) icon=e;;
  03*) icon=e;;
  04*) icon=e;;
  09*) icon=e;;
  10*) icon=e;;
  11*) icon=e;;
  13*) icon=e;;
  50*) icon=e;;
  *) icon=x;;
esac

echo $icon\ $weather, $temp"°C"