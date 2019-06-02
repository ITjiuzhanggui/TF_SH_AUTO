#!/bin/bash

set -e

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=6
TESTVER=$1

# Get latest image
bash $BASEDIR/getbuild_native_daily.sh | tee $BASEDIR/getbuild_native_daily.out
latest=$(cat $BASEDIR/getbuild_native_daily.out | tail -1 | awk -F': ' '{print $2}')
[ "$TESTVER" == "" ] && TESTVER=$latest

# Flash new image
bash $BASEDIR/fastboot_native.sh daily/$TESTVER $USBNO

sleep 2

# Init new SOS
bash $BASEDIR/sos_init.sh $USBNO 1
ip=$(cat $BASEDIR/${USBNO}.ip)
read -p "Now /dev/ttyUSB${USBNO} ip is $ip. Waiting for native test."

# disable autoupdate
bash $BASEDIR/disupdate.sh $ip

# Get Version
bash $BASEDIR/GETVER_native_daily.sh $USBNO $ip $TESTVER
read -p "Full the report"

# ISSUE test
bash $BASEDIR/GVTNOTEXIST.sh $ip
bash $BASEDIR/IASNOTWORK.sh $ip

read -p "Full the report"

# TEST CASE
bash $BASEDIR/testcase/OLINUX-4923.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4923. Full the report"
bash $BASEDIR/testcase/OLINUX-4924.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4924. Full the report"
bash $BASEDIR/testcase/OLINUX-4932.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4932. Full the report"
bash $BASEDIR/testcase/OLINUX-4938.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4938. Full the report"
bash $BASEDIR/testcase/OLINUX-4955.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4955. Full the report"
bash $BASEDIR/testcase/OLINUX-4956.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4956. Full the report"
bash $BASEDIR/testcase/OLINUX-4957.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4957. Full the report"
bash $BASEDIR/testcase/OLINUX-4958.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4958. Full the report"
bash $BASEDIR/testcase/OLINUX-4959.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4959. Full the report"
bash $BASEDIR/testcase/OLINUX-4960.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4960. Full the report"
bash $BASEDIR/testcase/OLINUX-4962.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4962. Full the report"
bash $BASEDIR/testcase/OLINUX-4965.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4965. Full the report"
bash $BASEDIR/testcase/OLINUX-4966.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4966. Full the report"
bash $BASEDIR/testcase/OLINUX-4967.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4967. Full the report"
bash $BASEDIR/testcase/OLINUX-4968.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4968. Full the report"
bash $BASEDIR/testcase/OLINUX-4969.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4969. Full the report"
bash $BASEDIR/testcase/OLINUX-4971.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4971. Full the report"
bash $BASEDIR/testcase/OLINUX-4973.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4973. Full the report"
bash $BASEDIR/testcase/OLINUX-4974.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4974. Full the report"
bash $BASEDIR/testcase/OLINUX-4996.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4996. Full the report"
bash $BASEDIR/testcase/OLINUX-4997.sh $USBNO $TESTVER
read -p "Finished the OLINUX-4997. Full the report"
bash $BASEDIR/testcase/OLINUX-5001.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5001. Full the report"
bash $BASEDIR/testcase/OLINUX-5033.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5033. Full the report"
bash $BASEDIR/testcase/OLINUX-5034.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5034. Full the report"
bash $BASEDIR/testcase/OLINUX-5035.sh $USBNO $TESTVER
read -p "Finished the OLINUX-5035. Full the report"

