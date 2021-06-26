#!/usr/bin/env bash

source $HOME/.colors &> /dev/null

workingDir=$(mktemp -d) && cd $workingDir

elmyra() {
  git clone https://github.com/ProtonAOSP/android_packages_apps_ElmyraService -b eleven packages_apps_ElmyraService

  cd $workingDir/packages_apps_ElmyraService
  git push ssh://git@github.com/AOSPK/packages_apps_ElmyraService HEAD:refs/heads/eleven --force
  git push ssh://git@github.com/AOSPK-DEV/packages_apps_ElmyraService HEAD:refs/heads/eleven --force
}

elmyra

rm -rf $workingDir
