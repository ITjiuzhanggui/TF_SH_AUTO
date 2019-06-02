#! /bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=$1

[ "$USBNO" == "" ] && USBNO=2
OSSN=$(bash $BASEDIR/getossn.sh ${USBNO})

export PATH=${BASEDIR}/../sources/platform-tools/:$PATH

adb kill-server
adb start-server

WORK=1
while [[ $WORK -le 30 ]]
do
  if [ "" != "`adb devices | grep -v devices | grep device`" ] ; then
    adb -s $OSSN shell settings put global package_verifier_enable 0
    adb -s $OSSN install -t ${BASEDIR}/../sources/stress_wayland_android.apk
    result=$?
    if [ $result -eq 0 ] ; then
      WORK=0
      break
    fi
    (( WORK++ ))
    sleep 2
  fi
  sleep 2
done

sleep 20

# remove apk
adb -s $OSSN uninstall com.example.native_activity
printf "The adb install is "
[ $WORK -eq 0 ] && echo WORKING || echo NOT WORK

