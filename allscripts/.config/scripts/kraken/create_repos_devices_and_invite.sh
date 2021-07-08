#!/usr/bin/env bash

clear

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens &> /dev/null

workingDir=$(mktemp -d) && cd $workingDir

echo -e "${BOL_CYA}Cloning official_devices${END}"
git clone https://github.com/AOSPK/official_devices &> /dev/null

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
      mkdir -p ${workingDir}/official_devices/builds/eleven/{vanilla,gapps}/${device} &> /dev/null
      mkdir -p ${workingDir}/official_devices/changelogs/eleven/{vanilla,gapps}/${device} &> /dev/null
      cd $pwd

      if grep -q "common\|kernel\|vendor" <<< "$repo"; then
        gh repo create AOSPK-Devices/${repo} --public --confirm &> /dev/null
      else
        gh repo create AOSPK-Devices/${repo} -d "${brandDevice} ${nameDevice} maintained by @${maintainer}" --public --confirm &> /dev/null
        editDescription() {
          curl \
            -H "Authorization: Token ${githubToken}" \
            -H "Content-Type:application/json" \
            -H "Accept: application/json" \
            -X PATCH \
            --data "{ \"name\": \"${repo}\", \"description\":\"${brandDevice} ${nameDevice} maintained by @${maintainer}\" }" \
            https://api.github.com/repos/AOSPK-Devices/${repo}
        }
        editDescription &> /dev/null
      fi

      echo -e "\n${BOL_GRE}Creating the repository${END} ${BLU}${device}\n# ${CYA}${repo}${END} and inviting the ${YEL}@${maintainer}${END} maintainer"
      echo -e "${RED}${brandDevice} $nameDevice${END}"
      gh api -X PUT repos/AOSPK-Devices/${repo}/collaborators/${maintainer} -f permission=admin &> /dev/null
      gh api -XPATCH "repos/AOSPK/${repoName}" -f default_branch="eleven" &> /dev/null
    done
  done < <(jq -r ".[] | select(.github_username == \"${maintainer}\") | .devices[].codename" $jsonMaintainers)
done

cd ${workingDir}/official_devices
status=$(git add . -n)
if [[ -n $status ]]; then
  git config --global user.email "bot@aospk.org"
  git config --global user.name "Kraken Project Bot"
  git add . && git commit -m "[KRAKEN-CI] Automatic structuring" && git push
fi

rm -rf $workingDir

bash $HOME/.dotfiles/allscripts/.config/scripts/kraken/create_repos_devices_and_invite.sh &> /dev/null
