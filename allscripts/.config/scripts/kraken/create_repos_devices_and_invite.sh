#!/usr/bin/env bash

clear

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens &> /dev/null

workingDir=$HOME/GitHub

workingDir=$(mktemp -d) && cd $workingDir
git clone https://github.com/AOSPK/official_devices

jsonDevices=${workingDir}/official_devices/devices.json
jsonMaintainers=${workingDir}/official_devices/team/maintainers.json

editDescription() {
  echo "${BOL_BLU}Editing description repo ${BOL_MAG}${organization}/${deviceRepo}${END}"
  curl \
    -H "Authorization: Token ${githubToken}" \
    -H "Content-Type:application/json" \
    -H "Accept: application/json" \
    -X PATCH \
    --data "{ \"name\": \"${deviceRepo}\", \"description\":\"${brandDevice} ${nameDevice} maintained by @${maintainerGithub}\" }" \
    https://api.github.com/repos/AOSPK-Devices/${deviceRepo} &> /dev/null
}

createRepo() {
  reposToCreate=( $(echo $repositories | awk '{ print $1 '}) $(echo $repositories | awk '{ print $2 '}) $(echo $repositories | awk '{ print $3 '}) $(echo $repositories | awk '{ print $4 '}) $(echo $repositories | awk '{ print $5 '}) $(echo $repositories | awk '{ print $6 '}) $(echo $repositories | awk '{ print $7 '}) )
  for reposToCreate in "${reposToCreate[@]}"; do

    repoCheckName=$(echo $reposToCreate | cut -c1-7)
    [[ $repoCheckName == vendor_ ]] && organization=TheBootloops || organization=AOSPK-Devices

    curl -H "Authorization: token ${githubToken}" --data "{\"name\":\"${reposToCreate}\"}" https://api.github.com/orgs/$organization/repos &> /dev/null
    gh api -X PUT repos/${organization}/${reposToCreate}/collaborators/${maintainerGithub} -f permission=admin &> /dev/null
    gh api -XPATCH "repos/${organization}/${repoName}" -f default_branch="eleven" &> /dev/null

    echo "${BOL_BLU}Creating repo ${BOL_MAG}$organization/$reposToCreate ${BOL_BLU}and inviting ${BOL_MAG}${maintainerGithub}${END}"

    repoCheckName=$(echo $reposToCreate | cut -c1-7)
    [[ $repoCheckName == device_ ]] && editDescription

  done
}

for codename in $(jq '.[] | select(.name|test("^")) | .codename' $jsonDevices | tr -d '"'); do

    brandDevice=$(jq -r ".[] | select(.codename == \"${codename}\") | .brand" $jsonDevices)
    nameDevice=$(jq -r ".[] | select(.codename == \"${codename}\") | .name" $jsonDevices)
    repositories=$(jq -r ".[] | select(.codename == \"${codename}\") | .repositories[]" $jsonDevices)
    deprecated=$(jq -r ".[] | select(.codename == \"${codename}\") | .deprecated" $jsonDevices)

    maintainerGithub=$(jq -r ".[] | select(.devices[].codename == \"${codename}\") | .github_username" $jsonMaintainers)
    maintainerName=$(jq -r ".[] | select(.devices[].codename == \"${codename}\") | .name" $jsonMaintainers)

    deviceRepo="device_${brandDevice,,}_${codename}"
    vendorRepo="vendor_${brandDevice,,}_${codename}"

    if [[ $deprecated == true ]]; then
      echo -e "${BOL_BLU}${BLU}$brandDevice $nameDevice ${BOL_MAG}($codename)${END} ${BOL_RED}DEPRECATED!!!${END}"
    else
      echo -e "${BOL_BLU}${BLU}$brandDevice $nameDevice ${BOL_MAG}($codename)${END}"
      echo -e "${BOL_GRE}${GRE}$maintainerName ($maintainerGithub)"
      echo -e "${BOL_YEL}Repositories:\n${YEL}$repositories"
      createRepo
    fi

    echo -e "${BOL_CYA}\n--------- END ---------${END}\n"

done
