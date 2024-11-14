# First Execution Policy has to set to RemoteSigned...
#
# Set-ExecutionPolicy RemoteSigned -Force
#
$AppsToRemove = @(
    # -- TC --
    'Beckhoff Support Info Report'        # 4022
    'Beckhoff Target Browser'             # >= 4022.14
    'Beckhoff TE130x Scope View'          # 4024
    'Beckhoff TE132x Bode Plot'           # 4024
    'Beckhoff TE1010 Realtime Monitor'
    'Beckhoff TE2000 HMI Engineering'
    'Beckhoff TE5950 Drive Manager 2'
    'Beckhoff TF3110 TC3 Filter Designer'
    'Beckhoff TF3300 Scope Server'
    'Beckhoff TF5400 TC3 Advanced Motion Pack'
    'Beckhoff TF5850 TC3 XTS Technology'  # does not work!
    'Beckhoff TF6010 ADS Monitor'
    'Beckhoff TF6100 OPC-UA'
    'Beckhoff TF6340 Serial Communication'
    'Beckhoff TF6xxx TwinCAT 3 Connectivity'
    'Beckhoff TwinCAT 3 Application Runtime Libraries (x64)' # 4024
    'Beckhoff TwinCAT 3 BlockDiagram'
    'Beckhoff TWinCAT 3 Scope'             # < 4024.0
    'Beckhoff TwinCAT 3 Type System (x64)' # 4024.0 only one
    'Beckhoff TwinCAT 3 Type System (x64)' # >= 4024.4 two and TFs can bring more!
    'Beckhoff TwinCAT AML DataExchange'    # 4024
    'Beckhoff TwinCAT PnP Driver Package'
    'Beckhoff TwinCAT 3 Measurement'       # 4024
    'Beckhoff TwinCAT Multiuser Git'       # >= 4024.4
    'Beckhoff TwinCAT Multiuser'           # 4024
    'Beckhoff TwinCAT 3.1 Remote Manager Components (Build 4018)' # RM 4018
    'Beckhoff TwinCAT 3.1 Remote Manager Components (Build 4020)' # RM 4020
    'Beckhoff TwinCAT 3.1 Remote Manager Components (Build 4022)' # RM 4022
    'Beckhoff TwinCAT 3.1 Remote Manager Components (Build 4024)' # RM 4024
    'Beckhoff TwinCAT 3.1 (Build 4024)' # TC3.1.4024
    'Beckhoff TwinCAT 3.1 (Build 4022)' # TC3.1.4022
    'Beckhoff TwinCAT XAE Shell'        # 4024
    'Git-for-TwinCAT-Multiuser'         # 4024.0 only
    'vs_minshellinteropmsi'             # 4024.0 only
    # ----- TC 2.11 x64 -----
    'TwinCAT 2.11 x64 Engineering'
    # ----- VS TcXae shell || VS2019 -----
    'Microsoft Help Viewer 2.3'         # TcXae Shell
    # ----- OPC UA -----
    'UaGateway 1.5.3'
    'UaGateway_COM_ProxyStub_3.00.101.2'
)

$RegKeys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
)

$Apps = $RegKeys |
Get-ChildItem |
Get-ItemProperty |
Where-Object { $AppsToRemove -contains $_.DisplayName -and $_.UninstallString }

foreach ( $App in $Apps ) {
    $UninstallString = if ( $App.Uninstallstring -match '^msiexec' ) {
        "$( $App.UninstallString -replace '/I', '/X' ) /qn /norestart"
    }
    else {
        $App.UninstallString
    }

    Write-Verbose $UninstallString

    Start-Process -FilePath cmd -ArgumentList '/c', $UninstallString -NoNewWindow -Wait
}

# TcCnc Service
$IsTcCnc = Test-Path HKLM:\SYSTEM\CurrentControlSet\Services\TcCnc
if ($IsTcCnc) {
    Remove-Item HKLM:\SYSTEM\CurrentControlSet\Services\TcCnc
}

# TcpIp Service
$IsTcCnc = Test-Path HKLM:\SYSTEM\CurrentControlSet\Services\TcpIpServer
if ($IsTcCnc) {
    Remove-Item HKLM:\SYSTEM\CurrentControlSet\Services\TcpIpServer
}