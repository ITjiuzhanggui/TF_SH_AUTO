#! /bin/bash

JID=$(basename $0 | cut -d'.' -f1)
BASEDIR=$(cd $(dirname "$0") && pwd)

UOSUSBNO=$1
TESTNO=$2
SOSUSBNO=$3
[ "$TESTNO" == "" ] && TESTNO=UNKNOWN
TESTFOLDER=${BASEDIR}/../../result/$(date +%Y%m%d)/$TESTNO

[ "$SOSUSBNO" == "" ] && SOSUSBNO=6
[ "$UOSUSBNO" == "" ] && UOSUSBNO=2

SOSOSSN=$(bash $BASEDIR/../getossn.sh ${SOSUSBNO})
SOSIP=$(cat $BASEDIR/../${SOSUSBNO}.ip)
UOSIP=$(cat $BASEDIR/../${UOSUSBNO}.ip)

UOSOSSN=$(bash ${BASEDIR}/../getossn.sh ${UOSUSBNO})
SOSOSSN=$(bash ${BASEDIR}/../getossn.sh ${SOSUSBNO})

Pass="Intel@123"

mkdir -p $TESTFOLDER/${JID}/

export PATH=${BASEDIR}/../../sources/platform-tools/:$PATH

echo "Prepared the test"

adb kill-server
adb start-server

while true
do
  if [ "" != "`adb devices | grep -v devices | grep $UOSOSSN | grep device`" ] ; then
    adb -s $UOSOSSN uninstall com.example.native_activity
    sleep 2
    adb -s $UOSOSSN shell settings put global package_verifier_enable 0
    adb -s $UOSOSSN install -t ${BASEDIR}/../../sources/stress_wayland_android.apk
    result=$?
    if [ $? -eq 0 ] ; then
      break
    fi
    sleep 2
  fi
  sleep 2
done

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm -fr daimler_ic/"
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no -r ${BASEDIR}/../../sources/0905/sos_workload/daimler_ic/ root@${SOSIP}:~/
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${UOSIP} "rm -fr daimler_ic/"
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no -r ${BASEDIR}/../../sources/0905/sos_workload/daimler_ic/ root@${UOSIP}:~/


echo "Prepared the test cast: native_base_fps"

echo "Run the test cast: native_base_fps"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias && cd daimler_ic && timeout 60 stdbuf -oL ./daimler_ic-wayland -x 2560 -y 960 -offscreen -ox 2560 -oy 960  2>&1 | tee ${JID}.native_base_fps.out"

echo "Finished the test cast: native_base_fps"
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${SOSIP}:~/daimler_ic/${JID}.native_base_fps.out $TESTFOLDER/${JID}/.
sleep 2

echo "Prepared the test cast: native_low_fps"

echo "Run the test cast: native_low_fps"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias && cd daimler_ic && timeout 60 stdbuf -oL ./daimler_ic-wayland -x 2560 -y 960 -offscreen -ox 2560 -oy 960 -m 65  2>&1 | tee ${JID}.native_low_fps.out"

echo "Finished the test cast: native_low_fps"
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${SOSIP}:~/daimler_ic/${JID}.native_low_fps.out $TESTFOLDER/${JID}/.
sleep 2

echo "Prepared the test cast: Guest_base_fps"

while true
do
  if [ "" != "`adb devices | grep -v devices | grep $UOSOSSN | grep device`" ] ; then
    adb -s $UOSOSSN push ${BASEDIR}/../../sources/0905/uos_workload/stress-wayland/single.80.geometry.offscreen /data/local/tmp/config.txt
    result=$?
    if [ $? -eq 0 ] ; then
      break
    fi
    sleep 2
  fi
  sleep 2
done

sleep 20

# login owner
adb -s $UOSOSSN shell pm list users | tail -1 | awk -F'[:|}]' '{print $3}' | xargs adb -s $UOSOSSN shell am switch-user
adb -s $UOSOSSN shell input keyboard keyevent 61
adb -s $UOSOSSN shell input keyboard keyevent 61
adb -s $UOSOSSN shell input keyboard keyevent 66

echo "Run the test cast: Guest_base_fps"
adb -s $UOSOSSN logcat | grep native-activity  2>&1 | tee $TESTFOLDER/${JID}/${JID}.Guest_base_fps.out &

# run test case
adb -s $UOSOSSN shell am start -n com.example.native_activity/android.app.NativeActivity
sleep 60

echo "Finished the test cast: Guest_base_fps"
adb -s $UOSOSSN shell am force-stop com.example.native_activity
#ps -ef | grep -v grep | grep "adb logcat" | awk '{cmd=\"kill -9 \"\$2; system(cmd)}'
pkill -f "adb -s $UOSOSSN logcat"
adb -s $UOSOSSN reboot
sleep 60

echo "Prepared the test cast: sos_only_low_fps"

echo "Run the test cast: sos_only_low_fps"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${UOSIP} "export XDG_RUNTIME_DIR=/run/ias && cd daimler_ic && timeout 60 stdbuf -oL ./daimler_ic-wayland -x 2560 -y 960 -offscreen -ox 2560 -oy 960 -m 65  2>&1 | tee ${JID}.sos_only_low_fps.out"

echo "Finished the test cast: sos_only_low_fps"
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${UOSIP}:~/daimler_ic/${JID}.sos_only_low_fps.out $TESTFOLDER/${JID}/.
sleep 2

echo "Prepared the test cast: sos_with_uos_low_fps"

while true
do
  if [ "" != "`adb devices | grep -v devices | grep $UOSOSSN | grep device`" ] ; then
    adb -s $UOSOSSN push ${BASEDIR}/../../sources/0905/uos_workload/stress-wayland/single.80.geometry.offscreen /data/local/tmp/config.txt
    result=$?
    if [ $? -eq 0 ] ; then
      break
    fi
    sleep 2
  fi
  sleep 2
done

sleep 20

echo "Run the test cast: sos_with_uos_low_fps"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${UOSIP} "export XDG_RUNTIME_DIR=/run/ias && cd daimler_ic && timeout 80 stdbuf -oL ./daimler_ic-wayland -x 2560 -y 960 -offscreen -ox 2560 -oy 960 -m 65  2>&1 | tee ${JID}.sos_with_uos_low_fps.out" &

adb -s $UOSOSSN logcat | grep native-activity  2>&1 | tee $TESTFOLDER/${JID}/${JID}.Guest_low_fps.out &

adb -s $UOSOSSN shell am start -n com.example.native_activity/android.app.NativeActivity

sleep 80

echo "Finished the test cast: sos_with_uos_low_fps"
adb -s $UOSOSSN shell am force-stop com.example.native_activity
pkill -f "adb -s $UOSOSSN logcat"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${UOSIP} "ps -ef | grep -v grep | grep daimler_ic-wayland | awk '{cmd=\"kill -9 \"\$2; system(cmd)}'"

sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${UOSIP}:~/daimler_ic/${JID}.sos_with_uos_low_fps.out $TESTFOLDER/${JID}/.

sleep 1
adb -s $UOSOSSN reboot

echo "Finished the ${JID}"

# remove apk
#adb -s $UOSOSSN uninstall com.example.native_activity
