# Deployment Guide - Safety Alert Application

## Prerequisites

### Required Accounts
- [ ] Google Play Console account ($25 one-time fee)
- [ ] Apple Developer account ($99/year)
- [ ] Firebase project (already set up)
- [ ] Google Cloud account (for Cloud Functions - optional)

### Required Tools
- [ ] Flutter 3.9+ installed
- [ ] Xcode 14+ (for iOS builds - macOS only)
- [ ] Android Studio with SDK 33+
- [ ] Firebase CLI: `npm install -g firebase-tools`
- [ ] Fastlane (optional, for automated deployment)

### Code Signing
- [ ] Android: Keystore file generated
- [ ] iOS: Distribution certificate and provisioning profiles

## Environment Configuration

### 1. Firebase Production Setup

#### Create Production Project
```bash
# Login to Firebase
firebase login

# Create new project or use existing
firebase projects:list
```

#### Configure Firebase Services
1. **Authentication:**
   - Enable Phone Authentication
   - Add authorized domains for production

2. **Firestore:**
   - Create production database
   - Deploy security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
   - Create indexes:
   ```bash
   firebase deploy --only firestore:indexes
   ```

3. **Cloud Storage:**
   - Configure CORS for image uploads
   - Deploy storage rules:
   ```bash
   firebase deploy --only storage
   ```

4. **Cloud Messaging (FCM):**
   - Download production `google-services.json` (Android)
   - Download production `GoogleService-Info.plist` (iOS)
   - Replace development files with production files

5. **Analytics:**
   - Already configured, verify in Firebase console

#### Security Rules Examples

**Firestore Rules (`firestore.rules`):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Alerts collection
    match /alerts/{alertId} {
      allow read: if true; // Public read
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (request.auth.uid == resource.data.creatorId ||
         request.resource.data.diff(resource.data).affectedKeys().hasOnly(['confirmations', 'resolvedAt', 'isFalseAlarm']));
      allow delete: if request.auth.uid == resource.data.creatorId;
    }

    // Users collection
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }

    // Watch groups
    match /watch_groups/{groupId} {
      allow read: if resource.data.isPrivate == false ||
        request.auth.uid in resource.data.memberIds;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.coordinatorId ||
        request.auth.uid in resource.data.administratorIds;
    }

    // Community fund
    match /community_funds/{fundId} {
      allow read: if true;
      allow write: if request.auth.uid in resource.data.administratorIds;
    }
  }
}
```

**Storage Rules (`storage.rules`):**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /alerts/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.resource.size < 10 * 1024 * 1024 && // 10MB limit
        request.resource.contentType.matches('image/.*');
    }

    match /profile_photos/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId &&
        request.resource.size < 5 * 1024 * 1024 && // 5MB limit
        request.resource.contentType.matches('image/.*');
    }
  }
}
```

### 2. Environment Variables

Create production configuration:

**`.env.production`:**
```env
FIREBASE_API_KEY=your_production_api_key
FIREBASE_PROJECT_ID=your_production_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_production_app_id
FIREBASE_MEASUREMENT_ID=your_measurement_id

# Google Maps API Key
GOOGLE_MAPS_API_KEY=your_production_maps_key

# Mobile Money Integration (for production)
MTN_MOMO_API_KEY=your_mtn_api_key
MTN_MOMO_USER_ID=your_mtn_user_id
MTN_MOMO_SUBSCRIPTION_KEY=your_subscription_key
ORANGE_MONEY_API_KEY=your_orange_api_key
```

## Android Deployment

### 1. Generate Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 2. Configure Key Properties

Create `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

Add to `.gitignore`:
```
**/android/key.properties
**/upload-keystore.jks
```

### 3. Update App Information

**`android/app/build.gradle.kts`:**
```kotlin
android {
    defaultConfig {
        applicationId = "com.cameroon.safetyalert"
        minSdk = 24
        targetSdk = 34
        versionCode = 1  // Increment for each release
        versionName = "1.0.0"  // Update version
    }
}
```

### 4. Build Release APK/AAB

```bash
# Clean build
flutter clean
flutter pub get

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Build APK (for direct distribution)
flutter build apk --release --split-per-abi

# Output locations:
# AAB: build/app/outputs/bundle/release/app-release.aab
# APK: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
#      build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
#      build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### 5. Google Play Console Setup

1. **Create App:**
   - Go to Google Play Console
   - Create new application
   - Select default language and app name

2. **App Content:**
   - Privacy Policy URL
   - App category: Health & Fitness / Lifestyle
   - Target audience: 18+
   - Data safety section: Declare data collection practices

3. **Store Listing:**
   - App title: "Safety Alert - Cameroon"
   - Short description (80 chars max)
   - Full description (4000 chars max)
   - Screenshots (minimum 2): Phone, 7-inch tablet, 10-inch tablet
   - Feature graphic: 1024 x 500
   - App icon: 512 x 512

4. **Content Rating:**
   - Complete IARC questionnaire
   - Expected rating: Everyone/PEGI 3

5. **Upload Release:**
   - Production track
   - Upload AAB file
   - Release name: "1.0.0"
   - Release notes (what's new)
   - Review and rollout

### 6. Post-Launch

```bash
# Monitor crash reports
# Google Play Console > Quality > Android vitals

# Track installations
# Google Play Console > Statistics
```

## iOS Deployment

### 1. Configure Xcode Project

Open `ios/Runner.xcworkspace` in Xcode:

1. **General Tab:**
   - Display Name: "Safety Alert"
   - Bundle Identifier: `com.cameroon.safetyalert`
   - Version: 1.0.0
   - Build: 1

2. **Signing & Capabilities:**
   - Team: Select your Apple Developer team
   - Signing Certificate: Apple Distribution
   - Provisioning Profile: App Store profile

3. **Info.plist:**
   - Privacy descriptions already configured
   - Verify all location/camera/photo permissions

### 2. App Store Connect Setup

1. **Create App:**
   - Go to App Store Connect
   - My Apps > + > New App
   - Platform: iOS
   - Name: "Safety Alert - Cameroon"
   - Primary Language: English
   - Bundle ID: Select created identifier
   - SKU: safetyalert-cameroon
   - User Access: Full Access

2. **App Information:**
   - Privacy Policy URL
   - Category: Health & Fitness / Lifestyle
   - License Agreement: Standard

3. **Pricing and Availability:**
   - Price: Free
   - Availability: Cameroon (or worldwide)

### 3. Build and Archive

```bash
# Clean build
flutter clean
cd ios
pod install
cd ..

# Build iOS release
flutter build ios --release

# Open Xcode to archive
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device (arm64)" as destination
2. Product > Archive
3. Wait for archive to complete
4. Window > Organizer > Archives
5. Select archive > Distribute App > App Store Connect > Upload
6. Select signing options > Upload

### 4. TestFlight

1. **Internal Testing:**
   - Add internal testers
   - Distribute build
   - Collect feedback

2. **External Testing:**
   - Create external test group
   - Add testers via email/public link
   - Submit for beta review

### 5. App Store Submission

1. **Prepare Metadata:**
   - Screenshots (required sizes for all devices)
   - Preview videos (optional)
   - Description
   - Keywords
   - Support URL
   - Marketing URL (optional)

2. **Build Selection:**
   - Select uploaded build from TestFlight

3. **Submit for Review:**
   - Complete all required fields
   - Submit for review
   - Average review time: 24-48 hours

### 6. Post-Launch

```bash
# Monitor TestFlight feedback
# App Store Connect > TestFlight > Builds

# Track crash reports
# App Store Connect > Analytics > Crashes

# Monitor reviews
# App Store Connect > Ratings and Reviews
```

## Cloud Functions (Optional)

### 1. Initialize Functions

```bash
firebase init functions
cd functions
npm install
```

### 2. Example Functions

**Scheduled Alert Cleanup:**
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Delete resolved alerts older than 30 days
exports.cleanupOldAlerts = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const db = admin.firestore();
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const snapshot = await db.collection('alerts')
      .where('resolvedAt', '<', thirtyDaysAgo)
      .get();

    const batch = db.batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();

    console.log(`Deleted ${snapshot.size} old alerts`);
  });

// Send notifications for nearby alerts
exports.sendAlertNotifications = functions.firestore
  .document('alerts/{alertId}')
  .onCreate(async (snap, context) => {
    const alert = snap.data();

    // Query users within radius
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('notificationsEnabled', '==', true)
      .get();

    const tokens = [];
    usersSnapshot.forEach(doc => {
      const user = doc.data();
      if (user.fcmToken) {
        tokens.push(user.fcmToken);
      }
    });

    if (tokens.length === 0) return;

    const payload = {
      notification: {
        title: `${alert.dangerType} Alert Nearby`,
        body: alert.description,
      },
      data: {
        alertId: context.params.alertId,
        latitude: alert.latitude.toString(),
        longitude: alert.longitude.toString(),
        level: alert.level.toString(),
      }
    };

    return admin.messaging().sendToDevice(tokens, payload);
  });
```

### 3. Deploy Functions

```bash
firebase deploy --only functions
```

## Testing Checklist

### Pre-Deployment Testing

- [ ] **Authentication:**
  - [ ] Phone number sign-in works
  - [ ] Sign out works
  - [ ] Profile update works

- [ ] **Core Features:**
  - [ ] Create alert with photo
  - [ ] View alerts on map
  - [ ] Filter by danger type and level
  - [ ] Confirm alert
  - [ ] Resolve alert
  - [ ] Report false alarm

- [ ] **Location Services:**
  - [ ] GPS location accurate
  - [ ] Radius filtering works
  - [ ] Map markers display correctly

- [ ] **Offline Mode:**
  - [ ] Create alert offline
  - [ ] View cached alerts
  - [ ] Sync when online

- [ ] **Notifications:**
  - [ ] Receive push notifications
  - [ ] Notification settings work
  - [ ] DND mode works

- [ ] **Neighborhood Watch:**
  - [ ] Create watch group
  - [ ] Join group
  - [ ] Create meeting
  - [ ] RSVP to meeting

- [ ] **Performance:**
  - [ ] App launch < 3 seconds
  - [ ] Smooth scrolling
  - [ ] No memory leaks
  - [ ] Battery usage acceptable

- [ ] **Localization:**
  - [ ] French translations complete
  - [ ] English translations complete

### Platform-Specific Testing

**Android:**
- [ ] Test on Android 7+ devices
- [ ] Test different screen sizes
- [ ] Back button navigation
- [ ] Share functionality
- [ ] App permissions work

**iOS:**
- [ ] Test on iOS 12+ devices
- [ ] Test on iPhone and iPad
- [ ] Swipe gestures work
- [ ] App permissions work
- [ ] Dark mode support

## Performance Optimization

### 1. Image Optimization

```dart
// In firebase_storage_service.dart
Future<String> uploadImage(File image) async {
  // Compress before upload
  final compressedImage = await FlutterImageCompress.compressAndGetFile(
    image.absolute.path,
    image.path.replaceAll('.jpg', '_compressed.jpg'),
    quality: 85,
    minWidth: 1920,
    minHeight: 1080,
  );
  // Upload compressed image
}
```

### 2. Firestore Optimization

```dart
// Use pagination for large lists
QuerySnapshot getAlerts({DocumentSnapshot? startAfter}) {
  Query query = firestore.collection('alerts')
    .orderBy('createdAt', descending: true)
    .limit(20);

  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }

  return query.get();
}
```

### 3. Enable Proguard (Android)

Already configured in `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        proguardFiles(getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro')
    }
}
```

## Monitoring and Analytics

### 1. Firebase Analytics Events

```dart
// Track important user actions
analytics.logEvent(
  name: 'alert_created',
  parameters: {
    'danger_type': dangerType,
    'level': level,
  },
);
```

### 2. Crashlytics Setup

```dart
// In main.dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

### 3. Performance Monitoring

```dart
// Track custom traces
final trace = FirebasePerformance.instance.newTrace('alert_creation');
await trace.start();
// ... create alert
await trace.stop();
```

## Post-Deployment

### 1. Monitor Key Metrics

- Daily Active Users (DAU)
- Alerts created per day
- User retention rate
- Crash-free users percentage
- Average session duration
- Notification click-through rate

### 2. User Feedback

- Monitor app store reviews
- Set up in-app feedback mechanism
- Create support email: support@safetyalert-cameroon.com
- Monitor social media mentions

### 3. Regular Updates

- Bug fixes: Weekly as needed
- Feature updates: Monthly
- Security patches: Immediate
- Version naming: Semantic versioning (MAJOR.MINOR.PATCH)

## Security Considerations

### 1. API Keys

- Store in environment variables
- Never commit to version control
- Rotate keys periodically
- Use Firebase App Check to prevent API abuse

### 2. Data Privacy

- Implement user data deletion
- GDPR compliance for EU users
- Anonymous alert options
- Data retention policies

### 3. Authentication

- Implement rate limiting for phone auth
- Monitor suspicious activity
- Enable App Check for Firebase services

## Backup and Recovery

### 1. Firestore Backup

```bash
# Automated daily backups
gcloud firestore export gs://your-bucket/backups/$(date +%Y%m%d)
```

### 2. User Data Export

Implement data export functionality:
```dart
Future<Map<String, dynamic>> exportUserData(String userId) async {
  final userData = await firestore.collection('users').doc(userId).get();
  final alerts = await firestore.collection('alerts')
    .where('creatorId', isEqualTo: userId)
    .get();

  return {
    'profile': userData.data(),
    'alerts': alerts.docs.map((d) => d.data()).toList(),
  };
}
```

## Support and Maintenance

### Contact Information

- **Developer Email:** dev@safetyalert-cameroon.com
- **Support Email:** support@safetyalert-cameroon.com
- **Emergency Contact:** +237-XXX-XXX-XXX

### Maintenance Schedule

- **Daily:** Monitor crash reports and critical errors
- **Weekly:** Review user feedback and analytics
- **Monthly:** Security updates and feature releases
- **Quarterly:** Performance optimization review

## Rollback Plan

In case of critical issues:

1. **Immediate:**
   - Halt rollout in Play Console/App Store Connect
   - Communicate issue to users via notification

2. **Investigation:**
   - Check Firebase Crashlytics
   - Review recent code changes
   - Identify root cause

3. **Resolution:**
   - Deploy hotfix if possible
   - Otherwise, rollback to previous version
   - Submit emergency update

## Version History

| Version | Release Date | Changes |
|---------|-------------|---------|
| 1.0.0   | TBD         | Initial release - All 20 core features |

---

**Last Updated:** October 5, 2025
**Status:** Ready for Production Deployment
