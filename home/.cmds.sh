# Functions

function p () {
  git cherry-pick ${1}
}

# Functions for git
function push () {
  echo "Pushing github.com/AOSPK/${1} - ${2}" && echo
  git push ssh://git@github.com/AOSPK/${1} HEAD:refs/heads/${2} ${3}
}

function clone () {
  echo "Cloning github.com/AOSPK/${1} - ${2}" && echo
  git clone ssh://git@github.com/AOSPK/${1} -b ${2}
}

function los () {
  echo "Cloning github.com/LineageOS/android_${1} - ${2}" && echo
  rm -rf ${1} && git clone https://github.com/LineageOS/android_${1} -b ${2} ${1} && cd ${1}
}

function cm () {
  git add . && git commit --author "Alexandre Rangel <mamutal91@gmail.com>"
}

function c () {
  git add . && git commit --author "${1}"
}

function amend () {
  git add . && git commit --amend
}

function up() {
  pwd_upstream=$(pwd)
  REPO=${1}
  LOS=${2}
  AOSPK=${3}
  cd $HOME && rm -rf $REPO
  git clone https://github.com/LineageOS/android_$REPO -b $LOS $REPO
  cd $REPO && git push ssh://git@github.com/AOSPK/$REPO HEAD:refs/heads/$AOSPK --force
  cd $pwd_upstream
}

# Tree for beryllium
function tree () {
  rm -rf device/xiaomi/beryllium device/xiaomi/sdm845-common hardware/xiaomi
  git clone ssh://git@github.com/mamutal91/device_xiaomi_beryllium -b eleven device/xiaomi/beryllium
  git clone ssh://git@github.com/mamutal91/device_xiaomi_sdm845-common -b eleven device/xiaomi/sdm845-common
  git clone https://github.com/LineageOS/android_hardware_xiaomi -b lineage-18.1 hardware/xiaomi
}

function kernel () {
  rm -rf kernel/xiaomi
  git clone ssh://git@github.com/mamutal91/kernel_xiaomi_sdm845 -b eleven kernel/xiaomi/sdm845
}

function vendor () {
  rm -rf vendor/xiaomi
  git clone ssh://git@github.com/mamutal91/vendor_xiaomi -b eleven vendor/xiaomi
}

function www () {
}

# Update scripts
function cmds () {
  pwd=$(pwd)
  cd $HOME
  rm -rf $HOME/.cmds.sh && wget https://raw.githubusercontent.com/mamutal91/dotfiles/master/home/.cmds.sh && chmod +x $HOME/.cmds.sh && source $HOME/.zshrc
  cd $pwd
}
