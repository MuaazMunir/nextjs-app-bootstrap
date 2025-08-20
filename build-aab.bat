@echo off
echo 🎬 ProEdit Studio - Android App Bundle (AAB) Build
echo =================================================

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

echo [INFO] Exporting static files for Capacitor...
call npm run export

if %errorlevel% neq 0 (
    echo [ERROR] Next.js build failed!
    pause
    exit /b 1
)

echo [SUCCESS] Next.js build completed successfully!

echo [INFO] Setting up Android platform...
call npx cap add android 2>nul

echo [INFO] Syncing Capacitor files...
call npx cap sync android

if %errorlevel% neq 0 (
    echo [ERROR] Capacitor sync failed!
    pause
    exit /b 1
)

:: Check for keystore
if not exist "android\app\proedit-studio.keystore" (
    echo [WARNING] Keystore not found. Creating new keystore...
    echo Please provide the following information for your keystore:
    
    set /p USER_NAME="Enter your name: "
    set /p ORG_NAME="Enter your organization: "
    set /p CITY="Enter your city: "
    set /p STATE="Enter your state/province: "
    set /p COUNTRY="Enter your country code (e.g., US): "
    
    echo Creating keystore...
    keytool -genkey -v -keystore "android\app\proedit-studio.keystore" -alias proedit-studio -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=%USER_NAME%, OU=%ORG_NAME%, O=%ORG_NAME%, L=%CITY%, S=%STATE%, C=%COUNTRY%"
    
    if %errorlevel% equ 0 (
        echo [SUCCESS] Keystore created successfully!
    ) else (
        echo [ERROR] Failed to create keystore!
        pause
        exit /b 1
    )
) else (
    echo [INFO] Using existing keystore: android\app\proedit-studio.keystore
)

echo [INFO] Configuring Android build for AAB...

:: Create gradle.properties for signing
echo. >> android\gradle.properties
echo # Signing configuration for release builds >> android\gradle.properties
echo PROEDIT_RELEASE_STORE_FILE=proedit-studio.keystore >> android\gradle.properties
echo PROEDIT_RELEASE_KEY_ALIAS=proedit-studio >> android\gradle.properties
echo PROEDIT_RELEASE_STORE_PASSWORD= >> android\gradle.properties
echo PROEDIT_RELEASE_KEY_PASSWORD= >> android\gradle.properties

echo [WARNING] Please edit android\gradle.properties and add your keystore passwords:
echo PROEDIT_RELEASE_STORE_PASSWORD=your_keystore_password
echo PROEDIT_RELEASE_KEY_PASSWORD=your_key_password
echo.
pause

echo [INFO] Building Android App Bundle (AAB)...
echo This may take several minutes...

cd android
call gradlew bundleRelease

if %errorlevel% equ 0 (
    echo [SUCCESS] Android App Bundle built successfully!
    
    if exist "app\build\outputs\bundle\release\app-release.aab" (
        echo [SUCCESS] AAB file created: android\app\build\outputs\bundle\release\app-release.aab
        
        copy "app\build\outputs\bundle\release\app-release.aab" "..\proedit-studio-release.aab"
        echo [INFO] AAB copied to: proedit-studio-release.aab
        
        echo.
        echo [SUCCESS] 🎉 Android App Bundle ready for Google Play Console!
        echo [INFO] Upload file: proedit-studio-release.aab
        echo.
        echo Next steps:
        echo 1. Go to Google Play Console (play.google.com/console)
        echo 2. Select your app or create a new one
        echo 3. Go to Release ^> Production
        echo 4. Click 'Create new release'
        echo 5. Upload the proedit-studio-release.aab file
        echo 6. Fill in release notes and publish
        
    ) else (
        echo [ERROR] AAB file not found at expected location!
        pause
        exit /b 1
    )
) else (
    echo [ERROR] Android App Bundle build failed!
    echo Check the build logs above for errors
    pause
    exit /b 1
)

cd ..

echo.
echo [SUCCESS] Build process completed!
pause
