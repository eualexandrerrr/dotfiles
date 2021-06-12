#!/usr/bin/env bash

clear

source $HOME/.colors &>/dev/null

if [[ -z ${1} ]]; then
  echo -e "${BOL_YEL}You can: usage: command <vendor|push>${END}\n"
fi

workingDir=$(mktemp -d) && cd $workingDir

echo -e "${BOL_CYA}Cloning official_devices${END}"
git clone https://github.com/AOSPK/official_devices &>/dev/null

jsonDevices=${workingDir}/official_devices/devices.json
jsonMaintainers=${workingDir}/official_devices/team/maintainers.json

# GitLab vendors
if [[ ${1} = vendor ]]; then
  for vendorRepo in  $(jq '.[] | select(.name|test("^")) | .repositories' $jsonDevices | tr -d '"[]' | grep vendor); do
    rm -rf $vendorRepo && mkdir $vendorRepo
    cd $vendorRepo
    glab repo create AOSPK-Devices/${vendorRepo} --defaultBranch eleven --public
    cd ..
  done
fi

# Loop
for maintainer in $(jq '.[] | select(.name|test("^")) | .github_username' $jsonMaintainers | tr -d '"'); do
  while IFS= read -r device; do
    for repo in $(jq -r ".[] | select(.codename == \"${device}\") | .repositories[]" $jsonDevices); do

      brandDevice=$(jq -r ".[] | select(.codename == \"${device}\") | .brand" $jsonDevices)
      nameDevice=$(jq -r ".[] | select(.codename == \"${device}\") | .name" $jsonDevices)

      repoCheck=$repo

      if grep -q "common\|kernel\|vendor" <<<"$repo"; then
        gh repo create AOSPK-DevicesTest/${repo} --public --confirm &>/dev/null
      else
        gh repo create AOSPK-DevicesTest/${repo} -d "${brandDevice} ${nameDevice} maintained by @${maintainer}" --public --confirm &>/dev/null
      fi

      echo -e "\n${BOL_GRE}Creating the repository${END} ${BLU}${device} #${CYA}${repo}${END} and inviting the ${YEL}@${maintainer}${END} maintainer"
      echo -e "${RED}${brandDevice} $nameDevice${END}"

      gh api -X PUT repos/AOSPK-DevicesTest/${repo}/collaborators/${maintainer} -f permission=admin &>/dev/null

      if [[ ${1} = push ]]; then
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

        if grep -q "vendor" <<<"$repo"; then
          glab repo create AOSPK-Devices/${repo} --defaultBranch eleven --public
          git push ssh://git@gitlab.com/AOSPK-Devices/${repo} HEAD:refs/heads/eleven --force
          git push ssh://git@github.com/AOSPK-DevicesTest/${repo} HEAD:refs/heads/eleven --force
        else
          git push ssh://git@github.com/AOSPK-DevicesTest/${repo} HEAD:refs/heads/eleven --force
        fi

        git push ssh://git@github.com/AOSPK-DevicesTest/${repo} HEAD:refs/heads/eleven --force
        cd ..
      fi

    done
  done < <(jq -r ".[] | select(.github_username == \"${maintainer}\") | .devices[].codename" $jsonMaintainers)
done

rm -rf $workingDir
