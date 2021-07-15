#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

workingDir=$(mktemp -d) && cd $workingDir

dsc() {
  git clone https://github.com/PixelExperience/packages_resources_devicesettings-custom -b eleven packages_resources_devicesettings-custom

  cd $workingDir/packages_resources_devicesettings-custom
  git push ssh://git@github.com/AOSPK/packages_resources_devicesettings-custom HEAD:refs/heads/eleven --force
  git push ssh://git@github.com/AOSPK-DEV/packages_resources_devicesettings-custom HEAD:refs/heads/eleven --force
}

dsc

rm -rf $workingDir
