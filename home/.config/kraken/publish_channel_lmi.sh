#!/usr/bin/env bash

if [[ -z ${1} ]]; then
  echo "Você precisa definir o .zip, exemplo, ./publish_channel_lmi.sh Kraken-11-GApps-20210611-1919-lmi.zip"
  exit
else
  zipBuild=${1}
  clear
fi

pwd=$(pwd)

source /home/mamutal91/.botTokens

workingDir=$(mktemp -d) && cd $workingDir

year=$(echo ${dateFull} | cut -c3-4)
month=$(echo ${dateFull} | cut -c6-7)
day=$(echo ${dateFull} | cut -c9-10)

changelogFile=$(basename $zipBuild .zip)
changelogFile=${changelogFile}.txt

img=/home/mamutal91/.dotfiles/home/.config/kraken/images/banner_lmi.jpg

codename=lmi

rm -rf $changelogFile
wget https://raw.githubusercontent.com/AOSPK-DEV/official_devices/master/changelogs/${codename}/${changelogFile} &> /dev/null
sed -i "s/^/• /" $changelogFile

cat $changelogFile

changelogSource="*Source changelog:*
• Feature to enable/disable blur"

changelogDevice="*Device changelog:*
$(cat ${changelogFile})"

if [[ -z $changelogSource ]]; then
  changelogFull="$changelogDevice"
else
  changelogFull="$changelogSource

$changelogDevice"
fi

msg="#AOSPK #KRAKEN #ROM #Official #R #lmi
*The Kraken Project - OFFICIAL | Android 11.*
*Updated:* ${day}/${month}/'${year}

▪️[Vanilla (stock) variant](https://aospk.org/lmi) [1.2 GB]
▪️[GApps variant](https://aospk.org/lmi) [1.5 GB]
▪️[Support](https://t.me/AOSPKChat)

$changelogFull

*Required firmware:*
• V12.2.6.0.RJKMIXM

By @mamutal91
Follow @PocoF2ProGlobalReleases
Join @PocoF2ProGlobalOfficial"

function sendMessage() {
  curl "https://api.telegram.org/bot${botToken}/sendPhoto" \
    -F chat_id="${chatId}" \
    -F photo=@"${img}" \
    -F caption="${msg}" \
    -F parse_mode="markdown"
}
sendMessage

rm -rf $workingDir

cd $pwd
