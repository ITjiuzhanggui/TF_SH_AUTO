#!/bin/sh

USBNO=$1
SOSIP=$2
TESTVER=$3

Pass="Intel@123"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "echo"

echo "Get Clear Native version:"
SOSVER=$(sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "swupd info | head -1 | awk -F': ' '{print \$2}'")
echo $SOSVER

echo "Get Clear Native kernel:"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "uname -a"

echo "Get Clear Native Download link:"
echo "https://ubit-artifactory-sh.intel.com/artifactory/clearlinux-sh-local/gp2.0/${TESTVER}gordonpeak/native/"

