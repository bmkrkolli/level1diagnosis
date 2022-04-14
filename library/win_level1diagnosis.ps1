#!powershell
#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.CommandUtil
#Requires -Module Ansible.ModuleUtils.FileUtil

$params = Parse-Args $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name '_ansible_check_mode' -type 'bool' -default $false

$topprocessesbycpu = Get-AnsibleParam -obj $params -name "topprocessesbycpu" -type "int" -default 0
$topprocessesbymem = Get-AnsibleParam -obj $params -name "topprocessesbymem" -type "int" -default 0
$checklogicaldisk = Get-AnsibleParam -obj $params -name "checklogicaldisk" -type "str" -default "all"

try {
    $os = get-wmiobject Win32_OperatingSystem;
    $lbt = $os.ConverttoDateTime($os.LastBootupTime);
    $cpu = get-wmiobject win32_processor | Measure-Object -property LoadPercentage -Average | ForEach-Object{$_.Average};
    $cores = get-wmiobject Win32_ComputerSystem;
    $mem = get-wmiobject Win32_PerfFormattedData_PerfOS_Memory; 
    $am = $mem.AvailableMBytes;
    $tpm = (get-wmiobject Win32_ComputerSystem).TotalPhysicalMemory
    $tm = get-wmiobject Win32_ComputerSystem | ForEach-Object{[Math]::Round($_.TotalPhysicalMemory/1MB)};
    $um = [Math]::Round(100-(($am/$tm)*100));
    $pageinfo = get-wmiobject Win32_PageFileUsage;
    $pct = [Math]::Round(($pageinfo.CurrentUsage/$pageinfo.AllocatedBaseSize)*100,2);
    if($checklogicaldisk -eq "all"){
        $dsk = get-wmiobject Win32_LogicalDisk -Filter "DriveType='3'" | Select-Object Name, @{LABEL='UsedPercent'; EXPRESSION={(100 - [Math]::Round(($_.FreeSpace/$_.Size)*100, 2))}};
    } else {
        $checklogicaldisk = $checklogicaldisk + ":";
        if(get-wmiobject Win32_LogicalDisk -Filter "DeviceId='$checklogicaldisk'"){
            $dsk = get-wmiobject Win32_LogicalDisk -Filter "DeviceId='$checklogicaldisk'" | Select-Object Name, @{LABEL='UsedPercent'; EXPRESSION={(100 - [Math]::Round(($_.FreeSpace/$_.Size)*100, 2))}};;
        } else {
            $dsk = "$checklogicaldisk Drive not found"
        };
    };
    if($topprocessesbycpu -ne 0){ 
        $tpcpu = Get-Counter '\Process(*)\ID Process','\Process(*)\% Processor Time' -ErrorAction SilentlyContinue | 
            Select -ExpandProperty CounterSamples | 
            Where-Object InstanceName -NotMatch '^(?:idle|_total|system)$' | 
            Group-Object {Split-Path $_.Path} | 
            Select @{L='ProcessName';E={[regex]::matches($_.Name,'.*process\((.*)\)').groups[1].value}},
            @{L='CPUPercent';E={(($_.Group |? Path -like '*\% Processor Time' |% CookedValue)/100/$env:NUMBER_OF_PROCESSORS)}},
            @{L='ProcessId';E={$_.Group | ? Path -like '*\ID Process' | % RawValue}} | 
            Sort-Object -Descending CPU | 
            Select -First $topprocessesbycpu;
        $tpcpu | Add-Member -Name "User" -Value {get-wmiobject win32_process -Filter "ProcessId='$_.ProcessId'" | %{$_.getowner().user}}
    } else {
        $tpcpu = "";
    };
    if($topprocessesbymem -ne 0){ 
        $tpmem = Get-Counter '\Process(*)\ID Process','\Process(*)\Working Set' -ErrorAction SilentlyContinue | 
            Select -ExpandProperty CounterSamples | 
            Where-Object InstanceName -NotMatch '^(?:idle|_total|system)$' | 
            Group-Object {Split-Path $_.Path} | 
            Select @{L='ProcessName';E={[regex]::matches($_.Name,'.*process\((.*)\)').groups[1].value}},
            @{L='MemoryPercent';E={(($_.Group |? Path -like '*\Working Set' |% CookedValue)/100/$tpm)}},
            @{L='ProcessId';E={$_.Group | ? Path -like '*\ID Process' | % RawValue}} | 
            Sort-Object -Descending Memory | 
            Select -First $topprocessesbymem;
        $tpmem | Add-Member -Name "User" -Value {get-wmiobject win32_process -Filter "ProcessId='$_.ProcessId'" | %{$_.getowner().user}}
    } else {
        $tpmem = "";
    };

    $l1 = New-Object psobject -Property @{Hostname = $os.CSName; OS = $os.Caption; Version = $os.Version + " " + $os.OSArchitecture;
      LastBootUpTime = ($lbt.DateTime).replace(",",""); Cores = $cores.NumberOfProcessors; CPULoadPercent = $cpu; 
      MemoryMB = $tm; MemoryLoadPercent = $um; SWAPLoadPercent = $pct; FileSystems = $dsk; TopProcesessbyCPU = $tpcpu; TopProcesessbyMEM = $tpmem }; 

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
