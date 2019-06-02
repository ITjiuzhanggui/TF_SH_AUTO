#!/bin/sh

BASEDIR=$(cd $(dirname "$0") && pwd)
WORKDIR=`pwd`

USBNO=$1
SOSIP=$2
ANDROIDUOSVER=$3

Pass="Intel@123"

export PATH=$PATH:$(cd ${BASEDIR}/../sources/platform-tools/ && pwd)

adb kill-server
adb start-server

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "echo"

echo "Get Clear SOS version:"
SOSVER=$(sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "swupd info | head -1 | awk -F': ' '{print \$2}'")
echo $SOSVER

echo "Get Clear SOS kernel:"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "uname -a"

echo "Get Android UOS version:"
RAWVER=$(adb -s $(bash $BASEDIR/getossn.sh ${USBNO}) shell getprop ro.build.version.incremental)
#UOSVER=${RAWVER: -4}
echo ${ANDROIDUOSVER}

echo "Get Android UOS kernel:"
adb -s $(bash $BASEDIR/getossn.sh ${USBNO}) shell uname -a 

echo "Get Android UOS Download link:"
#SOSFOLDER=$(basename *${UOSVER})
echo "https://mcg-depot.intel.com/artifactory/cactus-absp-jf/build/eng-builds/master/PSI/weekly/${ANDROIDUOSVER}gordon_peak_acrn/userdebug/gordon_peak_acrn-flashfiles-${RAWVER}.zip"

