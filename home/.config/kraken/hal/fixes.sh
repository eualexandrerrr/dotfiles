#!/usr/bin/env bash

# FIXES
cd /tmp/
rm -rf hardware_qcom_display
git clone ssh://git@github.com/AOSPK/hardware_qcom_display -b eleven-caf-sm8250
cd hardware_qcom_display
git fetch "https://github.com/LineageOS/android_hardware_qcom_display" refs/changes/18/305418/1 && git cherry-pick FETCH_HEAD
git push
