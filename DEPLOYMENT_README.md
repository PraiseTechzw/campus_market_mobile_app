# CampusMarket - Complete Deployment Guide

## 🚀 Quick Start

### 1. Prerequisites
- Flutter SDK 3.16.0+
- Android Studio / VS Code
- Google Play Console account
- Firebase project configured
- App signing key generated

### 2. Build and Deploy
```bash
# Make scripts executable
chmod +x *.sh

# Run quality checks
./quality_check.sh
./security_check.sh

# Run tests
./run_tests.sh

# Build for production
./build_production.sh

# Upload to Play Store (manual)
# Use the generated .aab file in the release/ directory
```

## 📋 Documentation Overview

### Core Documentation
- **[PLAY_STORE_DEPLOYMENT.md](PLAY_STORE_DEPLOYMENT.md)** - Complete Play Store deployment guide
- **[APP_DESCRIPTION.md](APP_DESCRIPTION.md)** - App store listing content
- **[PRIVACY_POLICY.md](PRIVACY_POLICY.md)** - Privacy policy for compliance
- **[TERMS_OF_SERVICE.md](TERMS_OF_SERVICE.md)** - Terms of service
- **[BUILD_SCRIPTS.md](BUILD_SCRIPTS.md)** - Build automation documentation
- **[RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)** - Pre-release checklist

### Build Scripts
- **[build_production.sh](build_production.sh)** - Production build script
- **[build_debug.sh](build_debug.sh)** - Debug build script
- **[run_tests.sh](run_tests.sh)** - Testing script
- **[quality_check.sh](quality_check.sh)** - Code quality checks
- **[security_check.sh](security_check.sh)** - Security validation

## 🏗️ Project Configuration

### Updated Files
- `pubspec.yaml` - App description and version
- `android/app/build.gradle.kts` - Build configuration
- `android/app/proguard-rules.pro` - Code obfuscation
- `android/app/src/main/AndroidManifest.xml` - Permissions and metadata
- `android/app/src/main/res/xml/data_extraction_rules.xml` - Backup rules
- `android/app/src/main/res/values/colors.xml` - Notification colors
- `android/app/src/main/res/drawable/ic_notification.xml` - Notification icon

## 📱 App Information

### Basic Details
- **App Name**: CampusMarket
- **Package ID**: com.appixia.campus_market
- **Version**: 1.0.0+1
- **Category**: Shopping
- **Content Rating**: Teen (13+)
- **Target SDK**: Android 5.0+ (API 21+)

### Features
- Student marketplace for buying/selling
- Accommodation booking system
- Secure messaging between users
- Student verification system
- Multiple payment options (EcoCash, PayNow)
- Real-time notifications
- Admin dashboard

## 🔧 Build Configuration

### Production Build
```bash
# Clean and get dependencies
flutter clean && flutter pub get

# Run tests
flutter test

# Build App Bundle (Play Store)
flutter build appbundle --release

# Build APK (Direct distribution)
flutter build apk --release
```

### Debug Build
```bash
flutter build apk --debug
```

## 📦 Play Store Requirements

### Required Assets
- App icon (512x512 PNG)
- Feature graphic (1024x500 PNG)
- Screenshots (16:9 ratio, various devices)
- Privacy policy URL
- Terms of service URL

### Content Rating
- Violence: None
- Sexual content: None
- Language: None
- Controlled substances: None
- User-generated content: Yes (moderated)

### Legal Compliance
- Privacy policy published
- Terms of service published
- GDPR compliance verified
- COPPA compliance verified
- Data retention policies documented

## 🔐 Security Configuration

### App Signing
```bash
# Generate release keystore
keytool -genkey -v -keystore campus_market_release.keystore \
  -alias campus_market_key -keyalg RSA -keysize 2048 -validity 10000
```

### ProGuard Configuration
- Code obfuscation enabled
- Debug information removed
- Sensitive strings obfuscated
- Flutter and Firebase rules included

### Permissions
- Internet access
- Network state
- Location (for accommodation search)
- Camera (for listing photos)
- Storage (for images)
- Notifications

## 🧪 Testing Strategy

### Testing Tracks
1. **Internal Testing** - Team and close testers
2. **Closed Testing** - Beta testers
3. **Open Testing** - Public beta
4. **Production** - Public release

### Test Coverage
- Unit tests for all business logic
- Widget tests for UI components
- Integration tests for user flows
- Device testing on various Android versions
- Performance testing
- Security testing

## 📊 Monitoring and Analytics

### Firebase Integration
- Authentication
- Firestore database
- Cloud Storage
- Analytics
- Crashlytics
- Cloud Functions
- Push notifications

### Key Metrics
- User acquisition
- Engagement rates
- Crash rates
- Performance metrics
- User feedback
- Revenue tracking

## 🚨 Emergency Procedures

### Rollback Plan
1. Identify critical issue
2. Assess impact and scope
3. Execute rollback procedure
4. Notify users and stakeholders
5. Investigate root cause
6. Deploy fix

### Contact Information
- **Developer**: Praise Masunga
- **Organization**: Appixia Softwares Inc.
- **Support**: support@campusmarket.appixia.com
- **Legal**: legal@campusmarket.appixia.com
- **Privacy**: privacy@campusmarket.appixia.com

## 📈 Post-Launch

### Monitoring Schedule
- **Daily**: Check crash reports and key metrics
- **Weekly**: Review user feedback and performance
- **Monthly**: Analyze trends and plan updates
- **Quarterly**: Strategic review and planning

### Update Process
1. Feature development
2. Testing and quality assurance
3. Version bump and build
4. Play Store submission
5. Release monitoring
6. User feedback collection

## 🛠️ Troubleshooting

### Common Issues
- **Build fails**: Check Flutter version and dependencies
- **Upload fails**: Verify Play Store credentials
- **Tests fail**: Review test code and dependencies
- **Performance issues**: Optimize images and code

### Debug Commands
```bash
# Check Flutter setup
flutter doctor

# Check dependencies
flutter pub deps

# Clean and rebuild
flutter clean && flutter pub get

# Analyze code
flutter analyze
```

## 📚 Additional Resources

### Official Documentation
- [Flutter Deployment Guide](https://flutter.dev/docs/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Documentation](https://firebase.google.com/docs)

### Tools and Services
- Android Studio / VS Code
- Firebase Console
- Google Play Console
- ProGuard/R8
- Fastlane (optional)

---

## 🎯 Next Steps

1. **Generate App Signing Key** - Create release keystore
2. **Configure Firebase** - Set up project and services
3. **Create Store Assets** - Design app icon and screenshots
4. **Complete Store Listing** - Fill in all required information
5. **Run Quality Checks** - Execute all validation scripts
6. **Build and Test** - Create production build and test thoroughly
7. **Submit for Review** - Upload to Play Store and await approval
8. **Monitor and Iterate** - Track performance and user feedback

---

**CampusMarket Deployment Guide v1.0**  
**Author**: Praise Masunga (Appixia Softwares Inc.)  
**Last Updated**: December 2024  
**Status**: Ready for Production Deployment 