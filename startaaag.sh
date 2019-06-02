#! /bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=$1

[ "$USBNO" == "" ] && USBNO=2
CONNUSB=/dev/ttyUSB${USBNO}
DEBUGUSB=/dev/ttyUSB$(( USBNO  + 1 ))

#bash $BASEDIR/command.sh $DEBUGUSB 115200 $BASEDIR/cmd/patch_aaag_prestart.cmd
#bash $BASEDIR/sos_init.sh ${USBNO}
bash $BASEDIR/command.sh $DEBUGUSB 115200 $BASEDIR/cmd/start_uos.cmd

sleep 20
