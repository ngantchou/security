# Data Seeding Scripts

This directory contains scripts for populating the Firestore database with sample data for development and testing.

## Prerequisites

- Firebase project configured
- Firebase credentials set up
- Flutter SDK installed

## Usage

### 1. Ensure Firebase Configuration Exists

The script automatically reads Firebase credentials from:
- `android/app/google-services.json`

No manual configuration needed! The script will:
- ✅ Automatically detect your Firebase project
- ✅ Extract credentials from google-services.json
- ✅ Initialize Firebase with the correct settings

### 2. Run the Seed Script

From the project root directory:

```bash
dart run scripts/seed_data.dart
```

### 3. Alternative: Run as Flutter Script

If you encounter issues with `dart run`, use Flutter:

```bash
flutter pub get
flutter run scripts/seed_data.dart
```

## What Gets Seeded

The script creates the following sample data:

### Users (5 users)
- Jean Mbarga - Top contributor with high trust score
- Marie Ngoue - Community hero and blood donor
- Paul Kamga - Regular user
- Aminata Sow - Top contributor with search & rescue skills
- Bernard Tchoua - New user

### Alerts (20 alerts)
- Various danger types: fire, accident, crime, medical, natural disaster
- Different severity levels (1-5)
- Locations across Yaoundé neighborhoods
- Some resolved, some active
- User confirmations and interactions

### Neighborhood Watch Groups (3 groups)
- Bastos Neighborhood Watch
- Melen Security Network
- Nlongkak Community Guard

### Meetings (6 meetings)
- 2 meetings per watch group
- Scheduled for upcoming dates
- Various topics: safety meetings, training sessions

### Hospitals (4 hospitals)
- CHU Yaoundé
- Hôpital Central
- Clinique de l'Aéroport
- Hôpital Gynéco-Obstétrique

### Blood Donors (4 donors)
- Various blood types
- Different availability status
- Donation history

### NGOs (3 organizations)
- Cameroon Red Cross
- Plan Cameroun
- Doctors Without Borders

### Emergency Resources (4 resources)
- Fire extinguishers
- First aid kits
- Defibrillators
- Emergency generators

### Community Funds (2 funds)
- Bastos Emergency Fund
- Medical Emergency Support

## Customization

You can modify the seed data by editing `seed_data.dart`:

- Change the number of items created
- Modify location coordinates
- Add more sample data
- Adjust trust scores and statistics

## Clean Up

To remove all seeded data, you can:

1. **From Firebase Console:**
   - Go to Firestore Database
   - Delete collections manually

2. **Using Firebase CLI:**
   ```bash
   firebase firestore:delete --all-collections --project YOUR_PROJECT_ID
   ```

3. **Programmatically:**
   Create a cleanup script that deletes all documents.

## Important Notes

- ⚠️ **Never run this on production database!** Always use a development/staging Firebase project.
- 🔒 Ensure your Firestore security rules allow write access for testing.
- 📊 After seeding, verify data in Firebase Console > Firestore Database.
- 🧹 Clean up test data before deploying to production.

## Troubleshooting

### Permission Denied Error

If you get permission errors:
1. Check Firestore security rules
2. Temporarily allow write access for development:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true; // ONLY FOR DEVELOPMENT
       }
     }
   }
   ```

### Firebase Not Initialized

Make sure you've:
1. Added `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
2. Updated Firebase configuration in the script
3. Run `flutter pub get` to install dependencies

### Import Errors

If you get import errors:
```bash
flutter pub get
flutter pub upgrade
```

## Production Considerations

Before deploying to production:

1. ✅ Remove all test data
2. ✅ Update Firestore security rules
3. ✅ Verify indexes are created
4. ✅ Test with real user accounts
5. ✅ Monitor Firebase usage and costs

## License

This script is part of the Safety Alert application and follows the same license.
