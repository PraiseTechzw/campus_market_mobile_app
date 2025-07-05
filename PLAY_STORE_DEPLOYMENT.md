# CampusMarket - Play Store Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying CampusMarket to the Google Play Store for both internal testing and production release.

## Prerequisites
- Google Play Console account with developer access
- Android Studio or Flutter SDK installed
- Firebase project configured
- App signing key generated

## 1. App Signing Setup

### Generate Release Keystore
```bash
keytool -genkey -v -keystore campus_market_release.keystore -alias campus_market_key -keyalg RSA -keysize 2048 -validity 10000
```

### Configure Signing in build.gradle.kts
Update `android/app/build.gradle.kts`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = "campus_market_key"
        keyPassword = "your-key-password"
        storeFile = file("campus_market_release.keystore")
        storePassword = "your-store-password"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
}
```

## 2. Version Management

### Update Version in pubspec.yaml
```yaml
version: 1.0.0+1  # Format: version_name+version_code
```

### Version Code Guidelines
- Start with 1 for first release
- Increment by 1 for each release
- Never decrease version code
- Use semantic versioning for version name

## 3. Build Configuration

### Production Build
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### Debug Build for Testing
```bash
flutter build apk --debug
```

## 4. Play Store Console Setup

### App Information
- **App Name**: CampusMarket
- **Short Description**: Campus marketplace for students
- **Full Description**: See APP_DESCRIPTION.md
- **Category**: Shopping
- **Content Rating**: Teen (13+)
- **Tags**: marketplace, campus, student, accommodation, trading

### Store Listing Assets
- **App Icon**: 512x512 PNG
- **Feature Graphic**: 1024x500 PNG
- **Screenshots**: 16:9 ratio, various device sizes
- **Video**: Optional promotional video

## 5. Content Rating

### Content Rating Questionnaire
- **Violence**: None
- **Sexual Content**: None
- **Language**: None
- **Controlled Substances**: None
- **User Generated Content**: Yes (marketplace listings)

## 6. Privacy Policy

### Required Information
- Data collection practices
- Third-party services used
- User rights and choices
- Contact information
- Data retention policies

### Privacy Policy URL
Host at: https://campusmarket.appixia.com/privacy-policy

## 7. Testing Tracks

### Internal Testing
- Upload APK/AAB to internal testing track
- Add testers by email
- Test on various devices
- Verify all features work correctly

### Closed Testing
- Create closed testing track
- Add testers by email or Google Groups
- Collect feedback and bug reports
- Iterate based on feedback

### Open Testing
- Release to open testing track
- Public beta testing
- Monitor crash reports and analytics
- Prepare for production release

## 8. Production Release

### Pre-release Checklist
- [ ] All tests passing
- [ ] Privacy policy published
- [ ] Content rating completed
- [ ] Store listing assets uploaded
- [ ] App signing configured
- [ ] Firebase configuration updated
- [ ] Analytics and crash reporting enabled
- [ ] Performance optimized

### Release Process
1. Upload production AAB to Play Console
2. Complete store listing
3. Set up release notes
4. Configure phased rollout (optional)
5. Submit for review
6. Monitor review process
7. Publish when approved

## 9. Post-Release Monitoring

### Key Metrics to Track
- Install rate
- Crash rate
- User engagement
- Rating and reviews
- Performance metrics

### Tools for Monitoring
- Firebase Analytics
- Firebase Crashlytics
- Google Play Console Analytics
- User feedback and reviews

## 10. Update Process

### Version Update Steps
1. Update version in pubspec.yaml
2. Test thoroughly
3. Build new AAB
4. Upload to Play Console
5. Update release notes
6. Submit for review

### Rollback Plan
- Keep previous version ready
- Monitor for critical issues
- Have rollback procedure documented

## 11. Compliance Requirements

### GDPR Compliance
- Data processing transparency
- User consent mechanisms
- Data portability
- Right to deletion

### COPPA Compliance
- No collection of personal information from children under 13
- Appropriate content filtering
- Parental consent mechanisms

### Accessibility
- Screen reader support
- High contrast mode
- Scalable text
- Touch target sizes

## 12. Security Considerations

### Data Protection
- Encrypt sensitive data
- Secure API communications
- Implement proper authentication
- Regular security audits

### Code Obfuscation
- ProGuard rules configured
- R8 optimization enabled
- Sensitive strings obfuscated
- Debug information removed

## 13. Support and Maintenance

### User Support
- In-app help system
- FAQ section
- Contact support option
- Community forums

### Maintenance Schedule
- Regular security updates
- Performance optimizations
- Feature updates
- Bug fixes

## 14. Emergency Procedures

### Critical Issues
- Immediate rollback procedure
- Communication plan
- Support escalation
- Post-mortem analysis

### Contact Information
- Developer: Praise Masunga
- Organization: Appixia Softwares Inc.
- Support Email: support@campusmarket.appixia.com
- Emergency Contact: [Add emergency contact]

## 15. Resources

### Documentation
- [Flutter Deployment Guide](https://flutter.dev/docs/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Documentation](https://firebase.google.com/docs)

### Tools
- Android Studio
- Flutter SDK
- Firebase Console
- Google Play Console
- ProGuard/R8

---

**Last Updated**: December 2024
**Version**: 1.0
**Author**: Praise Masunga (Appixia Softwares Inc.) 