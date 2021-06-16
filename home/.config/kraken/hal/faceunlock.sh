#!/usr/bin/env bash

source $HOME/.colors 2>/dev/null 

workingDir=$(mktemp -d) && cd $workingDir

function faceunlock() {
  git clone https://gitlab.pixelexperience.org/android/external_faceunlock -b eleven external_faceunlock
  git clone https://github.com/PixelExperience/packages_apps_FaceUnlockService -b eleven packages_apps_FaceUnlockService

  cd $workingDir/external_faceunlock
  git push ssh://git@gitlab.com/AOSPK/external_faceunlock HEAD:refs/heads/eleven --force

  cd $workingDir/packages_apps_FaceUnlockService
  git push ssh://git@github.com/AOSPK/packages_apps_FaceUnlockService HEAD:refs/heads/eleven --force
  git push ssh://git@github.com/AOSPK-DEV/packages_apps_FaceUnlockService HEAD:refs/heads/eleven --force
}

faceunlock

rm -rf $workingDir
