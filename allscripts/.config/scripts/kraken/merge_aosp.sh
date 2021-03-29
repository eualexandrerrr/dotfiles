#!/usr/bin/env bash
# Copyright (C) 2016-2019 The Dirty Unicorns Project
# Copyright (C) 2016 Jacob McSwain
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

# The source directory; this is automatically two folder up because the script
# is located in vendor/du/scripts. Other ROMs will need to change this. The logic is
# as follows:
# 1. Get the absolute path of the script with readlink in case there is a symlink
#    This script may be symlinked by a manifest so we need to account for that
# 2. Get the folder containing the script with dirname
# 3. Move into the folder that is two folder above that one and print it

cd /mnt/storage/Kraken

WORKING_DIR=/mnt/storage/Kraken
#WORKING_DIR=$( cd $( dirname $( readlink -f "${BASH_SOURCE[0]}" ) )/../../.. && pwd )

# The tag you want to merge in goes here
BRANCH=android-${1}

# Manifest branch
KRAKEN_MANIFEST=aosp.xml

# Google source url
REPO=https://android.googlesource.com/platform/

# This is the array of upstream repos we track
upstream=()

# This is the array of repos with merge errors
failed=()

# This is the array of repos to blacklist and not merge
blacklist=('external/google' 'prebuilts/clang/host/linux-x86' 'prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9')

# Colors
COLOR_RED='\033[0;31m'
COLOR_BLANK='\033[0m'

function is_in_blacklist() {
  for aosp in ${blacklist[@]}
  do
    if [ "$aosp" == "$1" ]; then
      return 0;
    fi
  done
  return 1;
}

function get_repos() {
  declare -a repos=( $(repo list | cut -d: -f1) )
  curl --output /tmp/rebase.tmp $REPO --silent # Download the html source of the Android source page
  # Since their projects are listed, we can grep for them
  for i in ${repos[@]}
  do
    if grep -q "$i" /tmp/rebase.tmp; then # If Google has it and
      if grep -q "$i" $WORKING_DIR/manifest/$KRAKEN_MANIFEST; then # If we have it in our manifest and
        if grep "$i" $WORKING_DIR/manifest/$KRAKEN_MANIFEST | grep -q "remote="; then # If we track our own copy of it
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
  for i in ${upstream[@]}
  do
    rm -rf $i
  done
}

function force_sync() {
  echo "Repo Syncing..."
  sleep 10
  repo sync -c --force-sync >> /dev/null
  if [ $? -eq 0 ]; then
    echo "Repo Sync success"
  else
    echo "Repo Sync failure"
    exit 1
  fi
}

function merge() {
  cd $WORKING_DIR/$1
  git pull $REPO/$1.git -t $BRANCH
  if [ $? -ne 0 ]; then # If merge failed
    failed+=($1) # Add to the list
  fi
}

function build_repo() {
  cd $WORKING_DIR/build/make
  git pull $REPO/build.git -t $BRANCH
  if [ $? -ne 0 ]; then # If merge failed
    failed+=('build/make') # Add to the list
  fi
}

function print_result() {
  if [ ${#failed[@]} -eq 0 ]; then
    echo ""
    echo "========== "$BRANCH" is merged sucessfully =========="
    echo "========= Compile and test before pushing to github ========="
    echo ""
  else
    echo -e $COLOR_RED
    echo -e "These repos have merge errors: \n"
    for i in ${failed[@]}
    do
      echo -e "$i"
    done
    echo -e $COLOR_BLANK
  fi
}

# Start working
cd $WORKING_DIR

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
for i in ${upstream[@]}
do
  merge $i
done

# Merge in the build repo last since is got a different
# manifest path than what's in Google's source
build_repo

# Go back home
cd $WORKING_DIR

# Print any repos that failed, so we can fix merge issues
print_result
