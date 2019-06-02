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

PRECMD="export XDG_RUNTIME_DIR=/run/ias"
TESTSRC=$(cd ${BASEDIR}/../../sources/1031/tfw-pkg/ && pwd)
TESTCMD="cd $(basename ${TESTSRC})/bin && timeout 60 stdbuf -oL bash carchase_off.sh  2>&1 | tee ${JID}.out"

mkdir -p $TESTFOLDER/$JID/

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export http_proxy=http://child-prc.intel.com:913 &&
 export https_proxy=http://child-prc.intel.com:913 && swupd bundle-add libX11client"

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no -r ${TESTSRC} root@${SOSIP}:~/

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "${PRECMD} && ${TESTCMD}"

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${SOSIP}:~/$(basename ${TESTSRC})/${JID}.out $TESTFOLDER/${JID}/.

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm -fr $(basename ${TESTSRC})"
