# Project Structure - Safety Alert App (BLoC Pattern)

## Overview
This Flutter application follows Clean Architecture principles with the BLoC (Business Logic Component) pattern for state management.

## Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # App-wide constants
│   │   └── firebase_constants.dart     # Firebase collection/path constants
│   ├── error/
│   │   ├── exceptions.dart             # Exception classes
│   │   └── failures.dart               # Failure classes for Either<>
│   ├── network/
│   │   └── network_info.dart           # Network connectivity checking
│   ├── theme/
│   │   └── app_theme.dart              # App theme configuration
│   ├── usecases/
│   │   └── usecase.dart                # Base UseCase class
│   └── utils/
│       ├── enums.dart                  # All app enums
│       └── extensions.dart             # Extension methods
│
├── features/                           # Feature-based modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/           # Remote & Local data sources
│   │   │   ├── models/                # Data models (with JSON serialization)
│   │   │   └── repositories/          # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/              # Business entities
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/          # Repository interfaces
│   │   │   └── usecases/              # Business logic use cases
│   │   └── presentation/
│   │       ├── bloc/                  # BLoC files (events, states, bloc)
│   │       ├── pages/                 # Full screen pages
│   │       └── widgets/               # Reusable widgets
│   │
│   ├── alerts/
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── alert_entity.dart
│   │   └── presentation/
│   │
│   ├── danger_groups/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── neighborhood_groups/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── emergency_resources/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── blood_donors/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── volunteers/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── funds/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── news/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── l10n/                               # Localization files
│   ├── app_en.arb                     # English translations
│   ├── app_fr.arb                     # French translations
│   └── (app_pidgin.arb, etc.)         # Other languages
│
├── injection_container.dart            # Dependency injection setup (GetIt)
└── main.dart                           # App entry point

assets/
├── images/                             # Image assets
├── icons/                              # Icon assets
└── sounds/                             # Sound/audio assets
```

## Architecture Layers

### 1. Domain Layer (Business Logic)
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract classes defining data operations
- **Use Cases**: Single-responsibility business logic operations

### 2. Data Layer
- **Models**: Data Transfer Objects with JSON serialization
- **Data Sources**:
  - Remote: Firebase Firestore, Storage, Auth
  - Local: SharedPreferences, device storage
- **Repository Implementations**: Concrete implementations of domain repositories

### 3. Presentation Layer
- **BLoC**: State management
  - Events: User actions
  - States: UI states
  - BLoC: Business logic between events and states
- **Pages**: Full screen widgets
- **Widgets**: Reusable UI components

## BLoC Pattern Flow

```
User Action (UI)
    ↓
Event (in BLoC)
    ↓
BLoC processes event
    ↓
Calls UseCase (Domain)
    ↓
UseCase calls Repository (Domain Interface)
    ↓
Repository Implementation (Data Layer)
    ↓
DataSource (Remote/Local)
    ↓
Returns Either<Failure, Data>
    ↓
BLoC emits new State
    ↓
UI rebuilds based on State
```

## Key Features Implementation

### 1. Authentication
- Phone number authentication with Firebase Auth
- User profile management
- Verification system (National ID / Community Vouching)

### 2. Alerts
- Create, read, update, delete alerts
- Geolocation-based nearby alerts
- Alert confirmation system
- Automatic authority notification
- Real-time updates

### 3. Danger Groups
- Follow/unfollow danger types
- News feed for each group
- Comment system
- Group-specific notifications

### 4. Neighborhood Watch
- Create/join neighborhood groups
- Coordinator management
- Group-based alerts
- Community verification

### 5. Emergency Resources
- Hospital/clinic database
- Blood donor registry
- Volunteer responder network
- NGO integration

### 6. Financial Features
- Mobile Money integration (MTN MoMo, Orange Money)
- Emergency fund campaigns
- Community emergency fund
- Contribution tracking

### 7. Multi-language Support
- English, French, Pidgin, Fulfulde, Ewondo, Duala
- Voice alerts and audio comments
- Accessibility features

## Dependencies

### State Management
- `flutter_bloc` - BLoC pattern implementation
- `equatable` - Value equality for entities

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - NoSQL database
- `firebase_storage` - File storage
- `firebase_messaging` - Push notifications
- `firebase_analytics` - Analytics

### Geolocation
- `geolocator` - Location services
- `geoflutterfire_plus` - Geospatial queries
- `google_maps_flutter` - Map display
- `geocoding` - Address lookup

### Audio & Media
- `record` - Audio recording
- `audioplayers` - Audio playback
- `image_picker` - Image selection
- `permission_handler` - Permissions

### Networking
- `http` - HTTP client
- `dio` - Advanced HTTP client
- `connectivity_plus` - Network status

### UI Components
- `flutter_svg` - SVG support
- `cached_network_image` - Image caching
- `shimmer` - Loading animations
- `pull_to_refresh` - Pull to refresh

### Utilities
- `get_it` - Dependency injection
- `dartz` - Functional programming (Either<>)
- `shared_preferences` - Local storage
- `url_launcher` - URL launching

### Localization
- `flutter_localizations` - Flutter localization
- `intl` - Internationalization

## Code Generation

### Freezed (Data Classes)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Localization
```bash
flutter gen-l10n
```

## Firebase Configuration

### Collections Structure
See `TECHNICAL_SPECIFICATION.md` for detailed Firebase schema.

Key collections:
- `users` - User profiles
- `alerts` - Emergency alerts
- `dangerGroups` - Danger type groups
- `neighborhoodGroups` - Community groups
- `emergencyResources` - Hospitals, clinics, etc.
- `bloodDonors` - Blood donor registry
- `volunteerResponders` - Volunteer network
- `ngos` - NGO organizations
- `fundCampaigns` - Crowdfunding campaigns
- `communityEmergencyFund` - Community funds

## Testing Strategy

### Unit Tests
- Test use cases
- Test BLoC logic
- Test repository implementations

### Widget Tests
- Test UI components
- Test BLoC integration
- Test navigation

### Integration Tests
- Test complete user flows
- Test Firebase integration
- Test payment flows

## Next Steps

1. ✅ Set up project structure
2. ✅ Add dependencies
3. ✅ Create core utilities
4. ✅ Create base entities
5. ✅ Set up localization
6. 🔄 Implement Firebase configuration
7. 🔄 Create data models
8. 🔄 Implement repositories
9. 🔄 Create use cases
10. 🔄 Implement BLoCs
11. 🔄 Build UI screens
12. 🔄 Test & debug

## Running the App

```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Environment Setup

### Android
- Minimum SDK: 21
- Target SDK: 34

### iOS
- Minimum iOS: 12.0
- Swift version: 5.0

### Firebase Setup Required
1. Create Firebase project
2. Add Android app (download google-services.json)
3. Add iOS app (download GoogleService-Info.plist)
4. Enable Authentication, Firestore, Storage, Messaging
5. Configure security rules

## Contributing

Follow the established architecture:
1. Create feature in `features/` directory
2. Follow Clean Architecture layers
3. Use BLoC for state management
4. Write tests
5. Update documentation

## License

[To be determined]

---
**Last Updated**: 2025-10-03
**Flutter Version**: 3.9.0+
**Dart Version**: 3.9.0+
