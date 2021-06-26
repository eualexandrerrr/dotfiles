#!/usr/bin/env bash

source $HOME/.colors &>/dev/null 

workingDir=$(mktemp -d) && cd $workingDir

chromium() {
  cd $workingDir
  git clone https://github.com/LineageOS/android_external_chromium-webview -b master external_chromium

  cd $workingDir/external_chromium
  git push ssh://git@github.com/AOSPK/external_chromium-webview HEAD:refs/heads/eleven --force
  git push ssh://git@github.com/AOSPK-DEV/external_chromium-webview HEAD:refs/heads/eleven --force
}

chromium

rm -rf $workingDir
