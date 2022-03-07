#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

org=xiaomi-sm8250-devs
branch=lineage-19.0
repo=${1}
repoRebase=android_${repo}
project=${2}

rm -rf /tmp/dsadasdadASDASDaSDAS &> /dev/null
mkdir -p /tmp/dsadasdadASDASDaSDAS &> /dev/null
cd /tmp/dsadasdadASDASDaSDAS
git clone https://github.com/${org}/${repoRebase} ${repo} -b ${branch}
cd ${repo}

commitsIds=($(git log --pretty=format:"%H"))
f() { commitsIds=("${BASH_ARGV[@]}"); }

shopt -s extdebug
f "${commitsIds[@]}"
shopt -u extdebug

rm -rf /tmp/rebaseRepoLmiPocoF2Pro &> /dev/null
mkdir -p /tmp/rebaseRepoLmiPocoF2Pro &> /dev/null
cd /tmp/rebaseRepoLmiPocoF2Pro &> /dev/null
git init &> /dev/null

git fetch https://github.com/${org}/${repoRebase} ${branch} &> /dev/null
for i in "${commitsIds[@]}"; do
  git cherry-pick ${i} &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo -e "${BOL_GRE}Cherry-pick sucess${END}"
  else
    echo -e "${BOL_RED}Cherry-pick failure${END}"
    echo -e "\n *> ${BOL_YEL}${i}${END}\n"
    git add . && git cherry-pick --continue --no-edit
    if [[ -d overlay-${project}/lineage-sdk ]]; then
      pwd=$(pwd)
      cd overlay-${project} &> /dev/null
      mkdir -p packages/apps/Settings/res &> /dev/null
      cd lineage-sdk/lineage/res/res &> /dev/null
      mv values $pwd/overlay-${project}/packages/apps/Settings/res
      cd $pwd
    fi
    git add . && git commit --amend --no-edit
    git push ssh://git@github.com/mamutal91/${repo} HEAD:refs/heads/twelve --force &> /dev/null
  fi
  mv lineage_lmi.mk aosp_lmi.mk &> /dev/null
  mv lineage.dependencies aosp.dependencies &> /dev/null
  mv overlay-lineage overlay-${project} &> /dev/null
  mv overlay-${project}/lineage-sdk/lineage/res overlay-${project}/packages/apps/Setings/res &> /dev/null
  sed -i "s:overlay-lineage:overlay-${project}:g" kona.mk &> /dev/null
  sed -i "s:overlay-lineage:overlay-${project}:g" device.mk &> /dev/null
  sedS() {
  for i in $(ls *); do
    sed -i "s:vendor/lineage:vendor/aosp/:g" ${i}
    sed -i "s:vendor/lineage:vendor/aosp/:g" ${i}
    sed -i "s:lineage_:aosp_:g" ${i}
    sed -i "s:lineage_:aosp_:g" ${i}
    sed -i "s:android_device_xiaomi_sm8250-common:device_xiaomi_sm8250-common:g" ${i}
    sed -i "s:android_kernel_xiaomi_sm8250:kernel_xiaomi_sm8250:g" ${i}
    sed -i "s:lineage-18.1:twelve:g" ${i}
    sed -i "s:lineage-19.0:twelve:g" ${i}
    sed -i "s:common_full_phone.mk:common.mk:g" ${i}
    sed -i "s:Lineage stuff:AOSP stuff:g" ${i}
  done
  }
  sedS &> /dev/null
  git add . && git commit -s --amend --no-edit
done
git push ssh://git@github.com/mamutal91/${repo} HEAD:refs/heads/twelve --force &> /dev/null
