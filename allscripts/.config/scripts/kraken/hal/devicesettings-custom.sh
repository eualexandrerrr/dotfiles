#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

workingDir=$(mktemp -d) && cd $workingDir

dsc() {
  git clone https://github.com/LineageOS/android_packages_resources_devicesettings -b lineage-18.1 packages_resources_devicesettings

  cd $workingDir/packages_resources_devicesettings
  git push ssh://git@github.com/AOSPK/packages_resources_devicesettings HEAD:refs/heads/twelve --force
  git push ssh://git@github.com/AOSPK-Next/packages_resources_devicesettings HEAD:refs/heads/twelve --force
}

dsc

rm -rf $workingDir
