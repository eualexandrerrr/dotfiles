#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

rom="/mnt/storage/Kraken"
codename=lmi
buildtype=userdebug

argsC() {
  export TARGET_BOOT_ANIMATION_RES=1080
  export KRAKEN_BUILD_TYPE=OFFICIAL
  export BUILD_WITH_COLORS=1
}

ccacheC() {
  export USE_CCACHE=1
  export CCACHE_EXEC=/usr/bin/ccache
  export CCACHE_DIR=/mnt/storage/ccache
  ccache -M 100G -F 0
  sudo mkdir -p /home/mamutal91/.ccache &> /dev/null
  sudo mount --bind /mnt/storage/ccache ~/.ccache
}

s() {
  iconSuccess="$HOME/.config/assets/icons/success.png"
  iconFail="$HOME/.config/assets/icons/fail.png"
  mkdir -p $rom &> /dev/null
  cd $rom && clear
  nbfc set -s 100
  repo init -u https://github.com/AOSPK/manifest -b twelve
  repo sync -c --no-clone-bundle --current-branch --no-tags --force-sync -j$(nproc --all) 2>&1 | tee log.txt
  if [[ $? -eq 0 ]]; then
    echo "${BOL_GRE}Repo Sync success${END}"
    dunstify -i $iconSuccess "Kraken Builder" "Sync success"
  else
    echo "${BOL_RED}Repo Sync failure${END}"
    dunstify -i $iconFail "Kraken Builder" "Sync failure"
  fi
  git clone ssh://git@github.com/AOSPK/hardware_xiaomi -b twelve hardware/xiaomi &> /dev/null
  nbfc set -s 50
}

lunchC() {
  . build/envsetup.sh
  lunch aosp_${codename}-${buildtype}
}

apkAndimg() {
  pathPrebuilts=$HOME/Builds
  rm -rf ${pathPrebuilts}/{apk,img} &> /dev/null
  mkdir -p ${pathPrebuilts}/{apk,apk/accents,apk/overlay,img} &> /dev/null
  rm -rf obj/*/*/*.apk
  rm -rf symbols/*/*/*.apk
  cp -R */*/*.apk ${pathPrebuilts}/apk
  cp -R */*/*/*.apk ${pathPrebuilts}/apk
  cp -R */*/*/*/*.apk ${pathPrebuilts}/apk
  cp -R *.img ${pathPrebuilts}/img
  cp -R Kraken_overlays.zip ${pathPrebuilts}
}

moveBuild() {
  pwd=$(pwd)
  mkdir -p $HOME/Builds
  cd /mnt/storage/Kraken/out/target/product/lmi
  mv Kraken-12-*-*.zip $HOME/Builds
  apkAndimg &> /dev/null
  rm -rf /mnt/storage/Kraken/out/target/product/lmi/{*.md5sum,*.json}
  cd $pwd
}

b() {
  iconSuccess="$HOME/.config/assets/icons/success.png"
  iconFail="$HOME/.config/assets/icons/fail.png"
  cd $rom && clear
  nbfc set -s 100
  cp -rf log.txt old_log.txt
  argsC
  ccacheC &> /dev/null
  task=${1}
  [[ -z $task ]] && task=bacon
  cores=$(nproc --all)
  echo -e "${BOL_MAG}\nYou are building:"
  echo -e "${BOL_YEL}Task   : ${BOL_CYA}${task}"
  echo -e "${BOL_YEL}Device : ${BOL_CYA}${codename}"
  echo -e "${BOL_YEL}Type   : ${BOL_CYA}${buildtype}"
  echo -e "${BOL_YEL}Cores  : ${BOL_CYA}${cores}${END}"
  echo -e "${BOL_YEL}Pwd    : ${BOL_CYA}$PWD${END}"
  echo -e "\n"
  lunchC
  makeC() {
    [[ -z $task ]] && task=bacon
    make -j${cores} ${task} 2>&1 | tee log.txt
    if [[ $? -eq 0 ]]; then
      echo "${BOL_GRE}Build success${END}"
      dunstify -i $iconSuccess "Kraken Builder" "Build success"
      moveBuild &> /dev/null
    else
      echo "${BOL_RED}Build failure${END}"
      dunstify -i $iconFail "Kraken Builder" "Build failure"
    fi
  }

  if [[ $task == "overlays" ]]; then
    makeBuild=false
    echo building overlays
    bash vendor/aosp/build/tools/overlays.sh
  elif [[ $task == "changelog" ]]; then
    makeBuild=false
    echo generate changelogs
    bash vendor/aosp/build/tools/changelog
  elif [[ $task == "Settings" ]]; then
    makeBuild=true
    task=Settings
  elif [[ $task == "recovery" ]]; then
    makeBuild=true
    task=recoveryimage
  else
    makeBuild=true
    task=bacon
  fi

  [[ $makeBuild == "true" ]] && makeC

  nbfc set -s 50

  # Desligar o notebook se $1 for poweroff, porém, esperar 100 segundos para que esfrie os componentes
  [[ ${1} == poweroff ]] && sleep 100 && sudo poweroff
}

clean() {
  cd $rom && clear
  nbfc set -s 100
  argsC
  lunchC
  if [[ ${1} == "-f" ]]; then
    echo -e "${BOL_MAG}make clean${END}"
    make clean
  else
    echo -e "${BOL_MAG}make installclean${END}"
    make installclean
  fi
  nbfc set -s 50
}
