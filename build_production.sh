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