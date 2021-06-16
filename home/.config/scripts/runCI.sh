#!/usr/bin/env bash

source $HOME/.colors 2>/dev/null 
source $HOME/.myTokens 2>/dev/null 

cli="java -jar $HOME/.jenkins-cli.jar -s http://86.109.7.111:8080 -auth ${myUserCI}:${ciKrakenToken} -webSocket"

build="$cli build KrakenDev"
buildRandom="$cli build KrakenDev -p codename=mojito"
buildSync="$cli build KrakenDev -p sync=true"
buildSyncClean="$cli build KrakenDev -p sync=true -p mka_clean=true"
buildSyncInstallclean="$cli build KrakenDev -p sync=true -p mka_installclean=true"
makeClean="$cli build KrakenDev -p build=false -p sync=false -p mka_clean=true -p mka_installclean=false -p publishBuild=false"
onlySync="$cli build KrakenDev -p build=false -p sync=true -p mka_clean=false -p mka_installclean=false -p publishBuild=false"
stop="$cli stop-builds"
clear="$cli clear-queue"
console="$cli console KrakenDev -f"
disable="$cli disable-job"
enable="$cli enable-job"

echo -e "${BOL_BLU}Executing command via ci-cli...\n${END}${GRE}"

[ ${1} = build ] && echo -e "3. Building dirty for ${BLU}lmi${END}...${RED}" && $build
[ ${1} = buildRandom ] && echo -e "4. Building dirty for ${BLU}mojito${END}...${RED}" && $buildRandom
[ ${1} = buildSync ] && echo -e "5. Synchronizing source to build dirty...${RED}" && $buildSync
[ ${1} = buildSyncClean ] && echo -e "6. Cleaning build to build...${RED}" && $buildSyncClean
[ ${1} = buildSyncInstallclean ] && echo -e "7. Cleaning apps to build...${RED}" && $buildSyncInstallclean
[ ${1} = makeClean ] && echo -e "8. Make clean...${RED}" && $makeClean
[ ${1} = stopOnlySync ] && echo -e "9. Stopping jobs and synchronizing source...${RED}" && $stop KrakenDev && $onlySync
[ ${1} = stopJobs ] && echo -e "10. Stopping KrakenDev job running...${RED}" && $stop KrakenDev
[ ${1} = stopClear ] && echo -e "11. Stopping jobs and clearing jobs from the queue...${RED}" && $clear
[ ${1} = enableJobs ] && echo -e "12. Enabling jobs...${RED}" && $enable Kraken && $enable PA
[ ${1} = disableJobs ] && echo -e "13. Disabling jobs...${RED}" && $disable Kraken && $disable PA

echo -e "${BOL_YEL}"
echo -ne "#####                     (33%)\r"
sleep 1
echo -ne "##########                (48%)\r"
sleep 1
echo -ne "#######################   (100%)\r"
echo -ne "\n"
