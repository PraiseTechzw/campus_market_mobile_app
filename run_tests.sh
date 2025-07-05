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