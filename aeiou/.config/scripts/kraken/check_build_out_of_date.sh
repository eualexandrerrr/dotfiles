#!/usr/bin/env bash

clear

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

chatId="-1001485974314"

workingDir=$(mktemp -d) && cd $workingDir
git clone https://github.com/AOSPK/official_devices

# Criando message
msg=/tmp/message
echo -e "Devices with more than 30 days without releases\n" > $msg

jsonDevices=${workingDir}/official_devices/devices.json
jsonMaintainers=${workingDir}/official_devices/team/maintainers.json

for codename in $(jq '.[] | select(.name|test("^")) | .codename' $jsonDevices | tr -d '"'); do

    brandDevice=$(jq -r ".[] | select(.codename == \"${codename}\") | .brand" $jsonDevices)
    nameDevice=$(jq -r ".[] | select(.codename == \"${codename}\") | .name" $jsonDevices)
    repositories=$(jq -r ".[] | select(.codename == \"${codename}\") | .repositories[]" $jsonDevices)
    deprecated=$(jq -r ".[] | select(.codename == \"${codename}\") | .deprecated" $jsonDevices)

    maintainerGithub=$(jq -r ".[] | select(.devices[].codename == \"${codename}\") | .github_username" $jsonMaintainers)
    maintainerTelegram=$(jq -r ".[] | select(.devices[].codename == \"${codename}\") | .telegram_username" $jsonMaintainers)
    maintainerName=$(jq -r ".[] | select(.devices[].codename == \"${codename}\") | .name" $jsonMaintainers)

    deviceRepo="device_${brandDevice,,}_${codename}"
    vendorRepo="vendor_${brandDevice,,}_${codename}"

    if [[ $deprecated == true ]]; then
      echo -e "${BOL_BLU}${BLU}$brandDevice $nameDevice ${BOL_MAG}($codename)${END} ${BOL_RED}DEPRECATED!!!${END}"
    else
      echo -e "${BOL_BLU}${BLU}$brandDevice $nameDevice ${BOL_MAG}($codename)${END}"
      echo -e "${BOL_GRE}${GRE}$maintainerName ($maintainerGithub)"

      pwd=$(pwd)

      if [[ -d $workingDir/official_devices/changelogs/twelve/gapps/${codename} ]]; then
        cd $workingDir/official_devices/changelogs/twelve/gapps/${codename}
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
        echo "Never released"
        echo -e "${codename} # Never released @${maintainerTelegram}" >> $msg
      fi

      if [[ ${daysWithout} -gt 30 ]]; then
        echo -e "${codename} # ${daysWithout} @${maintainerTelegram}" >> $msg
      fi
      cd $pwd
    fi

    echo -e "${BOL_CYA}\n--------- END ---------${END}\n"

done

cat $msg

msg="$(cat $msg)"

sendMessage() {
  curl "https://api.telegram.org/bot${botTelegramToken}/sendMessage" \
    -d chat_id="$chatId" \
    --data-urlencode text="$msg" \
    --data-urlencode parse_mode="markdown" \
    --data-urlencode disable_web_page_preview="true"
}

echo "Finished successfully."
read -r -p "${BOL_RED}Post in my group maintainers? [Y/n] [enter=no]" confirmPost
if [[ ! $confirmPost =~ ^(y|Y) ]]; then
  exit
else
  sendMessage
fi
