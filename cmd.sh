#!/bin/bash

# connect.sh

# Usage:
# $ connect.sh <device> <port speed> <cmd>
# Example: connect.sh /dev/ttyS0 9600 cmd.txt

# Exit when any command fails
set -e

BASEDIR=$(cd $(dirname "$0") && pwd)

# Set up device
stty -F $1 $2

# Let cat read the device $1 in the background
cat $1 | tee -a $BASEDIR/cmd.out &

# Capture PID of background process so it is possible to terminate it when done
bgPid=$!

# Read commands from user, send them to device $1
while read cmd
do
   echo "$cmd"
   sleep 1
done > $1 

sleep 3

# Terminate background read process
kill -9 $bgPid
