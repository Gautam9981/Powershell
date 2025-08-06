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

# Disable Edge background mode
Set-ItemProperty -Path $edgePolicyPath -Name "BackgroundModeEnabled" -Value 0 -Type DWord

# Disable Edge updates globally
Set-ItemProperty -Path $edgeUpdatePath -Name "AutoUpdateCheckPeriodMinutes" -Value 0 -Type DWord
Set-ItemProperty -Path $edgeUpdatePath -Name "UpdateDefault" -Value 0 -Type DWord

# Disable Edge app-specific updates
Set-ItemProperty -Path $edgeAppPolicyPath -Name "UpdatePolicy" -Value 0 -Type DWord

# Disable Microsoft Edge update tasks (handles dynamic core task names)
$tasks = Get-ScheduledTask | Where-Object {
    $_.TaskName -like "MicrosoftEdgeUpdateTaskMachineCore*" -or
    $_.TaskName -eq "MicrosoftEdgeUpdateTaskMachineUA"
}

foreach ($task in $tasks) {
    try {
        Disable-ScheduledTask -TaskPath $task.TaskPath -TaskName $task.TaskName -ErrorAction Stop
        Write-Host "Disabled scheduled task: $($task.TaskName)"
    } catch {
        Write-Warning "Failed to disable task: $($task.TaskName) -- $($_.Exception.Message)"
    }
}

# Remove Edge shortcut from Startup folder (user-level)
$startupLink = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Microsoft Edge.lnk"
if (Test-Path $startupLink) {
    Remove-Item $startupLink -ErrorAction SilentlyContinue
    Write-Host "🧹 Removed Edge shortcut from Startup folder."
}

# OPTIONAL: Block Edge execution via ACL (can break system features)
# $edgeExePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
# if (Test-Path $edgeExePath) {
#     icacls $edgeExePath /deny "Users:(X)" | Out-Null
#     Write-Host "🚫 Blocked execution of Edge via ACL."
# } else {
#     Write-Warning "⚠️ Edge executable not found, skipping ACL block."
# }

# Final output
Write-Host "Group Policy settings to disable Microsoft Edge and its updates have been applied." -ForegroundColor Green
Write-Host "Background processes and scheduled tasks have been disabled." -ForegroundColor Green
Write-Host "Note: You may need to restart the system or run 'gpupdate /force' to ensure policies take full effect." -ForegroundColor Yellow
