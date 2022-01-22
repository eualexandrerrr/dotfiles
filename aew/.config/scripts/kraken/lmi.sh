#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

pwd=$(pwd)

git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

branch=twelve
branchRebase=lineage-19.0
branchRebaseKernel=lineage-19.0

if [[ ${1} == pe ]]; then
  pushToGitHubTree=mamutal91
  pushToGitHubVendor=mamutal91
  projectName=PE
  projectNameKernel=pe
  remoteBlobs=pixel-devices-blobs
  repoHardwareXiaomi=LineageOS/android_hardware_xiaomi
  repoHardwareXiaomiBranch=lineage-19.0
else
  pushToGitHubTree=AOSPK-Devices
  pushToGitHubVendor=TheBootloops
  projectName=Kraken
  projectNameKernel=kraken
  remoteBlobs=blobs
  repoHardwareXiaomi=AOSPK/hardware_xiaomi
  repoHardwareXiaomiBranch=twelve
fi

orgRebase=xiaomi-sm8250-devs

if [[ $orgRebase = xiaomi-sm8250-devs ]]; then
  orgRebaseVendor=SebaUbuntu
  repoVendor=android
  branchRebaseVendor=lineage-18.1
fi

if [[ $orgRebase = ArrowOS ]]; then
  orgRebaseVendor=the-muppets
  repoVendor=proprietary
fi

bringup="Initial changes for ${projectName}"

workingDir=$(mktemp -d) && cd $workingDir

tree() {
  git clone https://github.com/${orgRebase}/android_device_xiaomi_lmi -b ${branchRebase} device_xiaomi_lmi

  # Tree
  cd ${workingDir}/device_xiaomi_lmi

  sed -i "s/lineage_/aosp_/g" AndroidProducts.mk

  rm -rf overlay-lineage
  sed -i '/overlay-lineage/d' device.mk
  sed -i 's/overlay \\/overlay/' device.mk

  mv lineage_lmi.mk aosp_lmi.mk
  sed -i "s/lineage_/aosp_/g" aosp_lmi.mk
  sed -i "s:vendor/lineage:vendor/aosp:g" aosp_lmi.mk
  sed -i "s/Lineage stuff/${projectName} stuff/g" aosp_lmi.mk

  if [[ $projectName == PE ]]; then
    echo -e "\nNo change name include mk vendor aosp\n"
  else
    sed -i "s/common_full_phone.mk/common.mk/g" aosp_lmi.mk
  fi

  rm -rf lineage.dependencies
  echo '[
  {
    "repository": "device_xiaomi_sm8250-common",
    "target_path": "device/xiaomi/sm8250-common"
  },
  {
    "remote": "blobs",
    "repository": "vendor_xiaomi_lmi",
    "target_path": "vendor/xiaomi/lmi",
    "branch": "twelve"
  }
]' > aosp.dependencies

  echo "[
  {
    \"repository\": \"device_xiaomi_sm8250-common\",
    \"target_path\": \"device/xiaomi/sm8250-common\"
  },
  {
    \"remote\": \"${remoteBlobs}\",
    \"repository\": \"vendor_xiaomi_lmi\",
    \"target_path\": \"vendor/xiaomi/lmi\",
    \"branch\": \"twelve\"
  }
]"

  git add . && git commit --message "lmi: $bringup" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

  sed -i '$ d' overlay/frameworks/base/core/res/res/values/config.xml
  echo '
    <!-- Controls the navigation bar interaction mode:
         0: 3 button mode (back, home, overview buttons)
         1: 2 button mode (back, home buttons + swipe up for overview)
         2: gestures only for back, home and overview -->
    <integer name="config_navBarInteractionMode">1</integer>
</resources>' >> overlay/frameworks/base/core/res/res/values/config.xml
  git add . && git commit --message "lmi: Add the default gesture" --author "Alexandre Rangel <mamutal91@gmail.com>"

  # UDFPS
  sed -i '$d' overlay/frameworks/base/packages/SystemUI/res/values/config.xml
  echo "
    <!-- Color of the UDFPS pressed view -->
    <color name=\"config_udfpsColor\">#ffffff</color>

    <!-- HBM type of UDFPS overlay.
        0 - GLOBAL HBM
        1 - LOCAL HBM
    -->
    <integer name=\"config_udfps_hbm_type\">0</integer>
</resources>" | tee -a overlay/frameworks/base/packages/SystemUI/res/values/config.xml
  git add . && git commit --message "lmi: Re-add color and type HBM udfps" --author "TheScarastic <warabhishek@gmail.com>"

  git push ssh://git@github.com/${pushToGitHubTree}/device_xiaomi_lmi HEAD:refs/heads/${branch} --force

  # Common
  cd ${workingDir}
  git clone https://github.com/${orgRebase}/android_device_xiaomi_sm8250-common -b ${branchRebase} device_xiaomi_sm8250-common
  cd device_xiaomi_sm8250-common

  rm -rf overlay-lineage
  sed -i '/overlay-lineage/d' kona.mk
  sed -i 's/overlay \\/overlay/' kona.mk

  sed -i "s:vendor/lineage:vendor/aosp:g" kona.mk
  sed -i "s:vendor/lineage:vendor/aosp:g" BoardConfigCommon.mk

  rm -rf lineage.dependencies
  echo "[
  {
    \"repository\": \"kernel_xiaomi_sm8250\",
    \"target_path\": \"kernel/xiaomi/sm8250\"
  },
  {
    \"remote\": \"${remoteBlobs}\",
    \"repository\": \"vendor_xiaomi_sm8250-common\",
    \"target_path\": \"vendor/xiaomi/sm8250-common\",
    \"branch\": \"twelve\"
  },
  {
    \"remote\": \"github\",
    \"repository\": \"${repoHardwareXiaomi}\",
    \"target_path\": \"hardware/xiaomi\",
    \"branch\": \"${repoHardwareXiaomiBranch}\"
  }
]" > aosp.dependencies

  git add . && git commit --message "sm8250-common: $bringup" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

  # Props
  sed -i "s/debug.sf.latch_unsignaled=1/debug.sf.latch_unsignaled=0/g" system.prop
  sed -i "s/debug.sf.latch_unsignaled=1/debug.sf.latch_unsignaled=0/g" vendor.prop

  msg="sm8250-common: Disable debug.sf.latch_unsignaled from prop.
* Disabling this helps reduces notification flicker, UI performance is not impacted.
(per:  change https://android.googlesource.com/platform/frameworks/native/+/c5da271)

*Lmi: Also fixes Lags on Google Photos while playing videos."
  git add . && git commit --message "${msg} now" --signoff --author "soumyo19 <fsoummya@gmail.com>"

  # Rules
  sed -i "s/BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true/BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true\nBUILD_BROKEN_MISSING_REQUIRED_MODULES := true/g" BoardConfigCommon.mk
  git add . && git commit --message "sm8250-common: Add build broken rule" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

  git push ssh://git@github.com/${pushToGitHubTree}/device_xiaomi_sm8250-common HEAD:refs/heads/${branch} --force
}
tree

# Kernel and Vendor
function kernelAndVendor() {
  cd $workingDir

  if [[ $(cat /etc/hostname) == modinx ]]; then
    echo -e "${BOL_RED}\nVENDOR??? RODE ESSE SCRIPT SOMENTE NO SERVIDOR PARA NÃO CONSUMIR A INTERNET${END}"
    exit
  fi

  git clone https://gitlab.com/${orgRebaseVendor}/${repoVendor}_vendor_xiaomi -b ${branchRebaseVendor} vendor_xiaomi
  cp -rf vendor_xiaomi vendor_xiaomi_lmi
  cp -rf vendor_xiaomi vendor_xiaomi_sm8250-common

  cd ${workingDir}/vendor_xiaomi_lmi
  git filter-branch --prune-empty --subdirectory-filter lmi ${branchRebaseVendor}
  git push ssh://git@github.com/${pushToGitHubVendor}/vendor_xiaomi_lmi HEAD:refs/heads/${branch} --force

  cd ${workingDir}/vendor_xiaomi_sm8250-common
  git filter-branch --prune-empty --subdirectory-filter sm8250-common ${branchRebaseVendor}
  git push ssh://git@github.com/${pushToGitHubVendor}/vendor_xiaomi_sm8250-common HEAD:refs/heads/${branch} --force

  cd ${workingDir}
  git clone https://github.com/${orgRebase}/android_kernel_xiaomi_sm8250 -b ${branchRebaseKernel} kernel_xiaomi_sm8250
  cd ${workingDir}/kernel_xiaomi_sm8250

  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/alioth_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/apollo_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/cas_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/cmi_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/elish_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/enuma_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/lmi_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/monet_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/picasso_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/thyme_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/umi_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/vangogh_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/mikona_defconfig
  sed -i "s/lineageos/${projectNameKernel}/g" arch/arm64/configs/vendor/milito_defconfig

  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/alioth_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/apollo_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/cas_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/cmi_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/elish_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/enuma_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/lmi_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/monet_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/picasso_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/thyme_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/umi_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/vangogh_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/mikona_defconfig
  sed -i "s/lineage/${projectNameKernel}/g" arch/arm64/configs/vendor/milito_defconfig

  git add . && git commit --message "ARM64: configs: xiaomi: Set localversion to ${projectName}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

  git push ssh://git@github.com/${pushToGitHubTree}/kernel_xiaomi_sm8250 HEAD:refs/heads/${branch} --force
}
kernelAndVendor

cd $pwd
rm -rf $workingDir
