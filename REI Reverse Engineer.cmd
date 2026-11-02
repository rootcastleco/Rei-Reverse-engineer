@echo off
powershell.exe -NoProfile -File "%~dp0scripts\run_desktop.ps1"
if errorlevel 1 pause
