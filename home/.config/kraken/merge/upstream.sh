#!/usr/bin/env bash

# eleven    lineage-18.1
# ten       lineage-17.1
# pie       lineage-16.0
# oreo-mr1  lineage-15.1
# nougat    cm-14.1

# Use for define branch padrão
# gh api -XPATCH "repos/AOSPK/${i}" -f default_branch="eleven" >/dev/null && echo && echo $$ echo $repo &&

source repos.sh

los="lineage-18.1"
kraken="eleven"

los_caf="lineage-18.1-caf"
aospk_caf="eleven-caf"

tmp=/tmp/kraken-upstream
mkdir -p $tmp
cd $tmp

# REPOS > eleven (lineage-18.1)
for i in "${REPOS[@]}"; do
  rm -rf ${i} && echo && echo "***************" && echo ${i} && echo && git clone https://github.com/LineageOS/android_${i} -b $los ${i} && cd ${i} && echo && git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$kraken --force
done

# repos_caf > eleven-caf (lineage-18.1-caf)
for i in "${repos_caf[@]}"; do
  echo ${i}
  git clone https://github.com/LineageOS/android_${i} -b $los_caf ${i}
  cd ${i} && echo
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$aospk_caf --force
done

rm -rf $tmp
exit 0;
