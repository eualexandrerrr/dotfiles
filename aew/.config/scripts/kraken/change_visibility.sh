#!/usr/bin/env bash

array=(
  $(grep -Po 'name=\"\K[^"]+(?=\")' $HOME/manifest/aosp.xml)
  $(grep -Po 'name=\"\K[^"]+(?=\")' $HOME/manifest/extras.xml)
)

for i in ${array[@]}; do
  echo $i
  visibility=public

  changeVisibility() {
    curl \
      -H "Authorization: Token ${githubToken}" \
      -H "Content-Type:application/json" \
      -H "Accept: application/json" \
      -X PATCH \
      --data "{ \"visibility\": \"${visibility}\" }" \
      https://api.github.com/repos/AOSPK-Next/${i}
  }
  changeVisibility

done
