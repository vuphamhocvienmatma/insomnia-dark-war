@echo off
cd /d "%~dp0"
start "" "http://localhost:8000"
dotnet serve -p 8000
pause