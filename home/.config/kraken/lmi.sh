#!/usr/bin/env bash

LMI=/tmp/lmi
rm -rf $LMI && mkdir $LMI && cd $LMI

bringup="Initial changes for Kraken"

git clone https://github.com/xiaomi-sm8250-devs/android_device_xiaomi_lmi -b lineage-18.1
git clone https://github.com/xiaomi-sm8250-devs/android_device_xiaomi_sm8250-common -b lineage-18.1

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
    \"repository\": \"device_xiaomi_lmi-kernel\",
    \"target_path\": \"device/xiaomi/lmi-kernel\"
  },
  {
    \"repository\": \"device_xiaomi_sm8250-common\",
    \"target_path\": \"device/xiaomi/sm8250-common\"
  },
  {
    \"remote\": \"lab-devices\",
    \"repository\": \"vendor_xiaomi_lmi\",
    \"target_path\": \"vendor/xiaomi/lmi\"
  },
  {
    \"remote\": \"github\",
    \"repository\": \"LineageOS/android_hardware_xiaomi\",
    \"target_path\": \"hardware/xiaomi\",
    \"branch\": \"lineage-18.1\"
  }
]" > aosp.dependencies

git add . && git commit --message "lmi: $bringup" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"
git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_lmi HEAD:refs/heads/eleven --force

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
    \"remote\": \"lab-devices\",
    \"repository\": \"vendor_xiaomi_sm8250-common\",
    \"target_path\": \"vendor/xiaomi/sm8250-common\"
  }
]" > aosp.dependencies

git add . && git commit --message "sm8250-common: $bringup" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

# FaceUnlock
pwd=$(pwd)
mkdir -p overlay/packages/apps/FaceUnlockService/app/src/main/res/values
cd overlay/packages/apps/FaceUnlockService/app/src/main/res/values
wget https://raw.githubusercontent.com/PixelExperience-Devices/device_xiaomi_raphael/eleven/overlay/packages/apps/FaceUnlockService/app/src/main/res/values/config.xml
cd $pwd

msg="sm8250-common: overlay: FaceUnlockService: Define delay for our popup camera

* Android framework sometimes triggers face unlock at random times (after unlocking with pin or pattern, for example) so that the camera on devices with a pop-up camera is activated at unwanted times.

Adds a configurable delay to prevent this behavior"
git add . && git commit --message "$msg" --author "Henrique Silva <jhenrique09.mcz@hotmail.com>"

# Permissive
sed -i "s/BOARD_KERNEL_CMDLINE += androidboot.init_fatal_reboot_target=recovery/BOARD_KERNEL_CMDLINE += androidboot.init_fatal_reboot_target=recovery\nBOARD_KERNEL_CMDLINE += androidboot.selinux=permissive/g" BoardConfigCommon.mk
git add . && git commit --message "[DNM] sm8250-common: Permissive for now" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_sm8250-common HEAD:refs/heads/eleven --force

# Kernel and Vendor
cd $LMI

git clone https://github.com/xiaomi-sm8250-devs/android_device_xiaomi_lmi-kernel -b lineage-18.1
cd android_device_xiaomi_lmi-kernel
git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_lmi-kernel HEAD:refs/heads/eleven --force

cd ..
git clone https://gitlab.com/xiaomi-sm8250-devs/android_vendor_xiaomi -b lineage-18.1
mv android_vendor_xiaomi android_vendor_xiaomi_lmi
cp -rf android_vendor_xiaomi_lmi android_vendor_xiaomi_sm8250-common

cd android_vendor_xiaomi_lmi
git filter-branch --prune-empty --subdirectory-filter lmi lineage-18.1
git push ssh://git@gitlab.com/AOSPK-Devices/vendor_xiaomi_lmi HEAD:refs/heads/eleven --force

cd ../android_vendor_xiaomi_sm8250-common
git filter-branch --prune-empty --subdirectory-filter sm8250-common lineage-18.1
git push ssh://git@gitlab.com/AOSPK-Devices/vendor_xiaomi_sm8250-common HEAD:refs/heads/eleven --force

cd ..
git clone https://github.com/xiaomi-sm8250-devs/android_kernel_xiaomi_sm8250 -b lineage-18.1
cd android_kernel_xiaomi_sm8250

sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/umi_defconfig
sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/lmi_defconfig
sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/apollo_defconfig
sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/cas_defconfig
sed -i "s/lineageos/kraken/g" arch/arm64/configs/vendor/cmi_defconfig

git add . && git commit --message "ARM64: configs: xiaomi: Set localversion to kraken" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

git push ssh://git@github.com/AOSPK-Devices/kernel_xiaomi_sm8250 HEAD:refs/heads/eleven --force

rm -rf $LMI
