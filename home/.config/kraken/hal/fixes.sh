#!/usr/bin/env bash

# FIXES
cd /tmp/
rm -rf hardware_qcom_display
git clone ssh://git@github.com/AOSPK/hardware_qcom_display -b eleven-caf-sm8150
cd hardware_qcom_display
git fetch https://github.com/PixelExperience/hardware_qcom-caf_sm8150_display eleven && git cherry-pick 4133e8b2f42dd06935c1560254ca96336e41512c
git push
