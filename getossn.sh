#!/bin/bash

BASEDIR=$(cd $(dirname "$0") && pwd)
USBNO=$1

cat ${BASEDIR}/deviceinfo.${USBNO}.out | grep --binary-files=text "androidboot.serialno" | awk -F'=' '{print $2}'
