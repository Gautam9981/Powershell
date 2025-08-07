# Requires -RunAsAdministrator
function Assert-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Warning "This script must be run as Administrator!"
        exit 1
    }
}

Assert-Admin

$isoDir = "C:\Iso"
$isoName = "Fedora-KDE-Live-x86_64-42-1.6.iso"
$isoUrl = "https://download.fedoraproject.org/pub/fedora/linux/releases/42/Spins/x86_64/iso/$isoName"
$isoPath = Join-Path $isoDir $isoName

# Create ISO directory if it doesn't exist
if (-Not (Test-Path $isoDir)) {
    Write-Output "[*] Creating directory $isoDir..."
    New-Item -Path $isoDir -ItemType Directory | Out-Null
} else {
    Write-Output "[*] Directory $isoDir exists."
}

# Download Fedora KDE Spin 42 ISO if not present
if (-Not (Test-Path $isoPath)) {
    Write-Output "[*] Downloading Fedora KDE Spin 42 ISO to $isoPath ..."
    try {
        Invoke-WebRequest -Uri $isoUrl -OutFile $isoPath -ErrorAction Stop
        Write-Output "[*] Download complete."
    } catch {
        Write-Warning "Failed to download Fedora ISO. Check your internet connection."
        exit 1
    }
} else {
    Write-Output "[*] Fedora KDE Spin ISO already exists at $isoPath"
}

# Check if Grub2Win is installed
$grub2winPath = "$env:ProgramFiles\Grub2Win\grub2win.exe"
if (-Not (Test-Path $grub2winPath)) {
    Write-Output "[*] Grub2Win not found. Downloading and launching installer..."
    Start-Process "https://sourceforge.net/projects/grub2win/files/latest/download"
    Write-Output "Please install Grub2Win, then re-run this script."
    exit 0
} else {
    Write-Output "[*] Grub2Win is installed."
}

# Shrink C: partition by 150GB
Write-Output "[*] Shrinking C: partition by 150GB..."
try {
    $sizeToShrinkGB = 150
    $sizeToShrinkMB = $sizeToShrinkGB * 1024
    $supportedSize = Get-PartitionSupportedSize -DriveLetter C
    $newSize = $supportedSize.SizeMax - ($sizeToShrinkMB * 1MB)

    Resize-Partition -DriveLetter C -Size $newSize -ErrorAction Stop
    Write-Output "[*] Successfully shrunk C: partition."
} catch {
    Write-Warning "Failed to shrink C: partition. Make sure you have enough free space and run as Administrator."
    exit 1
}

# Create Grub2Win boot entry instructions file on Desktop
$entryGuidePath = Join-Path $env:USERPROFILE "Desktop\grub2win_fedora_entry.txt"
@"
--------------------------------------------
[ Add This Entry In Grub2Win Boot Menu ]
--------------------------------------------

Menu Name: Fedora KDE Live
Type:      ISO
ISO Path:  $isoPath
Kernel Params: inst.stage2=hd:LABEL=Fedora-KDE-Live-x86_64-42

Optional: inst.ks=http://yourserver/yourkickstart.ks

Then: Save and reboot into Fedora ISO
"@ | Out-File -Encoding UTF8 $entryGuidePath

Write-Output "[*] Created Grub2Win boot entry instructions at $entryGuidePath"

# Launch Grub2Win and open instructions
Write-Output "[*] Launching Grub2Win..."
Start-Process $grub2winPath

Write-Output "[*] Opening boot entry instructions..."
Start-Process notepad.exe $entryGuidePath

Write-Output "[>] Follow the instructions in Notepad to add the Fedora ISO boot entry in Grub2Win."
Write-Output "Once done, reboot your system to boot into Fedora Live."
