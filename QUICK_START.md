# Quick Start Guide - Safety Alert App

## ✅ What's Already Done

### Firebase Configuration
- ✅ Android: `google-services.json` configured
- ✅ iOS: `GoogleService-Info.plist` configured
- ✅ Firebase options file created
- ✅ Package name: `waves.digital.virgilant`
- ✅ Project ID: `alertecameroun`

### Project Setup
- ✅ Flutter BLoC architecture implemented
- ✅ All dependencies added (Firebase, geolocation, audio, etc.)
- ✅ Multi-language support (English & French)
- ✅ Theme configuration
- ✅ Core utilities (enums, extensions, constants)
- ✅ Base entities (User, Alert)
- ✅ Dependency injection setup
- ✅ Android permissions configured

## 🚀 Get Started in 3 Steps

### Step 1: Install Dependencies
```bash
cd /home/user/myapp
flutter pub get
```

### Step 2: Enable Firebase Services

Go to [Firebase Console](https://console.firebase.google.com/project/alertecameroun) and enable:

1. **Authentication** → Phone authentication
2. **Firestore Database** → Create database (test mode)
3. **Storage** → Enable storage
4. **Cloud Messaging** → Already enabled

### Step 3: Run the App
```bash
flutter run
```

## 📱 First Run

When you run the app, you'll see a red splash screen with:
- App logo (emergency icon)
- "Safety Alert" title
- "Community Safety Network" subtitle
- Loading indicator

This confirms Firebase is initializing correctly!

## 🔑 Get Google Maps API Key

For location features to work:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `alertecameroun`
3. Enable APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
4. Create API key
5. Update in `android/app/src/main/AndroidManifest.xml` line 51:
   ```xml
   android:value="YOUR_GOOGLE_MAPS_API_KEY"
   ```

## 📂 Important Files

### Configuration
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
- `lib/firebase_options.dart` - Flutter Firebase options
- `lib/main.dart` - App entry point

### Documentation
- `TECHNICAL_SPECIFICATION.md` - Complete system design & Firebase schema
- `PROJECT_STRUCTURE.md` - BLoC architecture & folder structure
- `SETUP_GUIDE.md` - Detailed setup instructions
- `README.md` - Original project requirements (French)

## 🎯 Next Development Tasks

### 1. Firebase Firestore Setup
Create initial collections in Firebase Console:
- `dangerGroups` - For danger type categories
- `regions` - Cameroon regions configuration

See `SETUP_GUIDE.md` for sample data.

### 2. Implement Authentication
- Phone number authentication screen
- OTP verification
- User profile setup
- Location permission request

### 3. Create Alert Flow
- Alert creation screen
- Danger type selection
- Location picker
- Photo/audio attachment
- Alert submission to Firestore

### 4. Build Home Screen
- Map view with nearby alerts
- Alert list view
- Bottom navigation
- Filter by danger type

## 🛠️ Development Commands

```bash
# Run app
flutter run

# Run with specific device
flutter run -d <device-id>

# Build APK
flutter build apk --release

# Clean build
flutter clean && flutter pub get

# Generate localization
flutter gen-l10n

# Run tests
flutter test

# Check for issues
flutter doctor
```

## 📊 Project Stats

- **Total Features Planned**: 20+
- **Completed**: 6/20 (30%)
  - ✅ Project structure
  - ✅ Dependencies
  - ✅ Multi-language
  - ✅ Base entities
  - ✅ Firebase config
  - ✅ Core utilities

- **In Progress**:
  - 🔄 Authentication BLoC
  - 🔄 Alert system

- **Pending**:
  - Danger groups
  - News feed
  - Neighborhood watch
  - Emergency resources
  - Blood donor registry
  - Volunteer network
  - Mobile money integration
  - Emergency funds

## 🌍 Cameroon-Specific Features

### Danger Types Configured
1. Fire (Incendie) 🔥
2. Flood (Inondation) 🌊
3. Armed Robbery (Vol à Main Armée) 🔫
4. Kidnapping (Enlèvement) ⚠️
5. Separatist Conflict (Conflit Séparatiste) ⚔️
6. Boko Haram Activity 🚨
7. Landslide (Glissement de Terrain) 🏔️
8. Riot (Émeute) 👥
9. Medical Emergency (Urgence Médicale) 🏥
10. Epidemic (Épidémie) 🦠
11. Livestock Theft (Vol de Bétail) 🐄
12. Natural Disaster (Catastrophe Naturelle) 🌪️

### Regions Coverage
All 10 Cameroon regions supported:
- Adamawa, Centre, East, Far North
- Littoral, North, Northwest, South
- Southwest, West

### Payment Methods
- MTN Mobile Money (MTN MoMo)
- Orange Money

## 📞 Support & Resources

### Documentation
- Flutter: https://docs.flutter.dev/
- Firebase: https://firebase.google.com/docs
- BLoC: https://bloclibrary.dev/

### Firebase Project
- Console: https://console.firebase.google.com/project/alertecameroun
- Project ID: `alertecameroun`
- Package: `waves.digital.virgilant`

## 🎨 App Branding

- **Primary Color**: Red (#FF3B30) - For alerts and urgency
- **Secondary Color**: Blue (#007AFF) - For actions
- **Accent Color**: Green (#34C759) - For success

Alert levels use color coding:
- Level 1: Green (Low)
- Level 2: Yellow (Medium-Low)
- Level 3: Orange (Medium)
- Level 4: Red-Orange (High)
- Level 5: Red (Critical)

## ⚡ Quick Tips

1. **Always run `flutter pub get` after pulling changes**
2. **Use `flutter clean` if you encounter build issues**
3. **Test on real devices, not just emulators**
4. **Check Firebase Console for real-time data**
5. **Read `TECHNICAL_SPECIFICATION.md` for Firebase schema**
6. **Follow BLoC pattern - see `PROJECT_STRUCTURE.md`**

## 🐛 Common Issues

**Build fails?**
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run
```

**Firebase not connecting?**
- Check internet connection
- Verify `google-services.json` in `android/app/`
- Enable services in Firebase Console

**Maps not showing?**
- Add Google Maps API key
- Enable required APIs in Google Cloud

---

**Ready to build?** Start with implementing the Authentication BLoC!

See `SETUP_GUIDE.md` for detailed instructions.

**Version**: 1.0.0
**Last Updated**: 2025-10-03
