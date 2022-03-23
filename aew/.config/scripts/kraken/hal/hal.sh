#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

workingDir=$(mktemp -d) && cd $workingDir

repos=(
    hardware_qcom_audio
    hardware_qcom_display
    hardware_qcom_media
)

branchBase="arrow-12.0-caf-${1}"
branchKraken="twelve-caf-${1}"
branchBaseLos="arrow-12.0-caf-${1}"
branchBaseLosOld="arrow-12.0-caf-${1}"

for i in ${repos[@]}; do

#  [[ $branchBase == "arrow-12.0-caf-msm8998" ]] && continue
#  [[ $branchBase == "arrow-12.0-caf-msm8996" ]] && continue
#  [[ $branchBase == "arrow-12.0-caf-sdm660" ]] && continue
#  [[ $branchBase == "arrow-12.0-caf-sdm845" ]] && continue
#  [[ $branchBase == "arrow-12.0-caf-sm8150" ]] && continue
#  [[ $branchBase == "arrow-12.0-caf-sm8250" ]] && continue

#  [[ $i == "hardware_qcom_audio" ]] && continue
#  [[ $i == "hardware_qcom_display" ]] && continue
#  [[ $i == "hardware_qcom_media" ]] && continue

  rm -rf ${i}
  echo -e "${BOL_GRE}Repo      : ${BOL_YEL}${i}${END}"
  echo -e "${BOL_GRE}ArrowOS   : ${BOL_YEL}${branchBase}${END}"
  echo -e "${BOL_GRE}LineageOS : ${BOL_YEL}${branchBaseLos}${END}"
  echo -e "${BOL_CYA}Kraken    : ${BOL_MAG}${branchKraken}${END}\n"

  git clone https://github.com/ArrowOS/android_${i} -b ${branchBase} ${i} --single-branch
  if [ $? -eq 0 ]; then
    echo -e "\n${BOL_GRE}ArrowOS ${branchBase} ${BOL_CYA}cloned success${END}"
  else
    git clone https://github.com/LineageOS/android_${i} -b ${branchBaseLos} ${i} --single-branch
    if [ $? -eq 0 ]; then
      echo -e "\n${BOL_GRE}LineageOS ${branchBaseLos} ${BOL_CYA}cloned success${END}"
    else
      git clone https://github.com/LineageOS/android_${i} -b ${branchBaseLosOld} ${i} --single-branch
      echo -e "\n${BOL_GRE}LineageOS ${branchBaseLosOld} ${BOL_CYA}cloned success${END}"
    fi
  fi

  cd ${i}
  echo -e "\n${BOL_CYA}Pushing to org ${BOL_MAG}AOSPK${END}"
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/${branchKraken} --force
  echo -e "\n${BOL_CYA}Pushing to org ${BOL_MAG}AOSPK-Next${END}\n"
  git push ssh://git@github.com/AOSPK-Next/${i} HEAD:refs/heads/${branchKraken} --force

  echo -e "\n${GRE}-----------------------------------------------"
done

rm -rf $workingDir
