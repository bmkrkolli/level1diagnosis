#!powershell
#Requires -Module Ansible.ModuleUtils.Legacy

try {
    $os = get-wmiobject Win32_OperatingSystem;
    $lbt = $os.ConverttoDateTime($os.LastBootupTime);
    $cpu = get-wmiobject win32_processor | Measure-Object -property LoadPercentage -Average | ForEach-Object{$_.Average};
    $cores = get-wmiobject Win32_ComputerSystem;
    $mem = get-wmiobject Win32_PerfFormattedData_PerfOS_Memory; 
    $am = $mem.AvailableMBytes;
    $tm = get-wmiobject Win32_ComputerSystem | ForEach-Object{[Math]::Round($_.TotalPhysicalMemory/1MB)};
    $um = [Math]::Round(100-(($am/$tm)*100));
    $pageinfo = get-wmiobject Win32_PageFileUsage;
    $pct = [Math]::Round(($pageinfo.CurrentUsage/$pageinfo.AllocatedBaseSize)*100,2);
    $dsk = get-wmiobject Win32_LogicalDisk -Filter "DriveType='3'" | Select-Object Name, @{LABEL='UsedPercent'; EXPRESSION={(100 - [Math]::Round(($_.FreeSpace/$_.Size)*100, 2))}};
    $l1 = New-Object psobject -Property @{Hostname = $os.CSName; OS = $os.Caption; Version = $os.Version + " " + $os.OSArchitecture;
        LastBootUpTime = ($lbt.DateTime).replace(",",""); Cores = $cores.NumberOfProcessors; CPULoadPercent = $cpu; 
        MemoryMB = $tm; MemoryLoadPercent = $um; SWAPLoadPercent = $pct; FileSystems = $dsk }; 
    
    $result = @{
        failed = $false
        changed = $false
        success = $true
        msg = ""
        rc = 0
        stderr = ""
        stderr_lines = ""
        stdout = $l1
        stdout_lines = $l1
    }
}
catch {
    $result = @{
        failed = $true
        changed = $false
        success = $false
        msg = "Failed to Get Level 1 Diagnosis Information"
        rc = 1
        stderr = $PSItem
        stderr_lines = $PSItem
        stdout = ""
        stdout_lines = ""
    }
}

Exit-Json $result;
