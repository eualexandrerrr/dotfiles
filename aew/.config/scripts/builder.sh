#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

magisk() {
  sudo adb sideload $HOME/Builds/Magisk-v25.2.apk
}

sideload() {
  lastBuild=$(cd $HOME/Builds && find -printf "%TY-%Tm-%Td %TT %p\n" | sort -n | awk '{ a=b ; b=$0 } END { print a }' | awk '{print $3}' | cut -c3-300)

  echo -e "${GRE}${lastBuild}${END}\n"
  echo "Waiting for device..."
  adb wait-for-device-recovery
  echo "Rebooting to sideload for install"
  adb reboot sideload-auto-reboot
  adb wait-for-sideload
  echo -e "\n${RED}Rebooting to sideload for install${END}"
  adb sideload $HOME/Builds/$lastBuild
}

tree() {
  cd $HOME/PixelStuffs
  echo $PWD
  rm -rf device/xiaomi hardware/xiaomi vendor/xiaomi kernel/xiaomi
  git clone ssh://git@github.com/mamutal91/device_xiaomi_veux -b thirteen device/xiaomi/veux
  git clone ssh://git@github.com/mamutal91/device_xiaomi_veux-kernel -b thirteen device/xiaomi/veux-kernel
  git clone ssh://git@github.com/mamutal91/vendor_xiaomi_veux -b thirteen vendor/xiaomi/veux

  git clone https://github.com/ghostrider-reborn/android_kernel_xiaomi_lisa -s -b sapphire kernel/xiaomi/sm6375

  git clone ssh://git@github.com/PixelExperience/hardware_xiaomi -b thirteen hardware/xiaomi
}

ccacheC() {
  clear
  sudo mkdir -p /mnt/ccache
  sudo mount --bind /home/mamutal91/.cache /mnt/ccache
  export USE_CCACHE=1
  export CCACHE_DIR=/mnt/ccache
  export CCACHE_EXEC=/usr/bin/ccache
  ccache -M 200G
}

s() {
  mkdir -p $HOME/PixelStuffs
  cd $HOME/PixelStuffs
  echo -e "${GRE}PixelStuffs${END} $PWD"
  repo init -u https://github.com/PixelStuffs/manifest -b thirteen
  repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all)
}

c() {
  ccacheC
  cd $HOME/PixelStuffs
  echo -e "${GRE}PixelStuffs${END} $PWD"

  cp -rf log.txt old_log.txt &> /dev/null

  . build/envsetup.sh && lunch aosp_veux-userdebug
  make bacon -j$(nproc --all) 2>&1 | tee log.txt

  sleep 10
  mkdir -p $HOME/Builds
  mv $HOME/PixelStuffs/out/target/product/veux/Arrow*.zip $HOME/Builds
  rm -rf $HOME/PixelStuffs/out/target/product/veux/Arrow*
}
