#!/usr/bin/env bash

clear

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens &> /dev/null

#workingDir=$(mktemp -d) && cd $workingDir
#git clone https://github.com/AOSPK/official_devices
workingDir=$HOME/GitHub

jsonDevices=${workingDir}/official_devices/devices.json
jsonMaintainers=${workingDir}/official_devices/team/maintainers.json

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

      pwd=$(pwd)

      if [[ -d $workingDir/official_devices/changelogs/eleven/gapps/${codename} ]]; then
        cd $workingDir/official_devices/changelogs/eleven/gapps/${codename}
        haveBuild=true
        for builds in $(ls); do
          year=$(echo $builds | cut -c17-20)
          month=$(echo $builds | cut -c21-22)
          day=$(echo $builds | cut -c23-24)
          lastBuild="${year}-${month}-${day}"
          date=$(date +"%Y-%m-%d")
          daysWithout=$((($(date -d $date +%s) - $(date -d $lastBuild +%s)) / 86400))
        done
        echo -e "${BOL_GRE}Days without releases ${BOL_MAG}${daysWithout}${END}"
      else
        haveBuild=false
        echo Nenhuma build
      fi
      cd $pwd
    fi

    echo -e "${BOL_CYA}\n--------- END ---------${END}\n"

done
