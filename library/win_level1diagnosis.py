#!python3 
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
module: win_level1diagnosis
short_description: Get basic level 1 information of OS, CPU Load, Memory Load, Disk Load, Pagefile Load, etc on Windows Server
options: null
description: 
  - This module gets basic level 1 information of OS, CPU Load, Memory Load, Disk Load, Pagefile Load, etc
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

EXAMPLE = r'''
  - name: "win_level1diagnosis Level 1 Diagnosis"
    win_level1diagnosis: 
'''

RETURN = r'''
OnSuccess:
{
    "stderr_lines": "",
    "_ansible_no_log": false,
    "stdout": {
        "MemoryLoadPercent": 43,
        "LastBootUpTime": "Wednesday March 16 2022 5:37:32 PM",
        "OSArchitecture": "64-bit",
        "Hostname": "WINSTD2019",
        "CPULoadPercent": 1,
        "MemoryMB": 6143,
        "PageFileLoadPercent": 34.38,
        "DiskLoad": [
            {
                "Name": "C:",
                "UsedPercent": 63.62
            },
            {
                "Name": "E:",
                "UsedPercent": 0.18
            }
        ],
        "Cores": 2,
        "LogicalProcessors": 2,
        "OS": "Microsoft Windows Server 2019 Standard"
    },
    "changed": false,
    "stderr": "",
    "rc": 0,
    "msg": "",
    "stdout_lines": {
        "MemoryLoadPercent": 43,
        "LastBootUpTime": "Wednesday March 16 2022 5:37:32 PM",
        "OSArchitecture": "64-bit",
        "Hostname": "WINSTD2019",
        "CPULoadPercent": 1,
        "MemoryMB": 6143,
        "PageFileLoadPercent": 34.38,
        "DiskLoad": [
            {
                "Name": "C:",
                "UsedPercent": 63.62
            },
            {
                "Name": "E:",
                "UsedPercent": 0.18999999999999773
            }
        ],
        "Cores": 2,
        "LogicalProcessors": 2,
        "OS": "Microsoft Windows Server 2019 Standard"
    }
}

OnFailure:
{
    "stderr_lines": "<Error Details>",
    "_ansible_no_log": false,
    "stdout": "",
    "changed": false,
    "stderr": "<Error Details>",
    "rc": 1,
    "msg": "",
    "stdout_lines": ""
}
'''