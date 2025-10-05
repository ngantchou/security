# Safety Alert App - Setup Guide

## Project Overview
A community-based safety alert application for Cameroon, built with Flutter and Firebase following the BLoC pattern.

---

## Prerequisites

### Required Software
- **Flutter SDK**: 3.9.0 or higher
- **Dart SDK**: 3.9.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase CLI** (optional but recommended)
- **Git**

### Firebase Project Setup
You already have a Firebase project: **alertecameroun**
- Project ID: `alertecameroun`
- Project Number: `771349358607`
- Storage Bucket: `alertecameroun.firebasestorage.app`

---

## Initial Setup

### 1. Clone and Install Dependencies

```bash
# Navigate to project directory
cd /home/user/myapp

# Get all Flutter dependencies
flutter pub get

# Generate localization files
flutter gen-l10n
```

### 2. Firebase Configuration

#### Already Configured:
✅ Android `google-services.json` (located in `android/app/`)
✅ Firebase options file (`lib/firebase_options.dart`)
✅ Android Gradle configuration

#### TODO - Add iOS Configuration:
If you plan to support iOS, you need to:
1. Go to Firebase Console: https://console.firebase.google.com/project/alertecameroun
2. Add an iOS app
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`
5. Update `lib/firebase_options.dart` with iOS API key

### 3. Enable Firebase Services

Go to Firebase Console and enable these services:

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable **Phone** authentication
3. Add authorized domains for your app

#### Firestore Database
1. Go to Firestore Database → Create database
2. Start in **test mode** (change to production rules later)
3. Select your region: `europe-west1` or closest to Cameroon
4. Deploy security rules from `TECHNICAL_SPECIFICATION.md`

#### Storage
1. Go to Storage → Get started
2. Start in **test mode** (change to production rules later)
3. Create folders: `audio/`, `images/`, `profile_photos/`, `verification_documents/`

#### Cloud Messaging
1. Go to Cloud Messaging
2. Already enabled with your Android app
3. No additional configuration needed for basic setup

#### Analytics
Already enabled with Firebase setup

### 4. Google Maps API Key

You need a Google Maps API key for location features:

1. Go to: https://console.cloud.google.com/
2. Select project: `alertecameroun`
3. Enable APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if supporting iOS)
   - Geocoding API
   - Places API
4. Create API key
5. Replace `YOUR_GOOGLE_MAPS_API_KEY` in:
   - `android/app/src/main/AndroidManifest.xml` (line 51)

### 5. Update Package Name (If Needed)

Current package: `waves.digital.virgilant`

If you want to change it:
1. Update `android/app/build.gradle.kts` → `applicationId`
2. Update `android/app/src/main/AndroidManifest.xml` → `package`
3. Rename folder: `android/app/src/main/kotlin/waves/digital/virgilant/`
4. Update `MainActivity.kt` package declaration
5. Re-download `google-services.json` with new package name

---

## Running the App

### Check Flutter Setup
```bash
flutter doctor
```
Fix any issues reported.

### Run on Device/Emulator

#### Android
```bash
# List available devices
flutter devices

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device-id>
```

#### Build APK
```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing configuration)
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

---

## Project Structure

```
lib/
├── core/                          # Core utilities
│   ├── constants/                 # App & Firebase constants
│   ├── error/                     # Error handling
│   ├── network/                   # Network utilities
│   ├── theme/                     # App theming
│   ├── usecases/                  # Base use case
│   └── utils/                     # Enums & extensions
│
├── features/                      # Feature modules (BLoC pattern)
│   ├── auth/                      # Authentication
│   ├── alerts/                    # Alert management
│   ├── danger_groups/             # Danger group features
│   ├── neighborhood_groups/       # Community groups
│   ├── emergency_resources/       # Hospitals, clinics, etc.
│   ├── blood_donors/              # Blood donor registry
│   ├── volunteers/                # Volunteer network
│   ├── funds/                     # Emergency funding
│   └── news/                      # News feed
│
├── l10n/                          # Localization (EN, FR)
├── firebase_options.dart          # Firebase configuration
├── injection_container.dart       # Dependency injection
└── main.dart                      # App entry point
```

---

## Development Workflow

### 1. Adding New Features

Follow Clean Architecture + BLoC:

```
feature_name/
├── data/
│   ├── datasources/              # Remote (Firebase) & Local
│   │   ├── feature_remote_datasource.dart
│   │   └── feature_local_datasource.dart
│   ├── models/                   # Data models with JSON
│   │   └── feature_model.dart
│   └── repositories/             # Repository implementation
│       └── feature_repository_impl.dart
├── domain/
│   ├── entities/                 # Business entities
│   │   └── feature_entity.dart
│   ├── repositories/             # Repository interface
│   │   └── feature_repository.dart
│   └── usecases/                 # Business logic
│       ├── get_feature.dart
│       └── create_feature.dart
└── presentation/
    ├── bloc/                     # State management
    │   ├── feature_bloc.dart
    │   ├── feature_event.dart
    │   └── feature_state.dart
    ├── pages/                    # Screens
    │   └── feature_page.dart
    └── widgets/                  # Reusable components
        └── feature_widget.dart
```

### 2. Code Generation

When you modify entities/models with Freezed or JSON serialization:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Localization

Adding new translations:

1. Add keys to `lib/l10n/app_en.arb`
2. Add translations to `lib/l10n/app_fr.arb`
3. Run: `flutter gen-l10n`
4. Use in code: `AppLocalizations.of(context)!.yourKey`

---

## Firebase Firestore Setup

### Initial Collections to Create

After setting up Firestore, create these collections manually or via Cloud Functions:

#### 1. Danger Groups (for testing)
Collection: `dangerGroups`

Example document:
```json
{
  "groupId": "fire",
  "dangerType": "fire",
  "name": {
    "en": "Fire",
    "fr": "Incendie"
  },
  "description": {
    "en": "Fire incidents and emergencies",
    "fr": "Incidents d'incendie et urgences"
  },
  "icon": "🔥",
  "color": "#FF3B30",
  "followerCount": 0,
  "newsEnabled": true,
  "isActive": true,
  "isRegionSpecific": false,
  "createdAt": <Timestamp>
}
```

Create similar documents for other danger types:
- flood
- armed_robbery
- kidnapping
- separatist_conflict
- boko_haram
- landslide
- riot
- accident
- medical_emergency
- epidemic
- livestock_theft
- natural_disaster

#### 2. Regions Configuration
Collection: `regions`

Add Cameroon regions for filtering:
```json
{
  "regionId": "littoral",
  "name": {
    "en": "Littoral",
    "fr": "Littoral"
  },
  "cities": ["Douala", "Edea", "Nkongsamba"]
}
```

Cameroon Regions:
- Adamawa
- Centre
- East
- Far North
- Littoral
- North
- Northwest
- South
- Southwest
- West

---

## Testing

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/features/auth/auth_test.dart

# With coverage
flutter test --coverage
```

### Testing Checklist
- [ ] Unit tests for use cases
- [ ] Unit tests for BLoCs
- [ ] Widget tests for UI components
- [ ] Integration tests for complete flows
- [ ] Test on real devices (not just emulator)
- [ ] Test offline functionality
- [ ] Test with poor network conditions

---

## Deployment

### Android Release Build

1. **Create Keystore**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Configure Signing**
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. **Update `android/app/build.gradle.kts`**
Add signing configuration (see Flutter docs)

4. **Build Release APK**
```bash
flutter build apk --release
```

5. **Build App Bundle (for Play Store)**
```bash
flutter build appbundle --release
```

### iOS Release Build

```bash
flutter build ios --release
```

Then open Xcode and archive for App Store.

---

## Environment Variables

For sensitive data (API keys, etc.), consider using:
- `flutter_dotenv` package
- Firebase Remote Config
- Environment-specific `firebase_options.dart` files

---

## Troubleshooting

### Issue: Dependencies not resolving
```bash
flutter clean
flutter pub get
```

### Issue: Firebase not connecting
- Check `google-services.json` is in `android/app/`
- Check package name matches Firebase console
- Check internet connection
- Enable Firestore/Auth in Firebase Console

### Issue: Google Maps not showing
- Verify API key in AndroidManifest.xml
- Enable required APIs in Google Cloud Console
- Check internet permission in AndroidManifest.xml

### Issue: Build errors
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Issue: Localization not working
```bash
flutter gen-l10n
flutter clean
flutter run
```

---

## Next Steps

### Immediate Tasks
1. ✅ Firebase setup complete
2. ⏳ Implement Authentication BLoC
3. ⏳ Create Alert creation flow
4. ⏳ Implement map view for nearby alerts
5. ⏳ Add Firebase Cloud Functions (see TECHNICAL_SPECIFICATION.md)

### Future Enhancements
- Push notification handling
- Background location tracking
- SMS fallback for offline alerts
- Mobile money integration
- Blood donor matching algorithm
- Community verification workflow

---

## Resources

### Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Docs](https://firebase.google.com/docs)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Technical Specification](./TECHNICAL_SPECIFICATION.md)
- [Project Structure](./PROJECT_STRUCTURE.md)

### Firebase Console
- Project: https://console.firebase.google.com/project/alertecameroun
- Authentication: https://console.firebase.google.com/project/alertecameroun/authentication
- Firestore: https://console.firebase.google.com/project/alertecameroun/firestore
- Storage: https://console.firebase.google.com/project/alertecameroun/storage

### Support
- Flutter Community: https://flutter.dev/community
- Firebase Community: https://firebase.google.com/community

---

## License
[To be determined]

**Last Updated**: 2025-10-03
**Version**: 1.0.0
