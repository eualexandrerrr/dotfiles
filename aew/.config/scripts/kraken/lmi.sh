#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

pwd=$(pwd)

git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

branch=twelve
branchRebase=lineage-19.1
branchRebaseKernel=lineage-19.1
pushToGitHubTree=AOSPK-Devices
remoteBlobs=blobs
projectName=Kraken

# ORG DE BASE!!!
orgRebase=xiaomi-sm8250-devs

if [[ $orgRebase == xiaomi-sm8250-devs ]]; then
  orgRebaseVendor=SebaUbuntu
  repoVendor=android
  branchRebaseVendor=lineage-18.1
fi

if [[ $orgRebase == ArrowOS ]]; then
  orgRebaseVendor=the-muppets
  repoVendor=proprietary
fi

bringup="Initial changes for ${projectName}"

workingDir=$(mktemp -d) && cd $workingDir

treeLMI() {
  git clone https://github.com/${orgRebase}/android_device_xiaomi_lmi -b ${branchRebase} device_xiaomi_lmi --single-branch

  # Tree
  cd ${workingDir}/device_xiaomi_lmi

  sed -i "s/lineage_/aosp_/g" AndroidProducts.mk

  sed -i 's:$(LOCAL_PATH)/overlay-lineage:$(LOCAL_PATH)/overlay-kraken:g'   device.mk
  mv overlay-lineage overlay-kraken
  rm -rf overlay-kraken/lineage-sdk
  #  sed -i '/overlay-lineage/d' device.mk
  #  sed -i 's/overlay \\/overlay/' device.mk

  mv lineage_lmi.mk aosp_lmi.mk
  sed -i "s/lineage_/aosp_/g" aosp_lmi.mk
  sed -i "s:vendor/lineage:vendor/aosp:g" aosp_lmi.mk
  sed -i "s/Lineage stuff/${projectName} stuff/g" aosp_lmi.mk

  sed -i "s/PRODUCT_MODEL := POCO F2 Pro/PRODUCT_MODEL := POCO F2 Pro\n\nKRAKEN_BUILD_TYPE := OFFICIAL\nTARGET_BOOT_ANIMATION_RES := 1080/g" aosp_lmi.mk

  sed -i "s/common_full_phone.mk/common.mk/g" aosp_lmi.mk

  rm -rf lineage.dependencies
  echo '[
  {
    "repository": "device_xiaomi_sm8250-common",
    "target_path": "device/xiaomi/sm8250-common"
  },
  {
    "remote": "blobs",
    "repository": "vendor_xiaomi_lmi",
    "target_path": "vendor/xiaomi/lmi"
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
    \"target_path\": \"vendor/xiaomi/lmi\"
  }
]"

  git add . && git commit --message "lmi: $bringup" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

  # Default gesture
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
  sed -i '$d' overlay-kraken/frameworks/base/packages/SystemUI/res/values/config.xml
  echo '
    <!-- Udfps vendor code -->
    <integer name="config_udfps_vendor_code">22</integer>

</resources>' | tee -a overlay-kraken/frameworks/base/packages/SystemUI/res/values/config.xml
  git add . && git commit --message "lmi: Add udfps vendor code" --author "TheScarastic <warabhishek@gmail.com>"

  # PADDING
  sed -i '$d' overlay/frameworks/base/packages/SystemUI/res/values/dimens.xml
  echo '
    <!-- The absolute side margins of quick settings -->
    <dimen name="rounded_corner_content_padding">70px</dimen>

</resources>' | tee -a overlay/frameworks/base/packages/SystemUI/res/values/dimens.xml

  msgPadding="lmi: Increase rounded corner content padding

* Android 12 requires a big space on right side to
 show privacy chips. So let's do the same for left
 keeping the design consistency."

  git add . && git commit --message "$msgPadding" --author "Mesquita <mesquita@aospa.co>"

  git push ssh://git@github.com/${pushToGitHubTree}/device_xiaomi_lmi HEAD:refs/heads/${branch} --force
}

treeCOMMON() {
  # Common
  cd ${workingDir}
  git clone https://github.com/${orgRebase}/android_device_xiaomi_sm8250-common -b ${branchRebase} device_xiaomi_sm8250-common --single-branch
  cd device_xiaomi_sm8250-common

  sed -i 's:$(LOCAL_PATH)/overlay-lineage:$(LOCAL_PATH)/overlay-kraken:g'   kona.mk
  mv overlay-lineage overlay-kraken
  rm -rf overlay-kraken/lineage-sdk
  #  sed -i '/overlay-lineage/d' kona.mk
  #  sed -i 's/overlay \\/overlay/' kona.mk

  sed -i 's:ifneq ($(WITH_GMS),true):ifneq ($(KRAKEN_GAPPS),true):g'   BoardConfigCommon.mk
  sed -i "s/org.lineageos.settings.resources/org.kraken.settings.resources/g" parts/Android.bp

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
    \"target_path\": \"vendor/xiaomi/sm8250-common\"
  },
  {
    \"repository\": \"hardware_xiaomi\",
    \"target_path\": \"hardware/xiaomi\"
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

# Kernel and Vendor
function kernelAndVendor() {
  cd $workingDir

  if [[ $(cat /etc/hostname) == nitro5 ]]; then
    echo -e "${BOL_RED}\nVENDOR??? RODE ESSE SCRIPT SOMENTE NO SERVIDOR PARA NÃO CONSUMIR A INTERNET${END}"
    exit
  fi

  git clone https://gitlab.com/${orgRebaseVendor}/${repoVendor}_vendor_xiaomi -b ${branchRebaseVendor} vendor_xiaomi --single-branch
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

  git add . && git commit --message "arch: ARM64: configs: xiaomi: Set localversion to ${projectName}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"

  git push ssh://git@github.com/${pushToGitHubTree}/kernel_xiaomi_sm8250 HEAD:refs/heads/${branch} --force
}

treeLMI
treeCOMMON

kernelAndVendor

cd $pwd
rm -rf $workingDir
