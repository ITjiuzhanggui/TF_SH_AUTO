#! /bin/bash

JID=$(basename $0 | cut -d'.' -f1) BASEDIR=$(cd $(dirname "$0") && pwd) USBNO=$1 TESTNO=$2

PriorityFlag=$3
[ "$PriorityFlag" == "" ] && PriorityFlag="p1"
 echo "PriorityFlag: $PriorityFlag"

[ "$TESTNO" == "" ] && TESTNO=UNKNOWN
TESTFOLDER=${BASEDIR}/../../result/$(date +%Y%m%d)/$TESTNO

[ "$USBNO" == "" ] && USBNO=2

OSSN=$(bash $BASEDIR/../getossn.sh ${USBNO})
SOSIP=$(cat $BASEDIR/../${USBNO}.ip)

Pass="Intel@123"

testfile="multi.80.geometry"

mkdir -p $TESTFOLDER/${JID}/

export PATH=${BASEDIR}/../../sources/platform-tools/:$PATH

echo "Prepared the test"

adb kill-server
adb start-server

while true
do
  if [ "" != "`adb devices | grep -v devices | grep $OSSN | grep device`" ] ; then
    adb -s $OSSN uninstall com.example.native_activity
    sleep 2
    adb -s $OSSN shell settings put global package_verifier_enable 0
    adb -s $OSSN install -t ${BASEDIR}/../../sources/stress_wayland_android.apk
    result=$?
    if [ $? -eq 0 ] ; then
      break
    fi
    sleep 2
  fi
  sleep 2
done

ssh-keygen -f "/root/.ssh/known_hosts" -R $SOSIP
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm -fr daimler_ic/"
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no -r ${BASEDIR}/../../sources/0905/sos_workload/daimler_ic/ root@${SOSIP}:~/

echo "Prepared the test cast: ${JID}"

#kill latest sos case
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "ps -ef | grep -v grep | grep daimler_ic-wayland | awk '{cmd=\"kill -9 \"\$2; system(cmd)}'"

while true
do
  if [ "" != "`adb devices | grep -v devices | grep device`" ] ; then
    adb -s $OSSN push ${BASEDIR}/../../sources/0905/uos_workload/stress-wayland/params_tr0/$testfile /data/local/tmp/config.txt
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
adb -s $OSSN shell pm list users | tail -1 | awk -F'[:|}]' '{print $3}' | xargs adb -s $OSSN shell am switch-user
adb -s $OSSN shell input keyboard keyevent 61
adb -s $OSSN shell input keyboard keyevent 61
adb -s $OSSN shell input keyboard keyevent 66


echo "Run the test cast: ${JID}"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "rm -fr /lib && ln -s /usr/lib64 /lib && echo \"1\" > /sys/kernel/debug/tracing/options/trace_printk && echo -1023 > /sys/module/i915/parameters/gvt_workload_priority"
 
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias && cd daimler_ic && timeout 120 stdbuf -oL ./daimler_ic-wayland -x 2560 -y 960 -m 61 -fullscreen  2>&1 | tee ${testfile}.out" &

# run test case
adb -s $OSSN logcat | grep native-activity  2>&1 | tee $TESTFOLDER/${JID}/${testfile}.Guest.out &
adb -s $OSSN shell am start -n com.example.native_activity/android.app.NativeActivity
sleep 120

echo "Finished the test case: ${JID}"

# stop test case
adb -s $OSSN shell am force-stop com.example.native_activity
pkill -f "adb -s $OSSN logcat"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "ps -ef | grep -v grep | grep daimler_ic-wayland | awk '{cmd=\"kill -9 \"\$2; system(cmd)}'"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "cat /sys/kernel/debug/tracing/trace > preemption_latency.log"

# Get result
if [ $PriorityFlag == "p1" ] ; then
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${SOSIP}:~/daimler_ic/${testfile}.out $TESTFOLDER/${JID}/.
sshpass -p ${Pass} scp -o StrictHostKeyChecking=no root@${SOSIP}:~/preemption_latency.log $TESTFOLDER/${JID}/.

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "echo \"0\" > /sys/kernel/debug/tracing/options/trace_printk"

python ${BASEDIR}/../../sources/0905/sos_workload/daimler_ic/preempt_latency.py -f $TESTFOLDER/${JID}/preemption_latency.log >  $TESTFOLDER/${JID}/${testfile}.out.result

echo "Successfully calculating."

fi
sleep 1
adb -s $OSSN reboot

# remove apk
#adb -s $OSSN uninstall com.example.native_activity
