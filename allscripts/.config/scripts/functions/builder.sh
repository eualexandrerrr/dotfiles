#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

rom="/mnt/nvme/Kraken"
codename=surya
buildtype=userdebug

argsC() {
#  echo -e "${BOL_RED}SELINUX_IGNORE_NEVERALLOWS=true${END}\n" && export SELINUX_IGNORE_NEVERALLOWS=true
}

ccacheC() {
  export USE_CCACHE=1
  export CCACHE_EXEC=/usr/bin/ccache
  export CCACHE_DIR=/mnt/nvme/ccache
  ccache -M 100G -F 0
  sudo mkdir -p /home/mamutal91/.ccache &> /dev/null
  sudo mount --bind /mnt/nvme/ccache ~/.ccache
}

s() {
  iconSuccess="$HOME/.config/assets/icons/success.png"
  iconFail="$HOME/.config/assets/icons/fail.png"
  mkdir -p $rom &> /dev/null
  cd $rom && clear
  nbfc set -s 100
  repo init -u ssh://git@github.com/AOSPK-Next/manifest -b twelve
  repo sync -c --no-clone-bundle --current-branch --no-tags --force-sync -j$(nproc --all)
  if [[ $? -eq 0 ]]; then
    echo "${BOL_GRE}Repo Sync success${END}"
    dunstify -i $iconSuccess "Builder" "Sync success"
  else
    echo "${BOL_RED}Repo Sync failure${END}"
    dunstify -i $iconFail "Builder" "Sync failure"
  fi
  nbfc set -s 50
}

lunchC() {
  . build/envsetup.sh
  lunch aosp_${codename}-${buildtype}
}

apkAndimg() {
  pathPrebuilts=/mnt/nvme/Builds
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
  pathBuilds=/mnt/nvme/Builds
  mkdir -p $pathBuilds
  cd /mnt/nvme/Kraken/out/target/product/lmi
  mv Kraken-12-*-*.zip $pathBuilds
  apkAndimg &> /dev/null
  rm -rf /mnt/nvme/Kraken/out/target/product/lmi/{*.md5sum,*.json}
  cd $pwd
}

b() {
  iconSuccess="$HOME/.config/assets/icons/success.png"
  iconFail="$HOME/.config/assets/icons/fail.png"
  cd $rom && clear
  nbfc set -s 100
  cp -rf log.txt old_log.txt
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
  argsC
  lunchC
  makeC() {
    [[ -z $task ]] && task=bacon
    make -j${cores} ${task} 2>&1 | tee log.txt
    if [[ $? -eq 0 ]]; then
      echo "${BOL_GRE}Build success${END}"
      moveBuild &> /dev/null
      dunstify -i $iconSuccess "Builder" "Build success"
    else
      echo "${BOL_RED}Build failure${END}"
      dunstify -i $iconFail "Builder" "Build failure"
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
