# Define registry paths
$edgePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$edgeUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
$edgeAppPolicyPath = "$edgeUpdatePath\Applications\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}"  # Microsoft Edge App GUID

# Create keys if they don't exist
New-Item -Path $edgePolicyPath -Force | Out-Null
New-Item -Path $edgeUpdatePath -Force | Out-Null
New-Item -Path $edgeAppPolicyPath -Force | Out-Null

# Disable Edge pre-launch and startup behavior
Set-ItemProperty -Path $edgePolicyPath -Name "AllowPrelaunch" -Value 0 -Type DWord
Set-ItemProperty -Path $edgePolicyPath -Name "AllowStartupBoost" -Value 0 -Type DWord
Set-ItemProperty -Path $edgePolicyPath -Name "RestoreOnStartup" -Value 0 -Type DWord
Set-ItemProperty -Path $edgePolicyPath -Name "HideFirstRunExperience" -Value 1 -Type DWord

# Disable Edge updates globally
Set-ItemProperty -Path $edgeUpdatePath -Name "AutoUpdateCheckPeriodMinutes" -Value 0 -Type DWord
Set-ItemProperty -Path $edgeUpdatePath -Name "UpdateDefault" -Value 0 -Type DWord

# Disable Edge app-specific updates
Set-ItemProperty -Path $edgeAppPolicyPath -Name "UpdatePolicy" -Value 0 -Type DWord

# Output results
Write-Host "Group Policy settings to disable Microsoft Edge and its updates have been applied." -ForegroundColor Green
Write-Host "Note: You may need to restart the system or run 'gpupdate /force' to ensure policies take full effect." -ForegroundColor Yellow
