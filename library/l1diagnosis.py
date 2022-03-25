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
import datetime
import json
import re
import csv

try:
  import psutil
  HAS_PSUTIL = True
except ImportError:
  HAS_PSUTIL = False

module = AnsibleModule(argument_spec=dict(), supports_check_mode=True)
result = {}

RELEASE_DATA = {}
FS = []
HN = platform.node()
KERNEL = platform.release()

with open("/etc/os-release") as file:
  reader = csv.reader(file, delimiter="=")
  for row in reader:
    if row:
      RELEASE_DATA[row[0]] = row[1]

OS = RELEASE_DATA["NAME"] + " " + RELEASE_DATA["VERSION"] 
  
if HAS_PSUTIL:
  for item in psutil.disk_partitions():
    FS.append({"Mount": item.mountpoint, "UsedPercent": psutil.disk_usage(item.mountpoint).percent})

  last_reboot = psutil.boot_time()
  LBT = datetime.datetime.fromtimestamp(last_reboot)
  CPU = psutil.cpu_percent()
  MEM = psutil.virtual_memory().percent
  CPUS = psutil.cpu_count()
  TMEM = (psutil.virtual_memory().total/1024)/1024
  SWAP = psutil.swap_memory().percent
  
  result['changed'] = False
  result['success'] = True
  result['failed'] = False
  result['msg'] = "Success"
  result['rc'] = 0
  result['stdout'] = {"Hostname": HN, "OS": OS, "Version": KERNEL, "LastBootUpTime": LBT, "CPULoadPercent": CPU, "MemoryLoadPercent": MEM, "SWAPLoadPercent": SWAP, "Cores": CPUS, "MemoryMB": TMEM, "FileSystems": FS}
  result['stdout_lines'] = {"Hostname": HN, "OS": OS, "Version": KERNEL, "LastBootUpTime": LBT, "CPULoadPercent": CPU, "MemoryLoadPercent": MEM, "SWAPLoadPercent": SWAP, "Cores": CPUS, "MemoryMB": TMEM, "FileSystems": FS}
else:
  result['changed'] = False
  result['success'] = False
  result['failed'] = True
  result['msg'] = "Failed to run module, because of psutil unavailable"
  result['rc'] = 1
  result['stderr'] = "Failed to run module, because of psutil unavailable"
  result['stderr_lines'] = "Failed to run module, because of psutil unavailable"

module.exit_json(**result)