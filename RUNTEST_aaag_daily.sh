#!/bin/bash

set -e

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=2
NATIVEUSBNO=$1
TESTVER=$2

[ "$NATIVEUSBNO" == "" ] && NATIVEUSBNO=6

# Get latest image
bash $BASEDIR/getbuild_aaag_daily.sh | tee $BASEDIR/getbuild_aaag_daily.out
latest=$(cat $BASEDIR/getbuild_aaag_daily.out | tail -1 | awk -F': ' '{print $2}')
[ "$TESTVER" == "" ] && TESTVER=$latest

# Flash new image
bash $BASEDIR/fastboot_aaag.sh daily/$TESTVER $USBNO

sleep 2

# Init new SOS
bash $BASEDIR/sos_init.sh $USBNO 1
ip=$(cat $BASEDIR/${USBNO}.ip)
sosip=$(cat $BASEDIR/${NATIVEUSBNO}.ip)
read -p "Now /dev/ttyUSB${USBNO} ip is $ip, /dev/ttyUSB${NATIVEUSBNO} ip is $sosip. Waiting for AaaG test."

# start UOS
bash $BASEDIR/startaaag.sh $USBNO
sleep 20

# disable autoupdate
bash $BASEDIR/disupdate.sh $ip

# Get Version
bash $BASEDIR/GETVER_aaag_daily.sh $USBNO $ip $TESTVER
read -p "Full the report"

# ISSUE test
bash $BASEDIR/GVTNOTEXIST.sh $ip
bash $BASEDIR/IASNOTWORK.sh $ip
bash $BASEDIR/OAM-70825.sh $USBNO

read -p "Full the report"

# TEST CASE
bash $BASEDIR/testcase/OLINUX-4975.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4975. Full the report"
bash $BASEDIR/testcase/OLINUX-4998_OLINUX-4999.sh $USBNO $TESTVER $NATIVEUSBNO
read -p "Finished the OLINUX-4998 and OLINUX-4999. Full the report"
bash $BASEDIR/testcase/OLINUX-5025.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5025. Full the report"
bash $BASEDIR/testcase/OLINUX-5026.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5026. Full the report"
bash $BASEDIR/testcase/OLINUX-5027.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5027. Full the report"
bash $BASEDIR/testcase/OLINUX-5028.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5028. Full the report"
bash $BASEDIR/testcase/OLINUX-5029.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5029. Full the report"
bash $BASEDIR/testcase/OLINUX-5030.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5030. Full the report"
bash $BASEDIR/testcase/OLINUX-5031.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5031. Full the report"
bash $BASEDIR/testcase/OLINUX-5032.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5032. Full the report"

