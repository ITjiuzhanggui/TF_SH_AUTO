#!/bin/sh

SOSIP=$1

Pass="Intel@123"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias/ && systemctl enable ias-earlyapp"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias/ && timeout 30 stdbuf -oL systemctl start ias-earlyapp"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias/ && systemctl status ias-earlyapp"

DETAIL=$(sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias/ && systemctl status ias-earlyapp")

printf "$DETAIL\n"

WORK=$(echo ${DETAIL} | grep active)
printf "The ias-earlyapp service is "
[ "$WORK" != "" ] && echo WORKING || echo "NOT WORK"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias/ && systemctl enable ias"
sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias/ && timeout 30 stdbuf -oL systemctl start ias"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias/ && systemctl status ias"

DETAIL=$(sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "export XDG_RUNTIME_DIR=/run/ias/ && systemctl status ias")

printf "$DETAIL\n"

WORK=$(echo ${DETAIL} | grep active)
printf "The ias service is "
[ "$WORK" != "" ] && echo WORKING || echo "NOT WORK"
