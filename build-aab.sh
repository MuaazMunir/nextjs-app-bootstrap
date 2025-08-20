#!/bin/bash

echo "🎬 ProEdit Studio - Android App Bundle (AAB) Build"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js first."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

# Install dependencies
print_status "Installing dependencies..."
npm install

# Build Next.js application
print_status "Building Next.js application..."
npm run build

# Export static files
print_status "Exporting static files for Capacitor..."
npm run export

if [ $? -ne 0 ]; then
    print_error "Next.js build failed!"
    exit 1
fi

print_success "Next.js build completed successfully!"

# Check if Capacitor is installed
if ! command -v cap &> /dev/null; then
    print_warning "Capacitor CLI not found. Installing..."
    npm install -g @capacitor/cli
fi

# Initialize Android platform if not exists
print_status "Setting up Android platform..."
npx cap add android 2>/dev/null || print_warning "Android platform already exists"

# Sync Capacitor
print_status "Syncing Capacitor files..."
npx cap sync android

if [ $? -ne 0 ]; then
    print_error "Capacitor sync failed!"
    exit 1
fi

# Check for keystore
KEYSTORE_PATH="android/app/proedit-studio.keystore"
if [ ! -f "$KEYSTORE_PATH" ]; then
    print_warning "Keystore not found. Creating new keystore..."
    print_status "Please provide the following information for your keystore:"
    
    read -p "Enter your name: " USER_NAME
    read -p "Enter your organization: " ORG_NAME
    read -p "Enter your city: " CITY
    read -p "Enter your state/province: " STATE
    read -p "Enter your country code (e.g., US): " COUNTRY
    read -s -p "Enter keystore password: " KEYSTORE_PASSWORD
    echo
    read -s -p "Confirm keystore password: " KEYSTORE_PASSWORD_CONFIRM
    echo
    
    if [ "$KEYSTORE_PASSWORD" != "$KEYSTORE_PASSWORD_CONFIRM" ]; then
        print_error "Passwords do not match!"
        exit 1
    fi
    
    # Create keystore
    keytool -genkey -v -keystore "$KEYSTORE_PATH" \
        -alias proedit-studio \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=$USER_NAME, OU=$ORG_NAME, O=$ORG_NAME, L=$CITY, S=$STATE, C=$COUNTRY" \
        -storepass "$KEYSTORE_PASSWORD" \
        -keypass "$KEYSTORE_PASSWORD"
    
    if [ $? -eq 0 ]; then
        print_success "Keystore created successfully!"
    else
        print_error "Failed to create keystore!"
        exit 1
    fi
else
    print_status "Using existing keystore: $KEYSTORE_PATH"
fi

# Update build.gradle for AAB
print_status "Configuring Android build for AAB..."

# Create signing config in build.gradle
GRADLE_FILE="android/app/build.gradle"
if [ -f "$GRADLE_FILE" ]; then
    # Backup original
    cp "$GRADLE_FILE" "${GRADLE_FILE}.backup"
    
    # Add signing configuration
    cat > temp_signing_config << 'GRADLE_EOF'

android {
    signingConfigs {
        release {
            if (project.hasProperty('PROEDIT_RELEASE_STORE_FILE')) {
                storeFile file(PROEDIT_RELEASE_STORE_FILE)
                storePassword PROEDIT_RELEASE_STORE_PASSWORD
                keyAlias PROEDIT_RELEASE_KEY_ALIAS
                keyPassword PROEDIT_RELEASE_KEY_PASSWORD
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    bundle {
        language {
            enableSplit = false
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}
GRADLE_EOF

    # Insert signing config into build.gradle if not already present
    if ! grep -q "signingConfigs" "$GRADLE_FILE"; then
        # Find the android block and insert signing config
        sed -i '/android {/r temp_signing_config' "$GRADLE_FILE"
    fi
    
    rm temp_signing_config
fi

# Create gradle.properties for signing
GRADLE_PROPERTIES="android/gradle.properties"
print_status "Configuring signing properties..."

cat >> "$GRADLE_PROPERTIES" << PROPS_EOF

# Signing configuration for release builds
PROEDIT_RELEASE_STORE_FILE=proedit-studio.keystore
PROEDIT_RELEASE_KEY_ALIAS=proedit-studio
PROEDIT_RELEASE_STORE_PASSWORD=
PROEDIT_RELEASE_KEY_PASSWORD=
PROPS_EOF

print_warning "Please edit android/gradle.properties and add your keystore passwords:"
print_status "PROEDIT_RELEASE_STORE_PASSWORD=your_keystore_password"
print_status "PROEDIT_RELEASE_KEY_PASSWORD=your_key_password"
print_status ""

read -p "Press Enter after you've updated the gradle.properties file..."

# Build AAB
print_status "Building Android App Bundle (AAB)..."
print_status "This may take several minutes..."

cd android
./gradlew bundleRelease

if [ $? -eq 0 ]; then
    print_success "Android App Bundle built successfully!"
    
    AAB_PATH="app/build/outputs/bundle/release/app-release.aab"
    if [ -f "$AAB_PATH" ]; then
        print_success "AAB file created: android/$AAB_PATH"
        
        # Get file size
        AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
        print_status "AAB file size: $AAB_SIZE"
        
        # Copy to root directory for easy access
        cp "$AAB_PATH" "../proedit-studio-release.aab"
        print_status "AAB copied to: proedit-studio-release.aab"
        
        echo ""
        print_success "🎉 Android App Bundle ready for Google Play Console!"
        print_status "Upload file: proedit-studio-release.aab"
        print_status "File location: $(pwd)/../proedit-studio-release.aab"
        
        echo ""
        print_status "Next steps:"
        print_status "1. Go to Google Play Console (play.google.com/console)"
        print_status "2. Select your app or create a new one"
        print_status "3. Go to Release > Production"
        print_status "4. Click 'Create new release'"
        print_status "5. Upload the proedit-studio-release.aab file"
        print_status "6. Fill in release notes and publish"
        
    else
        print_error "AAB file not found at expected location!"
        exit 1
    fi
else
    print_error "Android App Bundle build failed!"
    print_status "Check the build logs above for errors"
    exit 1
fi

cd ..

echo ""
print_success "Build process completed!"
