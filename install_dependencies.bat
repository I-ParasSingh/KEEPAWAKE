@echo off
cd /d "%~dp0"
echo ===============================================================
echo StayAwake - Automated Dependency Installer
echo ===============================================================
echo Launching terminal downloader script...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_dependencies.ps1"
echo.
echo Press any key to exit this window...
pause >nul
