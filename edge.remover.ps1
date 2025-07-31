# Clean Microsoft Edge (not WebView2)

Write-Output "Removing Microsoft Edge Start Menu shortcuts..."

# Remove Edge shortcuts from Start Menu (system-wide and user-specific)
$paths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Remove-Item $path -Force
        Write-Output "Removed: $path"
    }
}

# Block Edge browser from being reinstalled by Windows Update

Write-Output "Blocking Edge from being reinstalled..."

New-Item -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Name "DoNotUpdateToEdgeWithChromium" -Value 1 -Type DWord

Write-Output "Edge update block applied."

# Remove leftover Edge uninstall entries (do not touch WebView2)

function Remove-EdgeRegistryEntries {
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($path in $regPaths) {
        Get-ChildItem $path | ForEach-Object {
            $props = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
            if ($props.DisplayName -like "*Microsoft Edge*" -and $props.DisplayName -notlike "*WebView*") {
                Remove-Item $_.PSPath -Recurse -Force
                Write-Output "Removed Edge registry entry: $($props.DisplayName)"
            }
        }
    }
}

Remove-EdgeRegistryEntries

# Optional: Rebuild Search Index (manual step)

$rebuildSearchIndex = $true # Set to $false if you don't want to open the dialog

if ($rebuildSearchIndex) {
    Write-Output "Launching Search Index Rebuild dialog..."

    Start-Process -FilePath "control.exe" -ArgumentList "srchadmin.dll" -Wait

    Write-Output "Click 'Advanced' > 'Rebuild' manually in the dialog."
}

Write-Output "Microsoft Edge has been removed. WebView2 remains installed."
