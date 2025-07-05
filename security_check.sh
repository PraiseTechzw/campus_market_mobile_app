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