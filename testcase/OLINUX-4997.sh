#!/bin/bash

JID=$(basename $0 | cut -d'.' -f1)
BASEDIR=$(cd $(dirname "$0") && pwd)

USBNO=$1
TESTNO=$2
[ "$TESTNO" == "" ] && TESTNO=UNKNOWN
TESTFOLDER=${BASEDIR}/../../result/$(date +%Y%m%d)/$TESTNO

[ "$USBNO" == "" ] && USBNO=2

OSSN=$(bash $BASEDIR/../getossn.sh ${USBNO})
SOSIP=$(cat $BASEDIR/../${USBNO}.ip)

Pass="Intel@123"

TESTBIN=${BASEDIR}/../../sources/long/media_test_bin/m5lp
TESTSRC=${BASEDIR}/../../sources/long/hevc/1080P_HOBIT3_1920x1080_2700frames.yuv_cbr_bt2000_ip.h265

mkdir -p $TESTFOLDER/$JID/

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no ${TESTBIN} root@${SOSIP}:~/.
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no ${TESTSRC} root@${SOSIP}:~/.

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export GST_VAAPI_ALL_DRIVERS=1 && export LIBVA_DRIVER_NAME=iHD && export XDG_RUNTIME_DIR=/run/ias && timeout 60 stdbuf -oL bash $(basename ${TESTBIN}) $(basename ${TESTSRC})  2>&1 | tee ${JID}.out"

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${SOSIP}:~/${JID}.out $TESTFOLDER/${JID}/.

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm $(basename ${TESTBIN})"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm $(basename ${TESTSRC})"
