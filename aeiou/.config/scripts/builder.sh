#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

rom="$HOME/Kraken"
codename=lmi
buildtype=userdebug

argsC() {
#  echo -e "${BOL_RED}SELINUX_IGNORE_NEVERALLOWS=true${END}\n" && export SELINUX_IGNORE_NEVERALLOWS=true
}

proxyC() {
  ip="192.168.132.155:44355"
  git config --global socks.proxy ${ip}
  git config --global ssh.proxy http://${ip}
  git config --global http.proxy http://${ip}
  git config --global https.proxy http://${ip}
  export http_proxy="http://${ip}/"
  export ftp_proxy="ftp://${ip}/"
  export rsync_proxy="rsync://${ip}/"
  export no_proxy="localhost,127.0.0.1,192.168.1.1,::1,*.local"
  export HTTP_PROXY="http://${ip}/"
  export FTP_PROXY="ftp://${ip}/"
  export RSYNC_PROXY="rsync://${ip}/"
  export NO_PROXY="localhost,127.0.0.1,192.168.1.1,::1,*.local"
  export https_proxy="http://${ip}/"
  export HTTPS_PROXY="http://${ip}/"
}

ccacheC() {
  sudo mkdir /home/mamutal91/.ccacherom &> /dev/null
  sudo mount --bind /home/mamutal91/.ccache /home/mamutal91/.ccacherom
  export USE_CCACHE=1
  export CCACHE_EXEC=/usr/bin/ccache
  export CCACHE_DIR=/home/mamutal91/.ccacherom
  ccache -M 100G -F 0
}

s() {
  proxyC
  iconSuccess="$HOME/.config/assets/icons/success.png"
  iconFail="$HOME/.config/assets/icons/fail.png"
  mkdir -p $rom &> /dev/null
  cd $rom && clear
  nbfc set -s 100
  repo init -u https://github.com/AOSPK-Next/manifest -b twelve
#  repo init -u ssh://git@github.com/AOSPK-Next/manifest -b twelve
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
  cd out/target/product/lmi
  pathPrebuilts=$HOME/Builds
  rm -rf ${pathPrebuilts}/{apk,img} &> /dev/null
  mkdir -p ${pathPrebuilts}/{apk,apk/accents,apk/overlay,img} &> /dev/null
  rm -rf obj/*/*/*.apk
  rm -rf symbols/*/*/*.apk
  cp -R */*/*.apk ${pathPrebuilts}/apk
  cp -R */*/*/*.apk ${pathPrebuilts}/apk
  cp -R */*/*/*/*.apk ${pathPrebuilts}/apk
  cp -R *.img ${pathPrebuilts}/img
}

moveBuild() {
  pathBuilds=$HOME/Builds
  mkdir -p $pathBuilds
  mv $HOME/Kraken/out/target/product/*/Kraken-12-*-*.zip $pathBuilds
  [[ $codename == lmi ]] && apkAndimg &> /dev/null
  rm -rf $HOME/Kraken/out/target/product/*/{*.md5sum,*.sha256sum,*ota*.zip}
}

b() {
  iconSuccess="$HOME/.config/assets/icons/success.png"
  iconFail="$HOME/.config/assets/icons/fail.png"
  cd $rom && clear
  nbfc set -s 100
  cp -rf log.txt old_log.txt &> /dev/null
  ccacheC
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

    buildResult=SUCCESS
    logBuild=$(grep '####' $rom/log.txt)
    [[ $(echo $logBuild | grep "failed") ]] && buildResult=FAILED
    [[ $(echo $logBuild | grep "success") ]] && buildResult=SUCCESS

    if [[ $buildResult == "SUCCESS" ]]; then
      echo "${BOL_GRE}Build success${END}"
      moveBuild &> /dev/null
      dunstify -i $iconSuccess "Builder" "Build success"
    else
      echo "${BOL_RED}Build failure${END}"
      dunstify -i $iconFail "Builder" "Build failure"
    fi
  }

  if [[ $task == "changelog" ]]; then
    makeBuild=false
    echo generate changelogs
    bash vendor/aosp/build/tools/changelog
  elif [[ $task == "Settings" ]]; then
    makeBuild=true
    task=Settings
  elif [[ $task == "recoveryimage" ]]; then
    makeBuild=true
    task=recoveryimage
  elif [[ $task == "bootimage" ]]; then
    makeBuild=true
    task=bootimage
  else
    makeBuild=true
    task=bacon
  fi

  [[ $makeBuild == "true" ]] && makeC

  nbfc set -s 50

  # Desligar o notebook se algum argumento for poweroff, porém, esperar 100 segundos para que esfrie os componentes
  [[ $@ == poweroff ]] && sleep 100 && nbfc set -s 50 && sudo poweroff
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
