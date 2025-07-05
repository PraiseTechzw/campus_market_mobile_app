# CampusMarket 🎓

**Developer:** Praise Masunga  
**Organization:** Appixia Softwares Inc.  
**Version:** 1.0.0+1  
**Status:** Ready for Production Deployment

CampusMarket is a comprehensive student-focused platform that revolutionizes campus commerce, accommodation, and community building. Built with modern Flutter architecture, it provides a secure, verified marketplace exclusively for students.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.16.0+
- Android Studio / VS Code
- Google Play Console account
- Firebase project configured

### Development Setup
```bash
# Clone the repository
git clone https://github.com/appixia/campus_market.git
cd campus_market

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Production Build
```bash
# Windows
build_production.bat

# Linux/Mac
./build_production.sh
```

## ✨ Features

### 🛍️ Marketplace
- **Buy & Sell**: List textbooks, electronics, furniture, and more
- **Smart Search**: Advanced filtering and search capabilities
- **Favorites**: Save items and get price drop notifications
- **Ratings & Reviews**: Build trust within the campus community
- **Safe Trading**: Verified student accounts and secure transactions

### 🏠 Accommodation Services
- **Room Listings**: Find student housing near your campus
- **Landlord Verification**: Connect with verified property owners
- **Location-Based Search**: Find accommodation close to your university
- **Virtual Tours**: View rooms with detailed photos and descriptions
- **Booking System**: Secure accommodation booking and payments

### 👥 Student Verification
- **Secure Identity**: Verified student accounts for safe transactions
- **Campus Integration**: Connect with your university network
- **Trust System**: Build reputation through successful transactions
- **Report System**: Flag inappropriate content or behavior

### 💬 Communication Hub
- **In-App Messaging**: Chat securely with buyers and sellers
- **Real-time Notifications**: Stay updated on messages and deals
- **Group Chats**: Connect with roommates and study groups
- **File Sharing**: Share documents and images easily

### 💳 Payment Options
- **Multiple Methods**: EcoCash, PayNow, Cash on Delivery
- **Secure Transactions**: Protected payment processing
- **Escrow Service**: Safe payment handling for high-value items
- **Transaction History**: Track all your payments and purchases

### 🔔 Smart Notifications
- **Deal Alerts**: Get notified about items in your wishlist
- **Price Drops**: Never miss a good deal
- **Message Notifications**: Stay connected with the community
- **Customizable Settings**: Control what notifications you receive

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter 3.16.0+ (Dart)
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **State Management**: Riverpod (hooks_riverpod)
- **Navigation**: GoRouter
- **Local Storage**: Hive (offline support)
- **UI Framework**: Material Design 3
- **Analytics**: Firebase Analytics & Crashlytics

### Project Structure
```
lib/
├── application/          # State management & business logic
│   ├── providers/       # Riverpod providers
│   └── services/        # Business services
├── domain/              # Entities & repositories
│   ├── entities/        # Data models
│   ├── repositories/    # Data access interfaces
│   └── use_cases/       # Business use cases
├── infrastructure/      # External services & data sources
│   ├── firebase/        # Firebase implementations
│   ├── local/           # Local storage implementations
│   └── network/         # API implementations
└── presentation/        # UI & screens
    ├── core/            # Shared UI components
    ├── features/        # Feature-specific screens
    └── widgets/         # Reusable widgets
```

### Design System
- **Primary Color**: Lime Green (#32CD32)
- **Secondary Color**: Dark Green (#228B22)
- **Typography**: Roboto (Material Design)
- **Icons**: Material Icons & Font Awesome
- **Theme**: Light/Dark mode support

## 📱 Platform Support

### Android
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 34 (Android 14)
- **Architecture**: ARM64, ARMv7, x86_64
- **Permissions**: Camera, Location, Storage, Notifications

### iOS (Future)
- **Minimum Version**: iOS 12.0
- **Target Version**: iOS 17.0
- **Architecture**: ARM64
- **Permissions**: Camera, Location, Photos, Notifications

## 🔧 Development

### Code Quality
```bash
# Run code analysis
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Quality checks (Windows)
quality_check.bat

# Quality checks (Linux/Mac)
./quality_check.sh
```

### Build Commands
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# Web build (Future)
flutter build web
```

### Testing Strategy
- **Unit Tests**: Business logic and utilities
- **Widget Tests**: UI components and interactions
- **Integration Tests**: End-to-end user flows
- **Performance Tests**: App performance and memory usage

## 🚀 Deployment

### Play Store Deployment
The app is fully configured for Google Play Store deployment with comprehensive documentation:

- **[📋 Deployment Guide](DEPLOYMENT_README.md)** - Complete deployment overview
- **[🏪 Play Store Guide](PLAY_STORE_DEPLOYMENT.md)** - Step-by-step Play Store setup
- **[📝 App Description](APP_DESCRIPTION.md)** - Store listing content
- **[🔒 Privacy Policy](PRIVACY_POLICY.md)** - Legal compliance
- **[📜 Terms of Service](TERMS_OF_SERVICE.md)** - User agreements
- **[✅ Release Checklist](RELEASE_CHECKLIST.md)** - Pre-release validation

### Build Automation
```bash
# Production build (Windows)
build_production.bat

# Production build (Linux/Mac)
./build_production.sh

# Run tests (Windows)
run_tests.bat

# Run tests (Linux/Mac)
./run_tests.sh
```

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication, Firestore, Storage, and Functions
3. Download `google-services.json` and add to `android/app/`
4. Configure security rules for Firestore and Storage
5. Set up Firebase Analytics and Crashlytics

## 📊 Analytics & Monitoring

### Firebase Integration
- **Authentication**: Email/password, Google Sign-In
- **Firestore**: Real-time database for listings and messages
- **Storage**: Image upload for product photos
- **Functions**: Serverless backend logic
- **Analytics**: User behavior and app performance
- **Crashlytics**: Error tracking and reporting
- **Messaging**: Push notifications

### Key Metrics
- User acquisition and retention
- Marketplace transaction volume
- Accommodation booking rates
- User engagement and session duration
- App performance and crash rates
- Payment processing success rates

## 🔐 Security & Privacy

### Security Features
- **Student Verification**: Only verified students can join
- **Content Moderation**: Active monitoring of listings and messages
- **Data Encryption**: All sensitive data encrypted in transit and at rest
- **Secure Payments**: Protected payment processing
- **Privacy Controls**: User control over data sharing

### Compliance
- **GDPR**: Full compliance for EU users
- **COPPA**: No collection from children under 13
- **Data Retention**: Clear data retention policies
- **User Rights**: Access, correction, and deletion rights
- **Transparency**: Clear privacy policy and terms of service

## 🤝 Contributing

### Development Guidelines
1. Follow Flutter best practices and conventions
2. Write comprehensive tests for new features
3. Update documentation for API changes
4. Use conventional commit messages
5. Ensure code passes all quality checks

### Code Review Process
1. Create feature branch from `develop`
2. Implement feature with tests
3. Run quality checks and tests
4. Submit pull request
5. Code review and approval
6. Merge to `develop` branch

## 📈 Roadmap

### Version 1.1 (Q1 2025)
- [ ] iOS app release
- [ ] Advanced search filters
- [ ] Push notification improvements
- [ ] Performance optimizations

### Version 1.2 (Q2 2025)
- [ ] Web platform
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] Social features

### Version 2.0 (Q3 2025)
- [ ] AI-powered recommendations
- [ ] Video calling for negotiations
- [ ] Blockchain integration
- [ ] Advanced admin tools

## 📞 Support & Contact

### Technical Support
- **Email**: support@campusmarket.appixia.com
- **Documentation**: [Deployment Guide](DEPLOYMENT_README.md)
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

### Business Inquiries
- **Email**: business@campusmarket.appixia.com
- **Website**: https://campusmarket.appixia.com
- **LinkedIn**: [Appixia Softwares Inc.](https://linkedin.com/company/appixia)

### Legal & Privacy
- **Privacy**: privacy@campusmarket.appixia.com
- **Legal**: legal@campusmarket.appixia.com
- **DPO**: dpo@campusmarket.appixia.com

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Firebase Team**: For the robust backend services
- **Material Design**: For the design system
- **Open Source Community**: For the libraries and tools

---

**CampusMarket v1.0.0**  
**Built with ❤️ by Praise Masunga & Appixia Softwares Inc.**  
**Ready for Production Deployment** 🚀
