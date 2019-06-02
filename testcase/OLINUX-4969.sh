#!/bin/bash

JID=$(basename $0 | cut -d'.' -f1)
BASEDIR=$(cd $(dirname "$0") && pwd)
#TESTFOLDER=result/$(date +%Y%m%d%H%M%S)

USBNO=$1
TESTNO=$2
[ "$TESTNO" == "" ] && TESTNO=UNKNOWN
TESTFOLDER=${BASEDIR}/../../result/$(date +%Y%m%d)/$TESTNO

[ "$USBNO" == "" ] && USBNO=2

OSSN=$(bash $BASEDIR/../getossn.sh ${USBNO})
SOSIP=$(cat $BASEDIR/../${USBNO}.ip)

Pass="Intel@123"

PRECMD="rm -fr /lib && ln -s /usr/lib64 /lib && export XDG_RUNTIME_DIR=/run/ias"
TESTSRC=$(cd ${BASEDIR}/../../sources/1031/daimler_ic/ && pwd)
TESTCMD="cd $(basename ${TESTSRC}) && timeout 60 stdbuf -oL ./daimler_ic-wayland -x 1920 -y 1080 -offscreen -ox 1920 -oy 1080 -msaa 2  2>&1 | tee ${JID}.out"

mkdir -p $TESTFOLDER/$JID/

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no -r ${TESTSRC} root@${SOSIP}:~/

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "${PRECMD} && ${TESTCMD}"

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${SOSIP}:~/$(basename ${TESTSRC})/${JID}.out $TESTFOLDER/${JID}/.

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm -fr $(basename ${TESTSRC})"
