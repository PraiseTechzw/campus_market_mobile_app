@echo off
REM CampusMarket Production Build Script for Windows
REM Author: Praise Masunga
REM Organization: Appixia Softwares Inc.

echo 🚀 Starting CampusMarket Production Build...

REM Configuration
set APP_NAME=CampusMarket
set BUILD_DIR=build
set RELEASE_DIR=release

REM Get version from pubspec.yaml
for /f "tokens=2" %%i in ('findstr "version:" pubspec.yaml') do set VERSION=%%i
for /f "tokens=2 delims=+" %%i in ("%VERSION%") do set VERSION_NAME=%%i
for /f "tokens=3 delims=+" %%i in ("%VERSION%") do set BUILD_NUMBER=%%i

echo 📱 App: %APP_NAME%
echo 📦 Version: %VERSION_NAME%
echo 🔢 Build: %BUILD_NUMBER%

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean
flutter pub get

REM Run tests
echo 🧪 Running tests...
flutter test

REM Build App Bundle (recommended for Play Store)
echo 📦 Building App Bundle...
flutter build appbundle --release

REM Build APK (for direct distribution)
echo 📦 Building APK...
flutter build apk --release

REM Create release directory
if not exist %RELEASE_DIR% mkdir %RELEASE_DIR%

REM Copy builds to release directory
echo 📁 Copying builds to release directory...
copy "build\app\outputs\bundle\release\app-release.aab" "%RELEASE_DIR%\campus_market_%VERSION_NAME%_%BUILD_NUMBER%.aab"
copy "build\app\outputs\flutter-apk\app-release.apk" "%RELEASE_DIR%\campus_market_%VERSION_NAME%_%BUILD_NUMBER%.apk"

REM Generate build info
echo 📝 Generating build info...
(
echo CampusMarket Build Information
echo ==============================
echo App Name: %APP_NAME%
echo Version: %VERSION_NAME%
echo Build Number: %BUILD_NUMBER%
echo Build Date: %date%
echo Build Time: %time%
echo Git Commit: 
git rev-parse HEAD
echo Git Branch: 
git branch --show-current
echo Flutter Version: 
flutter --version
echo Dart Version: 
dart --version
echo.
echo Build Files:
echo - App Bundle: campus_market_%VERSION_NAME%_%BUILD_NUMBER%.aab
echo - APK: campus_market_%VERSION_NAME%_%BUILD_NUMBER%.apk
echo.
echo Notes:
echo - App Bundle (.aab) is recommended for Play Store upload
echo - APK (.apk) is for direct distribution and testing
) > "%RELEASE_DIR%\build_info.txt"

echo ✅ Production build completed successfully!
echo 📁 Build files located in: %RELEASE_DIR%
echo 📋 Build info: %RELEASE_DIR%\build_info.txt

REM Display file sizes
echo 📊 Build file sizes:
dir "%RELEASE_DIR%\*.aab" "%RELEASE_DIR%\*.apk" 2>nul

pause 