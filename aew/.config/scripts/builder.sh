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
  cd $HOME/EvoX
  echo $PWD
  rm -rf device/xiaomi vendor/xiaomi kernel/xiaomi kernel/xiaomi/sm6375
  git clone ssh://git@github.com/mamutal91/device_xiaomi_veux -b thirteen device/xiaomi/veux
  git clone ssh://git@github.com/mamutal91/device_xiaomi_veux-kernel -b thirteen device/xiaomi/veux-kernel
  git clone https://github.com/mamutal91/kernel_xiaomi_sm6375 -s -b thirteen kernel/xiaomi/sm6375
  git clone ssh://git@github.com/mamutal91/vendor_xiaomi_veux -b thirteen vendor/xiaomi/veux
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
  mkdir -p $HOME/EvoX
  cd $HOME/EvoX
  echo -e "${GRE}EvoX${END} $PWD"
  repo init -u https://github.com/Evolution-X/manifest -b tiramisu
  repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all)
}

c() {
  ccacheC
  cd $HOME/EvoX
  echo -e "${GRE}EvoX${END} $PWD"

  cp -rf log.txt old_log.txt &> /dev/null

  . build/envsetup.sh && lunch evolution_veux-userdebug
  make evolution -j$(nproc --all) 2>&1 | tee log.txt

  sleep 10
  mkdir -p $HOME/Builds
  mv $HOME/EvoX/out/target/product/veux/evo*.zip $HOME/Builds
  rm -rf $HOME/EvoX/out/target/product/veux/evo*
}
