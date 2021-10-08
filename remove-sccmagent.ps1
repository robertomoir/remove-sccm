# Run SSCM remove
# $ccmpath is path to SCCM Agent's own uninstall routine.
$CCMpath = 'C:\Windows\ccmsetup\ccmsetup.exe'
# And if it exists we will remove it, or else we will silently fail.
if (Test-Path $CCMpath) {
    Start-Process -FilePath $CCMpath -Args "/uninstall" -Wait -NoNewWindow
    # wait for exit
    $CCMProcess = Get-Process ccmsetup -ErrorAction SilentlyContinue
        try{
            $CCMProcess.WaitForExit()
        }catch{
        }
}

# Stop Services
Stop-Service -Name ccmsetup -Force -ErrorAction SilentlyContinue
Stop-Service -Name CcmExec -Force -ErrorAction SilentlyContinue
Stop-Service -Name smstsmgr -Force -ErrorAction SilentlyContinue
Stop-Service -Name CmRcService -Force -ErrorAction SilentlyContinue

# wait for services to exit
$CCMProcess = Get-Process ccmexec -ErrorAction SilentlyContinue
try{
    $CCMProcess.WaitForExit()
}catch{
}

 
# Remove WMI Namespaces
Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='ccm'" -Namespace root | Remove-WmiObject
Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='sms'" -Namespace root\cimv2 | Remove-WmiObject

# Remove Services from Registry
# Set $CurrentPath to services registry keys
$CurrentPath = "HKLM:\SYSTEM\CurrentControlSet\Services"
Remove-Item -Path $CurrentPath\CCMSetup -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\CcmExec -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\smstsmgr -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\CmRcService -Force -Recurse -ErrorAction SilentlyContinue

# Remove SCCM Client from Registry
# Update $CurrentPath to HKLM/Software/Microsoft
$CurrentPath = "HKLM:\SOFTWARE\Microsoft"
Remove-Item -Path $CurrentPath\CCM -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\CCMSetup -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\SMS -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\ -Recurse -Force -ErrorAction SilentlyContinue

# Reset MDM Authority
# CurrentPath should still be correct, we are removing this key: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\DeviceManageabilityCSP
Remove-Item -Path $CurrentPath\DeviceManageabilityCSP -Force -Recurse -ErrorAction SilentlyContinue

# Remove Folders and Files
# Tidy up garbage in Windows folder
$CurrentPath = $env:WinDir
Remove-Item -Path $CurrentPath\CCM -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\ccmsetup -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\ccmcache -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\SMSCFG.ini -Force -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\SMS*.mif -Force -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\SMS*.mif -Force -ErrorAction SilentlyContinue 
Remove-Item C:\Windows\System32\GroupPolicy\Machine\Registry.pol -Recurse -Force -ErrorAction SilentlyContinue

# Remove Configuration Manager Client and Software Centre shortcuts
$MSCPath = (Test-Path -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft System Center\Configuration Manager\Configuration Manager Console.lnk')
$MEMPath = (Test-Path -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Endpoint Manager\Configuration Manager\Configuration Manager Console.lnk')
If (($MSCPath -eq $true) -or ($MEMPath -eq $true)) {
   Remove-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft System Center\Configuration Manager\Software Center.lnk' -Force -ErrorAction SilentlyContinue
   Remove-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Endpoint Manager\Configuration Manager\Software Center.lnk' -Force -ErrorAction SilentlyContinue
} else {
   Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft System Center\" -Recurse -Force -ErrorAction SilentlyContinue
   Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Endpoint Manager\" -Recurse -Force -ErrorAction SilentlyContinue
}

#Remove ConfigMgr self-signed certificates
Get-ChildItem -Path "cert:LocalMachine\SMS\*" | Remove-Item -Recurse -Force
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\SystemCertificates\SMS\Certificates\*' -force
