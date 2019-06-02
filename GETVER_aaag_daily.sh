#!/bin/sh

BASEDIR=$(cd $(dirname "$0") && pwd)
WORKDIR=`pwd`

USBNO=$1
SOSIP=$2

Pass="Intel@123"

export PATH=$PATH:$(cd ${BASEDIR}/../sources/platform-tools/ && pwd)

adb kill-server
adb start-server

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "echo"

echo "Get Android SOS version:"
SOSVER=$(sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "swupd info | head -1 | awk -F': ' '{print \$2}'")
echo $SOSVER

echo "Get Android SOS kernel:"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "uname -a"

echo "Get Android UOS version:"
RAWVER=$(adb -s $(bash $BASEDIR/getossn.sh ${USBNO}) shell getprop ro.build.version.incremental)
UOSVER=${RAWVER: -4}
echo ${UOSVER}

echo "Get Android UOS kernel:"
adb -s $(bash $BASEDIR/getossn.sh ${USBNO}) shell uname -a 

echo "Get Android UOS Download link:"
SOSFOLDER=$(basename ${BASEDIR}/../images/aaag/daily/*${UOSVER})
echo "https://mcg-depot.intel.com/artifactory/cactus-absp-jf/master-latest/${SOSFOLDER}/gordon_peak_acrn/userdebug/gordon_peak_acrn-flashfiles-P0l00${SOSFOLDER}.zip"

