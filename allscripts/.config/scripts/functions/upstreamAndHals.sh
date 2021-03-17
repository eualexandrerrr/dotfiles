#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

upstream() {
  repo=${1}
  orgBase=ArrowOS
  [[ ${4} != "-f" ]] && branchBase=${2} || branchBase=arrow-11.0
  branchKraken=${3}
  [[ $repo == hardware_qcom_wlan ]] && branchBase="${branchBase}-caf" && branchKraken="${branchKraken}-caf"
  [[ $repo == hardware_qcom_bt ]] && branchBase="${branchBase}-caf" && branchKraken="${branchKraken}-caf"
  [[ $repo == hardware_qcom_bootctrl ]] && branchBase="${branchBase}-caf" && branchKraken="${branchKraken}-caf"
  workingDir=$(mktemp -d) && cd $workingDir
  echo -e "\n${BOL_BLU}Cloning ${BOL_RED}${repo} ${BOL_BLU}branch ${BOL_YEL}${branchBase} ${BOL_BLU}to ${BOL_YEL}${branchKraken}${END}\n"
  if [[ ${4} == "aosp" ]]; then
    echo "${BOL_RED}Forget everything above, I'm cloning it is straight from AOSP${END}"
    repoAOSP=$(echo $repo | sed "s/_/\//g")
    [[ $repoAOSP == hardware/libhardware/legacy ]] && repoAOSP="hardware/libhardware_legacy"
    git clone https://android.googlesource.com/platform/${repoAOSP} -b android-12.0.0_r2 ${repo}
  else
    git clone https://github.com/${orgBase}/android_${repo} -b ${branchBase} ${repo}
  fi
  cd ${repo}
  repo=$(echo $repo | sed -e "s/arrow/custom/g")
  repo=$(echo $repo | sed -e "s/Arrow/Custom/g")
  repo=$(echo $repo | sed -e "s/vendor_custom/vendor_aosp/g")
  gh repo create AOSPK/${repo} --public --confirm
  gh repo create AOSPK-Next/${repo} --private --confirm
  git push ssh://git@github.com/AOSPK/${repo} HEAD:refs/heads/${branchKraken} --force
  git push ssh://git@github.com/AOSPK-Next/${repo} HEAD:refs/heads/${branchKraken} --force
  gh api -XPATCH "repos/AOSPK/${repo}" -f default_branch="${branchKraken}" &> /dev/null
  gh api -XPATCH "repos/AOSPK-Next/${repo}" -f default_branch="${branchKraken}" &> /dev/null
  rm -rf $workingDir
}

up() {
  upstream ${1} arrow-12.0 twelve ${2}
}

hals() {
    pwd=$(pwd)
    branch=(
      msm8998
      sdm660
      sdm845
      sm8150
      sm8250
      sm8350
    )
    for i in "${branch[@]}"; do
      $HOME/.dotfiles/allscripts/.config/scripts/kraken/hal/hal.sh ${i}
    done
#    $HOME/.dotfiles/allscripts/.config/scripts/kraken/hal/devicesettings-custom.sh
    cd $pwd
}
