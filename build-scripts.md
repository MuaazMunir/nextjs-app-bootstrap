# ProEdit Studio - Build & Deployment Guide

## Prerequisites

### For Windows Installer:
```bash
npm install -g electron electron-builder
npm install --save-dev electron electron-builder electron-is-dev concurrently wait-on
```

### For Android APK:
```bash
npm install -g @capacitor/cli @capacitor/core @capacitor/android
npm install --save @capacitor/app @capacitor/haptics @capacitor/keyboard @capacitor/status-bar
```

## Build Commands

### 1. Windows Installer (.exe)
```bash
# Install dependencies
npm install

# Build for Windows (creates installer)
npm run build
npm run export
npx electron-builder --win

# Output: dist/ProEdit Studio Setup 1.0.0.exe
```

### 2. Windows Portable (.exe)
```bash
# Build portable version
npm run build
npm run export
npx electron-builder --win --config.win.target=portable

# Output: dist/ProEdit Studio 1.0.0.exe (portable)
```

### 3. Android APK
```bash
# Install Capacitor and build
npm install
npm run build
npm run export

# Initialize Capacitor (first time only)
npx cap add android

# Build APK
npx cap sync
npx cap build android

# Output: android/app/build/outputs/apk/debug/app-debug.apk
```

### 4. Android Release APK (Signed)
```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore android/app/proedit-studio.keystore -alias proedit-studio -keyalg RSA -keysize 2048 -validity 10000

# Build release APK
npm run build
npm run export
npx cap sync
npx cap build android --prod

# Output: android/app/build/outputs/apk/release/app-release.apk
```

## Development Commands

### Run in Development Mode
```bash
# Web development
npm run dev

# Electron development
npm run electron-dev

# Android development
npm run capacitor-run
```

## File Structure After Build

```
dist/
├── ProEdit Studio Setup 1.0.0.exe    # Windows Installer
├── ProEdit Studio 1.0.0.exe          # Windows Portable
└── latest.yml                         # Update manifest

android/app/build/outputs/apk/
├── debug/app-debug.apk               # Debug APK
└── release/app-release.apk           # Release APK (signed)

out/                                  # Static export for web
├── index.html
├── _next/
└── video-editor/
```

## Distribution

### Windows:
- **Installer**: `ProEdit Studio Setup 1.0.0.exe` - Full installer with auto-updater
- **Portable**: `ProEdit Studio 1.0.0.exe` - Standalone executable

### Android:
- **Debug APK**: For testing and development
- **Release APK**: For distribution (requires signing)

## Auto-Updates

The Windows version includes auto-update functionality. Updates are checked automatically and can be distributed via GitHub releases.

## Code Signing (Optional)

### Windows:
```bash
# Sign the executable (requires certificate)
npx electron-builder --win --publish=never --config.win.certificateFile=cert.p12 --config.win.certificatePassword=password
```

### Android:
```bash
# Sign APK with keystore
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore proedit-studio.keystore app-release-unsigned.apk proedit-studio
zipalign -v 4 app-release-unsigned.apk app-release.apk
```

## Troubleshooting

### Common Issues:

1. **FFmpeg not found**: Ensure FFmpeg.wasm is properly bundled
2. **Android build fails**: Check Android SDK and Java versions
3. **Windows signing fails**: Verify certificate and password
4. **Large bundle size**: Use webpack-bundle-analyzer to optimize

### Build Optimization:
- Enable tree shaking in webpack
- Compress assets with gzip
- Use dynamic imports for large libraries
- Optimize images and videos
