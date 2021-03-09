#!/usr/bin/env bash

source $HOME/.colors &>/dev/null 

# pn5xx
# sn100x

repos=(
    vendor_nxp_opensource_halimpl
    vendor_nxp_opensource_hidlimpl
)

branchLOS="arrow-12.0-${1}"
branchKK="twelve-${1}"

tmp="/tmp/kraken-hals"
rm -rf $tmp && mkdir -p $tmp
cd $tmp

for i in "${repos[@]}"; do
  rm -rf ${i}
  losURL="https://github.com/ArrowOS/android_${i}"
  krakenURL="ssh://git@github.com/AOSPK/${i}"
  echo "-------------------------------------------------------------------------"
  echo "${BLU}Clonando $losURL -b $branchLOS em ${i}${END}"
  git clone $losURL -b $branchLOS ${i}
  echo
  echo "${GRE}Pushand $krakenURL -b $branchKK para ${i}${END}"
  cd ${i}
  git push $krakenURL HEAD:refs/heads/$branchKK --force
  echo
done
