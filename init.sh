#! /bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=$1

[ "$USBNO" == "" ] && USBNO=2

CONNUSB=/dev/ttyUSB${USBNO}
DEBUGUSB=/dev/ttyUSB$(( USBNO + 1 ))

bash $BASEDIR/connect.sh $CONNUSB 115200 $BASEDIR/cmd/init.cmd

