#! /bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=$1

[ "$USBNO" == "" ] && USBNO=2
CONNUSB=/dev/ttyUSB${USBNO}
DEBUGUSB=/dev/ttyUSB$(( USBNO + 1 ))

stty -F ${DEBUGUSB} 115200 raw clocal -hupcl -echo
cat ${DEBUGUSB} | tail -n +2 | tee $BASEDIR/deviceinfo.${USBNO}.out &

bash $BASEDIR/connect.sh $CONNUSB 115200 $BASEDIR/cmd/reset.cmd

sleep 3

ps -ef | grep -v grep | grep "cat ${DEBUGUSB}" | awk '{cmd="kill -9 "$2; system(cmd)}'

dos2unix $BASEDIR/deviceinfo.${USBNO}.out
