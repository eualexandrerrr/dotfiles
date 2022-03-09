#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

limps=(
  "vendor_nxp_opensource_halimpl thirteen-pn5xx"
  "vendor_nxp_opensource_hidlimpl thirteen-pn5xx"
  "vendor_nxp_opensource_halimpl thirteen-sn100x"
  "vendor_nxp_opensource_hidlimpl thirteen-sn100x"
)

for i in "${limps[@]}"; do
  workingDir=$(mktemp -d) && cd $workingDir

  repo=$(echo ${i} | awk '{ print $1 }')
  branch=$(echo ${i} | awk '{ print $2 }')
  branchBase=$(sed "s:thirteen:arrow-12.1:g" <<< $branch)

  echo -e "\n${BOL_GRE}Repo   : ${repo}${END}"
  echo -e "${BOL_GRE}Branch : ${branch}${END}"
  echo -e "${BOL_GRE}Base   : ${branchBase}\n${END}"

  git clone https://github.com/ArrowOS/android_${repo} -b ${branchBase} ${repo}
  cd ${repo}
  git push ssh://git@github.com/MammothOS/${repo} HEAD:refs/heads/${branch} --force
  git push ssh://git@github.com/MammothOS-Next/${repo} HEAD:refs/heads/${branch} --force

  cd $workingDir
done
