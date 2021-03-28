#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

rom="/mnt/storage/Kraken"
codename=lmi
buildtype=userdebug

argsC() {
  export TARGET_BOOT_ANIMATION_RES=1080
  export KRAKEN_BUILD_TYPE=OFFICIAL
#  export TARGET_INCLUDE_PIXEL_STYLE=true
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
  iconSuccess="$HOME/.config/assets/icons/success.png"
  iconFail="$HOME/.config/assets/icons/fail.png"
  cd $rom && clear
  rm -rf .repo/local_manifests
  nbfc set -s 100
  repo init -u https://github.com/AOSPK/manifest -b twelve
  repo sync -c -j$(nproc --all) --no-clone-bundle --current-branch --no-tags --force-sync
  if [[ $? -eq 0 ]]; then
    echo "${BOL_GRE}Repo Sync success${END}"
    dunstify -i $iconSuccess "Kraken Builder" "Sync success"
  else
    echo "${BOL_RED}Repo Sync failure${END}"
    dunstify -i $iconFail "Kraken Builder" "Sync failure"
  fi
}

lunchC() {
  . build/envsetup.sh
  lunch aosp_${codename}-${buildtype}
}

moveBuild() {
  pwd=$(pwd)
  mkdir -p $HOME/Builds &> /dev/null
  cd /mnt/storage/Kraken/out/target/product/lmi
  mv Kraken-12-*-lmi-*.zip $HOME/Builds
  cd $pwd
}

b() {
  iconSuccess="$HOME/.config/assets/icons/success.png"
  iconFail="$HOME/.config/assets/icons/fail.png"
  cd $rom && clear
  nbfc set -s 100
  cp -rf log.txt old_log.txt
  argsC
  ccacheC
  task=bacon
  var=${1}
  re='^[0-9]+$'
  if ! [[ $var =~ $re ]] ; then
    cores=7
  else
    cores=${1}
  fi
  echo -e "${BOL_MAG}\nYou are building:"
  echo -e "${BOL_YEL}Task   : ${BOL_CYA}${task}"
  echo -e "${BOL_YEL}Device : ${BOL_CYA}${codename}"
  echo -e "${BOL_YEL}Type   : ${BOL_CYA}${buildtype}"
  echo -e "${BOL_YEL}Cores  : ${BOL_CYA}${cores}${END}"
  echo -e "${BOL_YEL}Pwd    : ${BOL_CYA}$PWD${END}"
  echo -e "\n"
  lunchC
  make -j${cores} ${task}
  if [[ $? -eq 0 ]]; then
    echo "${BOL_GRE}Build success${END}"
    dunstify -i $iconSuccess "Kraken Builder" "Build success"
  else
    echo "${BOL_RED}Build failure${END}"
    dunstify -i $iconFail "Kraken Builder" "Build failure"
  fi
  nbfc set -s 50
  moveBuild
  if [[ ${1} == poweroff ]]; then
    sleep 100
    sudo poweroff
  fi
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
