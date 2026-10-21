# ==============================================================================
# StayAwake - Automated Terminal Dependency Downloader & Installer
# ==============================================================================
# This script:
# 1. Checks if Python 3 is already available in PATH.
# 2. If missing, automatically downloads official Python from python.org using curl/Invoke-WebRequest.
# 3. Installs Python silently in user-space (InstallAllUsers=0, PrependPath=1) -> ZERO ADMIN RIGHTS NEEDED.
# 4. Refreshes the environment PATH in the current session.
# 5. Verifies Microsoft Edge / Google Chrome for standalone App Mode.
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Text)
    Write-Host "`n[+] $Text" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "    [OK] $Text" -ForegroundColor Green
}

function Write-WarningMsg {
    param([string]$Text)
    Write-Host "    [!] $Text" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Text)
    Write-Host "    [ERROR] $Text" -ForegroundColor Red
}

Write-Host "=================================================================" -ForegroundColor Magenta
Write-Host "          StayAwake - Terminal Dependency Downloader            " -ForegroundColor White
Write-Host "=================================================================" -ForegroundColor Magenta

# 1. Check Python
Write-Step "Checking for existing Python installation..."
$pythonFound = $false

try {
    $pyVer = & python --version 2>&1
    if ($LASTEXITCODE -eq 0 -and $pyVer -match "Python\s+3") {
        Write-Success "Python is already installed: $pyVer"
        $pythonFound = $true
    }
} catch {
    $pythonFound = $false
}

# Also check common local appdata user locations
if (-not $pythonFound) {
    $localPyPaths = @(
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
        "$env:LOCALAPPDATA\Python\pythoncore-3.14-64\python.exe"
    )
    foreach ($path in $localPyPaths) {
        if (Test-Path $path) {
            Write-Success "Found Python at: $path"
            $pythonFound = $true
            # Add to current session path
            $pyDir = Split-Path $path
            $env:Path = "$pyDir;$pyDir\Scripts;$env:Path"
            break
        }
    }
}

# 2. Download and install Python if not found
if (-not $pythonFound) {
    Write-Step "Python was not detected. Initiating terminal download..."
    
    $pythonVersion = "3.12.9"
    $installerUrl = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe"
    $installerPath = "$env:TEMP\python-$pythonVersion-installer.exe"

    Write-Host "    Source: $installerUrl" -ForegroundColor Gray
    Write-Host "    Target: $installerPath" -ForegroundColor Gray

    # Try curl first (fastest and handles redirects natively)
    $downloadSuccess = $false
    if (Get-Command "curl.exe" -ErrorAction SilentlyContinue) {
        Write-Host "    Downloading via curl.exe..." -ForegroundColor Gray
        & curl.exe -L -o $installerPath $installerUrl --progress-bar
        if ($LASTEXITCODE -eq 0 -and (Test-Path $installerPath)) {
            $downloadSuccess = $true
        }
    }

    # Fallback to Invoke-WebRequest if curl fails
    if (-not $downloadSuccess) {
        Write-Host "    Downloading via PowerShell Invoke-WebRequest..." -ForegroundColor Gray
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
        if (Test-Path $installerPath) {
            $downloadSuccess = $true
        }
    }

    if (-not $downloadSuccess) {
        Write-ErrorMsg "Failed to download Python installer. Please check your internet connection."
        exit 1
    }

    Write-Success "Download completed successfully."

    # 3. Silent user-space installation (NO ADMIN REQUIRED)
    Write-Step "Installing Python silently in user-space (no administrator rights needed)..."
    Write-Host "    Running: $installerPath /quiet InstallAllUsers=0 PrependPath=1 Include_test=0" -ForegroundColor Gray

    $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1", "Include_test=0", "SimpleInstall=1" -Wait -PassThru

    # Cleanup installer
    Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue

    if ($installProcess.ExitCode -eq 0 -or $installProcess.ExitCode -eq 3010) {
        Write-Success "Python installed successfully!"
    } else {
        Write-WarningMsg "Installer exited with code: $($installProcess.ExitCode). Verifying path..."
    }

    # Refresh current environment PATH from registry
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $env:Path = "$userPath;$machinePath"

    # Verify newly installed Python
    try {
        $pyVerNew = & python --version 2>&1
        Write-Success "Verified: $pyVerNew is now active in this terminal."
    } catch {
        Write-WarningMsg "Python installed, but terminal session needs to detect it. Restarting CMD/PowerShell will make it permanent."
    }
}

# 4. Check Browser Engine (Edge / Chrome)
Write-Step "Checking for Chromium browser (Microsoft Edge / Google Chrome)..."
$browserFound = $false
$edgePaths = @(
    "$env:ProgramFiles (x86)\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
)
$chromePaths = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles (x86)\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)

foreach ($bPath in ($edgePaths + $chromePaths)) {
    if (Test-Path $bPath) {
        Write-Success "Found compatible browser: $bPath"
        $browserFound = $true
        break
    }
}

if (-not $browserFound) {
    Write-WarningMsg "Neither Edge nor Chrome was found in standard locations. The app will open in your default browser."
}

# 5. Ready Summary
Write-Host "`n=================================================================" -ForegroundColor Magenta
Write-Host "               All Dependencies Are Ready!                      " -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Magenta
Write-Host "You can now run StayAwake immediately using either method:" -ForegroundColor White
Write-Host "  1. Double-click: Start-KeepAwake.bat" -ForegroundColor Cyan
Write-Host "  2. Terminal:     python server.py" -ForegroundColor Cyan
Write-Host "=================================================================`n" -ForegroundColor Magenta
