# CampusMarket

**Developer:** Praise Masunga  
**Organization:** Appixia Softwares Inc.

CampusMarket is a student-focused platform for campus marketplace, accommodation, verification, messaging, and more.

## Features
- Marketplace for buying/selling
- Accommodation booking
- Student verification
- In-app messaging
- Payments (EcoCash, PayNow, Cash on Delivery)
- Notifications
- User roles (student, landlord, admin)
- Admin dashboard

## Tech Stack
- Flutter 3+
- Firebase (Auth, Firestore, Storage, Functions)
- Riverpod (hooks_riverpod)
- GoRouter
- Hive (offline support)

## Branding
- Primary Color: Lime Green (#32CD32)
- Logo and splash assets provided

## Folder Structure
- `lib/presentation` – UI & screens
- `lib/application` – State management, logic
- `lib/domain` – Entities, repositories, use cases
- `lib/infrastructure` – Data sources, services

## Getting Started
1. Clone the repo
2. Run `flutter pub get`
3. Set up Firebase (see below)
4. Run the app: `flutter run`

## Firebase Setup
- Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
- Configure environment variables as needed.

---

## License
MIT
