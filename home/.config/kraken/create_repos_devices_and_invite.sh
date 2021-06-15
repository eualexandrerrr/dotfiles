#!/usr/bin/env bash

clear

source $HOME/.colors &>/dev/null

workingDir=$(mktemp -d) && cd $workingDir

echo -e "${BOL_CYA}Cloning official_devices${END}"
git clone https://github.com/AOSPK/official_devices &>/dev/null

jsonDevices=${workingDir}/official_devices/devices.json
jsonMaintainers=${workingDir}/official_devices/team/maintainers.json

# Loop
for maintainer in $(jq '.[] | select(.name|test("^")) | .github_username' $jsonMaintainers | tr -d '"'); do
  while IFS= read -r device; do
    for repo in $(jq -r ".[] | select(.codename == \"${device}\") | .repositories[]" $jsonDevices); do

      brandDevice=$(jq -r ".[] | select(.codename == \"${device}\") | .brand" $jsonDevices)
      nameDevice=$(jq -r ".[] | select(.codename == \"${device}\") | .name" $jsonDevices)

      pwd=$(pwd)
      cd ${workingDir}/official_devices
      mkdir -p ${workingDir}/official_devices/builds/eleven/{vanilla,gapps}/${device} &>/dev/null
      mkdir -p ${workingDir}/official_devices/changelogs/eleven/{vanilla,gapps}/${device} &>/dev/null
      cd $pwd

      if grep -q "common\|kernel\|vendor" <<<"$repo"; then
        gh repo create AOSPK-Devices/${repo} --public --confirm &>/dev/null
      else
        gh repo create AOSPK-Devices/${repo} -d "${brandDevice} ${nameDevice} maintained by @${maintainer}" --public --confirm &>/dev/null
      fi

      echo -e "\n${BOL_GRE}Creating the repository${END} ${BLU}${device}\n# ${CYA}${repo}${END} and inviting the ${YEL}@${maintainer}${END} maintainer"
      echo -e "${RED}${brandDevice} $nameDevice${END}"

      gh api -X PUT repos/AOSPK-Devices/${repo}/collaborators/${maintainer} -f permission=admin &>/dev/null
    done
  done < <(jq -r ".[] | select(.github_username == \"${maintainer}\") | .devices[].codename" $jsonMaintainers)
done

cd ${workingDir}/official_devices
status=$(git add . -n)
if [[ ! -z "$status" ]]; then
  git config --global user.email "krakengerrit@gmail.com"
  git config --global user.name "Kraken Project Bot"
  git add . && git commit -m "[KRAKEN-CI] Automatic structuring" && git push
fi

rm -rf $workingDir
