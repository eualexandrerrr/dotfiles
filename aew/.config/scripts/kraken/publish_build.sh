#!/usr/bin/env bash

# Lembretes:
# ssh mamutal91@shell.sourceforge.net create

source $HOME/.myTokens/tokens.sh &> /dev/null
source $HOME/.Xcolors &> /dev/null

mkdir -p $HOME/Builds/ToPublish

rm -rf /tmp/official_devices
git clone ssh://git@github.com/MammothOS/official_devices /tmp/official_devices

post_test=false
post_build=false

if [[ $post_test == true ]]; then
  chatId="-1001702262779" # Channel (MAMUTAL91)
  botTokenPublish=${mamutal91_botToken}
else
  chatId="-1001082850126" # Channel (OFFICIAL)
  botTokenPublish=${botTelegramToken}
fi

build=$1

if [[ -z $build ]]; then
  echo -e " ${BOL_RED}Você deve selecionar o nome do zip como argumento, exemplo:"
  echo -e "\n${BOL_MAG}  ./publish_build.sh ${MAG}Kraken-12-GApps-20220206-1247-lmi.zip"
  echo -e "\n${MAG}   A Build deve estar em ${BOL_MAG}$HOME/Builds/ToPublish${END}\n\n"
  sleep 200
fi

buildToAdd="$HOME/Builds/ToPublish/${build}"
buildToAddJson="${buildToAdd}.json"

filename=$(grep filename $buildToAddJson | awk '{ print $2 }' | tr -d '",')
size=$(du -h $buildToAdd | awk '{ print $1 }')
url=$(grep url $buildToAddJson | awk '{ print $2 }' | tr -d '",')
romtype=$(grep romtype $buildToAddJson | awk '{ print $2 }' | tr -d '",')
android=$(grep android $buildToAddJson | awk '{ print $2 }' | tr -d '",')
version=$(grep version $buildToAddJson | awk '{ print $2 }' | tr -d '",')

date=$(echo $buildToAdd | cut -d "-" -f4)

dateY=$(echo $date | cut -c1-4)
dateM=$(echo $date | cut -c5-6)
dateD=$(echo $date | cut -c7-8)

codename=$(echo $buildToAdd | cut -d "-" -f6)
codename=$(basename ${codename} .zip)

mkdir -p /tmp/official_devices/builds/${android}/${romtype}

# Upload zip
if [[ $post_build == "true" ]]; then # Se for post de teste, não irá fazer upload para o SourceForge
  pwd=$(pwd)
  cd $HOME/Builds/ToPublish
  ssh -o StrictHostKeyChecking=no mamutal91@shell.sourceforge.net create
  ssh -o StrictHostKeyChecking=no mamutal91@shell.sourceforge.net uptime
  echo -e "\nCreating folder SourceForge (${android}/${codename}/${romtype})...\n"
  ssh -t -t mamutal91@shell.sourceforge.net "mkdir -p /home/frs/project/aospk/${android}/${codename}/${romtype}"
  sleep 5
  echo -e "\nUploading ${buildToAdd} to SourceForge...\n"
  scp -i ~/.ssh/id_ed25519 ${buildToAdd} mamutal91@frs.sourceforge.net:/home/frs/p/aospk/${android}/${codename}/${romtype}
  if [[ $? -eq 0 ]]; then
      echo -e "\n${GRE}Zip successfully uploaded to our SourceForge${END}\n"
  else
      echo "\n${RED}Failed to send zip to SourceForge, aborting...\n"
  fi
  cd $pwd
else
  echo -e "\n${BOL_MAG}NO UPLOAD, post_build is true...${END}"
fi

buildJson="/tmp/official_devices/builds/${android}/${romtype}/${codename}.json"
jsonTemp="/tmp/${codename}.json"
# Functions
addNewBuild() {
  jq --argjson var "$(< $buildToAddJson)" '.[] += [$var]' $buildJson
}

createNewJson() {
  echo -e "{\n  \"response\": ["
  cat $buildToAddJson
  echo -e "  ]\n}"
}

# Checar se já existe o json do device
if ls $buildJson &> /dev/null; then
  echo -e "\n${BOL_GRE}NEW BUILD ADDED, ${BOL_MAG}json exitente!${END}"
  rm -rf $jsonTemp
  addNewBuild > $jsonTemp &> /dev/null
  cp -rf $jsonTemp $buildJson
else
  echo -e "\n${BOL_GRE}CREATE NEW JSON${BOL_MAG}json ${BOL_RED}NÂO ${BOL_MAG}exitente!${END}"
  createNewJson > $jsonTemp &> /dev/null
  cp -rf $jsonTemp $buildJson
fi

if [[ $romtype == "gapps" ]]; then
  romtypeFormatted="GApps"
else
  romtypeFormatted="Vanilla"
fi

# Capturar dados do device e maintainer
jsonDevices="/tmp/official_devices/devices.json"
[ $codename = lmi ] && typeMaintainer=lead || typeMaintainer=maintainers
jsonMaintainers="/tmp/official_devices/team/${typeMaintainer}.json"
brand=$(cat $jsonDevices | jq -r ".[] | select(.codename == \"${codename}\") | .brand")
name=$(cat $jsonDevices | jq -r ".[] | select(.codename == \"${codename}\") | .name")
maintainerName=$(cat $jsonMaintainers | jq -r ".[] | select(.devices[].codename == \"${codename}\") | .name")
maintainerGitHub=$(cat $jsonMaintainers | jq -r ".[] | select(.devices[].codename == \"${codename}\") | .github_username")
maintainerTelegram=$(cat $jsonMaintainers | jq -r ".[] | select(.devices[].codename == \"${codename}\") | .telegram_username")
fullName="${brand} ${name} (${codename})"

# Mensagem da build
msg="🆙 New build available
📱 *${fullName}*
👤 by ${maintainerGitHub}

*Version:* Android ${version} - _${android}_
*Type:* ${romtypeFormatted}
*Date:* ${dateY}.${dateM}.${dateD}
*Size:* ${size}

[Download](${url})

#${codename} #${codename}${romtype} #${android}"

# Send message
sendMessage() {
  echo -e "${BOL_RED}SENDING MESSAGE TELEGRAM${END}"
  curl "https://api.telegram.org/bot${botTokenPublish}/sendMessage" \
    -d chat_id="${chatId}" \
    --data-urlencode text="${msg}" \
    --data-urlencode parse_mode="markdown" \
    --data-urlencode disable_web_page_preview="true"
}

commitOfficialDevices() {
  echo "Commiting..."
  msgCommit="[KRAKEN-CI]: ${fullName} #${romtype} #${android} #${dateY}.${dateM}.${dateD}
  by ${maintainerName} @${maintainerGitHub}"
  git config --global user.email "bot@aospk.org" && git config --global user.name "Kraken Project Bot"
  cd /tmp/official_devices
  git add .
  git commit -m "$msgCommit"
  git config --global user.email "mamutal91@gmail.com" && git config --global user.name "Alexandre Rangel"
  if [[ $? -eq 0 ]]; then
    echo "Commit success"
  else
    echo "Commit failure"
    ssh -t -t mamutal91@shell.sourceforge.net "rm -rf /home/frs/project/aospk/${android}/${codename}/${romtype}/${zipBuild}"
  fi
  git push ssh://git@github.com/MammothOS-Next/official_devices HEAD:refs/heads/master --force
  git push ssh://git@github.com/MammothOS/official_devices HEAD:refs/heads/master
  echo -e "\nWaiting for the build to be available for download on SourceForge, this could take up to 12 minutes..."
  echo -e "started at: $(date)\nend: $(date --date='+12 minutes')"
  sleep $((60 * 12))
}

if grep $build $buildJson; then
  echo -e "\n${BOL_RED}ESSA BULD JÁ EXISTE NO JSON, NÃO VOU FAZER COMMIT${END}"
else
  commitOfficialDevices
fi

sendMessage &> /dev/null

echo -e "${BOL_RED}\n\nFIM!!!${END}"
sleep 20
