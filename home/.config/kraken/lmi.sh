#!/usr/bin/env bash

pwd=$(pwd)

git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

branch=eleven-wip

orgRebase=LineageOS # or xiaomi-sm8250-devs

branchLOS=lineage-18.1

bringup="Initial changes for Kraken"

workingDir=$(mktemp -d) && cd $workingDir

git clone https://github.com/${orgRebase}/android_device_xiaomi_lmi -b ${branchLOS}
git clone https://github.com/${orgRebase}/android_device_xiaomi_sm8250-common -b ${branchLOS}

# Tree
cd android_device_xiaomi_lmi

sed -i "s/lineage_/aosp_/g" AndroidProducts.mk

mv lineage_lmi.mk aosp_lmi.mk
sed -i "s/lineage_/aosp_/g" aosp_lmi.mk
sed -i "s/vendor\/lineage/vendor\/aosp/" aosp_lmi.mk
sed -i "s/Lineage stuff/Kraken stuff/g" aosp_lmi.mk

mv overlay-lineage overlay-kraken
sed -i "s/overlay-lineage/overlay-kraken/g" device.mk

rm -rf lineage.dependencies
echo "[
  {
    \"repository\": \"device_xiaomi_sm8250-common\",
    \"target_path\": \"device/xiaomi/sm8250-common\"
  },
  {
    \"repository\": \"vendor_xiaomi_lmi\",
    \"target_path\": \"vendor/xiaomi/lmi\"
  },
  {
    \"remote\": \"github\",
    \"repository\": \"LineageOS/android_hardware_xiaomi\",
    \"target_path\": \"hardware/xiaomi\",
    \"branch\": \"${branchLOS}\"
  }
]" > aosp.dependencies

git add . && git commit --message "lmi: $bringup" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

# Overlay fod
mkdir -p overlay-kraken/frameworks/base/packages/SystemUI/res/values
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!--
/*
** Copyright 2021 The Kraken Project
**
** Licensed under the Apache License, Version 2.0 (the \"License\");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an \"AS IS\" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
*/
-->

<!-- These resources are around just to allow their values to be customized
     for different hardware and product builds. -->
<resources>
    <!-- Biometric Prompt -->
    <dimen name=\"biometric_dialog_fod_margin\">150dp</dimen>
</resources>" | tee overlay-kraken/frameworks/base/packages/SystemUI/res/values/custom_config.xml &>/dev/null

git add . && git commit --message "lmi: overlay: Adjust biometric prompt layout" --author "Mesquita <mesquita@aospa.co>"

# Translations pt-BR
mkdir -p parts/res/values-pt-rBR
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!--
     Copyright (C) 2018 The LineageOS Project

     Licensed under the Apache License, Version 2.0 (the \"License\");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at

          http://www.apache.org/licenses/LICENSE-2.0

     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an \"AS IS\" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.
-->
<resources>
    <!-- Popup camera settings -->
    <string name=\"popup_led_title\">Efeito visual</string>
    <string name=\"popup_led_summary\">Mostra a animação quando a câmera frontal aparece e se retrai</string>
    <string name=\"popup_title\">Efeitos de câmera frontal</string>
    <string name=\"popup_title_muqin\">Xylophone</string>
    <string name=\"popup_title_yingyan\">Condor</string>
    <string name=\"popup_title_mofa\">Magic</string>
    <string name=\"popup_title_jijia\">Mecha</string>
    <string name=\"popup_title_chilun\">Gearwheel</string>
    <string name=\"popup_title_cangmen\">Cabin door</string>

    <!-- Popup camera strings -->
    <string name=\"popup_camera_tip\">Warning</string>
    <string name=\"popup_camera_takeback_failed_times_calibrate\">Não foi possível fechar a câmera frontal várias vezes. Tente calibrar a câmera.</string>
    <string name=\"popup_camera_popup_failed_times_calibrate\">Não foi possível abrir a câmera frontal várias vezes. Tente calibrar a câmera.</string>
    <string name=\"popup_camera_calibrate_running\">A câmera frontal não pode ser usada durante a calibração.</string>
    <string name=\"popup_camera_calibrate_now\">Calibrar</string>
    <string name=\"popup_camera_calibrate_failed\">Não foi possível calibrar</string>
    <string name=\"popup_camera_calibrate_success\">Calibrado com sucesso. Você pode abrir a câmera frontal agora.</string>
    <string name=\"stop_operate_camera_frequently\">Você está abrindo a câmera frontal com muita frequência.</string>
    <string name=\"takeback_camera_front_failed\">Não foi possível fechar a câmera frontal. Tente novamente.</string>
    <string name=\"popup_camera_front_failed\">Não foi possível abrir a câmera frontal. Tente novamente.</string>
</resources>" | tee parts/res/values-pt-rBR/strings.xml &>/dev/null
git add . && git commit --message "lmi: parts: Translations for Portuguese Brazil" --author "Alexandre Rangel <mamutal91@gmail.com>"

git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_lmi HEAD:refs/heads/${branch} --force

# Common
cd ../android_device_xiaomi_sm8250-common

mv overlay-lineage overlay-kraken
cd overlay-kraken
mv lineage-sdk custom-sdk
cd custom-sdk
mv lineage kraken

cd ../../

sed -i "s/overlay-lineage/overlay-kraken/g" kona.mk
sed -i "s/vendor\/lineage/vendor\/aosp/" kona.mk

rm -rf lineage.dependencies
echo "[
  {
    \"repository\": \"kernel_xiaomi_sm8250\",
    \"target_path\": \"kernel/xiaomi/sm8250\"
  },
  {
    \"repository\": \"vendor_xiaomi_sm8250-common\",
    \"target_path\": \"vendor/xiaomi/sm8250-common\"
  }
]" > aosp.dependencies

git add . && git commit --message "sm8250-common: $bringup" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

# FaceUnlock
pwd_faceunlock=$(pwd)
mkdir -p overlay/packages/apps/FaceUnlockService/app/src/main/res/values
cd overlay/packages/apps/FaceUnlockService/app/src/main/res/values
wget https://raw.githubusercontent.com/PixelExperience-Devices/device_xiaomi_raphael/eleven/overlay/packages/apps/FaceUnlockService/app/src/main/res/values/config.xml
cd $pwd_faceunlock

msg="sm8250-common: overlay: FaceUnlockService: Define delay for our popup camera

* Android framework sometimes triggers face unlock at random times (after unlocking with pin or pattern, for example) so that the camera on devices with a pop-up camera is activated at unwanted times.

Adds a configurable delay to prevent this behavior"
git add . && git commit --message "$msg" --author "Henrique Silva <jhenrique09.mcz@hotmail.com>"

# Props
sed -i "s/debug.sf.latch_unsignaled=1/debug.sf.latch_unsignaled=0/g" system.prop
sed -i "s/debug.sf.latch_unsignaled=1/debug.sf.latch_unsignaled=0/g" vendor.prop

msg="sm8250-common: Disable debug.sf.latch_unsignaled from prop.
* Disabling this helps reduces notification flicker, UI performance is not impacted.
(per:  change https://android.googlesource.com/platform/frameworks/native/+/c5da271)

*Lmi: Also fixes Lags on Google Photos while playing videos."
git add . && git commit --message "${msg} now" --signoff --author "soumyo19 <fsoummya@gmail.com>"

git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_sm8250-common HEAD:refs/heads/${branch} --force

# Kernel and Vendor
cd $workingDir

git clone https://gitlab.com/xiaomi-sm8250-devs/android_vendor_xiaomi -b ${branchLOS}
mv android_vendor_xiaomi android_vendor_xiaomi_lmi
cp -rf android_vendor_xiaomi_lmi android_vendor_xiaomi_sm8250-common

cd android_vendor_xiaomi_lmi
git filter-branch --prune-empty --subdirectory-filter lmi ${branchLOS}
git push ssh://git@github.com/AOSPK-Devices/vendor_xiaomi_lmi HEAD:refs/heads/${branch} --force
git push ssh://git@gitlab.com/AOSPK-Devices/vendor_xiaomi_lmi HEAD:refs/heads/${branch} --force

cd ../android_vendor_xiaomi_sm8250-common
git filter-branch --prune-empty --subdirectory-filter sm8250-common ${branchLOS}
git push ssh://git@github.com/AOSPK-Devices/vendor_xiaomi_sm8250-common HEAD:refs/heads/${branch} --force
git push ssh://git@gitlab.com/AOSPK-Devices/vendor_xiaomi_sm8250-common HEAD:refs/heads/${branch} --force

cd ..
git clone https://github.com/${orgRebase}/android_kernel_xiaomi_sm8250 -b ${branchLOS}
cd android_kernel_xiaomi_sm8250

sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/umi_defconfig
sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/lmi_defconfig
sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/apollo_defconfig
sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/cas_defconfig
sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/cmi_defconfig
git add . && git commit --message "ARM64: configs: xiaomi: Set localversion to kraken" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

git push ssh://git@github.com/AOSPK-Devices/kernel_xiaomi_sm8250 HEAD:refs/heads/${branch} --force

cd $pwd

rm -rf $workingDir
