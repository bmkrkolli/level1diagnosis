<# 
.NAME
    Operations Tool
.SYNOPSIS
    Operations Tool
.DESCRIPTION
    Created this tool for some common tasks in VDI
        - Check User Sessions and Machines
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(692,387)
$Form.text                       = "Operations Tool"
$Form.TopMost                    = $false
$Form.BackColor                  = [System.Drawing.ColorTranslator]::FromHtml("#8b8b8b")

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "LoginID"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(9,10)
$Label1.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$Label1.ForeColor                = [System.Drawing.ColorTranslator]::FromHtml("#000000")

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Password"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(169,10)
$Label2.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$LoginID                    = New-Object system.Windows.Forms.TextBox
$LoginID.multiline          = $false
$LoginID.width              = 150
$LoginID.height             = 20
$LoginID.location           = New-Object System.Drawing.Point(9,26)
$LoginID.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$LoginID.ForeColor          = [System.Drawing.ColorTranslator]::FromHtml("#7ed321")
$LoginID.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#000000")

$Passwd                         = New-Object system.Windows.Forms.TextBox
$Passwd.multiline               = $false
$Passwd.width                   = 150
$Passwd.height                  = 20
$Passwd.location                = New-Object System.Drawing.Point(169,26)
$Passwd.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Passwd.ForeColor               = [System.Drawing.ColorTranslator]::FromHtml("#7ed321")
$Passwd.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#000000")

$Log                             = New-Object system.Windows.Forms.TextBox
$Log.multiline                   = $true
$Log.width                       = 672
$Log.height                      = 267
$Log.Anchor                      = 'top,right,bottom,left'
$Log.location                    = New-Object System.Drawing.Point(9,110)
$Log.Font                        = New-Object System.Drawing.Font('Lucida Console',10)
$Log.ForeColor                   = [System.Drawing.ColorTranslator]::FromHtml("#7ed321")
$Log.BackColor                   = [System.Drawing.ColorTranslator]::FromHtml("#000000")

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "User LAN ID to Fetch"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(9,60)
$Label3.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$UserID                         = New-Object system.Windows.Forms.TextBox
$UserID.multiline               = $false
$UserID.width                   = 150
$UserID.height                  = 20
$UserID.location                = New-Object System.Drawing.Point(9,78)
$UserID.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$UserID.ForeColor               = [System.Drawing.ColorTranslator]::FromHtml("#7ed321")
$UserID.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#000000")

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Fetch Details"
$Button1.width                   = 94
$Button1.height                  = 25
$Button1.location                = New-Object System.Drawing.Point(170,76)
$Button1.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "clear"
$Button2.width                   = 82
$Button2.height                  = 25
$Button2.Anchor                  = 'top,right'
$Button2.location                = New-Object System.Drawing.Point(600,7)
$Button2.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$Form.controls.AddRange(@($Label1,$LoginID,$Log,$Button1,$Button2,$Passwd,$Label2,$Label3,$UserID))

$Button1.Add_Click({ fetchuser })
$Form.Add_Load({ OnLoad })
$Button2.Add_Click({ ClearLog })
$Log.Add_DoubleClick({ ClearLogDC })

function ClearLogDC { $Log.Text = "" }
function ClearLog { $Log.Text = "" }
function OnLoad { 
    Hide-Console
    Clear-Host
    $log.Scrollbars = "Vertical"
}

#Check to make sure powershell is ran as admin
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

function Show-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11

    [Console.Window]::ShowWindow($consolePtr, 4)
}

function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}


function fetchuser { 

}  

[void]$Form.ShowDialog()
