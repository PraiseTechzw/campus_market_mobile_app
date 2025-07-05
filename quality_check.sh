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