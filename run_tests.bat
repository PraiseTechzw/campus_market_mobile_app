@echo off
REM CampusMarket Testing Script for Windows
REM Author: Praise Masunga
REM Organization: Appixia Softwares Inc.

echo 🧪 Starting CampusMarket Tests...

REM Run unit tests
echo 🔬 Running unit tests...
flutter test

REM Run integration tests (if available)
if exist "integration_test" (
    echo 🔬 Running integration tests...
    flutter test integration_test/
)

REM Run widget tests
echo 🔬 Running widget tests...
flutter test test/widget_test.dart

echo ✅ All tests completed successfully!
pause 