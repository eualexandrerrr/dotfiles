#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

sideload() {
  if [[ ${1} == magisk ]]; then
    zip="Magisk-v25.2.apk"
  else
    zip=$(cd $HOME/Builds && find -printf "%TY-%Tm-%Td %TT %p\n" | sort -n | awk '{ a=b ; b=$0 } END { print a }' | awk '{print $3}' | cut -c3-300)
  fi

  echo -e "${GRE}${zip}${END}\n"
  echo "Waiting for device..."
  adb wait-for-device-recovery
  echo "Rebooting to sideload for install"
  adb reboot sideload-auto-reboot
  adb wait-for-sideload
  echo -e "\n${RED}Rebooting to sideload for install${END}"
  adb sideload $HOME/Builds/$zip
}

tree() {
  cd $HOME/Paranoid
  echo $PWD
  rm -rf device/xiaomi vendor/xiaomi kernel/xiaomi kernel/xiaomi/sm6375
  git clone ssh://git@github.com/mamutal91/device_xiaomi_veux -s -b topaz device/xiaomi/veux
  git clone ssh://git@github.com/mamutal91/device_xiaomi_veux-kernel -s -b topaz device/xiaomi/veux-kernel
  git clone https://github.com/mamutal91/kernel_xiaomi_sm6375 -s -b topaz kernel/xiaomi/sm6375
  git clone ssh://git@gitlab.com/mamutal91/vendor_xiaomi_veux -s -b topaz vendor/xiaomi/veux
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
  if [[ ${1} == "b" ]]; then
    mkdir -p $HOME/Blaze
    cd $HOME/Blaze
    echo -e "${GRE}Blaze${END} $PWD"
    repo init -u https://github.com/ProjectBlaze/manifest.git -b 13
    repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all)
  else
    mkdir -p $HOME/Paranoid
    cd $HOME/Paranoid
    echo -e "${GRE}Paranoid${END} $PWD"
    repo init -u https://github.com/AOSPA/manifest -b topaz
    repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all)
  fi
}

c() {
  if [[ ${1} == "b" ]]; then
    cd $HOME/Blaze
    ccacheC
    echo -e "${GRE}Blaze${END} $PWD"

    cp -rf log.txt old_log.txt &> /dev/null

    . build/envsetup.sh && lunch blaze_veux-userdebug
    make bacon -j$(nproc --all) 2>&1 | tee log.txt

    sleep 5
    mkdir -p $HOME/Builds
    cp -rf $HOME/Blaze/out/target/product/veux/*.zip $HOME/Builds
    rm -rf $HOME/Blaze/out/target/product/veux/* &> /dev/null
  else
    cd $HOME/Paranoid
    ccacheC
    echo -e "${GRE}Paranoid${END} $PWD"

    cp -rf log.txt old_log.txt &> /dev/null

    ./rom-build.sh veux -t userdebug | tee log.txt

    sleep 5
    mkdir -p $HOME/Builds
    cp -rf $HOME/Paranoid/out/target/product/veux/*.zip $HOME/Builds
    rm -rf $HOME/Paranoid/out/target/product/veux/* &> /dev/null
    rm -rf $HOME/Builds/aospa_veux-ota-eng.mamutal91.zip
  fi
}
