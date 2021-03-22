#!/usr/bin/env bash

# eleven    lineage-18.1
# ten       lineage-17.1
# pie       lineage-16.0
# oreo-mr1  lineage-15.1
# nougat    cm-14.1

# Use for define branch padrão
# gh api -XPATCH "repos/AOSPK/${i}" -f default_branch="eleven" >/dev/null && echo && echo $$ echo $repo &&

source repos.sh

LOS="lineage-18.1"
AOSPK="eleven"

LOS_CAF="lineage-18.1-caf"
AOSPK_CAF="eleven-caf"

tmp=/tmp/kraken-upstream
mkdir -p $tmp
cd $tmp

# REPOS > eleven (lineage-18.1)
for i in "${REPOS[@]}"; do
  rm -rf ${i} && echo && echo "***************" && echo ${i} && echo && git clone https://github.com/LineageOS/android_${i} -b $LOS ${i} && cd ${i} && echo && git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$AOSPK --force
done

# REPOS_CAF > eleven-caf (lineage-18.1-caf)
for i in "${REPOS_CAF[@]}"; do
  echo ${i}
  git clone https://github.com/LineageOS/android_${i} -b $LOS_CAF ${i}
  cd ${i} && echo
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$AOSPK_CAF --force
done

rm -rf $tmp
exit 0;
