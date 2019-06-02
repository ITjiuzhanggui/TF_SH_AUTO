#! /bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
WORKDIR=`pwd`

latest=$1
USBNO=$2

[ "$USBNO" == "" ] && USBNO=2
CONNUSB=/dev/ttyUSB${USBNO}
DEBUGUSB=/dev/ttyUSB$(( USBNO  + 1 ))

cd $BASEDIR

for (( ; ; )) 
do
timeout 4 stdbuf -oL /opt/intel/platformflashtool/bin/fastboot -s $DEVICE flashing unlock
[ $? == 0 ] && break || bash $BASEDIR/reset.sh $USBNO
DEVICE=`sh $BASEDIR/getossn.sh $USBNO`
echo "Now the $CONNUSB OS SN is $DEVICE."
sleep 1
done
 
cflasher -f $BASEDIR/../images/aaag/$latest/flash_AaaG.json -c SOS_and_AaaG --os-sn $DEVICE

#sh fastboot.run

bash $BASEDIR/init.sh $USBNO
sleep 5

cd $WORKDIR
