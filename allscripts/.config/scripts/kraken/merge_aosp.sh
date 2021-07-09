#!/bin/bash
#
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

cd /mnt/roms/jobs/Kraken

usage() {
    echo "Usage ${0} <merge|rebase> <oldaosptag> <newaosptag>"
}

# Verify argument count
if [[ "$#" -ne 3 ]]; then
    usage
    exit 1
fi

OPERATION="${1}"
OLDTAG="${2}"
NEWTAG="${3}"

if [[ "${OPERATION}" != "merge" -a "${OPERATION}" != "rebase" ]]; then
    usage
    exit 1
fi

# Check to make sure this is being run from the top level repo dir
if [[ ! -e "build/envsetup.sh" ]]; then
    echo "Must be run from the top level repo dir"
    exit 1
fi

# Source build environment (needed for aospremote)
. build/envsetup.sh

TOP="${ANDROID_BUILD_TOP}"
MERGEDREPOS="${TOP}/merged_repos.txt"
MANIFEST="${TOP}/.repo/manifests/aosp.xml"
BRANCH=$(git -C ${TOP}/.repo/manifests.git config --get branch.default.merge | sed 's#refs/heads/##g')
STAGINGBRANCH="staging/${BRANCH}_${OPERATION}-${NEWTAG}"
STAGINGBRANCH="staging/${BRANCH}_${OPERATION}-${NEWTAG}"

# Build list of LineageOS forked repos
PROJECTPATHS=$(grep "remote=\"aospk/" "${MANIFEST}" | sed -n 's/.*path="\([^"]\+\)".*/\1/p')

echo -e "#### Old tag = ${OLDTAG} \n#### Branch = ${BRANCH} \n#### Staging branch = ${STAGINGBRANCH}"

# Make sure manifest and forked repos are in a consistent state
echo "#### Verifying there are no uncommitted changes on Kraken forked AOSP projects ####"
for PROJECTPATH in ${PROJECTPATHS} .repo/manifests; do
    cd "${TOP}/${PROJECTPATH}"
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "Path ${PROJECTPATH} has uncommitted changes. Please fix."
        exit 1
    fi
done
echo "#### Verification complete - no uncommitted changes found ####"

# Remove any existing list of merged repos file
rm -f "${MERGEDREPOS}"

# Sync and detach from current branches XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
#repo sync -d

# Ditch any existing staging branches (across all projects)
echo OOOOOOOOI
repo abandon "${STAGINGBRANCH}"

# Iterate over each forked project
for PROJECTPATH in ${PROJECTPATHS}; do
    cd "${TOP}/${PROJECTPATH}"
    repo start "${STAGINGBRANCH}" .
    aospremote | grep -v "Remote 'aosp' created"
    git fetch -q --tags aosp "${NEWTAG}"

    PROJECTOPERATION="${OPERATION}"

    # Check if we've actually changed anything before attempting to merge
    # If we haven't, just "git reset --hard" to the tag
    if [[ -z "$(git diff HEAD ${OLDTAG})" ]]; then
        git reset --hard "${NEWTAG}"
        echo -e "reset\t\t${PROJECTPATH}" | tee -a "${MERGEDREPOS}"
        continue
    fi

    # Was there any change upstream? Skip if not.
    if [[ -z "$(git diff ${OLDTAG} ${NEWTAG})" ]]; then
        echo -e "nochange\t\t${PROJECTPATH}" | tee -a "${MERGEDREPOS}"
        continue
    fi

    # Determine whether OLDTAG is an ancestor of NEWTAG
    # ie is history consistent.
    git merge-base --is-ancestor "${OLDTAG}" "${NEWTAG}"
    # If no, force rebase.
    if [[ "$?" -eq 1 ]]; then
        echo -n "#### Project ${PROJECTPATH} old tag ${OLD} is not an ancestor "
        echo    "of new tag ${NEWTAG}, forcing rebase ####"
        PROJECTOPERATION="rebase"
    fi

    if [[ "${PROJECTOPERATION}" == "merge" ]]; then
        echo "#### Merging ${NEWTAG} into ${PROJECTPATH} ####"
        git merge --no-edit --log "${NEWTAG}"
    elif [[ "${PROJECTOPERATION}" == "rebase" ]]; then
        echo "#### Rebasing ${PROJECTPATH} onto ${NEWTAG} ####"
        git rebase --onto "${NEWTAG}" "${OLDTAG}"
    fi

    CONFLICT=""
    if [[ -n "$(git status --porcelain)" ]]; then
        CONFLICT="conflict-"
    fi
    echo -e "${CONFLICT}${PROJECTOPERATION}\t\t${PROJECTPATH}" | tee -a "${MERGEDREPOS}"
done













echo "SAAAAAAAAAAAAAAAAAIIIIIIIIIIIIIINNNNNNNNNNNDOOOOOOOOOOOO"
exit

#!/usr/bin/env bash
# Copyright (C) 2016-2018 The Dirty Unicorns project
# Copyright (C) 2016 Jacob McSwain
# Copyright (C) 2019 PixelExperience
# Copyright (C) 2021 The Kraken Project
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

source $HOME/.colors &>/dev/null

workingDir=/mnt/roms/jobs/KrakenDev

# The tag you want to merge in goes here
branchAOSP=android-11.0.0_r39
branchKraken=eleven

# Google source url
REPO=https://android.googlesource.com/platform

# This is the array of upstream repos we track
upstream=()

# This is the array of repos with merge errors
failed=()

# This is the array of repos to blacklist and not merge
blacklist=('manifest' 'cts' 'pdk' 'prebuilts/build-tools' 'external/chromium-webview')

# Colors
colorRed='\033[0;31m'
colorBlank='\033[0m'

is_in_blacklist() {
    for repo in ${blacklist[@]}
    do
        if [[ "$repo" == "$1" ]]; then
            return 0;
        fi
    done
    return 1;
}

get_repos() {
    declare -a repos=( $(repo list | cut -d: -f1) )
    curl --output /tmp/rebase.tmp $REPO --silent # Download the html source of the Android source page
    # Since their projects are listed, we can grep for them
    for i in ${repos[@]}
    do
        if grep -q "$i" /tmp/rebase.tmp; then # If Google has it and
            if grep -q "$i" $workingDir/.repo/manifests/aosp.xml; then # If we have it in our manifest and
                if grep "$i" $workingDir/.repo/manifests/aosp.xml | grep -q "remote="; then # If we track our own copy of it
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

delete_upstream() {
    for i in ${upstream[@]}
    do
        echo "${RED}Removing ${BLU}${i}${END}"
        rm -rf $i
    done
}

force_sync() {
    echo "${BOL_CYA}Repo Syncing...${END}"
    sleep 5
    repo sync -c -j$(nproc --all) --no-clone-bundle --current-branch --no-tags --force-sync >> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "${GRE}Repo Sync success${END}"
    else
        echo "${RED}Repo Sync failure${END}"
        exit 1
    fi
}

merge() {
    echo -e "\n${CYA}Merging ${GRE}$1${END} \n"
    cd $workingDir/$1
    git pull $REPO/$1.git -t $branchAOSP --no-edit
    if [[ $? -ne 0 ]]; then # If merge failed
        git_status=$(git status)
        if grep -q "You have unmerged paths" <<<"$git_status"; then
            failed+=($1) # Add to the list
        fi
    fi
}

build_repo() {
    echo -e "\n${CYA}Merging build/make ${END}\n"
    cd $workingDir/build/make
    git pull $REPO/build.git -t $branchAOSP --no-edit
    if [[ $? -ne 0 ]]; then # If merge failed
        git_status=$(git status)
        if grep -q "You have unmerged paths" <<<"$git_status"; then
            failed+=('build/make') # Add to the list
        fi
    fi
}

permission_controller_repo() {
    echo -e "\n${CYA}Merging packages/apps/PermissionController${END} \n"
    cd $workingDir/packages/apps/PermissionController
    git pull https://android.googlesource.com/platform/packages/apps/PackageInstaller.git -t $branchAOSP --no-edit
    if [[ $? -ne 0 ]]; then # If merge failed
        git_status=$(git status)
        if grep -q "You have unmerged paths" <<<"$git_status"; then
            failed+=('packages/apps/PermissionController') # Add to the list
        fi
    fi
}

print_result() {
    if [[ ${#failed[@]} -eq 0 ]]; then
        echo ""
        echo "========== "$branchAOSP" is merged sucessfully =========="
        echo "========= Compile and test before pushing to github ========="
        echo ""
    else
        echo -e $colorRed
        echo -e "These repos have merge errors: \n"
        echo -e "These repos have merge errors: \n" > $workingDir/merge_errors.txt
        for i in ${failed[@]}
        do
            echo -e "$i"
            echo -e "$i\n" >> $workingDir/merge_errors.txt
        done
        echo -e $colorBlank
    fi
}

# Start working
cd $workingDir

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
    repoKraken=$(pwd | sed "s/\/mnt\/roms\/jobs\/KrakenDev\///; s/\//_/g")
    echo -e "${RED}Pushing to org AOSPK-DEV ${GRE}${repoKraken}${END}"
    git remote add old https://github.com/AOSPK/${repoName} &>/dev/null
    git fetch --unshallow old &>/dev/null
    git push ssh://git@github.com/AOSPK-DEV/${repoKraken} HEAD:refs/heads/${branchKraken}
    echo
done

# Merge in the build repo last since is got a different
# manifest path than what's in Google's source
build_repo

# Merge in the packages/apps/PermissionController repo last since is got a different
# manifest path than what's in Google's source
permission_controller_repo

# Go back home
cd $workingDir

# Print any repos that failed, so we can fix merge issues
print_result
