#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.mytokens/.myTokens &> /dev/null

rom="/mnt/storage/Kraken"
codename=lmi
buildtype=userdebug

argsC() {
  export TARGET_BOOT_ANIMATION_RES=1080
}

ccacheC() {
  export USE_CCACHE=1
  export CCACHE_EXEC=/usr/bin/ccache
  export CCACHE_DIR=/mnt/storage/ccache
  ccache -M 100G -F 0
  sudo mkdir -p /home/mamutal91/.ccache &> /dev/null
  sudo mount --bind /mnt/storage/ccache ~/.ccache
}

proxy() {
  if [[ -n ${1} ]]; then
    echo "${BOL_CYA}Proxy: ${1}${END}"
    export http_proxy="http://${1}/"
    export ftp_proxy="ftp://${1}/"
    export rsync_proxy="rsync://${1}/"
    export no_proxy="localhost,127.0.0.1,192.168.1.1,::1,*.local"
    export HTTP_PROXY="http://${1}/"
    export FTP_PROXY="ftp://${1}/"
    export RSYNC_PROXY="rsync://${1}/"
    export NO_PROXY="localhost,127.0.0.1,192.168.1.1,::1,*.local"
    export https_proxy="http://${1}/"
    export HTTPS_PROXY="http://${1}/"
    git config --global http.proxy http://${1}
    git config --global https.proxy http://${1}
  else
    echo -e "${BOL_RED} You need set proxy!\n${BOL_GRE}Example: ${BOL_CYA}s 192.168.17.28:44355${END}"
    sleep 20
    exit
  fi
}

unproxy() {
  git config --global --unset http.proxy
  git config --global --unset https.proxy
}

s() {
  currentWifi=$(iwctl station wlan0 show | grep 'Connected network' | awk '{ print $3}')
  if [[ $currentWifi == "MamutMovel" ]]; then
    echo "${BOL_RED}Você não pode fazer sync na sua rede móvel de 100GB${END}"
    sleep 20 && exit
  fi
  if [[ ${1} == -f ]]; then
    echo "${BOL_GRE}Syncing!${END}"
  else
    proxy ${1}
  fi
  cd $rom && clear
  rm -rf .repo/local_manifests
  nbfc set -s 100
  repo init -u https://github.com/AOSPK/manifest -b twelve
  repo sync -c -j$(nproc --all) --no-clone-bundle --current-branch --no-tags --force-sync
  dunstify "Kraken Builder" "Sync finished"
}

lunchC() {
  . build/envsetup.sh
  lunch aosp_${codename}-${buildtype}
}

b() {
  cd $rom && clear
  nbfc set -s 100
  argsC
  ccacheC
  task=${1}
  [[ -z $task ]] && task=bacon || task=${1}
  echo -e "${BOL_MAG}\nYou are building:"
  echo -e "${BOL_YEL}Task   : ${BOL_CYA}${task}"
  echo -e "${BOL_YEL}Device : ${BOL_CYA}${codename}"
  echo -e "${BOL_YEL}Type   : ${BOL_CYA}${buildtype}"
  echo -e "${BOL_YEL}Pwd    : ${BOL_CYA}$PWD"
  echo -e "\n\n"
  lunchC
  make -j$(nproc --all) ${task} 2>&1 | tee log.txt
  dunstify "Kraken Builder" "Build finished"
  nbfc set -s 50
}

clean() {
  cd $rom && clear
  nbfc set -s 100
  argsC
  lunchC
  [[ ${1} == "-f" ]] && make clean || make installclean
  dunstify "Kraken Builder" "Clean finished"
  nbfc set -s 50
}
