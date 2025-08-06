# Ensure script runs as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Applying Chrome Group Policy settings..." -ForegroundColor Cyan

# Define registry path
$chromePolicyPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"

# Create Chrome policy key
New-Item -Path $chromePolicyPath -Force | Out-Null

# Disable password import
Set-ItemProperty -Path $chromePolicyPath -Name "PasswordImportEnabled" -Value 0 -Type DWord

# Disable Google Translate
Set-ItemProperty -Path $chromePolicyPath -Name "TranslateEnabled" -Value 0 -Type DWord

# Disable background mode
Set-ItemProperty -Path $chromePolicyPath -Name "BackgroundModeEnabled" -Value 0 -Type DWord

# Disable metrics reporting
Set-ItemProperty -Path $chromePolicyPath -Name "MetricsReportingEnabled" -Value 0 -Type DWord

# Disable default browser prompt
Set-ItemProperty -Path $chromePolicyPath -Name "DefaultBrowserSettingEnabled" -Value 0 -Type DWord

# Disable Privacy Sandbox features
Set-ItemProperty -Path $chromePolicyPath -Name "PrivacySandboxPromptEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path $chromePolicyPath -Name "PrivacySandboxSettings2" -Value 0 -Type DWord

Write-Host "All Chrome policies applied." -ForegroundColor Green

# Launch Chrome (optional)
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (Test-Path $chromePath) {
    Start-Process $chromePath
} else {
    Write-Warning "Chrome not found at default location: $chromePath"
}
