#!python3 
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function
__metaclass__ = type


DOCUMENTATION = r'''
---
module: level1diagnosis
short_description: Get basic level 1 information of OS, CPU Load, Memory Load, Filesystems Load, SWAP Load, etc
description: 
  - This module gets basic level 1 information of OS, CPU Load, Memory Load, Filesystems Load, SWAP Load, etc
options: null

attributes:
    check_mode:
        support: full
    diff_mode:
        support: full
    vault:
        support: none
notes:

seealso:

author:

'''

EXAMPLES = r'''
- name: "level1diagnosis Level 1 Diagnosis"
  level1diagnosis: 

'''

RETURN = r'''#'''

# import module snippets
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.common.sys_info import get_platform_subclass

import os
import platform
import sys
import psutil
import datetime
import json
import re

module = AnsibleModule(argument_spec=dict(), supports_check_mode=True)
result = {}

try:
  HN = platform.node()
  OS = platform.system()
  KERNEL = platform.release()
  LBT = os.system('uptime -s')
  CPU = os.system("which top >/dev/null 2>&1 && (top -b -n 2 | grep 'Cpu(s)' | tail -n 1 | awk '{print $2}'| awk -F. '{print $1}')||echo 'top command not found'")
  MEM = os.system("free | grep Mem | awk '{print $3/$2 * 100.0}'||echo 'free command not found'")
  CPUS = os.system("nproc||echo 'nproc command not found'")
  TMEM = os.system("free -m | grep Mem | awk '{print $2}'||echo 'free command not found'")
  SWAP = os.system("free | grep 'Swap' | awk '{t = $2; f = $4; print (f/t)}'||echo 'free command not found'")
#  FS = os.system("df -TPh -x squashfs -x tmpfs -x devtmpfs | awk 'BEGIN {ORS=\",\"} NR>1{print \"{\"Mount\":\"\"$7\"\", \"UsedPercent\":\"\"$6\"\"}\"}'||echo 'df command not found,'") 
#  STDOUTPUT = "\"Hostname\": \"" + HN + "\", \"OS\": \"" + OS + "\", \"Cores\": \"" + CPUS + "\", \"MemoryMB\": \"" + TMEM + "\", \"Version\": \"" + KERNEL + "\", \"LastBootUpTime\":\"" + LBT + "\", \"CPULoadPercent\": " + CPU + ", \"MemoryLoadPercent\": " + MEM + ", \"SWAPLoadPercent\": " + SWAP # + ", \"Filesystems\": [" + FS + "]"
  result['changed'] = False
  result['success'] = True
  result['failed'] = False
  result['msg'] = {"Hostname": HN, "OS": OS, "Version": KERNEL, "LastBootUpTime": LBT}
#  result['stdout'] = "Hostname: " + HN + ", OS: " + OS + ", Cores: " + CPUS + ", MemoryMB: " + TMEM + ", Version: " + KERNEL + ", LastBootUpTime:" + LBT + ", CPULoadPercent: " + CPU + ", MemoryLoadPercent: " + MEM + ", SWAPLoadPercent: " + SWAP
#  result['stdout_lines'] = "Hostname: " + HN + ", OS: " + OS + ", Cores: " + CPUS + ", MemoryMB: " + TMEM + ", Version: " + KERNEL + ", LastBootUpTime:" + LBT + ", CPULoadPercent: " + CPU + ", MemoryLoadPercent: " + MEM + ", SWAPLoadPercent: " + SWAP
  result['stderr'] = ""
  result['stderr_lines'] = ""
except:
  result['changed'] = False
  result['success'] = False
  result['failed'] = True
  result['msg'] = "Failed to run module"
  result['rc'] = 1
  result['stdout'] = ""
  result['stdout_lines'] = ""
  result['stderr'] = "Failed to run module"
  result['stderr_lines'] = "Failed to run module"

module.exit_json(**result)