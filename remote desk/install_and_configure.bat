@echo off
:: install_and_configure.bat -- run as admin to install UltraVNC server as a service from USB

openfiles >nul 2>&1
if %errorlevel% neq 0 (
  echo Requesting administrator privileges...
  powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo Running with Administrator privileges.
setlocal

set USBDRIVE=%~d0
set INSTALLER=%USBDRIVE%\VNC-Setup\ultravnc-setup.exe

if not exist "%INSTALLER%" (
  echo ERROR: Cannot find installer at %INSTALLER%
  pause
  exit /b 1
)

echo Found installer: %INSTALLER%
echo Launching UltraVNC installer...
echo ====================================
echo Please, when the graphical installer opens:
echo  - Choose "UltraVNC Server"
echo  - Choose "Install as a Service"
echo  - Choose "Start server after install"
echo  - Set a password when prompted
echo ====================================
pause

start "" /wait "%INSTALLER%"

echo Installer finished. Now configuring firewall...

for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /R "IPv4 Address"') do (
  for /f "tokens=* delims= " %%B in ("%%A") do set LOCALIP=%%B & goto :gotIP
)
:gotIP
if "%LOCALIP%"=="" (
  echo Could not detect local IPv4 address automatically.
) else (
  echo Detected local IP: %LOCALIP%
  for /f "tokens=1-4 delims=." %%i in ("%LOCALIP%") do set SUBNET=%%i.%%j.%%k.0
  echo Allowing subnet %SUBNET%/24 ...
  netsh advfirewall firewall add rule name="UltraVNC allow subnet 5900" dir=in action=allow protocol=TCP localport=5900 remoteip=%SUBNET%
  netsh advfirewall firewall add rule name="UltraVNC allow subnet 5800" dir=in action=allow protocol=TCP localport=5800 remoteip=%SUBNET%
)

sc query uvnc_service >nul 2>&1
if %errorlevel%==0 (
  echo Service found, starting...
  net start uvnc_service >nul 2>&1
  sc query uvnc_service
) else (
  echo Service not found. Open services.msc to check manually.
)

echo.
echo Done!
echo After installation, UltraVNC Server will start automatically at every boot.
echo You can now connect from your main PC using the target's IP on port 5900.
pause
endlocal
exit /b 0
