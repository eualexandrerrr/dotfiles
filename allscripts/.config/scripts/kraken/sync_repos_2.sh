#!/usr/bin/env bash

branch="twelve"

cd /tmp
rm -rf aosp.xml custom.xml
wget https://raw.githubusercontent.com/AOSPK/manifest/${branch}/aosp.xml
wget https://raw.githubusercontent.com/AOSPK/manifest/${branch}/custom.xml

repo_aosp=($(grep -Po 'name=\"\K[^"]+(?=\")' /tmp/aosp.xml))

for repo_aosp in ${repo_aosp[@]}; do
  [[ $repo_aosp == "aospk" ]] && continue
  [[ $repo_aosp == "aospk-gitlab" ]] && continue
  [[ $repo_aosp == "hub-devices" ]] && continue
  [[ $repo_aosp == "blobs" ]] && continue
  [[ $repo_aosp == "github" ]] && continue
  [[ $repo_aosp == "gitlab" ]] && continue
  [[ $repo_aosp == "manifest" ]] && continue
  cd /tmp
  rm -rf $repo_aosp
  git clone ssh://git@github.com/AOSPK/${repo_aosp} -b ${branch} $repo_aosp
  cd $repo_aosp
  git push ssh://git@github.com/AOSPK-Next/${repo_aosp} HEAD:refs/heads/${branch} --force
done

# Custom
repo_custom=($(grep -Po 'name=\"\K[^"]+(?=\")' /tmp/custom.xml))

for repo_custom in ${repo_custom[@]}; do
  [[ $repo_custom == "hardware_qcom_bootctrl" ]] && branch="${branch}-caf"
  [[ $repo_custom == "hardware_qcom_wlan" ]] && branch="${branch}-caf"
  cd /tmp
  rm -rf $repo_custom
  git clone ssh://git@github.com/AOSPK/${repo_custom} -b ${branch} $repo_custom
  cd $repo_custom
  git push ssh://git@github.com/AOSPK-Next/${repo_custom} HEAD:refs/heads/${branch} --force
done

# HALS
cd /tmp
rm -rf custom.xml
wget https://raw.githubusercontent.com/AOSPK/manifest/${branch}/custom.xml

hals=($(grep hardware_qcom_audio /tmp/custom.xml | awk '{ print $6 }' | cut -c22-300 | tr -d '"="'))

for hal in ${hals[@]}; do
  repos=('audio' 'media' 'display')
  for repo in ${repos[@]}; do
    cd /tmp
    rm -rf ${repo}_${branch}-caf-${hal}
    git clone ssh://git@github.com/AOSPK/hardware_qcom_${repo} -b ${branch}-caf-${hal} ${repo}_${branch}-caf-${hal}
    cd ${repo}_${branch}-caf-${hal}
    git push ssh://git@github.com/AOSPK-Next/hardware_qcom_${repo} HEAD:refs/heads/${branch}-caf-${hal} --force
  done
done
