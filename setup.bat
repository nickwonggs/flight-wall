@echo off
setlocal
title Flight Wall Setup

echo.
echo  ==============================
echo    Flight Wall - Setup Wizard
echo  ==============================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Install from https://python.org then re-run this.
    pause
    exit /b 1
)
echo [OK] Python found.

REM Collect credentials
echo.
echo Enter your OpenSky Network credentials.
echo (Free account at https://opensky-network.org - optional but recommended)
echo.
set /p OSUSER="OpenSky username (leave blank to skip): "
if "%OSUSER%"=="" (
    echo Skipping credentials - anonymous mode only.
    goto :AUTOSTART
)
set /p OSPASS="OpenSky password: "

REM Write proxy-config.txt
echo %OSUSER%> "%~dp0proxy-config.txt"
echo %OSPASS%>> "%~dp0proxy-config.txt"
echo.
echo [OK] Saved credentials to proxy-config.txt

:AUTOSTART
echo.
set /p STARTUP="Auto-start proxy on Windows login? (y/n): "
if /i not "%STARTUP%"=="y" goto :DONE

REM Add to Windows Startup folder via Task Scheduler
schtasks /create /tn "FlightWallProxy" /tr "wscript.exe \"%~dp0start-proxy.vbs\"" /sc onlogon /f >nul 2>&1
if errorlevel 1 (
    echo [WARN] Could not create scheduled task (try running as Administrator).
    echo        Alternatively, copy start-proxy.vbs to your Startup folder manually:
    echo        shell:startup
) else (
    echo [OK] Proxy will auto-start at login via Task Scheduler.
)

:DONE
echo.
echo Setup complete!
echo.
echo Next steps:
echo   1. Open flightwall.html in your browser
echo   2. Click the gear icon (top-right)
if not "%OSUSER%"=="" (
    echo   3. Set Proxy URL to: http://localhost:8765
    echo   4. Double-click start-proxy.vbs to start the proxy now
) else (
    echo   3. Enter credentials when you have an OpenSky account
)
echo.
pause
