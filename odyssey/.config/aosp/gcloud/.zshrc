#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

# Themes https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export TERM="xterm-256color"
export EDITOR="nano"
export BROWSER="/usr/bin/google-chrome-stable"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"

alias nano="sudo nano"
alias pacman="sudo pacman"
alias systemctl="sudo systemctl"
alias p="git cherry-pick ${1}"
alias rm="sudo rm"
alias pkill="sudo pkill"

export PATH=$HOME/.bin:$PATH
export USE_CCACHE=1
export CCACHE_DIR="$HOME/.ccache"
export CCACHE_EXEC="$(which ccache)"

export SELINUX_IGNORE_NEVERALLOWS=true
export CUSTOM_BUILD_TYPE=OFFICIAL
export OPENGAPPS_TYPE=ALPHA

export aosp="$HOME/aosp"
export branch="ten"
export los="lineage-17.1"

alias bp="cd $aosp && repo sync -c -j$(nproc --all) --no-clone-bundle --no-tags --force-sync && opengapps && . build/envsetup.sh && lunch aosp_beryllium-userdebug && make -j$(nproc --all) bacon 2>&1 | tee log.txt"
alias b="cd $aosp && . build/envsetup.sh && lunch aosp_beryllium-userdebug && make -j$(nproc --all) bacon 2>&1 | tee log.txt"

alias up="sudo mv ${1} /var/www/html"

function update () {
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get autoremove -y
}

function push () {
  git push ssh://git@github.com/mamutal91/${1} HEAD:refs/heads/${2} --force
  git push ssh://git@github.com/aosp-forking/${1} HEAD:refs/heads/${2} --force
}

function tree () {
  cd $aosp
  rm -rf device/xiaomi/beryllium
  rm -rf device/xiaomi/sdm845-common
  git clone ssh://git@github.com/mamutal91/device_xiaomi_beryllium -b $branch device/xiaomi/beryllium
  git clone ssh://git@github.com/mamutal91/device_xiaomi_sdm845-common -b $branch device/xiaomi/sdm845-common
}

function tree_pull () {
  pwd_tree_pull=$(pwd)
  rm -rf $HOME/.pull_rebase && mkdir $HOME/.pull_rebase && cd $HOME/.pull_rebase
  rm -rf device_xiaomi_beryllium device_xiaomi_sdm845-common

  git clone ssh://git@github.com/mamutal91/device_xiaomi_beryllium -b $branch
  cd device_xiaomi_beryllium
  git pull --rebase https://github.com/AOSiP-Devices/device_xiaomi_beryllium -t ten && git rebase
  echo && echo "Pushing..." && echo && git push && echo && echo && cd ..

  git clone ssh://git@github.com/mamutal91/device_xiaomi_sdm845-common -b $branch
  cd device_xiaomi_sdm845-common
  git pull --rebase https://github.com/AOSiP-Devices/device_xiaomi_sdm845-common -t ten && git rebase
  echo && echo "Pushing..." && echo && git push && echo && echo && cd ..

  rm -rf device_xiaomi_beryllium device_xiaomi_sdm845-common
  cd $pwd_tree_pull
}

function tree_kernel () {
  cd $aosp
  rm -rf kernel/xiaomi
  git clone https://github.com/AOSiP-Devices/kernel_xiaomi_sdm845 -b ten kernel/xiaomi/sdm845
}

function tree_vendor () {
  pwd_tree_vendor=$(pwd)
  cd $aosp
  rm -rf vendor/xiaomi
  git clone https://github.com/AOSiP-Devices/proprietary_vendor_xiaomi -b ten vendor/xiaomi
  cd vendor/xiaomi
  rm -rf dipper jasmine_sprout mido msm8953-common perseus platina phoenix raphael sdm660-common wayne wayne-common whyred
  cd $pwd_tree_vendor
}

function opengapps () {
  pwd_opengapps=$(pwd)
  cd $aosp/vendor/opengapps/build && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/all && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/arm && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/arm64 && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/x86 && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/x86_64 && git lfs fetch --all && git lfs pull && echo && pwd
  cd $pwd_opengapps
}

function scripts () {
  scripts=$(pwd)
  cd $HOME
  rm -rf $HOME/.zshrc && wget https://raw.githubusercontent.com/mamutal91/dotfiles/master/odyssey/.config/aosp/gcloud/.zshrc && source $HOME/.zshrc
  rm -rf setup.sh && wget https://raw.githubusercontent.com/mamutal91/dotfiles/master/odyssey/.config/aosp/gcloud/setup.sh
  cd $scripts
}
