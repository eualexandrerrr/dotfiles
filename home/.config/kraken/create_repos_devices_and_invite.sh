#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

workingDir=$(mktemp -d) && cd $workingDir

git clone ssh://git@github.com/AOSPK/official_devices

jsonDevices=$HOME/official_devices/devices.json
jsonMaintainers=$HOME/official_devices/team/maintainers.json

for maintainer in $(jq '.[] | select(.name|test("^")) | .github_username' $jsonMaintainers | tr -d '"'); do
  while IFS= read -r device; do
    for repo in $(jq -r ".[] | select(.codename == \"${device}\") | .repositories[]" $jsonDevices); do

      brandDevice=$(jq -r ".[] | select(.codename == \"${device}\") | .brand" $jsonDevices)
      nameDevice=$(jq -r ".[] | select(.codename == \"${device}\") | .name" $jsonDevices)

      repoCheck=$repo

      if grep -q "common\|kernel\|vendor" <<<"$repo"; then
        gh repo create AOSPK-Devices2/${repo} --public --confirm &>/dev/null
      else
        gh repo create AOSPK-Devices2/${repo} -d "${brandDevice} ${nameDevice} maintained by @${maintainer}" --public --confirm &>/dev/null
      fi

      echo -e "\n${BOL_GRE}Creating the repository${END} ${BLU}${device} #${CYA}${repo}${END} and inviting the ${YEL}@${maintainer}${END} maintainer"
      echo -e "${RED}${brandDevice} $nameDevice${END}"

      gh api -X PUT repos/AOSPK-Devices2/${repo}/collaborators/${maintainer} -f permission=admin &>/dev/null

      rm -rf $repo
      repoExist=$(git ls-remote --heads https://github.com/AOSPK-Devices/${repo} eleven)
      if [[ -z ${repoExist} ]]; then
        repoExist=$(git ls-remote --heads https://github.com/PixelExperience-Devices/${repo} eleven)
        if [[ -z ${repoExist} ]]; then
          echo "${BOL_YEL} * ~ PixelBlobs${END}"
          git clone https://gitlab.pixelexperience.org/android/vendor-blobs/${repo} -b eleven
        else
          echo "${BOL_YEL} * ~ PixelExperience-Devices${END}"
          git clone https://github.com/PixelExperience-Devices/${repo} -b eleven $repo
        fi
      else
        echo "${BOL_YEL} * ~ AOSPK-Devices${END}"
        git clone https://github.com/AOSPK-Devices/${repo} -b eleven $repo
      fi

      cd $repo
      git push ssh://git@github.com/AOSPK-Devices2/${repo} HEAD:refs/heads/eleven --force
      cd ..

    done
  done < <(jq -r ".[] | select(.github_username == \"${maintainer}\") | .devices[].codename" $jsonMaintainers)
done

rm -rf $workingDir
