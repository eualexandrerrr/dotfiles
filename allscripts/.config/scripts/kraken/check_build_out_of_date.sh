#!/usr/bin/env bash

clear

source $HOME/.colors &> /dev/null
source $HOME/.botTokens &> /dev/null

chatId="-1001397744652"

workingDir=$(mktemp -d) && cd $workingDir

git clone https://github.com/AOSPK/official_devices

rm -rf /tmp/nobuild
rm -rf /tmp/msg
echo "* 📅 Days out of date*" > /tmp/msg
echo >> /tmp/msg
echo "_Please, help us not to leave more than 30 days out of date..._" >> /tmp/msg
echo >> /tmp/msg

jsonDevices=${workingDir}/official_devices/devices.json
jsonMaintainers=${workingDir}/official_devices/team/maintainers.json

# Loop
for maintainer in $(jq '.[] | select(.name|test("^")) | .telegram_username' $jsonMaintainers | tr -d '"'); do
  while IFS= read -r device; do

    deprecated=$(jq -r ".[] | select(.codename == \"${device}\") | .deprecated" $jsonDevices)

    if [[ $deprecated == true ]]; then
      continue
    fi

    # Verifica se existe builds
    if [[ -n "$(ls -A ${workingDir}/official_devices/changelogs/eleven/gapps/${device} &> /dev/null)" ]]; then
      cd ${workingDir}/official_devices/changelogs/eleven/gapps/${device} &> /dev/null
      for builds in $(ls); do
        year=$(echo $builds | cut -c17-20)
        month=$(echo $builds | cut -c21-22)
        day=$(echo $builds | cut -c23-24)
        lastBuild="${year}-${month}-${day}"
        date=$(date +"%Y-%m-%d")
        daysWithou=$((($(date -d $date +%s) - $(date -d $lastBuild +%s)) / 86400))
      done
      lastBuild=$(xargs -n 1 <<< ${lastBuild[@]} | sort -nr | head -1)
      build=true
    else
      build=false
      echo "📱 ${device} - _maintained by_ @${maintainer}" >> /tmp/nobuild
      echo >> /tmp/nobuild
      continue
    fi

    echo $device $daysWithou >> /tmp/test

    echo -e "\n----------------------------------------------"
    echo -e " ${BLU}$device"
    echo -e " ${BLU}@$maintainer"
    echo -e " ${BOL_GRE}Última build: ${END}${GRE}$lastBuild"
    echo -e " ${BOL_GRE}Data atual: ${END}${GRE}$lastBuild"
    echo -e " ${BOL_GRE}Dias sem postar: ${END}${BOL_RED}$daysWithou${END}"
    if [[ $build != true ]]; then
      echo -e " ${BOL_RED}O DEVICE NÃO TEM BUILD LANÇADA${END}"
    fi

    if [[ $daysWithou -ge 30 ]]; then
      if [[ $build == true ]]; then
        if [[ $daysWithou == "1" ]]; then
          daysFormatted="${daysWithou} day"
        else
          daysFormatted="${daysWithou} days"
        fi
      fi
      echo -e " ${RED}Tem mais que 30 dias sem postar${END}"
      echo "📱 *${device}* - ${daysFormatted} - _maintained by_ @${maintainer}" >> /tmp/msg
      echo >> /tmp/msg
    fi

  done \
    < <(jq -r ".[] | select(.telegram_username == \"${maintainer}\") | .devices[].codename" $jsonMaintainers)
done

sed -i '1i\\' /tmp/nobuild
sed -i '1 i\* ⚠️ No build released *' /tmp/nobuild

if [[ -e "/tmp/nobuild" ]]; then
  msg=$(cat /tmp/msg && cat /tmp/nobuild)
else
  msg=$(cat /tmp/msg)
fi

cat /tmp/msg
cat /tmp/nobuild

sendMessage() {
  curl "https://api.telegram.org/bot${botToken}/sendMessage" \
    -d chat_id="$chatId" \
    --data-urlencode text="$msg" \
    --data-urlencode parse_mode="markdown" \
    --data-urlencode disable_web_page_preview="true"
}

rm -rf $workingDir

echo "Finished successfully."
read -r -p "${BOL_RED}Post in my group maintainers? [Y/n] [enter=no]" confirmPost
if [[ ! $confirmPost =~ ^(y|Y) ]]; then
  exit
else
  sendMessage
fi
