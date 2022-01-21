#!/usr/bin/env bash


pathROMRecovery="$HOME/Kraken/bootable/recovery"
pathImgsRebranded="$HOME/recovery"

img=(
  fastbootd.png
  logo_image.png
  logo_image_switch.png
)

for img in ${img[@]}; do

  array=(
    384x240
    256x160
    512x320
    768x480
    1024x640
  )

  array2=(
    res-hdpi/images
    res-mdpi/images
    res-xhdpi/images
    res-xxhdpi/images
    res-xxxhdpi/images
  )

  for i in ${!array[*]}; do

    echo "${array[$i]} - ${array2[$i]}"

    echo -e "$img\n"

    convert -resize "${array[$i]}"  "${pathImgsRebranded}/${img}" ${pathROMRecovery}/"${array2[$i]}"/"$img"

    optipng -o7 ${pathImgsRebranded}/"${array2[$i]}"/"$img"

  done

  echo -e "\n\n----------------------------------------------------"

done
