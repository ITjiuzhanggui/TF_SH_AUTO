#!/bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=$1
ISFIRST=$2

[ "$USBNO" == "" ] && USBNO=2
CONNUSB=/dev/ttyUSB${USBNO}
DEBUGUSB=/dev/ttyUSB$(( USBNO  + 1 ))

if [ "$ISFIRST" == "" ] ; then
bash $BASEDIR/init.sh $USBNO
sleep 2
fi

undo=Unreachable
bash $BASEDIR/connect.sh $DEBUGUSB 115200 $BASEDIR/cmd/sos_console.cmd
while [ "$undo" != "" ]
do
    rm -f $BASEDIR/command.out
    bash $BASEDIR/connect.sh $DEBUGUSB 115200 $BASEDIR/cmd/sos_init.cmd
    #sleep 4
    #bash $BASEDIR/connect.sh $DEBUGUSB 115200 $BASEDIR/sos_init.cmd
    bash $BASEDIR/command.sh $DEBUGUSB 115200 $BASEDIR/cmd/sos_ssh.cmd
    ip=$(cat $BASEDIR/command.out | grep inet | grep -v inet6 | grep -v 127.0.0.1 | awk -F'[ |/]' '{print $6}' | tail -1)
    timeout 5 ping $ip | tee $BASEDIR/pin.out
    undo=$(cat $BASEDIR/pin.out | tail -1 | grep Unreachable)
    #timeout 10 sshpass -p "Intel@123" ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oPubkeyAuthentication=no root@$ip echo 1
    #sshisconn=$?
    #[ $sshisconn -ne 0 ] || undo=No
    ssh-keygen -f "/root/.ssh/known_hosts" -R $ip
    echo $ip > $BASEDIR/$USBNO.ip
    sshpass -p "Intel@123" ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oPubkeyAuthentication=no root@$ip "swupd mirror -s http://linux-ftp.jf.intel.com/pub/mirrors/clearlinux/update"
done

