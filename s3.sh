#! /bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=$1

[ "$USBNO" == "" ] && USBNO=2

CONNUSB=/dev/ttyUSB${USBNO}
DEBUGUSB=/dev/ttyUSB$(( USBNO + 1 ))

stty -F $CONNUSB 115200 raw clocal -hupcl -echo
cat $CONNUSB | tee -a $BASEDIR/s3.out &
bgPid=$!

echo -e "g" > $CONNUSB

sleep 3

kill -9 $bgPid
ps -ef | grep -v grep | grep "cat $CONNUSB" | awk '{cmd="kill -9 "$2; system(cmd)}'
