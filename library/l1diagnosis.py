#!python3 
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type


DOCUMENTATION = r'''
---
module: level1diagnosis
short_description: Get basic level 1 information of OS, CPU Load, Memory Load, Filesystems Load, SWAP Load, etc
description: 
  - This module gets basic level 1 information of OS, CPU Load, Memory Load, Filesystems Load, SWAP Load, etc
options:
  topprocessesbycpu
    description:
      - No. of processes consuming high cpu
    type: int
    default: 0
  topprocessesbymem
    description:
      - No. of processes consuming high memory
    type: int
    default: 0
  checkfilesystems
    description:
      - check filesystems and used percent(example: /)
    type: string
    default: all 
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
from ansible.module_utils.urls import open_url

import platform
import sys
import datetime
import json
import re
import csv
import syslog
import logging
import os


def run_module():
    try:
      import psutil
      HAS_PSUTIL = True
    except ImportError:
      HAS_PSUTIL = False

    module_args = dict(
      topprocessesbycpu=dict(type='int', required=False, default=0),
      topprocessesbymem=dict(type='int', required=False, default=0),
      checkfilesystem=dict(type='str', required=False, default='all')
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    result = dict(
        changed=False,
        msg=''
    )

    logger_name = module._syslog_facility
    logger = getattr(syslog, logger_name, syslog.LOG_USER)
    syslog.openlog(str(module), 0, logger)
#    syslog.syslog(syslog.LOG_INFO, "Started on " + module.params['endpoint'])

    logging.basicConfig(filemode='w', level=logging.INFO, format='%(asctime)s  %(levelname)s  %(message)s') #filename='app.log',
    loggerl=logging.getLogger()
#    loggerl.info("Started on " + module.params['endpoint'])

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
      if module_args['checkfilesystem'] == 'all':
        for item in psutil.disk_partitions():
          FS.append({"Mount": item.mountpoint, "UsedPercent": psutil.disk_usage(item.mountpoint).percent})
      else:
        for item in psutil.disk_partitions():
          FS.append({"Mount": item.mountpoint, "UsedPercent": psutil.disk_usage(item.mountpoint).percent})

      syslog.syslog(syslog.LOG_INFO, "Getting Info using PSUTIL")
      loggerl.info("Getting Info using PSUTIL")

      last_reboot = psutil.boot_time()
      LBT = datetime.datetime.fromtimestamp(last_reboot)
      CPU = psutil.cpu_percent()
      MEM = psutil.virtual_memory().percent
      CPUS = psutil.cpu_count()
      TMEM = (psutil.virtual_memory().total/1024)/1024
      SWAP = psutil.swap_memory().percent

      processes = []
      TPCPU = []
      TPMEM = []
      for proc in psutil.process_iter(['pid']):
          p = psutil.Process(pid=proc.pid)
          processes.append(p.as_dict(attrs=['pid', 'name', 'username', 'cpu_percent', 'memory_percent']))

      if int(module_args['topprocessesbycpu']) >> 0:
        cpu = sorted(processes, key=lambda i: i['cpu_percent'], reverse=True)
        count = 0
        
        while (count < module_args['topprocessesbycpu']):   
            count = count + 1
            TPCPU.append(cpu[count])

      if int(module_args['topprocessesbycpu']) >> 0:
        mem = sorted(processes, key=lambda i: i['memory_percent'], reverse=True)
        count = 0
        while (count < module_args['topprocessesbymem']):   
            count = count + 1
            TPMEM.append(mem[count])

      #syslog.syslog(syslog.LOG_INFO, "Printing Results " + inventory_hostname)
      
      result['changed'] = False
      result['success'] = True
      result['failed'] = False
      result['msg'] = "Success"
      result['rc'] = 0
      result['stdout'] = {"Hostname": HN, "OS": OS, "Version": KERNEL, "LastBootUpTime": LBT, "CPULoadPercent": CPU, "MemoryLoadPercent": MEM, "SWAPLoadPercent": SWAP, "Cores": CPUS, "MemoryMB": TMEM, "FileSystems": FS, "TopProcesessbyCPU": TPCPU, "TopProcesessbyMEM": TPMEM}
      result['stdout_lines'] = {"Hostname": HN, "OS": OS, "Version": KERNEL, "LastBootUpTime": LBT, "CPULoadPercent": CPU, "MemoryLoadPercent": MEM, "SWAPLoadPercent": SWAP, "Cores": CPUS, "MemoryMB": TMEM, "FileSystems": FS, "TopProcesessbyCPU": TPCPU, "TopProcesessbyMEM": TPMEM}
    else:
      result['changed'] = False
      result['success'] = False
      result['failed'] = True
      result['msg'] = "Failed to run module, because of psutil unavailable"
      result['rc'] = 1
      result['stderr'] = "Failed to run module, because of psutil unavailable"
      result['stderr_lines'] = "Failed to run module, because of psutil unavailable"
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()