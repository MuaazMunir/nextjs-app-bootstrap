# 🎬 ProEdit Studio - Deployment Guide

## Overview

ProEdit Studio is now ready for cross-platform deployment with support for:
- **Windows**: Standalone installer (.exe) and portable executable
- **Android**: APK for mobile devices
- **Web**: Static website deployment

## Quick Start

### For Windows Users:
```bash
# Double-click build.bat or run in Command Prompt:
build.bat
```

### For Linux/Mac Users:
```bash
# Make executable and run:
chmod +x build.sh
./build.sh
```

## Prerequisites

### Required Software:
1. **Node.js 18+** - [Download](https://nodejs.org/)
2. **npm** (comes with Node.js)
3. **Git** (optional) - [Download](https://git-scm.com/)

### For Windows Builds:
- **Electron Builder** (auto-installed)
- **Windows SDK** (for signing - optional)

### For Android Builds:
- **Android Studio** - [Download](https://developer.android.com/studio)
- **Java JDK 11+** - [Download](https://adoptium.net/)
- **Android SDK** (comes with Android Studio)
- **Capacitor CLI** (auto-installed)

## Build Commands

### 1. Windows Installer
Creates a full installer with auto-updater support:
```bash
npm run build
npm run export
npx electron-builder --win --config.win.target=nsis
```
**Output**: `dist/ProEdit Studio Setup 1.0.0.exe`

### 2. Windows Portable
Creates a standalone executable:
```bash
npm run build
npm run export
npx electron-builder --win --config.win.target=portable
```
**Output**: `dist/ProEdit Studio 1.0.0.exe`

### 3. Android APK (Debug)
For testing and development:
```bash
npm run build
npm run export
npx cap add android
npx cap sync
npx cap build android
```
**Output**: `android/app/build/outputs/apk/debug/app-debug.apk`

### 4. Android APK (Release)
For distribution (requires signing):
```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore android/app/proedit-studio.keystore -alias proedit-studio -keyalg RSA -keysize 2048 -validity 10000

# Build release APK
npm run build
npm run export
npx cap sync
npx cap build android --prod
```
**Output**: `android/app/build/outputs/apk/release/app-release.apk`

## File Structure After Build

```
📁 ProEdit Studio/
├── 📁 dist/                                    # Windows builds
│   ├── ProEdit Studio Setup 1.0.0.exe         # Windows Installer
│   ├── ProEdit Studio 1.0.0.exe               # Windows Portable
│   └── latest.yml                              # Auto-update manifest
├── 📁 android/app/build/outputs/apk/          # Android builds
│   ├── 📁 debug/
│   │   └── app-debug.apk                       # Debug APK
│   └── 📁 release/
│       └── app-release.apk                     # Release APK
├── 📁 out/                                     # Web build
│   ├── index.html
│   ├── 📁 _next/
│   └── �� video-editor/
└── 📁 build-tools/                             # Build scripts
    ├── build.sh                                # Linux/Mac build script
    ├── build.bat                               # Windows build script
    └── build-scripts.md                        # Detailed instructions
```

## Distribution

### Windows Distribution:
1. **Installer Version**: 
   - Full installation with desktop shortcuts
   - Auto-updater support
   - Uninstaller included
   - Recommended for most users

2. **Portable Version**:
   - Single executable file
   - No installation required
   - Perfect for USB drives
   - Ideal for testing

### Android Distribution:
1. **Debug APK**:
   - For testing and development
   - Larger file size
   - Debug information included

2. **Release APK**:
   - Optimized for production
   - Smaller file size
   - Requires code signing
   - Ready for Google Play Store

### Web Distribution:
- Static files in `out/` directory
- Can be hosted on any web server
- CDN-friendly
- Progressive Web App (PWA) ready

## Advanced Configuration

### Code Signing (Windows)
```bash
# With certificate file
npx electron-builder --win --publish=never \
  --config.win.certificateFile=cert.p12 \
  --config.win.certificatePassword=yourpassword
```

### Android Signing
```bash
# Sign APK manually
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore proedit-studio.keystore \
  app-release-unsigned.apk proedit-studio

# Align APK
zipalign -v 4 app-release-unsigned.apk app-release.apk
```

### Auto-Updates (Windows)
The Windows version includes automatic update checking. Updates are distributed via GitHub releases:

1. Create a GitHub release with the new version
2. Upload the installer and `latest.yml`
3. Users will be notified of updates automatically

## Performance Optimization

### Bundle Size Optimization:
- Tree shaking enabled
- Dynamic imports for large libraries
- Compressed assets
- Optimized images

### Runtime Performance:
- Video compression to 1080p for smooth editing
- WebAssembly for video processing
- Efficient memory management
- Hardware acceleration support

## Troubleshooting

### Common Build Issues:

1. **"Node.js not found"**
   - Install Node.js 18+ from nodejs.org
   - Restart terminal after installation

2. **"Android build failed"**
   - Install Android Studio
   - Set ANDROID_HOME environment variable
   - Accept Android SDK licenses

3. **"Electron build failed"**
   - Clear node_modules: `rm -rf node_modules && npm install`
   - Update Electron: `npm update electron`

4. **"FFmpeg not working"**
   - FFmpeg.wasm is bundled automatically
   - Check browser compatibility
   - Ensure HTTPS for production

### Build Optimization:
```bash
# Clear cache and rebuild
npm run clean
npm install
npm run build

# Analyze bundle size
npm install -g webpack-bundle-analyzer
npx webpack-bundle-analyzer out/_next/static/chunks/*.js
```

## System Requirements

### Development:
- **OS**: Windows 10+, macOS 10.15+, Ubuntu 18.04+
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 5GB free space
- **Node.js**: 18.0.0 or higher

### Windows App:
- **OS**: Windows 10 (64-bit) or newer
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 2GB free space
- **Graphics**: DirectX 11 compatible

### Android App:
- **OS**: Android 7.0 (API level 24) or newer
- **RAM**: 3GB minimum, 4GB recommended
- **Storage**: 1GB free space
- **Architecture**: ARM64 or x86_64

## Support & Updates

### Getting Help:
- Check the troubleshooting section above
- Review build logs for specific errors
- Ensure all prerequisites are installed
- Try building on a clean environment

### Version Updates:
- Windows: Automatic updates via built-in updater
- Android: Manual APK installation or app store updates
- Web: Automatic updates when hosted

## Security Considerations

### Code Signing:
- Windows executables should be signed for trust
- Android APKs must be signed for distribution
- Use proper certificates from trusted authorities

### Permissions:
- Windows: File system access for video processing
- Android: Storage and camera permissions
- Web: Local storage and media access

---

## Ready to Deploy! 🚀

Your ProEdit Studio is now ready for professional deployment across Windows and Android platforms. The automated build scripts make it easy to create installers and APKs with just a few commands.

**Quick Deploy Commands:**
- Windows: `build.bat` (double-click)
- Linux/Mac: `./build.sh`
- Manual: Follow the build commands above

Happy editing! 🎬✨
