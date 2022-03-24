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

import os
import re

# import module snippets
from ansible.module_utils.basic import AnsibleModule

import os
import platform

print(os.getlogin())
print(platform.machine())
print(platform.system())
print(platform.version())