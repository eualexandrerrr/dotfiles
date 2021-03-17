#!/usr/bin/env bash

zipBuild=${1}

source $HOME/.mytokens/.myTokens &> /dev/null

chatId="-1001485974314"

dateFull=$(echo ${zipBuild} | tr -d 'KrakenVanillaGAppszip' | cut -c6-13)
year=$(echo ${dateFull} | cut -c3-4)
month=$(echo ${dateFull} | cut -c4-5)
day=$(echo ${dateFull} | cut -c5-6)

echo $year

pwd=$(pwd)
cd /tmp
rm -rf lmi.png
wget https://github.com/AOSPK/official_devices/raw/master/images/banners/lmi.png
img=/tmp/lmi.png
cd $pwd

codename=lmi

msg="#AOSPK #KRAKEN #ROM #Official #R #lmi
*The Kraken Project - OFFICIAL | Android 11.*
*Updated:* ${day}/${month}/'${year}

▪️[Vanilla (stock) variant](https://aospk.org/lmi) [1.2 GB]
▪️[GApps variant](https://aospk.org/lmi) [1.5 GB]
▪️[Support](https://t.me/AOSPKChat)


*Required firmware:*
• V12.2.6.0.RJKMIXM

By @mamutal91
Follow @PocoF2ProGlobalReleases
Join @PocoF2ProGlobalOfficial"

sendMessage() {
  curl "https://api.telegram.org/bot${botToken}/sendPhoto" \
    -F chat_id="${chatId}" \
    -F photo=@"${img}" \
    -F caption="${msg}" \
    -F parse_mode="markdown"
}
sendMessage
