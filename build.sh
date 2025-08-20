#!/bin/bash

echo "🎬 ProEdit Studio - Automated Build Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

print_status "Installing dependencies..."
npm install

# Build the Next.js application
print_status "Building Next.js application..."
npm run build

# Export static files
print_status "Exporting static files..."
npm run export

if [ $? -eq 0 ]; then
    print_success "Next.js build completed successfully!"
else
    print_error "Next.js build failed!"
    exit 1
fi

# Ask user what to build
echo ""
echo "What would you like to build?"
echo "1) Windows Installer (.exe)"
echo "2) Windows Portable (.exe)"
echo "3) Android APK (Debug)"
echo "4) Android APK (Release)"
echo "5) All platforms"
echo "6) Exit"

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        print_status "Building Windows Installer..."
        if command -v electron-builder &> /dev/null; then
            npx electron-builder --win --config.win.target=nsis
            if [ $? -eq 0 ]; then
                print_success "Windows Installer built successfully!"
                print_status "Output: dist/ProEdit Studio Setup 1.0.0.exe"
            else
                print_error "Windows Installer build failed!"
            fi
        else
            print_error "electron-builder not found. Installing..."
            npm install -g electron-builder
            npx electron-builder --win --config.win.target=nsis
        fi
        ;;
    2)
        print_status "Building Windows Portable..."
        if command -v electron-builder &> /dev/null; then
            npx electron-builder --win --config.win.target=portable
            if [ $? -eq 0 ]; then
                print_success "Windows Portable built successfully!"
                print_status "Output: dist/ProEdit Studio 1.0.0.exe"
            else
                print_error "Windows Portable build failed!"
            fi
        else
            print_error "electron-builder not found. Installing..."
            npm install -g electron-builder
            npx electron-builder --win --config.win.target=portable
        fi
        ;;
    3)
        print_status "Building Android APK (Debug)..."
        if command -v cap &> /dev/null; then
            npx cap add android 2>/dev/null || true
            npx cap sync
            npx cap build android
            if [ $? -eq 0 ]; then
                print_success "Android Debug APK built successfully!"
                print_status "Output: android/app/build/outputs/apk/debug/app-debug.apk"
            else
                print_error "Android APK build failed!"
            fi
        else
            print_error "Capacitor CLI not found. Installing..."
            npm install -g @capacitor/cli
            npx cap add android
            npx cap sync
            npx cap build android
        fi
        ;;
    4)
        print_status "Building Android APK (Release)..."
        print_warning "Make sure you have generated a keystore file first!"
        if command -v cap &> /dev/null; then
            npx cap add android 2>/dev/null || true
            npx cap sync
            npx cap build android --prod
            if [ $? -eq 0 ]; then
                print_success "Android Release APK built successfully!"
                print_status "Output: android/app/build/outputs/apk/release/app-release.apk"
            else
                print_error "Android Release APK build failed!"
            fi
        else
            print_error "Capacitor CLI not found. Installing..."
            npm install -g @capacitor/cli
            npx cap add android
            npx cap sync
            npx cap build android --prod
        fi
        ;;
    5)
        print_status "Building all platforms..."
        
        # Windows Installer
        print_status "Building Windows Installer..."
        npx electron-builder --win --config.win.target=nsis
        
        # Windows Portable
        print_status "Building Windows Portable..."
        npx electron-builder --win --config.win.target=portable
        
        # Android APK
        print_status "Building Android APK..."
        npx cap add android 2>/dev/null || true
        npx cap sync
        npx cap build android
        
        print_success "All builds completed!"
        ;;
    6)
        print_status "Exiting..."
        exit 0
        ;;
    *)
        print_error "Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
print_success "Build process completed!"
print_status "Check the following directories for output files:"
print_status "- Windows: ./dist/"
print_status "- Android: ./android/app/build/outputs/apk/"
print_status "- Web: ./out/"

echo ""
print_status "To run the application:"
print_status "- Windows: Double-click the .exe file"
print_status "- Android: Install the .apk file on your device"
print_status "- Web: Serve the ./out/ directory with a web server"
