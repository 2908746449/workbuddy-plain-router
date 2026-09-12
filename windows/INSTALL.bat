@echo off
setlocal
cd /d "%~dp0"
title WorkBuddy Plain Router Installer

echo ============================================================
echo  WorkBuddy Plain Router - Install
echo ============================================================
echo.
echo This installer will patch WorkBuddy prompt templates and set
echo ACC_PRODUCT_CONFIG_PATH for the current Windows user.
echo.

echo [1/2] Installing...
powershell -STA -NoProfile -ExecutionPolicy Bypass -File "%~dp0unlock-all-in-one.ps1"
set "EC=%ERRORLEVEL%"
echo.
echo [2/2] Verifying...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\verify-install.ps1"
echo.
echo Installer exit code: %EC%
echo If WorkBuddy was open, fully quit it and reopen a NEW task.
echo.
pause
exit /b %EC%
