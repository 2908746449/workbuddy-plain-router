@echo off
setlocal
cd /d "%~dp0"
title WorkBuddy Plain Router Restore
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\restore-workbuddy.ps1"
echo.
pause
