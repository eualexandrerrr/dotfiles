#!/usr/bin/env bash

devices=$HOME/GitHub/official_devices/devices.json
maintainers=$HOME/GitHub/official_devices/team/maintainers.json

cat $devices | jq -r 'map(select(.brand != null)) | sort_by(.brand, .name)' | tee $devices
cat $maintainers | jq -r 'map(select(.name != null)) | sort_by(.name)' | tee $maintainers
