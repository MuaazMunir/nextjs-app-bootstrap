@echo off
echo 🎬 ProEdit Studio - Windows Build Script
echo ==========================================

:: Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js first.
    pause
    exit /b 1
)

:: Check if npm is installed
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed. Please install npm first.
    pause
    exit /b 1
)

echo [INFO] Installing dependencies...
call npm install

echo [INFO] Building Next.js application...
call npm run build

echo [INFO] Exporting static files...
call npm run export

if %errorlevel% neq 0 (
    echo [ERROR] Next.js build failed!
    pause
    exit /b 1
)

echo [SUCCESS] Next.js build completed successfully!
echo.

echo What would you like to build?
echo 1) Windows Installer (.exe)
echo 2) Windows Portable (.exe)
echo 3) Android APK (Debug)
echo 4) Android APK (Release)
echo 5) All platforms
echo 6) Exit

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto build_installer
if "%choice%"=="2" goto build_portable
if "%choice%"=="3" goto build_android_debug
if "%choice%"=="4" goto build_android_release
if "%choice%"=="5" goto build_all
if "%choice%"=="6" goto exit_script
goto invalid_choice

:build_installer
echo [INFO] Building Windows Installer...
call npx electron-builder --win --config.win.target=nsis
if %errorlevel% equ 0 (
    echo [SUCCESS] Windows Installer built successfully!
    echo [INFO] Output: dist\ProEdit Studio Setup 1.0.0.exe
) else (
    echo [ERROR] Windows Installer build failed!
)
goto end_script

:build_portable
echo [INFO] Building Windows Portable...
call npx electron-builder --win --config.win.target=portable
if %errorlevel% equ 0 (
    echo [SUCCESS] Windows Portable built successfully!
    echo [INFO] Output: dist\ProEdit Studio 1.0.0.exe
) else (
    echo [ERROR] Windows Portable build failed!
)
goto end_script

:build_android_debug
echo [INFO] Building Android APK (Debug)...
call npx cap add android 2>nul
call npx cap sync
call npx cap build android
if %errorlevel% equ 0 (
    echo [SUCCESS] Android Debug APK built successfully!
    echo [INFO] Output: android\app\build\outputs\apk\debug\app-debug.apk
) else (
    echo [ERROR] Android APK build failed!
)
goto end_script

:build_android_release
echo [INFO] Building Android APK (Release)...
echo [WARNING] Make sure you have generated a keystore file first!
call npx cap add android 2>nul
call npx cap sync
call npx cap build android --prod
if %errorlevel% equ 0 (
    echo [SUCCESS] Android Release APK built successfully!
    echo [INFO] Output: android\app\build\outputs\apk\release\app-release.apk
) else (
    echo [ERROR] Android Release APK build failed!
)
goto end_script

:build_all
echo [INFO] Building all platforms...
echo [INFO] Building Windows Installer...
call npx electron-builder --win --config.win.target=nsis
echo [INFO] Building Windows Portable...
call npx electron-builder --win --config.win.target=portable
echo [INFO] Building Android APK...
call npx cap add android 2>nul
call npx cap sync
call npx cap build android
echo [SUCCESS] All builds completed!
goto end_script

:invalid_choice
echo [ERROR] Invalid choice. Please run the script again.
pause
exit /b 1

:exit_script
echo [INFO] Exiting...
exit /b 0

:end_script
echo.
echo [SUCCESS] Build process completed!
echo [INFO] Check the following directories for output files:
echo [INFO] - Windows: .\dist\
echo [INFO] - Android: .\android\app\build\outputs\apk\
echo [INFO] - Web: .\out\
echo.
echo [INFO] To run the application:
echo [INFO] - Windows: Double-click the .exe file
echo [INFO] - Android: Install the .apk file on your device
echo [INFO] - Web: Serve the .\out\ directory with a web server
echo.
pause
