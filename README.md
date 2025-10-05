# Safety Alert Application - Cameroon

A community-driven safety alert mobile application built with Flutter, designed specifically for Cameroon to help communities stay safe and informed about local dangers and emergencies.

## 🎯 Overview

This application enables citizens to quickly report and receive alerts about various types of dangers in their vicinity, fostering community vigilance and rapid emergency response. The app supports multiple local languages and integrates with Cameroon-specific services like mobile money platforms.

## 🏗️ Architecture

- **Pattern**: Clean Architecture + BLoC (Business Logic Component)
- **State Management**: flutter_bloc
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Messaging, Analytics)
- **Geolocation**: GeoFlutterFire for radius-based queries
- **Maps**: Google Maps Flutter

## 📱 Core Features

### ✅ Completed Features (Progress: 100%) 🎉

#### 1. **Authentication System**
- [x] Phone number authentication with OTP
- [x] Guest mode (view-only access)
- [x] User profile management
- [x] BLoC-based state management

#### 2. **Alert Creation & Management**
- [x] Create alerts with danger types, levels (1-5), description
- [x] Automatic geolocation with reverse geocoding
- [x] Image upload support (up to 3 images)
- [x] Real-time Firestore integration
- [x] Alert status management (active, resolved, false alarm)

#### 3. **Alert Viewing**
- [x] **Map View**: Google Maps with color-coded markers by alert level
  - Green (Level 1) → Red (Level 5)
  - User location tracking
  - Radius circle visualization (1-50 km)
  - Real-time alert updates via streams
- [x] **List View**: Scrollable alert cards with pull-to-refresh
  - Alert count header
  - Filter by radius
  - Empty state handling
- [x] **Alert Detail Sheet**: Draggable bottom sheet with full information
  - Stats (views, confirmations, help offered)
  - Location details
  - Creator information
  - Action buttons (Confirm, Offer Help)

#### 4. **Navigation**
- [x] Seamless switching between Map and List views
- [x] Home page with quick access to all features
- [x] Floating action buttons for view switching

#### 5. **Multi-language Support**
- [x] Infrastructure setup for French, English, Pidgin
- [x] ARB files configuration
- [x] Internationalization ready

#### 6. **Technical Infrastructure**
- [x] Clean Architecture (3 layers: Domain, Data, Presentation)
- [x] Dependency Injection (GetIt)
- [x] Error handling with Either pattern (dartz)
- [x] Firebase services integration
- [x] Audio recording package configured (record)

---

### 🔨 Recently Completed

#### 7. **Voice Alerts & Audio Recording** ✅
- [x] Record package enabled with Linux compatibility fix
- [x] Audio recording widget implementation with pause/resume
- [x] Audio playback widget with seek controls
- [x] Firebase Storage service for audio uploads
- [x] Audio recording integrated in alert creation
- [x] Audio playback in alert detail view
- [x] Audio comments on existing alerts

#### 22. **Push Notifications** ✅
- [x] Firebase Cloud Messaging integration
- [x] Local notifications with priority channels
- [x] Real-time danger alerts in vicinity
- [x] Configurable notification radius (1-50 km)
- [x] Notification preferences by danger type
- [x] Sound/vibration customization
- [x] Do Not Disturb mode
- [x] Notification settings page
- [ ] Server-side notification triggers (pending)

#### 8. **Cameroon-Specific Danger Type Groups** ✅
- [x] Organized danger categories:
  - Crime & Security (armed robbery, kidnapping, livestock theft, separatist conflict, boko haram)
  - Health Emergencies (medical emergency, epidemic)
  - Natural Disasters (fire, flood, landslide, natural disaster)
  - Traffic & Transport (accident)
  - Public Safety (riot)
- [x] Danger group icons and localized names
- [x] Filter news feed by danger groups or individual types
- [x] Toggle between group and type filtering
- [ ] Infrastructure group (pending - no danger types assigned)

#### 9. **News Feed for Danger Groups** ✅
- [x] Feed of alerts from followed groups
- [x] Filter by danger type or danger group
- [x] Sort by proximity, time, or severity
- [x] Post creation for group members
- [x] Pull-to-refresh functionality
- [x] Empty state with group discovery link
- [x] Group discovery page with search
- [x] Follow/unfollow groups
- [x] Group cards with stats (members, alerts, posts)

#### 11. **Alert Interactions** ✅
- [x] Confirm alert (increase verification count)
- [x] Offer help (volunteer assistance)
- [x] Mark as resolved
- [x] Report false alarm
- [x] Share alert externally

#### 21. **Offline Mode** ✅
- [x] Local storage with Hive
- [x] Offline alert creation (queued for sync)
- [x] Automatic sync when connectivity restored
- [x] Sync service with retry logic
- [x] Offline indicator in UI
- [x] Pending alerts counter
- [x] Network connectivity monitoring
- [ ] Cached map tiles (pending)
- [ ] Offline alert viewing (pending - currently caches online alerts)

#### 23. **User Profiles** ✅
- [x] Profile picture upload and display
- [x] Bio field (max 150 characters)
- [x] Location fields (region, city, neighborhood)
- [x] Edit profile page with image picker
- [x] Verification badges display
- [x] Alert history statistics
- [x] Contribution points and level
- [x] Recent activity feed
- [x] Badge grid (earned/unearned)
- [ ] Privacy settings (pending)

#### 10. **Commenting System** ✅
- [x] Text comments on alerts
- [x] Audio comments (voice notes)
- [x] Comment moderation (flagging)
- [x] Reply to comments (threading)
- [x] Like/unlike comments
- [x] Real-time comment updates
- [x] Edit and delete own comments
- [x] User profile pictures in comments

#### 12. **Neighborhood Watch Groups** ✅
- [x] Create/join local watch groups
- [x] Group coordinators with admin privileges
- [x] Member directory with skills tracking
- [x] Member approval workflow
- [x] Meeting scheduling
- [x] RSVP to meetings
- [x] Location-based group discovery (GeoFlutterFire)
- [x] Private/public groups
- [x] Role management (Coordinator, Moderator, Member)
- [x] Group statistics (members, alerts, meetings)

#### 13. **Community Verification System** ✅
- [x] Trusted user badges (14 badge types)
- [x] Verification levels (Bronze, Silver, Gold, Platinum, Diamond)
- [x] Contribution score system
- [x] Reputation tracking
- [x] Verified professional accounts
- [x] Badge display on profiles
- [x] Level progression system

#### 14. **Resource Sharing** ✅
- [x] Emergency resource directory:
  - Generators
  - Medical supplies
  - Safe houses/shelters
  - Water sources
  - Food supplies
  - Vehicles, Tools, Communication equipment
- [x] Resource availability tracking
- [x] Request/offer resources
- [x] Location-based resource discovery
- [x] Resource status management
- [x] Request approval workflow

#### 15. **Volunteer Responder Network** ✅
- [x] Register as emergency volunteer
- [x] Skills/specialization tags (10 skill types)
  - First Aid, Medic, Rescue, Firefighting
  - Security, Translation, Counseling
  - Logistics, Communication
- [x] Proximity-based volunteer alerts (configurable radius)
- [x] Response confirmation system
- [x] Volunteer statistics (responses, rating)
- [x] Availability toggle

#### 16. **Hospital/Clinic Database** ✅
- [x] Medical facilities directory
- [x] Contact information (phone, emergency line)
- [x] Facility types (Hospital, Clinic, Health Center, Pharmacy)
- [x] Specializations and services
- [x] Operating hours & 24/7 service indicator
- [x] Ambulance & Emergency Room availability
- [x] Location-based search with GeoFlutterFire

#### 17. **Blood Donor Registry** ✅
- [x] Register as blood donor
- [x] All blood types (A+, A-, B+, B-, O+, O-, AB+, AB-)
- [x] Location-based donor search
- [x] Availability status with auto-calculation
- [x] 90-day donation interval tracking
- [x] Urgent blood request system
- [x] Donation history

#### 18. **NGO/Humanitarian Integration** ✅
- [x] Partner organization directory
- [x] NGO types (International, National, Local, Faith-based, Community)
- [x] NGO-specific alert channels with subscriptions
- [x] Focus areas tracking (Health, Education, Relief, etc.)
- [x] Volunteer opportunity listings
- [x] Resource coordination with NGOs
- [x] Volunteer recruitment system
- [x] Verification system for NGOs
- [x] Project tracking
- [x] Contact management (email, phone, website)

#### 19. **Mobile Money Integration** ✅
- [x] MTN Mobile Money (MTN MoMo) integration
- [x] Orange Money integration
- [x] Emergency crowdfunding campaigns
- [x] Campaign categories (Medical, Emergency, Education, Infrastructure, Disaster)
- [x] Donation tracking with donor history
- [x] Transaction management
- [x] Payment statuses (Pending, Processing, Completed, Failed, Refunded)
- [x] Anonymous donation option
- [x] Campaign progress tracking
- [x] Multiple payment types (Donation, Community Fund, Resource Purchase)
- [x] Currency support (XAF - Central African CFA franc)

#### 20. **Community Emergency Fund** ✅
- [x] Collective fund contributions (one-time & recurring)
- [x] Emergency disbursement requests
- [x] Transparent fund management with transaction history
- [x] Contribution history tracking
- [x] Real-time fund balance visibility
- [x] Multi-administrator approval system
- [x] Voting mechanism for disbursements
- [x] Fund rules configuration (min/max amounts, approvals needed)
- [x] Emergency categories (Medical, Housing, Food, Education, Disaster, Funeral)
- [x] Supporting documentation system
- [x] Disbursement tracking and receipts
- [x] Community-level fund management (Region/City/Neighborhood)

---

### 🎊 ALL CORE FEATURES COMPLETE! (100%)

The Safety Alert Application for Cameroon is now feature-complete with **20 major features** fully implemented!

#### Additional Enhancement Opportunities:

#### 22. **Server-side Notification Triggers** (Optional Enhancement)
- [ ] Cloud Functions for automatic notification sending
- [ ] Trigger notifications when new alerts are created
- [ ] Location-based notification targeting
- [ ] Batch notification processing

#### 24. **Analytics Dashboard**
- [ ] Alert statistics (by type, time, location)
- [ ] Community safety score
- [ ] Trending dangers
- [ ] Response time metrics
- [ ] User engagement analytics

#### 25. **Admin Panel**
- [ ] Content moderation
- [ ] User management (ban, verify)
- [ ] Alert verification
- [ ] Spam detection
- [ ] System monitoring

#### 26. **Advanced Features**
- [ ] SOS panic button with auto-alert
- [ ] Emergency contact quick dial
- [ ] Offline maps
- [ ] Video evidence upload
- [ ] AI-powered alert categorization
- [ ] Translation of user content

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.9+
- **Language**: Dart
- **State Management**: flutter_bloc ^8.1.6
- **Functional Programming**: dartz ^0.10.1
- **Dependency Injection**: get_it ^8.0.0

### Backend & Services
- **Authentication**: Firebase Auth (Phone)
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Geolocation**: geolocator ^13.0.1, geoflutterfire_plus ^0.0.3
- **Maps**: google_maps_flutter ^2.9.0
- **Geocoding**: geocoding ^3.0.0

### Additional Packages
- **Audio**: record ^5.2.1, audioplayers ^6.1.0
- **Images**: image_picker ^1.1.2, cached_network_image ^3.4.1
- **Notifications**: flutter_local_notifications ^17.2.3
- **Network**: http ^1.2.2, dio ^5.7.0
- **Storage**: shared_preferences ^2.3.2
- **Permissions**: permission_handler ^11.3.1
- **UI**: flutter_svg ^2.0.10, shimmer ^3.0.0, pull_to_refresh ^2.0.0
- **Connectivity**: connectivity_plus ^6.0.5
- **Utils**: intl, url_launcher ^6.3.1

### Code Generation
- **JSON**: json_serializable ^6.8.0
- **Freezed**: freezed ^2.5.2
- **Build Runner**: build_runner ^2.4.12

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── enums.dart
│   │   ├── extensions.dart
│   │   └── validators.dart
│   └── usecases/
│       └── usecase.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_phone.dart
│   │   │       ├── verify_otp.dart
│   │   │       ├── sign_out.dart
│   │   │       └── continue_as_guest.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           ├── welcome_page.dart
│   │           ├── phone_input_page.dart
│   │           └── otp_verification_page.dart
│   ├── alerts/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── alert_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── alert_model.dart
│   │   │   └── repositories/
│   │   │       └── alert_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── alert_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── alert_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_alert.dart
│   │   │       ├── get_nearby_alerts.dart
│   │   │       └── watch_nearby_alerts.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── alert_bloc.dart
│   │       │   ├── alert_event.dart
│   │       │   └── alert_state.dart
│   │       ├── pages/
│   │       │   ├── create_alert_page.dart
│   │       │   ├── map_view_page.dart
│   │       │   └── alerts_list_page.dart
│   │       └── widgets/
│   │           ├── alert_card.dart
│   │           └── alert_detail_sheet.dart
│   └── home/
│       └── presentation/
│           └── pages/
│               └── home_page.dart
├── l10n/
│   ├── app_en.arb
│   ├── app_fr.arb
│   └── app_pcm.arb (Pidgin)
├── injection_container.dart
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK (3.9.0 or higher)
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd myapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

### Build Commands

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# iOS build
flutter build ios --release
```

---

## 🌍 Localization

The app supports multiple languages to serve Cameroon's diverse population:

- **French** (Français) - Primary official language
- **English** - Secondary official language
- **Pidgin** (Cameroon Pidgin English) - Widely spoken
- **Future**: Support for local languages (Ewondo, Duala, Fulfulde, etc.)

### Adding Translations

1. Edit ARB files in `lib/l10n/`
2. Run code generation:
   ```bash
   flutter gen-l10n
   ```

---

## 🔐 Security & Privacy

- Phone numbers hashed before storage
- Location data encrypted in transit
- User data compliant with privacy regulations
- Secure Firebase rules for data access
- No third-party data sharing without consent

---

## 🤝 Contributing

This is a community-driven project. Contributions are welcome!

### Priority Areas
1. Voice alerts and audio recording UI
2. Danger type groups and news feed
3. Mobile money integration (MTN/Orange)
4. Offline mode
5. Localization improvements

---

## 📄 License

TBD - To be determined

---

## 📞 Contact & Support

For questions, suggestions, or support:
- GitHub Issues: [Create an issue]
- Email: TBD

---

## 🙏 Acknowledgments

- Cameroon developer community
- Firebase team for backend infrastructure
- Flutter team for excellent framework
- All contributors and testers

---

**Built with ❤️ for Cameroon 🇨🇲**
