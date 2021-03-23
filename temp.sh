#!/usr/bin/env bash

org=ArrowOS-Devices
repo=android_device_xiaomi_vayu
branch=arrow-11.0

git clone https://github.com/${org}/${repo} ${repo} -b ${branch}
cd $HOME/${repo}

commitsIds=($(git log --pretty=format:"%H"))
f() { commitsIds=("${BASH_ARGV[@]}"); }

shopt -s extdebug
f "${commitsIds[@]}"
shopt -u extdebug

rm -rf $HOME/test &> /dev/null
mkdir -p $HOME/test &> /dev/null
cd $HOME/test &> /dev/null
git init &> /dev/null

git fetch https://github.com/${org}/${repo} ${branch}
for i in "${commitsIds[@]}"; do
  git cherry-pick ${i}
  echo -e "${BOL_RED}${i}${END}"
  git push ssh://git@github.com/mamutal91/test HEAD:refs/heads/twelve --force &> /dev/null
done

exit

for i in $(cd $HOME/device_xiaomi_lmi && git log --pretty=format:"%H" --no-patch); do
  mkdir -p $HOME/test &> /dev/null
  echo ${i}
#  echo "$i" | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'

#  cd $HOME/test
#  git init
#  git fetch https://github.com/xiaomi-sm8250-devs/android_device_xiaomi_lmi lineage-19.0
#  git cherry-pick ${i}
#  git push ssh://git@github.com/mamutal91/test HEAD:refs/heads/twelve --force
done

exit

createDependencies() {
  for i in $(jq -r ".[] | select(.codename == \"ali\") | .repositories" $HOME/GitHub/official_devices/devices.json | tr -d '", []'); do
    repository=${i}
    target_path=$(echo ${i} | sed "s:_:/:g")

    repoCheckName=$(echo $repository | cut -c1-7)
    if [[ $repoCheckName == "vendor_" ]]; then
      echo -e ""
      echo -e "    \"remote\":       \"blobs\","
      echo -e "    \"repository\":   \"${repository}\","
      echo -e "    \"target_path\":  \"${target_path}\","
      echo -e "    \"branch\":       \"twelve\""
      echo -e "  },"
    else
      echo -e "  {"
      echo -e "    \"repository\":   \"${repository}\","
      echo -e "    \"target_path\":  \"${target_path}\""
      echo -e "  },"
    fi
  done
}

echo -e "["
createDependencies
echo -e "]"
