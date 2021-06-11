#!/usr/bin/env bash

year=$(echo ${dateFull} | cut -c3-4)
month=$(echo ${dateFull} | cut -c6-7)
day=$(echo ${dateFull} | cut -c9-10)

zipBuild=Kraken-11-GApps-20210611-1919-lmi.zip
changelogFile=$(basename $zipBuild .zip)
changelogFile=${changelogFile}.txt

codename=lmi

rm -rf $changelogFile
wget https://raw.githubusercontent.com/AOSPK/official_devices/master/changelogs/${codename}/${changelogFile} &>/dev/null
sed -i "s/^/• /" $changelogFile

cat $changelogFile

changelogSource="*Source changelog:*
• Feature to enable/disable blur"

changelogDevice="*Device changelog:*
$(cat ${changelogFile})"

if [ -z "$changelogSource" ]; then
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
  curl "https://api.telegram.org/bot${botToken}/sendMessage" \
    -d chat_id="$chatId" \
    --data-urlencode text="$msg" \
    --data-urlencode parse_mode="markdown" \
    --data-urlencode disable_web_page_preview="true"
}
sendMessage &>/dev/null
