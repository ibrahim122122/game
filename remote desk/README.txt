UltraVNC One-time Setup (do once, requires Admin)
1. Run "install_and_configure.bat" as Administrator (right-click -> Run as administrator).
2. Follow the UltraVNC installer:
   - Choose "UltraVNC Server" and "Install as Service" (so it starts at boot).
   - Allow starting the server after install.
3. When prompted, set a strong VNC password and write it down.
4. The batch will add firewall rules limited to the detected local subnet.
5. After install, verify UltraVNC Server runs (tray icon) or check Services (uvnc_service).
