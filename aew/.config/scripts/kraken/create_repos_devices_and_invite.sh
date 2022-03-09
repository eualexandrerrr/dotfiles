#!/usr/bin/env bash

clear

source $HOME/.Xconfigs # My general configs

workingDir=$(mktemp -d) && cd $workingDir
git clone ssh://git@github.com/MammothOS/official_devices

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
    https://api.github.com/repos/MammothOS-Devices/${deviceRepo}
}

createRepo() {
  reposToCreate=($( echo $repositories | awk '{ print $1 '}) $(echo $repositories | awk '{ print $2 '}) $(echo $repositories | awk '{ print $3 '}) $(echo $repositories | awk '{ print $4 '}) $(echo $repositories | awk '{ print $5 '}) $(echo $repositories | awk '{ print $6 '}) $(echo $repositories | awk '{ print $7 '}))
  for reposToCreate in "${reposToCreate[@]}"; do

    repoCheckName=$(echo $reposToCreate | cut -c1-7)
    [[ $repoCheckName == vendor_ ]] && organization=TheBootloops || organization=MammothOS-Devices

    curl -H "Authorization: token ${githubToken}" --data "{\"name\":\"${reposToCreate}\"}" https://api.github.com/orgs/$organization/repos
    gh api -X PUT "repos/${organization}/${reposToCreate}/collaborators/${maintainerGithub}" -f permission="admin"
    gh api -XPATCH "repos/${organization}/${repoName}" -f default_branch="thirteen"

    echo "${BOL_BLU}Creating repo ${BOL_MAG}$organization/$reposToCreate ${BOL_BLU}and inviting ${BOL_MAG}${maintainerGithub}${END}"

    repoCheckName=$(echo $reposToCreate | cut -c1-7)
    [[ $repoCheckName == device_ ]] && editDescription

  done
}

generateBanner() {
  echo "${BOL_BLU}Creating banner ${BOL_MAG}${codename}${END}"
  bannerModel=${workingDir}/official_devices/images/banners/banner_model.png

  outputTmp1=/tmp/bannertmp1_${codename}.png
  outputTmp2=/tmp/bannertmp2_${codename}.png
  outputTmp3=/tmp/${codename}.png

  rm -rf $outputTmp1 $outputTmp2 $outputTmp3

  ffmpeg -i $bannerModel -vf "drawtext=text='${brandDevice}':fontcolor=white:fontsize=28:x=170:y=363:" $outputTmp1
  ffmpeg -i $outputTmp1 -vf "drawtext=text='${nameDevice}':fontcolor=white:fontsize=45:x=170:y=403:" $outputTmp2
  ffmpeg -i $outputTmp2 -vf "drawtext=text='${maintainerGithub}':fontcolor=white:fontsize=25:x=230:y=461:" $outputTmp3

  cp -rf /tmp/${codename}.png ${workingDir}/official_devices/images/banners/
}

gitCommit() {
  pwd=$(pwd)
  cd ${workingDir}/official_devices
  status=$(git add . -n)
  if [[ -n $status   ]]; then
    echo -e "${BOL_GRE}Commit!${END}"
    m="[KRAKEN-CI]: Updates"
    git config --global user.email "bot@aospk.org" && git config --global user.name "Kraken Project Bot"
    git add .
    git commit -m "${m}" --signoff --author "Kraken Project Bot <bot@aospk.org>" --date "$(date)"
    git push
    git config --global user.email "mamutal91@gmail.com" && git config --global user.name "Alexandre Rangel"
  else
    echo ${BOL_MAG}No commits!${END}
  fi
  cd $pwd
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
    rm -rf ${workingDir}/official_devices/images/banners/${codename}.png
  else
    echo -e "${BOL_BLU}${BLU}$brandDevice $nameDevice ${BOL_MAG}($codename)${END}"
    echo -e "${BOL_GRE}${GRE}$maintainerName ($maintainerGithub)"
    echo -e "${BOL_YEL}Repositories:\n${YEL}$repositories"
    createRepo &> /dev/null
    generateBanner &> /dev/null
  fi

  echo -e "${BOL_CYA}\n--------- END ---------${END}\n"
done

gitCommit
