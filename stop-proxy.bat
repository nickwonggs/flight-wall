@echo off
echo Stopping Flight Wall proxy...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8765 " ^| findstr "LISTENING"') do (
    taskkill /f /pid %%a >nul 2>&1
)
echo Done.
timeout /t 2 >nul
