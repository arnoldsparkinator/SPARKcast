# backup.ps1 — save SPARKcast to GitHub in one step
# Usage:  .\backup.ps1 "optional commit message"
# If you omit the message, it uses the current date/time.

param(
    [string]$Message = ""
)

# Locate git (works even if PATH wasn't refreshed after install)
$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not $git) {
    $git = @(
        "C:\Program Files\Git\cmd\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $git) {
    Write-Host "git not found. Install Git for Windows first." -ForegroundColor Red
    exit 1
}

if (-not $Message) { $Message = "Backup " + (Get-Date -Format "yyyy-MM-dd HH:mm") }

& $git add -A
& $git commit -m $Message
& $git push

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBackup complete: $Message" -ForegroundColor Green
} else {
    Write-Host "`nPush may have failed - check the output above (are you logged in?)." -ForegroundColor Yellow
}
