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

TESTBIN=${BASEDIR}/../../sources/long/media_test_bin/mm4dec
TESTSRC=${BASEDIR}/../../sources/long/media_test_bin/1080P_HOBIT3_1920x1080_2700frames.yuv_cbr_bt2000_ip.h264
TESTBIN2=${BASEDIR}/../../sources/long/media_test_bin/mm5dec
TESTSRC2=${BASEDIR}/../../sources/long/hevc/1080P_HOBIT3_1920x1080_2700frames.yuv_cbr_bt2000_ip.h265


mkdir -p $TESTFOLDER/$JID/

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no -r ${BASEDIR}/../../sources/long/media_sample/ root@${SOSIP}:~/
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no ${TESTBIN} root@${SOSIP}:~/media_sample/.
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no ${TESTSRC} root@${SOSIP}:~/media_sample/.

echo "timeout 60 stdbuf -oL bash $(basename ${TESTBIN}) $(basename ${TESTSRC}) 18"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export GST_VAAPI_ALL_DRIVERS=1 && export LIBVA_DRIVER_NAME=iHD && export XDG_RUNTIME_DIR=/run/ias && chmod +x -R media_sample/ && cd media_sample && timeout 60 stdbuf -oL bash $(basename ${TESTBIN}) $(basename ${TESTSRC}) 18  2>&1 | tee ${JID}.h264AVC.out"

#sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm -f media_sample/$(basename ${TESTSRC})"

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no ${TESTBIN2} root@${SOSIP}:~/media_sample/.
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no ${TESTSRC2} root@${SOSIP}:~/media_sample/.

echo "timeout 60 stdbuf -oL bash $(basename ${TESTBIN2}) $(basename ${TESTSRC2}) 18"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export GST_VAAPI_ALL_DRIVERS=1 && export LIBVA_DRIVER_NAME=iHD && export XDG_RUNTIME_DIR=/run/ias && chmod +x -R media_sample/ && cd media_sample && timeout 60 stdbuf -oL bash $(basename ${TESTBIN2}) $(basename ${TESTSRC2}) 18  2>&1 | tee ${JID}.h265HEVC.out"

echo "timeout 60 stdbuf -oL ./sample_multi_transcode -i::h264 $(basename ${TESTSRC}) -o::h264 out.h264 -w 320 -h 240"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export GST_VAAPI_ALL_DRIVERS=1 && export LIBVA_DRIVER_NAME=iHD && export XDG_RUNTIME_DIR=/run/ias && chmod +x -R media_sample/ && cd media_sample && timeout 60 stdbuf -oL ./sample_multi_transcode -i::h264 $(basename ${TESTSRC}) -o::h264 out.h264 -w 320 -h 240  2>&1 | tee ${JID}.h264Transcode.out"

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${SOSIP}:~/media_sample/${JID}.*.out $TESTFOLDER/${JID}/.

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm -fr media_sample/"
