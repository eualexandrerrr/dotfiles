#!/usr/bin/env bash
# Copyright (C) 2016 DirtyUnicorns
# Copyright (C) 2016 Jacob McSwain
# Copyright (C) 2018 ArrowOS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source $HOME/.Xconfigs # My general configs

cd $HOME/Kraken

WORKING_DIR=$HOME/Kraken
echo "${YEL}WORKING_DIR=${CYA}$WORKING_DIR${END}"

# The tag you want to merge in goes here
BRANCH="android-12.0.0_r7"

# Google source url
REPO=https://android.googlesource.com/platform/

# This is the array of upstream repos we track
upstream=()

# This is the array of repos with merge errors
failed=()

# This is the array of repos with merge fine
success=()

# This is the array of repos push failed
pushedF=()

# This is the array of repos pushed fine
pushedP=()

# This is the array of repos to blacklist and not merge
blacklist=('cts' 'prebuilt' 'external/chromium-webview' 'prebuilts/build-tools' 'packages/apps/MusicFX' 'packages/apps/FMRadio'
           'packages/apps/Gallery2' 'packages/apps/Updater' 'hardware/qcom/power' 'prebuilts/r8' 'prebuilts/tools' 'tools/metalava'
           'prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9' 'prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8')

# Colors
COLOR_RED='\033[0;31m'
COLOR_BLANK='\033[0m'

function is_in_blacklist() {
  for j in ${blacklist[@]}; do
    if [ "$j" == "$1" ]; then
      return 0
    fi
  done
  return 1
}

function warn_user() {
  echo "Make sure that you have added your ssh keys on gerrit before proceeding!"
  read -r -p "Do you want to continue? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if [[ -f /tmp/gu.tmp ]]; then
      username=$(cat /tmp/gu.tmp)
      echo "found username: $username"
    else
      echo "Please enter your gerrit username"
      read username
      echo $username > /tmp/gu.tmp
    fi
  else
    echo "PUSH ABORTED!"
    exit 1
  fi
}

function get_repos() {
  declare -a repos=($( repo list | cut -d: -f1))
  curl --output /tmp/rebase.tmp $REPO --silent # Download the html source of the Android source page
  # Since their projects are listed, we can grep for them
  for i in ${repos[@]}; do
    if grep -q "$i" /tmp/rebase.tmp; then # If Google has it and
      if grep -q "$i" $WORKING_DIR/manifest/aosp.xml; then # If we have it in our manifest and
        if grep "$i" $WORKING_DIR/manifest/aosp.xml | grep -q 'remote="aospk"'; then # If we track our own copy of it
          if ! is_in_blacklist $i; then # If it's not in our blacklist
            upstream+=("$i") # Then we need to update it
          else
            echo "$i is in blacklist"
          fi
        fi
      fi
    fi
  done
  rm /tmp/rebase.tmp
}

function delete_upstream() {
  for i in ${upstream[@]}; do
    rm -rf $i
  done
}

function force_sync() {
  echo "${GRE}Repo Syncing...${END}"
  sleep 1
  repo sync -c -j$(nproc --all) --no-clone-bundle --current-branch --no-tags --force-sync
  if [ $? -eq 0 ]; then
    echo "${BOL_GRE}Repo Sync success${END}"
  else
    echo "${BOL_RED}Repo Sync failure${END}"
    exit 1
  fi
}

function merge() {
  cd $WORKING_DIR/$1
  git pull $REPO/$1 $BRANCH
  if [ $? -ne 0 ]; then # If merge failed
    failed+=($1) # Add to the list
  else
    success+=($1)
    push $1
  fi
}

function print_result() {
  if [ ${#failed[@]} -eq 0 ]; then
    echo ""
    echo "========== "$BRANCH" is merged/pushed sucessfully =========="
    echo "========= Compile and test before pushing  ========="
    echo ""
  else
    echo -e $COLOR_RED
    echo -e "These repos have merge errors: \n"
    for i in ${failed[@]}; do
      echo -e "$i"
    done
    echo -e $COLOR_BLANK
  fi

  echo ""
  echo "${GRE}======== "$BRANCH" has been merged successfully to these repos ========${END}"
  echo ""
  for i in ${success[@]}; do
    echo -e "$i"
  done

  echo ""
  echo "${BLU}======== "$BRANCH" has been pushed successfully to these repos ========${END}"
  echo ""
  for i in ${pushedP[@]}; do
    echo -e "$i"
  done

  echo ""
  echo "${RED}======== "$BRANCH" push has failed to these repos ========${END}"
  echo ""
  for i in ${pushedF[@]}; do
    echo -e "$i"
  done
}

function push() {
  cd $WORKING_DIR/$1
  project_name=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')
  #  git remote add gerrit ssh://$username@gerrit.aospk.org:29418/$project_name
  git push ssh://git@github.com/AOSPK-Next/${project_name} HEAD:refs/heads/twelve-${BRANCH} --force
  if [ $? -ne 0 ]; then # If merge failed
    pushedF+=($1) # Add to the list
  else
    pushedP+=($1)
  fi
}

function gerrit_push() {
  echo "IT IS RECOMMENDED THAT YOU HAVE AN ACCOUNT ON OUR GERRIT AND ADDED YOUR SSH KEYS!!"
  warn_user
  get_repos
  for i in ${upstream[@]}; do
    echo $i
    #push $i
  done
  print_result
}

if [[ ${1} == push ]]; then
  gerrit_push
else

  # Start working
  cd $WORKING_DIR

  # Warn user that this may destroy unsaved work
  # warn_user

  # Get the upstream repos we track
  get_repos

  echo "================================================"
  echo "          Force Syncing all your repos          "
  echo "         and deleting all upstream repos        "
  echo " This is done so we make sure you're up to date "
  echo "================================================"

  delete_upstream
  force_sync

  # Merge every repo in upstream
  for i in ${upstream[@]}; do
    merge $i
  done

  # Print any repos that failed, so we can fix merge issues
  print_result
fi
