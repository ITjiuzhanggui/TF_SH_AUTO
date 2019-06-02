#!/bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
BootLoaderBin=$1
USBNO=$2

[ "$USBNO" == "" ] && USBNO=2

CONNUSB=/dev/ttyUSB${USBNO}
DEBUGUSB=/dev/ttyUSB$(( USBNO + 1 ))


read -p "Waiting for Unplug the power cable, press and hold the “ignition” button (item 6 in the board connections picture above) before plugging the power cable back in. After five seconds, release the “ignition” button."

/opt/intel/platformflashtool/bin/ias-spi-programmer --write $BootLoaderBin

stty -F $CONNUSB 115200 raw clocal -hupcl -echo
cat $CONNUSB | tee -a Bootloader.out &
bgPid=$!

echo -e "g" > $CONNUSB

kill -9 $bgPid
ps -ef | grep -v grep | grep "cat $CONNUSB" | awk '{cmd="kill -9 "$2; system(cmd)}'

/opt/intel/platformflashtool/bin/ias-spi-programmer --write $BootLoaderBin

