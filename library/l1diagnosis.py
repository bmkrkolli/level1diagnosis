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

module = AnsibleModule()
result = {}
result['changed'] = False

try:
    import psutil
    result['success'] = True
    result['msg'] = platform.machine() + "," + platform.system() + "," + platform.version()
    result['rc'] = 0
except ImportError:
    PSUTIL_IMP_ERR = traceback.format_exc()
    result['success'] = False
    result['msg'] = PSUTIL_IMP_ERR
    result['rc'] = 1

module.exit_json(**result)