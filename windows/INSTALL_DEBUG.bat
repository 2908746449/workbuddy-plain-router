@echo off
setlocal
cd /d "%~dp0"
title WorkBuddy Plain Router Installer DEBUG

echo ============================================================
echo  WorkBuddy Plain Router - Debug Install
echo  Logs: install-stdout.log / install-stderr.log
echo ============================================================
echo.
if exist "%~dp0install-stdout.log" del "%~dp0install-stdout.log"
if exist "%~dp0install-stderr.log" del "%~dp0install-stderr.log"

echo [ENV] Date: %DATE% %TIME% > "%~dp0install-stdout.log"
echo [ENV] CurrentDir: %CD% >> "%~dp0install-stdout.log"
echo [ENV] PowerShell version: >> "%~dp0install-stdout.log"
powershell -NoProfile -Command "$PSVersionTable.PSVersion.ToString()" >> "%~dp0install-stdout.log" 2>&1

echo [RUN] unlock-all-in-one.ps1 >> "%~dp0install-stdout.log"
powershell -STA -NoProfile -ExecutionPolicy Bypass -File "%~dp0unlock-all-in-one.ps1" >> "%~dp0install-stdout.log" 2>> "%~dp0install-stderr.log"
set "EC=%ERRORLEVEL%"
echo [RUN] installer exit code: %EC% >> "%~dp0install-stdout.log"

echo [RUN] verify-install.ps1 >> "%~dp0install-stdout.log"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\verify-install.ps1" >> "%~dp0install-stdout.log" 2>> "%~dp0install-stderr.log"
echo.
echo Done. ExitCode: %EC%
echo Check install-stdout.log and install-stderr.log in this folder.
echo.
pause
exit /b %EC%
