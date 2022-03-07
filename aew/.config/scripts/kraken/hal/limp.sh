#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

limps=(
  "vendor_nxp_opensource_halimpl twelve-pn5xx"
  "vendor_nxp_opensource_hidlimpl twelve-pn5xx"
  "vendor_nxp_opensource_halimpl twelve-sn100x"
  "vendor_nxp_opensource_hidlimpl twelve-sn100x"
)

for i in "${limps[@]}"; do
  workingDir=$(mktemp -d) && cd $workingDir

  repo=$(echo ${i} | awk '{ print $1 }')
  branch=$(echo ${i} | awk '{ print $2 }')
  branchBase=$(sed "s:twelve:arrow-12.0:g" <<< $branch)

  echo -e "\n${BOL_GRE}Repo   : ${repo}${END}"
  echo -e "${BOL_GRE}Branch : ${branch}${END}"
  echo -e "${BOL_GRE}Base   : ${branchBase}\n${END}"

  git clone https://github.com/ArrowOS/android_${repo} -b ${branchBase} ${repo}
  cd ${repo}
  git push ssh://git@github.com/AOSPK/${repo} HEAD:refs/heads/${branch} --force
  git push ssh://git@github.com/AOSPK-Next/${repo} HEAD:refs/heads/${branch} --force

  cd $workingDir
done
