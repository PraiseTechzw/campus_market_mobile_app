@echo off
REM CampusMarket Code Quality Check Script for Windows
REM Author: Praise Masunga
REM Organization: Appixia Softwares Inc.

echo 🔍 Starting Code Quality Check...

REM Run Flutter analyze
echo 🔍 Running Flutter analyze...
flutter analyze

REM Run dart format check
echo 🎨 Checking code formatting...
dart format --set-exit-if-changed .

REM Check for TODO comments
echo 📝 Checking for TODO comments...
findstr /s /i "TODO" lib\*.dart
if %errorlevel% equ 0 (
    echo ⚠️  Found TODO comments, review manually
) else (
    echo ✅ No TODO comments found
)

echo ✅ Code quality check completed!
pause 