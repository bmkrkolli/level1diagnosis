#!/bin/bash

: '
DOCUMENTATION 
module: level1diagnosis
short_description: Get basic level 1 information of OS, CPU Load, Memory Load, Filesystems Load, SWAP Load, etc on Unix Server
options: null

EXAMPLE
  - name: "level1diagnosis Level 1 Diagnosis"
    level1diagnosis: 

RETURN
OnSuccess:
{
    "stderr_lines": "",
    "_ansible_no_log": false,
    "stdout": {
        "Kernel": "4.18.0-348.12.2.el8_5.x86_64 x86_64",
        "LastBootUpTime": "2022-03-12 10:13:15",
        "MemoryLoadPercent": 18.9222,
        "Hostname": "rhel8-4",
        "CPULoadPercent": 0,
        "MemoryMB": "5725",
        "Cores": "2",
        "Filesystems": [
            {
                "Mount": "/",
                "UsedPercent": "9%"
            },
            {
                "Mount": "/boot",
                "UsedPercent": "97%"
            }
        ],
        "OS": "Red Hat Enterprise Linux 8.5 (Ootpa)",
        "SWAPLoadPercent": 1
    },
    "changed": false,
    "stderr": "",
    "rc": 0,
    "msg": "",
    "stdout_lines": {
        "Kernel": "4.18.0-348.12.2.el8_5.x86_64 x86_64",
        "LastBootUpTime": "2022-03-12 10:13:15",
        "MemoryLoadPercent": 18.9222,
        "Hostname": "rhel8-4",
        "CPULoadPercent": 0,
        "MemoryMB": "5725",
        "Cores": "2",
        "Filesystems": [
            {
                "Mount": "/",
                "UsedPercent": "9%"
            },
            {
                "Mount": "/boot",
                "UsedPercent": "97%"
            }
        ],
        "OS": "Red Hat Enterprise Linux 8.5 (Ootpa)",
        "SWAPLoadPercent": 1
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
'


HN=$(uname -n||echo 'uname command not found')
OS=$(egrep -w "NAME|VERSION" /etc/os-release|awk -F= '{ print $2 }'|sed 's/"//g'||echo '/etc/os-release command not found')
KERNEL=$(uname -ri||echo 'uname command not found')
LBT=$(uptime -s||echo 'uptime command not found')
CPU=$(which top >/dev/null 2>&1 && (top -b -n 2 | grep 'Cpu(s)' | tail -n 1 | awk '{print $2}'| awk -F. '{print $1}')||echo 'top command not found')
MEM=$(free | grep Mem | awk '{print $3/$2 * 100.0}'||echo 'free command not found')
CPUS=$(nproc||echo 'nproc command not found')
TMEM=$(free -m | grep Mem | awk '{print $2}'||echo 'free command not found')
SWAP=$(free | grep 'Swap' | awk '{t = $2; f = $4; print (f/t)}'||echo 'free command not found')
FS=$(df -TPh -x squashfs -x tmpfs -x devtmpfs | awk 'BEGIN {ORS=","} NR>1{print "{\"Mount\":\""$7"\", \"UsedPercent\":\""$6"\"}"}'||echo 'df command not found,')

STDOUTPUT="\"Hostname\": \""$HN"\", \"OS\": \""$OS"\", \"Cores\": \""$CPUS"\", \"MemoryMB\": \""$TMEM"\", \"Version\": \""$KERNEL"\", \"LastBootUpTime\":\""$LBT"\", \"CPULoadPercent\": "$CPU", \"MemoryLoadPercent\": "$MEM", \"SWAPLoadPercent\": "$SWAP", \"Filesystems\": ["${FS::-1}"]"

ER="not found"
if [[ $STDOUTPUT =~ $ER ]];
then
    echo "{ \"changed\": false, \"failed\": true, \"success\": false, \"rc\": 1, \"msg\": \"\", \"stderr\": {"$STDOUTPUT"}, \"stderr_lines\": {"$STDOUTPUT"}, \"stdout\": \"\", \"stdout_lines\": \"\" }"
    exit 1
else
    echo "{ \"changed\": false, \"failed\": false, \"success\": true, \"rc\": 0, \"msg\": \"\", \"stderr\": \"\", \"stderr_lines\": \"\", \"stdout\": {"$STDOUTPUT"}, \"stdout_lines\": {"$STDOUTPUT"} }"
    exit 0
fi
