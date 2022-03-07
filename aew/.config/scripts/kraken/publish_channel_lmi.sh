#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

zipBuild=${1}
codename=${2}

chatId="-1001485974314"

dateFull=$(echo ${zipBuild} | tr -d 'KrakenVanillaGAppszip' | cut -c6-13)
year=$(echo ${dateFull} | cut -c3-4)
month=$(echo ${dateFull} | cut -c4-5)
day=$(echo ${dateFull} | cut -c5-6)

pwd=$(pwd)
cd /tmp
rm -rf ${codename}.png
wget https://github.com/AOSPK/official_devices/raw/master/images/banners/${codename}.png &> /dev/null
img=/tmp/${codename}.png
cd $pwd

msg="#AOSPK #KRAKEN #ROM #Official #S #lmi
*The Kraken Project - OFFICIAL | Android 12.*
*Updated:* ${day}/${month}/'${year}

▪️[Download](https://aospk.org/devices/lmi)
▪️[Support](https://t.me/AOSPKChat)

*Required firmware:*
• V12.5.3.0.RJKMIXM

[By] @mamutal91
[Follow] @PocoF2ProGlobalReleases
[Join] @PocoF2ProGlobalOfficial"

sendMessage() {
  curl "https://api.telegram.org/bot${botTelegramToken}/sendPhoto" \
    -F chat_id="${chatId}" \
    -F photo=@"${img}" \
    -F caption="${msg}" \
    -F parse_mode="markdown"
}
sendMessage
