param(
    [switch]$NoFrontend,
    [switch]$NoBackend
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Start-WindowedProcess {
    param(
        [Parameter(Mandatory = $true)] [string]$Title,
        [Parameter(Mandatory = $true)] [string]$Command,
        [Parameter(Mandatory = $true)] [string]$WorkingDirectory
    )

    Start-Process powershell -ArgumentList @(
        '-NoExit',
        '-Command',
        $Command
    ) -WorkingDirectory $WorkingDirectory -WindowStyle Normal | Out-Null

    Write-Host "Started $Title" -ForegroundColor Green
}

if (-not $NoBackend) {
    $backendCommand = @"
Set-Location '$repoRoot'
. '.\.venv\Scripts\Activate.ps1'
python -m uvicorn api.main:app --reload --port 8000
"@

    Start-WindowedProcess -Title 'Backend API' -Command $backendCommand -WorkingDirectory $repoRoot
}

if (-not $NoFrontend) {
    $frontendCommand = @"
Set-Location '$repoRoot\frontend'
npx vite --host 127.0.0.1 --strictPort
"@

    Start-WindowedProcess -Title 'Frontend App' -Command $frontendCommand -WorkingDirectory $repoRoot
}

Write-Host ""
Write-Host "Open the app here:" -ForegroundColor Cyan
Write-Host "  http://127.0.0.1:5173" -ForegroundColor Cyan
Write-Host "  http://127.0.0.1:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use -NoBackend or -NoFrontend to start only one side." -ForegroundColor Yellow
