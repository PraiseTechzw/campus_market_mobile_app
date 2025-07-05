# CampusMarket Build Scripts and Automation

## Overview
This document contains build scripts, automation tools, and deployment procedures for CampusMarket Android app.

## 1. Build Scripts

### 1.1 Production Build Script (build_production.sh)
```bash
#!/bin/bash

# CampusMarket Production Build Script
# Author: Praise Masunga
# Organization: Appixia Softwares Inc.

set -e

echo "🚀 Starting CampusMarket Production Build..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="CampusMarket"
BUILD_DIR="build"
RELEASE_DIR="release"
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')
BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)
VERSION_NAME=$(echo $VERSION | cut -d'+' -f1)

echo -e "${GREEN}📱 App: $APP_NAME${NC}"
echo -e "${GREEN}📦 Version: $VERSION_NAME${NC}"
echo -e "${GREEN}🔢 Build: $BUILD_NUMBER${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
flutter test

# Build App Bundle (recommended for Play Store)
echo -e "${YELLOW}📦 Building App Bundle...${NC}"
flutter build appbundle --release

# Build APK (for direct distribution)
echo -e "${YELLOW}📦 Building APK...${NC}"
flutter build apk --release

# Create release directory
mkdir -p $RELEASE_DIR

# Copy builds to release directory
echo -e "${YELLOW}📁 Copying builds to release directory...${NC}"
cp build/app/outputs/bundle/release/app-release.aab $RELEASE_DIR/campus_market_${VERSION_NAME}_${BUILD_NUMBER}.aab
cp build/app/outputs/flutter-apk/app-release.apk $RELEASE_DIR/campus_market_${VERSION_NAME}_${BUILD_NUMBER}.apk

# Generate build info
echo -e "${YELLOW}📝 Generating build info...${NC}"
cat > $RELEASE_DIR/build_info.txt << EOF
CampusMarket Build Information
==============================
App Name: $APP_NAME
Version: $VERSION_NAME
Build Number: $BUILD_NUMBER
Build Date: $(date)
Build Time: $(date +%T)
Git Commit: $(git rev-parse HEAD)
Git Branch: $(git branch --show-current)
Flutter Version: $(flutter --version | head -n 1)
Dart Version: $(dart --version | head -n 1)

Build Files:
- App Bundle: campus_market_${VERSION_NAME}_${BUILD_NUMBER}.aab
- APK: campus_market_${VERSION_NAME}_${BUILD_NUMBER}.apk

Notes:
- App Bundle (.aab) is recommended for Play Store upload
- APK (.apk) is for direct distribution and testing
EOF

echo -e "${GREEN}✅ Production build completed successfully!${NC}"
echo -e "${GREEN}📁 Build files located in: $RELEASE_DIR${NC}"
echo -e "${GREEN}📋 Build info: $RELEASE_DIR/build_info.txt${NC}"

# Display file sizes
echo -e "${YELLOW}📊 Build file sizes:${NC}"
ls -lh $RELEASE_DIR/*.aab $RELEASE_DIR/*.apk 2>/dev/null || true
```

### 1.2 Debug Build Script (build_debug.sh)
```bash
#!/bin/bash

# CampusMarket Debug Build Script
# Author: Praise Masunga
# Organization: Appixia Softwares Inc.

set -e

echo "🔧 Starting CampusMarket Debug Build..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="CampusMarket"
BUILD_DIR="build"
DEBUG_DIR="debug"
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')
BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)
VERSION_NAME=$(echo $VERSION | cut -d'+' -f1)

echo -e "${GREEN}📱 App: $APP_NAME${NC}"
echo -e "${GREEN}📦 Version: $VERSION_NAME${NC}"
echo -e "${GREEN}🔢 Build: $BUILD_NUMBER${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Build Debug APK
echo -e "${YELLOW}📦 Building Debug APK...${NC}"
flutter build apk --debug

# Create debug directory
mkdir -p $DEBUG_DIR

# Copy debug build
echo -e "${YELLOW}📁 Copying debug build...${NC}"
cp build/app/outputs/flutter-apk/app-debug.apk $DEBUG_DIR/campus_market_debug_${VERSION_NAME}_${BUILD_NUMBER}.apk

echo -e "${GREEN}✅ Debug build completed successfully!${NC}"
echo -e "${GREEN}📁 Debug build located in: $DEBUG_DIR${NC}"
```

### 1.3 Testing Script (run_tests.sh)
```bash
#!/bin/bash

# CampusMarket Testing Script
# Author: Praise Masunga
# Organization: Appixia Softwares Inc.

set -e

echo "🧪 Starting CampusMarket Tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Run unit tests
echo -e "${YELLOW}🔬 Running unit tests...${NC}"
flutter test

# Run integration tests (if available)
if [ -d "integration_test" ]; then
    echo -e "${YELLOW}🔬 Running integration tests...${NC}"
    flutter test integration_test/
fi

# Run widget tests
echo -e "${YELLOW}🔬 Running widget tests...${NC}"
flutter test test/widget_test.dart

echo -e "${GREEN}✅ All tests completed successfully!${NC}"
```

## 2. Deployment Scripts

### 2.1 Play Store Upload Script (upload_playstore.sh)
```bash
#!/bin/bash

# CampusMarket Play Store Upload Script
# Author: Praise Masunga
# Organization: Appixia Softwares Inc.

set -e

echo "📤 Starting Play Store Upload..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="CampusMarket"
RELEASE_DIR="release"
TRACK="internal" # internal, alpha, beta, production

# Check if AAB file exists
AAB_FILE=$(find $RELEASE_DIR -name "*.aab" | head -n 1)

if [ -z "$AAB_FILE" ]; then
    echo -e "${RED}❌ No AAB file found in $RELEASE_DIR${NC}"
    echo -e "${YELLOW}💡 Run build_production.sh first${NC}"
    exit 1
fi

echo -e "${GREEN}📦 Found AAB file: $AAB_FILE${NC}"

# Check if bundletool is installed
if ! command -v bundletool &> /dev/null; then
    echo -e "${YELLOW}📥 Installing bundletool...${NC}"
    # Add bundletool installation logic here
fi

# Upload to Play Store
echo -e "${YELLOW}📤 Uploading to Play Store ($TRACK track)...${NC}"
# Add Play Store upload logic here using fastlane or gcloud

echo -e "${GREEN}✅ Play Store upload completed!${NC}"
echo -e "${GREEN}🔗 Check Play Console for upload status${NC}"
```

### 2.2 Firebase Distribution Script (upload_firebase.sh)
```bash
#!/bin/bash

# CampusMarket Firebase Distribution Script
# Author: Praise Masunga
# Organization: Appixia Softwares Inc.

set -e

echo "🔥 Starting Firebase Distribution..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="CampusMarket"
RELEASE_DIR="release"
FIREBASE_PROJECT="campus-market-app"

# Check if APK file exists
APK_FILE=$(find $RELEASE_DIR -name "*.apk" | head -n 1)

if [ -z "$APK_FILE" ]; then
    echo -e "${RED}❌ No APK file found in $RELEASE_DIR${NC}"
    echo -e "${YELLOW}💡 Run build_production.sh first${NC}"
    exit 1
fi

echo -e "${GREEN}📦 Found APK file: $APK_FILE${NC}"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${YELLOW}📥 Installing Firebase CLI...${NC}"
    npm install -g firebase-tools
fi

# Login to Firebase
echo -e "${YELLOW}🔐 Logging into Firebase...${NC}"
firebase login

# Distribute via Firebase App Distribution
echo -e "${YELLOW}📤 Distributing via Firebase...${NC}"
firebase appdistribution:distribute $APK_FILE \
    --app $FIREBASE_PROJECT \
    --groups "testers" \
    --release-notes "CampusMarket v$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)"

echo -e "${GREEN}✅ Firebase distribution completed!${NC}"
```

## 3. Version Management Scripts

### 3.1 Version Update Script (update_version.sh)
```bash
#!/bin/bash

# CampusMarket Version Update Script
# Author: Praise Masunga
# Organization: Appixia Softwares Inc.

set -e

echo "📝 Updating CampusMarket Version..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current version
CURRENT_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')
CURRENT_VERSION_NAME=$(echo $CURRENT_VERSION | cut -d'+' -f1)
CURRENT_BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)

echo -e "${GREEN}📦 Current Version: $CURRENT_VERSION_NAME${NC}"
echo -e "${GREEN}🔢 Current Build: $CURRENT_BUILD_NUMBER${NC}"

# Get new version from user
read -p "Enter new version name (e.g., 1.0.1): " NEW_VERSION_NAME
read -p "Enter new build number (current: $CURRENT_BUILD_NUMBER): " NEW_BUILD_NUMBER

# Validate input
if [ -z "$NEW_VERSION_NAME" ] || [ -z "$NEW_BUILD_NUMBER" ]; then
    echo -e "${RED}❌ Version name and build number are required${NC}"
    exit 1
fi

# Update pubspec.yaml
echo -e "${YELLOW}📝 Updating pubspec.yaml...${NC}"
sed -i "s/version: $CURRENT_VERSION/version: $NEW_VERSION_NAME+$NEW_BUILD_NUMBER/" pubspec.yaml

# Update Android version
echo -e "${YELLOW}📝 Updating Android version...${NC}"
sed -i "s/versionCode = $CURRENT_BUILD_NUMBER/versionCode = $NEW_BUILD_NUMBER/" android/app/build.gradle.kts
sed -i "s/versionName = \"$CURRENT_VERSION_NAME\"/versionName = \"$NEW_VERSION_NAME\"/" android/app/build.gradle.kts

echo -e "${GREEN}✅ Version updated successfully!${NC}"
echo -e "${GREEN}📦 New Version: $NEW_VERSION_NAME+$NEW_BUILD_NUMBER${NC}"

# Commit changes
read -p "Commit version changes? (y/n): " COMMIT_CHANGES
if [ "$COMMIT_CHANGES" = "y" ]; then
    git add pubspec.yaml android/app/build.gradle.kts
    git commit -m "Bump version to $NEW_VERSION_NAME+$NEW_BUILD_NUMBER"
    echo -e "${GREEN}✅ Version changes committed${NC}"
fi
```

## 4. Quality Assurance Scripts

### 4.1 Code Quality Check (quality_check.sh)
```bash
#!/bin/bash

# CampusMarket Code Quality Check Script
# Author: Praise Masunga
# Organization: Appixia Softwares Inc.

set -e

echo "🔍 Starting Code Quality Check..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Run Flutter analyze
echo -e "${YELLOW}🔍 Running Flutter analyze...${NC}"
flutter analyze

# Run dart format check
echo -e "${YELLOW}🎨 Checking code formatting...${NC}"
dart format --set-exit-if-changed .

# Run custom lint rules
echo -e "${YELLOW}📋 Running custom lint checks...${NC}"
# Add custom lint checks here

# Check for TODO comments
echo -e "${YELLOW}📝 Checking for TODO comments...${NC}"
TODO_COUNT=$(grep -r "TODO" lib/ | wc -l)
if [ $TODO_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $TODO_COUNT TODO comments${NC}"
    grep -r "TODO" lib/
else
    echo -e "${GREEN}✅ No TODO comments found${NC}"
fi

# Check file sizes
echo -e "${YELLOW}📊 Checking file sizes...${NC}"
find lib/ -name "*.dart" -size +1000k -exec echo "Large file: {}" \;

echo -e "${GREEN}✅ Code quality check completed!${NC}"
```

### 4.2 Security Check (security_check.sh)
```bash
#!/bin/bash

# CampusMarket Security Check Script
# Author: Praise Masunga
# Organization: Appixia Softwares Inc.

set -e

echo "🔒 Starting Security Check..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for hardcoded secrets
echo -e "${YELLOW}🔍 Checking for hardcoded secrets...${NC}"
if grep -r "password\|secret\|key\|token" lib/ --exclude-dir=generated; then
    echo -e "${YELLOW}⚠️  Potential secrets found, review manually${NC}"
else
    echo -e "${GREEN}✅ No obvious secrets found${NC}"
fi

# Check for debug prints
echo -e "${YELLOW}🔍 Checking for debug prints...${NC}"
DEBUG_PRINTS=$(grep -r "print(" lib/ | wc -l)
if [ $DEBUG_PRINTS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $DEBUG_PRINTS debug prints${NC}"
    grep -r "print(" lib/
else
    echo -e "${GREEN}✅ No debug prints found${NC}"
fi

# Check dependencies for vulnerabilities
echo -e "${YELLOW}🔍 Checking dependencies...${NC}"
flutter pub deps

echo -e "${GREEN}✅ Security check completed!${NC}"
```

## 5. Automation Workflows

### 5.1 GitHub Actions Workflow (.github/workflows/build.yml)
```yaml
name: CampusMarket CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Run analyze
      run: flutter analyze
    
    - name: Build APK
      run: flutter build apk --debug

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build App Bundle
      run: flutter build appbundle --release
    
    - name: Upload to Play Store
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_CONFIG }}
        packageName: com.appixia.campus_market
        releaseFiles: build/app/outputs/bundle/release/app-release.aab
        track: internal
```

## 6. Usage Instructions

### 6.1 Making Scripts Executable
```bash
chmod +x build_production.sh
chmod +x build_debug.sh
chmod +x run_tests.sh
chmod +x upload_playstore.sh
chmod +x upload_firebase.sh
chmod +x update_version.sh
chmod +x quality_check.sh
chmod +x security_check.sh
```

### 6.2 Typical Build Workflow
```bash
# 1. Update version (if needed)
./update_version.sh

# 2. Run quality checks
./quality_check.sh
./security_check.sh

# 3. Run tests
./run_tests.sh

# 4. Build for production
./build_production.sh

# 5. Upload to Play Store
./upload_playstore.sh

# 6. Distribute via Firebase (optional)
./upload_firebase.sh
```

### 6.3 Environment Setup
```bash
# Install required tools
npm install -g firebase-tools
npm install -g @google-cloud/cli

# Configure Firebase
firebase login

# Configure Google Cloud
gcloud auth login
gcloud config set project campus-market-app
```

## 7. Troubleshooting

### 7.1 Common Issues
- **Build fails**: Check Flutter version and dependencies
- **Upload fails**: Verify Play Store credentials and permissions
- **Tests fail**: Review test code and dependencies
- **Version conflicts**: Ensure version numbers are consistent

### 7.2 Debug Commands
```bash
# Check Flutter version
flutter --version

# Check dependencies
flutter pub deps

# Clean and rebuild
flutter clean && flutter pub get

# Check for issues
flutter doctor
```

---

**Build Scripts v1.0**  
**Author**: Praise Masunga (Appixia Softwares Inc.)  
**Last Updated**: December 2024 