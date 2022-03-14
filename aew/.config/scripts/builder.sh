#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

rom="$HOME/Kraken"
codename=lmi
buildtype=userdebug

argsC() {
  #  echo -e "${BOL_RED}SELINUX_IGNORE_NEVERALLOWS=true${END}\n" && export SELINUX_IGNORE_NEVERALLOWS=true
}

ccacheC() {
  sudo mkdir -p /mnt/ccache
  sudo mount --bind /home/mamutal91/.cache /mnt/ccache
  export USE_CCACHE=1
  export CCACHE_DIR=/mnt/ccache
  export CCACHE_EXEC=/usr/bin/ccache
  ccache -M 100G
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
  pwd=$(pwd)
  cd out/target/product/lmi
  pathPrebuilts=$HOME/Builds
  rm -rf ${pathPrebuilts}/{apk,img,json} &> /dev/null
  mkdir -p ${pathPrebuilts}/{apk,apk/accents,apk/overlay,img} &> /dev/null
  rm -rf obj/*/*/*.apk
  rm -rf symbols/*/*/*.apk
  cp -R */*/*.apk ${pathPrebuilts}/apk
  cp -R */*/*/*.apk ${pathPrebuilts}/apk
  cp -R */*/*/*/*.apk ${pathPrebuilts}/apk
  cp -R *.img ${pathPrebuilts}/img
  cd $pwd
}

moveBuild() {
  pathBuilds=$HOME/Builds
  mkdir -p $pathBuilds
  mv $HOME/Kraken/out/target/product/${codename}/Kraken-12-*-*.zip $pathBuilds
  mv $HOME/Kraken/out/target/product/${codename}/Kraken-12-*-*.json $pathBuilds/json
  apkAndimg
  rm -rf $HOME/Kraken/out/target/product/${codename}/{*.md5sum,*.sha256sum,*ota*.zip,*.json}
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
  [[ $task == "poweroff" ]] && task=bacon
  cores=$(nproc --all)
  if [[ $@ == "poweroff" ]]; then
    export poweroff="yes"
    echo -e "\n${BOL_RED}Eu vou desligar após compilar${END}"
  fi
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

  msg="*Task:* ${task}
*Codename:* ${codename}
*Result:* ${buildResult}
*Finish:* $(date +"%H:%M")"

    sendTelegramMsg() {
      curl "https://api.telegram.org/bot${mamutal91_botToken}/sendMessage" \
        -d chat_id="-1001702262779" \
        -d disable_notification="false" \
        --data-urlencode text="${msg}" \
        --data-urlencode parse_mode="markdown" \
        --data-urlencode disable_web_page_preview="true"
  }
  sendTelegramMsg &> /dev/null

  nbfc set -s 50

  # Desligar o notebook se algum argumento for poweroff, porém, esperar 100 segundos para que esfrie os componentes
  if [[ $poweroff == "yes" ]]; then
    sleep 60
    nbfc set -s 50
    sudo poweroff
  fi
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
