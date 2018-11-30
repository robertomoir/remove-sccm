
# Run SSCM remove
# Should really error check this to make sure the uninstall hasn't been already ran
# As it will error out if so :-(
Start-Process -FilePath 'C:\Windows\ccmsetup\ccmsetup.exe' -Args "/uninstall" -Wait -NoNewWindow

# wait for exit

$CCMProcess = Get-Process ccmsetup -ErrorAction SilentlyContinue

try{
    $CCMProcess.WaitForExit()
}catch{
 

}


# Stop Services
Stop-Service -Name ccmsetup -Force -ErrorAction SilentlyContinue
Stop-Service -Name CcmExec -Force -ErrorAction SilentlyContinue
Stop-Service -Name smstsmgr -Force -ErrorAction SilentlyContinue
Stop-Service -Name CmRcService -Force -ErrorAction SilentlyContinue

# wait for exit

$CCMProcess = Get-Process ccmexec -ErrorAction SilentlyContinue

try{

    $CCMProcess.WaitForExit()

}catch{


}

 
# Remove WMI Namespaces
Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='ccm'" -Namespace root | Remove-WmiObject
Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='sms'" -Namespace root\cimv2 | Remove-WmiObject

# Remove Services from Registry
$CurrentPath = “HKLM:\SYSTEM\CurrentControlSet\Services”
Remove-Item -Path $CurrentPath\CCMSetup -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\CcmExec -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\smstsmgr -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\CmRcService -Force -Recurse -ErrorAction SilentlyContinue

# Remove SCCM Client from Registry
$CurrentPath = “HKLM:\SOFTWARE\Microsoft”
Remove-Item -Path $CurrentPath\CCM -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\CCMSetup -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\SMS -Force -Recurse -ErrorAction SilentlyContinue

# Reset MDM Authority
# CurrentPath should still be correct, we are removing this key: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\DeviceManageabilityCSP
Remove-Item -Path $CurrentPath\DeviceManageabilityCSP -Force -Recurse -ErrorAction SilentlyContinue

# Remove Folders and Files
$CurrentPath = $env:WinDir
Remove-Item -Path $CurrentPath\CCM -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\ccmsetup -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\ccmcache -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\SMSCFG.ini -Force -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\SMS*.mif -Force -ErrorAction SilentlyContinue
Remove-Item -Path $CurrentPath\SMS*.mif -Force -ErrorAction SilentlyContinue 