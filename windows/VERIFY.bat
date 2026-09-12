@echo off
setlocal
cd /d "%~dp0"
title WorkBuddy Plain Router Verify
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\verify-install.ps1"
echo.
pause
