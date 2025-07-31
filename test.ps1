# Paths to scan for WebView2
$pathsToCheck = @(
    "$env:ProgramFiles\Microsoft\EdgeWebView\Application",
    "$env:ProgramFiles(x86)\Microsoft\EdgeWebView\Application",
    "$env:LocalAppData\Microsoft\EdgeWebView\Application"
)

$webviewFound = $false

Write-Host "Scanning for Microsoft Edge WebView2 Runtime..." -ForegroundColor Cyan

foreach ($basePath in $pathsToCheck) {
    if (Test-Path $basePath) {
        $exePaths = Get-ChildItem -Path $basePath -Recurse -Filter "msedgewebview2.exe" -ErrorAction SilentlyContinue
        if ($exePaths.Count -gt 0) {
            foreach ($exe in $exePaths) {
                Write-Host "WebView2 runtime found: $($exe.FullName)" -ForegroundColor Green
            }
            $webviewFound = $true
            break
        }
    }
}

if (-not $webviewFound) {
    Write-Host "WebView2 runtime NOT found in any of the expected paths." -ForegroundColor Red
    Write-Host "Download it from:" -ForegroundColor Yellow
    Write-Host "https://developer.microsoft.com/en-us/microsoft-edge/webview2/" -ForegroundColor Yellow
}

Write-Host "Scan complete." -ForegroundColor Cyan
