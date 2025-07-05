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