#!/bin/sh

SOSIP=$1

Pass="Intel@123"

sshpass -p ${Pass} ssh -o StrictHostKeyChecking=no root@${SOSIP} "ls -alt /sys/module/i915/parameters/ && echo -1023 > /sys/module/i915/parameters/gvt_workload_priority"
result=$?
printf "The gvt_workload_priority setting is "
[ $result -eq 0 ] && echo WORKING || echo "NOT WORK($result)"
