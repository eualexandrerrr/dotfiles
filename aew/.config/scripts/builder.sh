#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

codename=veux

ccacheC() {
  sudo mkdir -p /mnt/ccache
  sudo mount --bind /home/mamutal91/.cache /mnt/ccache
  export USE_CCACHE=1
  export CCACHE_DIR=/mnt/ccache
  export CCACHE_EXEC=/usr/bin/ccache
  ccache -M 200G

#  export JAVA_HOME=/usr/lib/jvm/java-18-openjdk
  export JAVA_HOME=/usr/lib/jvm/java-8-openjdk/
  sudo nbfc set -s 100
}

s() {
  clear

  mkdir -p $HOME/PixelExperience
  cd $HOME/PixelExperience
  repo init -u ssh://git@github.com/PixelExperience/manifest -b thirteen
  repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all)
}

b() {
  clear

  cp -rf log.txt old_log.txt &> /dev/null
  ccacheC

  export TARGET_BOOT_ANIMATION_RES=1080
  export TARGET_USES_AOSP_RECOVERY=true
  export TARGET_SUPPORTS_GOOGLE_RECORDER=true
  export TARGET_INCLUDE_LIVE_WALLPAPERS=true
  export TARGET_SUPPORTS_QUICK_TAP=true
  export TARGET_FACE_UNLOCK_SUPPORTED=true

  cd $HOME/PixelExperience
  . build/envsetup.sh && lunch aosp_${codename}-userdebug
  make bacon -j$(nproc --all) 2>&1 | tee log.txt
}
