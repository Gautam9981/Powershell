Write-Host "=== Starting Windows 11 Debloat Script ==="

# Disable telemetry services
$services = @(
    "DiagTrack",
    "dmwappushservice",
    "diagnosticshub.standardcollector.service"
)

foreach ($svc in $services) {
    Get-Service -Name $svc -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Service $_.Name -Force -ErrorAction SilentlyContinue
        Set-Service $_.Name -StartupType Disabled
    }
}

# Disable telemetry tasks
$tasks = @(
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem",
    "\Microsoft\Windows\Shell\FamilySafetyMonitor",
    "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
)

foreach ($task in $tasks) {
    schtasks /Change /TN $task /Disable 2>$null
}

# Block telemetry hosts (with safe overwrite to avoid file lock issues)
$telemetryHosts = @(
    "vortex.data.microsoft.com",
    "settings-win.data.microsoft.com",
    "telemetry.microsoft.com",
    "watson.telemetry.microsoft.com",
    "telecommand.telemetry.microsoft.com",
    "oca.telemetry.microsoft.com",
    "sqm.telemetry.microsoft.com",
    "wes.df.telemetry.microsoft.com"
)

$hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
try {
    $existingContent = Get-Content -Path $hostsFile -ErrorAction Stop
    $newLines = @()

    foreach ($entry in $telemetryHosts) {
        if (-not ($existingContent -match [regex]::Escape($entry))) {
            $newLines += "0.0.0.0 $entry"
        }
    }

    if ($newLines.Count -gt 0) {
        $updatedContent = $existingContent + $newLines
        Set-Content -Path $hostsFile -Value $updatedContent -Force
        Write-Host "Telemetry entries added to hosts file."
    } else {
        Write-Host "All telemetry entries already exist in hosts file."
    }
} catch {
    Write-Host "Error modifying hosts file: $_"
}

# Disable Start menu recommendations
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1

# Remove Microsoft Edge browser (but not Edge WebView2 Runtime)
$edgeApp = Get-AppxPackage -Name "Microsoft.MicrosoftEdge.Stable" -AllUsers
if ($edgeApp) {
    Write-Host "Removing Microsoft Edge browser..."
    Remove-AppxPackage -Package $edgeApp.PackageFullName -ErrorAction SilentlyContinue
} else {
    Write-Host "Edge browser not found or already removed."
}

# Ensure Edge WebView2 runtime is retained
$webviewPath = "$env:ProgramFiles (x86)\Microsoft\EdgeWebView\Application"
if (Test-Path $webviewPath) {
    Write-Host "Edge WebView2 runtime is present and will be retained."
} else {
    Write-Host "Warning: Edge WebView2 runtime not detected at expected location."
}

# Remove Cortana
Get-AppxPackage -Name "Microsoft.549981C3F5F10" -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue

# Remove Feedback Hub
Get-AppxPackage -Name "Microsoft.WindowsFeedbackHub" -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue

Write-Host "`nDebloat complete. Biometrics and Edge WebView2 retained. Reboot recommended."
