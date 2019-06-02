#!/bin/bash

/opt/intel/platformflashtool/bin/ioc_flash_server_app -s /dev/ttyUSB$2 -t $1
