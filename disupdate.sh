#!/bin/sh

SOSIP=$1

Pass="Intel@123"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "swupd autoupdate --disable"

