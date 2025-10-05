# Technical Specification - Cameroon Safety Alert Application

## 1. System Architecture Overview

### Technology Stack
- **Frontend**: Flutter (Android & iOS)
- **Backend**: Firebase Suite
  - Firebase Authentication
  - Cloud Firestore (NoSQL Database)
  - Firebase Cloud Storage (Audio files, images)
  - Firebase Cloud Messaging (Push notifications)
  - Firebase Cloud Functions (Backend logic, triggers)
  - Firebase Hosting (Admin dashboard)
- **Payment Integration**: MTN Mobile Money API, Orange Money API
- **Geolocation**: Google Maps API, Geoflutterfire
- **Languages**: Flutter Intl for i18n

---

## 2. Firebase Database Schema (Cloud Firestore)

### 2.1 Users Collection
```
users/{userId}
{
  uid: string,
  phoneNumber: string,
  email: string?,
  displayName: string,
  preferredLanguage: string, // 'fr', 'en', 'pidgin', 'fulfulde', etc.
  profilePhoto: string?, // Storage URL
  nationalIdVerified: boolean,
  verificationMethod: string, // 'nationalId', 'communityVouching'
  verificationDate: timestamp,

  // Location
  location: GeoPoint,
  region: string, // 'Far North', 'Littoral', 'North West', etc.
  city: string,
  neighborhood: string,

  // Contacts
  emergencyContacts: [
    {
      name: string,
      phoneNumber: string,
      relationship: string
    }
  ],

  // Preferences
  alertRadius: number, // in km
  notificationPreferences: {
    pushEnabled: boolean,
    smsEnabled: boolean,
    alertLevels: [1,2,3,4,5] // Which levels to receive
  },

  // Roles
  roles: {
    isVolunteerResponder: boolean,
    isSecurityProfessional: boolean,
    isProfessionalType: string?, // 'firefighter', 'paramedic', 'police'
    isNGOWorker: boolean,
    ngoId: string?
  },

  // Blood Donor
  bloodDonor: {
    isAvailable: boolean,
    bloodType: string, // 'A+', 'O-', etc.
    lastDonationDate: timestamp,
    willingToTravel: number // km
  },

  // Resources
  sharedResources: [
    {
      resourceType: string, // 'generator', 'medical_supplies', 'safe_house'
      description: string,
      availability: boolean
    }
  ],

  // Stats
  alertsCreated: number,
  alertsConfirmed: number,
  credibilityScore: number, // 0-100
  falseAlertCount: number,

  // Subscriptions
  followedDangerGroups: [string], // danger type IDs
  joinedNeighborhoodGroups: [string], // group IDs

  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 2.2 Alerts Collection
```
alerts/{alertId}
{
  alertId: string,
  creatorId: string, // User who created alert
  creatorName: string,
  creatorLocation: GeoPoint,

  // Alert Details
  dangerType: string, // 'fire', 'flood', 'armed_robbery', 'kidnapping', etc.
  dangerGroupId: string, // Reference to dangerGroups collection
  level: number, // 1-5
  title: string,
  description: string,
  audioCommentUrl: string?, // Firebase Storage URL
  images: [string], // Storage URLs

  // Location
  location: GeoPoint,
  geohash: string, // For geo queries
  region: string,
  city: string,
  neighborhood: string,
  address: string?,

  // Status
  status: string, // 'active', 'resolved', 'false_alarm', 'verified'
  severity: string, // 'low', 'medium', 'high', 'critical'

  // Confirmation
  confirmations: number,
  confirmedBy: [
    {
      userId: string,
      userName: string,
      timestamp: timestamp,
      comment: string?,
      audioCommentUrl: string?
    }
  ],

  // Authority Alert
  authoritiesNotified: boolean,
  authoritiesNotifiedAt: timestamp?,
  authorityType: [string], // ['police', 'firefighters', 'ambulance']

  // Engagement
  viewCount: number,
  helpOffered: number,

  // Timestamps
  createdAt: timestamp,
  updatedAt: timestamp,
  resolvedAt: timestamp?
}
```

### 2.3 Danger Groups Collection
```
dangerGroups/{groupId}
{
  groupId: string,
  dangerType: string, // 'flood', 'separatist_conflict', 'boko_haram', etc.
  name: {
    en: string,
    fr: string,
    pidgin: string?
  },
  description: {
    en: string,
    fr: string,
    pidgin: string?
  },
  icon: string, // Asset path or emoji
  color: string, // Hex color code

  // Followers
  followerCount: number,
  followers: [string], // User IDs (subcollection for scalability)

  // News Feed
  newsEnabled: boolean,
  moderators: [string], // User IDs who can post news

  // Settings
  isActive: boolean,
  isRegionSpecific: boolean,
  regions: [string]?, // If region-specific

  createdAt: timestamp
}
```

### 2.4 Danger Group News Collection
```
dangerGroups/{groupId}/news/{newsId}
{
  newsId: string,
  groupId: string,

  // Author
  authorId: string,
  authorName: string,
  authorType: string, // 'user', 'moderator', 'ngo', 'authority'

  // Content
  title: string,
  content: string,
  audioUrl: string?,
  images: [string],

  // Location (optional)
  location: GeoPoint?,
  region: string?,

  // Engagement
  viewCount: number,
  commentCount: number,
  likeCount: number,

  // Status
  isPinned: boolean,
  isVerified: boolean,

  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 2.5 Comments Subcollection
```
dangerGroups/{groupId}/news/{newsId}/comments/{commentId}
{
  commentId: string,
  userId: string,
  userName: string,
  userPhoto: string?,

  comment: string,
  audioCommentUrl: string?,

  // Engagement
  likeCount: number,

  createdAt: timestamp
}
```

### 2.6 Neighborhood Watch Groups Collection
```
neighborhoodGroups/{groupId}
{
  groupId: string,
  name: string,
  description: string,

  // Location
  location: GeoPoint, // Center point
  geohash: string,
  region: string,
  city: string,
  neighborhood: string,
  coverageRadius: number, // in km

  // Leadership
  coordinatorId: string,
  coordinatorName: string,
  coordinatorPhone: string,

  deputies: [
    {
      userId: string,
      name: string,
      phone: string
    }
  ],

  // Members
  memberCount: number,
  members: [string], // User IDs (consider subcollection for large groups)

  // Settings
  requiresApproval: boolean,
  isActive: boolean,

  // Stats
  alertsCreated: number,
  incidentsResolved: number,

  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 2.7 Emergency Resources Collection
```
emergencyResources/{resourceId}
{
  resourceId: string,
  type: string, // 'hospital', 'clinic', 'pharmacy', 'fire_station', 'police_station'

  // Details
  name: string,
  description: string,
  phone: string,
  alternatePhone: string?,
  email: string?,
  website: string?,

  // Location
  location: GeoPoint,
  geohash: string,
  region: string,
  city: string,
  address: string,

  // Services
  services: [string], // ['emergency', '24/7', 'trauma', 'maternity']
  hasAmbulance: boolean,
  capacity: string?, // 'small', 'medium', 'large'

  // Status
  isOperational: boolean,
  operatingHours: string,

  // Verification
  isVerified: boolean,
  verifiedBy: string?, // NGO or authority ID
  verifiedAt: timestamp?,

  // Stats
  rating: number, // 0-5
  reviewCount: number,

  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 2.8 Blood Donor Registry (Optimized Queries)
```
bloodDonors/{donorId}
{
  donorId: string, // Same as userId
  userId: string,
  name: string,
  phone: string,

  // Blood Info
  bloodType: string,
  lastDonationDate: timestamp,
  isAvailable: boolean,

  // Location
  location: GeoPoint,
  geohash: string,
  region: string,
  city: string,
  willingToTravel: number, // km

  // Stats
  donationCount: number,

  updatedAt: timestamp
}
```

### 2.9 Volunteer Responders Collection
```
volunteerResponders/{responderId}
{
  responderId: string, // Same as userId
  userId: string,
  name: string,
  phone: string,

  // Qualifications
  certifications: [
    {
      type: string, // 'first_aid', 'cpr', 'firefighter', 'paramedic'
      issuedBy: string,
      issuedDate: timestamp,
      expiryDate: timestamp?
    }
  ],

  // Location
  location: GeoPoint,
  geohash: string,
  region: string,
  city: string,
  responseRadius: number, // km

  // Availability
  isAvailable: boolean,
  availabilitySchedule: {
    // Day of week: time ranges
    monday: [{start: string, end: string}],
    tuesday: [{start: string, end: string}],
    // etc.
  },

  // Stats
  responsesCompleted: number,
  averageResponseTime: number, // minutes
  rating: number, // 0-5

  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 2.10 NGOs Collection
```
ngos/{ngoId}
{
  ngoId: string,
  name: string,
  description: string,
  type: string, // 'humanitarian', 'health', 'security', 'disaster_relief'

  // Contact
  phone: string,
  email: string,
  website: string?,

  // Location
  headquarters: GeoPoint,
  regionsServed: [string],

  // Services
  services: [string],
  hasEmergencyHotline: boolean,
  hotlineNumber: string?,

  // Verification
  isVerified: boolean,
  registrationNumber: string,

  // Staff
  staffMembers: [string], // User IDs

  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 2.11 Emergency Fund Campaigns Collection
```
fundCampaigns/{campaignId}
{
  campaignId: string,

  // Campaign Details
  title: string,
  description: string,
  alertId: string?, // If linked to specific alert
  dangerType: string,

  // Creator
  creatorId: string,
  creatorName: string,
  creatorType: string, // 'user', 'ngo', 'neighborhood_group'

  // Beneficiary
  beneficiaryName: string,
  beneficiaryPhone: string,
  beneficiaryVerified: boolean,

  // Funding
  goalAmount: number, // XAF
  currentAmount: number,
  contributorCount: number,

  // Payment Methods
  mobileMoneyNumbers: {
    mtnMomo: string?,
    orangeMoney: string?
  },

  // Location
  location: GeoPoint?,
  region: string,

  // Status
  status: string, // 'active', 'completed', 'cancelled'
  isVerified: boolean,
  verifiedBy: string?, // NGO or authority

  // Timestamps
  createdAt: timestamp,
  deadline: timestamp,
  completedAt: timestamp?
}
```

### 2.12 Contributions Subcollection
```
fundCampaigns/{campaignId}/contributions/{contributionId}
{
  contributionId: string,
  campaignId: string,

  // Contributor
  contributorId: string?,
  contributorName: string, // Can be anonymous
  isAnonymous: boolean,

  // Payment
  amount: number,
  paymentMethod: string, // 'mtn_momo', 'orange_money'
  transactionId: string,
  transactionStatus: string, // 'pending', 'completed', 'failed'

  // Message
  message: string?,

  createdAt: timestamp
}
```

### 2.13 Community Emergency Fund
```
communityEmergencyFund/{fundId}
{
  fundId: string,

  // Fund Details
  name: string,
  description: string,
  fundType: string, // 'neighborhood', 'regional', 'national'

  // Association
  neighborhoodGroupId: string?,
  region: string?,

  // Balance
  totalBalance: number, // XAF
  contributorCount: number,

  // Management
  administrators: [string], // User IDs
  requiresApproval: boolean,
  minimumApprovers: number,

  // Settings
  minimumContribution: number,
  contributionFrequency: string?, // 'weekly', 'monthly', 'one_time'

  createdAt: timestamp,
  updatedAt: timestamp
}
```

### 2.14 Fund Contributions Subcollection
```
communityEmergencyFund/{fundId}/contributions/{contributionId}
{
  contributionId: string,
  fundId: string,

  contributorId: string,
  contributorName: string,

  amount: number,
  paymentMethod: string,
  transactionId: string,

  isRecurring: boolean,
  recurringSchedule: string?,

  createdAt: timestamp
}
```

### 2.15 Fund Disbursements Subcollection
```
communityEmergencyFund/{fundId}/disbursements/{disbursementId}
{
  disbursementId: string,
  fundId: string,

  // Request
  requestedBy: string, // User ID
  requestedByName: string,
  reason: string,
  linkedAlertId: string?,

  amount: number,

  // Approval
  status: string, // 'pending', 'approved', 'rejected', 'disbursed'
  approvers: [
    {
      userId: string,
      userName: string,
      vote: string, // 'approve', 'reject'
      comment: string?,
      timestamp: timestamp
    }
  ],

  // Disbursement
  disbursedTo: string, // Phone number or mobile money account
  disbursedBy: string, // Administrator ID
  disbursementMethod: string,
  transactionId: string?,

  createdAt: timestamp,
  disbursedAt: timestamp?
}
```

### 2.16 Notifications Collection
```
notifications/{notificationId}
{
  notificationId: string,

  // Recipient
  recipientId: string,

  // Content
  type: string, // 'alert', 'confirmation', 'news', 'fund_contribution', etc.
  title: string,
  body: string,
  imageUrl: string?,

  // Navigation
  screen: string, // Deep link screen
  data: {
    alertId: string?,
    newsId: string?,
    campaignId: string?
  },

  // Status
  isRead: boolean,
  isSent: boolean,

  createdAt: timestamp,
  readAt: timestamp?
}
```

---

## 3. Firebase Security Rules

### 3.1 Core Principles
- Users can only edit their own data
- Alerts are readable by users within radius
- Verified users can perform sensitive actions
- Rate limiting on alert creation (prevent spam)
- Community moderators have elevated permissions

### 3.2 Example Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isVerified() {
      return isSignedIn() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.nationalIdVerified == true;
    }

    function hasGoodCredibility() {
      let userData = get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
      return userData.credibilityScore >= 50;
    }

    // Users
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }

    // Alerts
    match /alerts/{alertId} {
      allow read: if isSignedIn();
      allow create: if isVerified() && hasGoodCredibility();
      allow update: if isOwner(resource.data.creatorId) || isVerified();
      allow delete: if isOwner(resource.data.creatorId);
    }

    // Danger Groups
    match /dangerGroups/{groupId} {
      allow read: if true; // Public
      allow write: if false; // Admin only via Cloud Functions

      match /news/{newsId} {
        allow read: if true;
        allow create: if isVerified();
        allow update: if isOwner(resource.data.authorId);
        allow delete: if isOwner(resource.data.authorId);

        match /comments/{commentId} {
          allow read: if true;
          allow create: if isSignedIn();
          allow update: if isOwner(resource.data.userId);
          allow delete: if isOwner(resource.data.userId);
        }
      }
    }

    // Other collections follow similar patterns...
  }
}
```

---

## 4. Firebase Cloud Functions

### 4.1 Alert Processing Functions

#### `onAlertCreated`
```javascript
exports.onAlertCreated = functions.firestore
  .document('alerts/{alertId}')
  .onCreate(async (snap, context) => {
    const alert = snap.data();

    // 1. Find nearby users using geohash queries
    const nearbyUsers = await findUsersInRadius(alert.location, alert.level);

    // 2. Send push notifications
    await sendAlertNotifications(nearbyUsers, alert);

    // 3. Send SMS for high-level alerts
    if (alert.level >= 3) {
      await sendSMSAlerts(nearbyUsers, alert);
    }

    // 4. Check if authorities should be notified
    if (alert.level >= 3 && alert.confirmations >= 3) {
      await notifyAuthorities(alert);
    }

    // 5. Update danger group stats
    await updateDangerGroupStats(alert.dangerGroupId);
  });
```

#### `onAlertConfirmation`
```javascript
exports.onAlertConfirmation = functions.firestore
  .document('alerts/{alertId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if confirmations increased
    if (after.confirmations > before.confirmations) {
      // Update credibility score of confirmer
      await updateCredibilityScore(after.confirmedBy[after.confirmations - 1].userId, 5);

      // Check authority notification threshold
      if (after.level >= 3 && after.confirmations >= 3 && !after.authoritiesNotified) {
        await notifyAuthorities(after);
        await change.after.ref.update({
          authoritiesNotified: true,
          authoritiesNotifiedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }
  });
```

### 4.2 Notification Functions

#### `sendPushNotification`
```javascript
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  const { userId, title, body, data: notifData } = data;

  // Get user's FCM token
  const userDoc = await admin.firestore().doc(`users/${userId}`).get();
  const fcmToken = userDoc.data().fcmToken;

  const message = {
    notification: { title, body },
    data: notifData,
    token: fcmToken
  };

  await admin.messaging().send(message);

  // Log notification
  await admin.firestore().collection('notifications').add({
    recipientId: userId,
    title, body,
    data: notifData,
    isRead: false,
    isSent: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
});
```

#### `sendSMSAlert`
```javascript
exports.sendSMSAlert = functions.https.onCall(async (data, context) => {
  const { phoneNumber, message, alertId } = data;

  // Integration with SMS gateway (Twilio, Africa's Talking, etc.)
  // For Cameroon: Use local SMS provider

  const smsResult = await sendSMS(phoneNumber, message);

  return { success: smsResult.success, messageId: smsResult.id };
});
```

### 4.3 Payment Integration Functions

#### `initiateMobileMoneyPayment`
```javascript
exports.initiateMobileMoneyPayment = functions.https.onCall(async (data, context) => {
  const {
    provider, // 'mtn_momo' or 'orange_money'
    phoneNumber,
    amount,
    campaignId,
    contributorId
  } = data;

  let paymentResult;

  if (provider === 'mtn_momo') {
    paymentResult = await initiateMTNMoMoPayment({
      phoneNumber,
      amount,
      reference: campaignId
    });
  } else if (provider === 'orange_money') {
    paymentResult = await initiateOrangeMoneyPayment({
      phoneNumber,
      amount,
      reference: campaignId
    });
  }

  // Create contribution record
  await admin.firestore()
    .collection(`fundCampaigns/${campaignId}/contributions`)
    .add({
      contributorId,
      amount,
      paymentMethod: provider,
      transactionId: paymentResult.transactionId,
      transactionStatus: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

  return {
    success: true,
    transactionId: paymentResult.transactionId
  };
});
```

#### `handlePaymentWebhook`
```javascript
exports.handlePaymentWebhook = functions.https.onRequest(async (req, res) => {
  const { provider, transactionId, status, amount } = req.body;

  // Verify webhook signature
  if (!verifyWebhookSignature(req)) {
    res.status(401).send('Unauthorized');
    return;
  }

  // Find contribution by transaction ID
  const contributionQuery = await admin.firestore()
    .collectionGroup('contributions')
    .where('transactionId', '==', transactionId)
    .get();

  if (contributionQuery.empty) {
    res.status(404).send('Contribution not found');
    return;
  }

  const contributionDoc = contributionQuery.docs[0];
  const campaignId = contributionDoc.ref.parent.parent.id;

  // Update contribution status
  await contributionDoc.ref.update({
    transactionStatus: status
  });

  // If successful, update campaign amount
  if (status === 'completed') {
    await admin.firestore()
      .doc(`fundCampaigns/${campaignId}`)
      .update({
        currentAmount: admin.firestore.FieldValue.increment(amount),
        contributorCount: admin.firestore.FieldValue.increment(1)
      });

    // Send thank you notification
    const contributorId = contributionDoc.data().contributorId;
    if (contributorId) {
      await sendThankYouNotification(contributorId, amount, campaignId);
    }
  }

  res.status(200).send('OK');
});
```

### 4.4 Geolocation Functions

#### `findNearbyUsers`
```javascript
const geofire = require('geofire-common');

exports.findNearbyUsers = functions.https.onCall(async (data, context) => {
  const { latitude, longitude, radiusInKm } = data;

  const center = [latitude, longitude];
  const radiusInM = radiusInKm * 1000;

  // Calculate geohash query bounds
  const bounds = geofire.geohashQueryBounds(center, radiusInM);

  const promises = [];
  for (const b of bounds) {
    const q = admin.firestore().collection('users')
      .orderBy('geohash')
      .startAt(b[0])
      .endAt(b[1]);

    promises.push(q.get());
  }

  // Collect results
  const snapshots = await Promise.all(promises);
  const matchingDocs = [];

  for (const snap of snapshots) {
    for (const doc of snap.docs) {
      const lat = doc.get('location.latitude');
      const lng = doc.get('location.longitude');

      // Calculate distance
      const distanceInKm = geofire.distanceBetween([lat, lng], center);

      if (distanceInKm <= radiusInKm) {
        matchingDocs.push({
          id: doc.id,
          ...doc.data(),
          distance: distanceInKm
        });
      }
    }
  }

  return matchingDocs;
});
```

### 4.5 Community Verification Functions

#### `submitVerificationRequest`
```javascript
exports.submitVerificationRequest = functions.https.onCall(async (data, context) => {
  const { userId, verificationType, documentUrl, voucherIds } = data;

  await admin.firestore().collection('verificationRequests').add({
    userId,
    verificationType, // 'nationalId' or 'communityVouching'
    documentUrl,
    voucherIds,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

  // Notify vouchers if community vouching
  if (verificationType === 'communityVouching') {
    for (const voucherId of voucherIds) {
      await sendVerificationRequestNotification(voucherId, userId);
    }
  }

  return { success: true };
});
```

### 4.6 Credibility Score Functions

#### `updateCredibilityScore`
```javascript
exports.updateCredibilityScore = functions.https.onCall(async (data, context) => {
  const { userId, points, reason } = data;

  const userRef = admin.firestore().doc(`users/${userId}`);
  const userDoc = await userRef.get();

  const currentScore = userDoc.data().credibilityScore || 50;
  const newScore = Math.max(0, Math.min(100, currentScore + points));

  await userRef.update({
    credibilityScore: newScore
  });

  // Log the change
  await admin.firestore().collection('credibilityLog').add({
    userId,
    previousScore: currentScore,
    newScore,
    points,
    reason,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });

  return { newScore };
});
```

#### `checkFalseAlert`
```javascript
exports.checkFalseAlert = functions.firestore
  .document('alerts/{alertId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();

    if (after.status === 'false_alarm') {
      const creatorId = after.creatorId;

      // Decrease credibility score
      await updateCredibilityScore(creatorId, -10, 'false_alarm');

      // Increment false alert count
      await admin.firestore().doc(`users/${creatorId}`).update({
        falseAlertCount: admin.firestore.FieldValue.increment(1)
      });

      // If too many false alerts, suspend user
      const userDoc = await admin.firestore().doc(`users/${creatorId}`).get();
      if (userDoc.data().falseAlertCount >= 3) {
        await admin.firestore().doc(`users/${creatorId}`).update({
          isSuspended: true,
          suspensionReason: 'multiple_false_alerts'
        });
      }
    }
  });
```

---

## 5. Multi-Language Support (i18n)

### 5.1 Supported Languages
- French (fr)
- English (en)
- Pidgin (pidgin)
- Fulfulde (ff)
- Ewondo (ewo)
- Duala (dua)

### 5.2 Implementation
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0

flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 5.3 ARB Files Structure
```json
// lib/l10n/app_en.arb
{
  "appTitle": "Safety Alert",
  "alertButton": "Send Alert",
  "dangerTypes": {
    "fire": "Fire",
    "flood": "Flood",
    "armedRobbery": "Armed Robbery",
    "kidnapping": "Kidnapping",
    "separatistConflict": "Separatist Conflict",
    "bokoHaram": "Boko Haram Activity"
  }
}

// lib/l10n/app_fr.arb
{
  "appTitle": "Alerte Sécurité",
  "alertButton": "Envoyer une Alerte",
  "dangerTypes": {
    "fire": "Incendie",
    "flood": "Inondation",
    "armedRobbery": "Vol à Main Armée",
    "kidnapping": "Enlèvement",
    "separatistConflict": "Conflit Séparatiste",
    "bokoHaram": "Activité Boko Haram"
  }
}
```

---

## 6. Audio Recording Integration

### 6.1 Dependencies
```yaml
dependencies:
  record: ^5.0.0
  audioplayers: ^5.0.0
  permission_handler: ^11.0.0
```

### 6.2 Implementation Flow
1. Request microphone permission
2. Record audio (max 60 seconds for comments)
3. Save to local temp file
4. Upload to Firebase Storage
5. Get download URL
6. Store URL in Firestore

### 6.3 Storage Path Structure
```
audio/
  alerts/{alertId}/
    creator_comment.m4a
  confirmations/{confirmationId}/
    comment.m4a
  news/{newsId}/
    audio.m4a
  comments/{commentId}/
    audio.m4a
```

---

## 7. Mobile Money Integration

### 7.1 MTN Mobile Money API

#### Authentication
```dart
class MTNMoMoService {
  final String apiKey;
  final String apiUser;
  final String subscriptionKey;
  final String baseUrl = 'https://sandbox.momodeveloper.mtn.com'; // or production

  Future<String> getAccessToken() async {
    // Implementation for OAuth token
  }

  Future<PaymentResult> requestToPay({
    required String phoneNumber,
    required double amount,
    required String reference,
  }) async {
    final token = await getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/collection/v1_0/requesttopay'),
      headers: {
        'Authorization': 'Bearer $token',
        'X-Reference-Id': reference,
        'X-Target-Environment': 'mtncameroon',
        'Ocp-Apim-Subscription-Key': subscriptionKey,
      },
      body: jsonEncode({
        'amount': amount.toString(),
        'currency': 'XAF',
        'externalId': reference,
        'payer': {
          'partyIdType': 'MSISDN',
          'partyId': phoneNumber
        },
        'payerMessage': 'Emergency fund contribution',
        'payeeNote': 'Safety Alert App'
      }),
    );

    return PaymentResult(
      success: response.statusCode == 202,
      transactionId: reference,
    );
  }

  Future<PaymentStatus> checkTransactionStatus(String referenceId) async {
    // Implementation
  }
}
```

### 7.2 Orange Money API

```dart
class OrangeMoneyService {
  final String clientId;
  final String clientSecret;
  final String merchantKey;
  final String baseUrl = 'https://api.orange.com/orange-money-webpay/cm/v1';

  Future<String> getAccessToken() async {
    // OAuth implementation
  }

  Future<PaymentResult> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String reference,
  }) async {
    final token = await getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/webpayment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'merchant_key': merchantKey,
        'currency': 'XAF',
        'order_id': reference,
        'amount': amount.toInt(),
        'return_url': 'safetyalert://payment/callback',
        'cancel_url': 'safetyalert://payment/cancel',
        'notif_url': 'https://your-cloud-function-url/paymentWebhook',
        'lang': 'fr',
        'reference': reference
      }),
    );

    return PaymentResult.fromJson(jsonDecode(response.body));
  }
}
```

---

## 8. Push Notifications with FCM

### 8.1 Setup
```yaml
dependencies:
  firebase_messaging: ^14.0.0
  flutter_local_notifications: ^16.0.0
```

### 8.2 Notification Types
- **Alert Notifications**: High priority, sound + vibration
- **Confirmation Requests**: Normal priority
- **News Updates**: Low priority, silent
- **Fund Contributions**: Normal priority

### 8.3 Notification Payload Structure
```json
{
  "notification": {
    "title": "🚨 Alerte Niveau 4 - Incendie",
    "body": "À 2.3 km de vous - Quartier Bonanjo"
  },
  "data": {
    "type": "alert",
    "alertId": "alert123",
    "screen": "AlertDetail",
    "latitude": "4.0511",
    "longitude": "9.7679",
    "level": "4",
    "dangerType": "fire"
  },
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "high_priority_alerts",
      "sound": "alert_sound.mp3"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "alert_sound.aiff",
        "badge": 1
      }
    }
  }
}
```

---

## 9. Geolocation with Geoflutterfire

### 9.1 Dependencies
```yaml
dependencies:
  geoflutterfire_plus: ^0.0.2
  geolocator: ^10.0.0
  google_maps_flutter: ^2.5.0
```

### 9.2 Storing Locations
```dart
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

Future<void> createAlert({
  required String dangerType,
  required GeoPoint location,
}) async {
  final geoFirePoint = GeoFirePoint(
    GeoPoint(location.latitude, location.longitude),
  );

  await FirebaseFirestore.instance.collection('alerts').add({
    'dangerType': dangerType,
    'location': location,
    'geohash': geoFirePoint.geohash,
    'geopoint': geoFirePoint.geopoint,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
```

### 9.3 Querying Nearby Alerts
```dart
Stream<List<Alert>> getNearbyAlerts({
  required GeoPoint center,
  required double radiusInKm,
}) {
  return GeoCollectionReference(
    FirebaseFirestore.instance.collection('alerts'),
  ).subscribeWithin(
    center: GeoFirePoint(GeoPoint(center.latitude, center.longitude)),
    radiusInKm: radiusInKm,
    field: 'geopoint',
    geopointFrom: (data) => data['geopoint'] as GeoPoint,
    strictMode: true,
  );
}
```

---

## 10. Offline Support & SMS Fallback

### 10.1 Offline Persistence
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(MyApp());
}
```

### 10.2 SMS Fallback via Cloud Function
```javascript
exports.sendSMSFallback = functions.https.onCall(async (data, context) => {
  const { phoneNumber, alertData } = data;

  // Format alert message for SMS (160 chars)
  const message = `ALERTE ${alertData.level}/5: ${alertData.dangerType} - ${alertData.neighborhood}. ${alertData.distance}km de vous. App: bit.ly/safetyalert`;

  // Send via SMS provider (Africa's Talking, Twilio, etc.)
  await sendSMS(phoneNumber, message);

  return { success: true };
});
```

---

## 11. Admin Dashboard (Firebase Hosting)

### 11.1 Features
- View all alerts on map
- Verify resources (hospitals, NGOs)
- Manage danger groups
- Review verification requests
- Monitor false alerts
- Manage community funds
- Analytics dashboard

### 11.2 Tech Stack
- React.js / Vue.js
- Firebase SDK
- Google Maps JavaScript API
- Chart.js for analytics

---

## 12. Analytics & Monitoring

### 12.1 Firebase Analytics Events
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'alert_created',
  parameters: {
    'danger_type': 'fire',
    'level': 4,
    'region': 'Littoral',
    'has_audio': true,
  },
);
```

### 12.2 Key Metrics to Track
- Alert creation rate by region
- Average response time
- Confirmation rate
- False alert percentage
- User engagement (DAU/MAU)
- Fund contribution amounts
- Blood donor availability
- Volunteer response rate

---

## 13. Security Considerations

### 13.1 Data Privacy
- Encrypt sensitive data at rest
- Use HTTPS for all communications
- Implement GDPR-like consent flows
- Allow users to delete their data
- Anonymize location data after 30 days

### 13.2 Anti-Spam Measures
- Rate limit alert creation (max 3/hour per user)
- Require verification for new users
- Implement credibility scoring
- Community reporting of false alerts
- Automatic suspension after 3 false alerts

### 13.3 Payment Security
- Never store payment credentials
- Use secure webhooks with signature verification
- Implement transaction reconciliation
- Monitor for suspicious activity
- Comply with mobile money provider security requirements

---

## 14. Performance Optimization

### 14.1 Firestore Query Optimization
- Use composite indexes for complex queries
- Implement pagination (limit + startAfter)
- Cache frequently accessed data
- Use collection group queries sparingly

### 14.2 Storage Optimization
- Compress audio files (AAC format)
- Resize images before upload
- Implement CDN for static assets
- Set lifecycle policies for old files

### 14.3 Notification Optimization
- Batch notifications when possible
- Use topic-based messaging for groups
- Implement quiet hours
- Allow users to customize notification levels

---

## 15. Testing Strategy

### 15.1 Unit Tests
- Model classes
- Service layer (Firebase interactions)
- Utility functions (distance calculations, etc.)

### 15.2 Integration Tests
- Cloud Functions
- Payment flows
- Notification delivery
- Geolocation queries

### 15.3 End-to-End Tests
- Alert creation and confirmation flow
- Fund contribution flow
- Group creation and management
- Emergency resource search

---

## 16. Deployment Strategy

### 16.1 Environments
- **Development**: Firebase development project
- **Staging**: Firebase staging project with test data
- **Production**: Firebase production project

### 16.2 CI/CD Pipeline
```yaml
# .github/workflows/deploy.yml
name: Deploy to Firebase

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release

      - name: Deploy Cloud Functions
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}

      - name: Deploy Firestore Rules
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only firestore:rules
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

---

## 17. Cost Estimation (Firebase)

### 17.1 Firestore
- **Reads**: ~1M/month = $0.36
- **Writes**: ~500K/month = $1.08
- **Storage**: ~10GB = $1.80

### 17.2 Cloud Functions
- **Invocations**: ~2M/month = $0.80
- **Compute time**: ~100K GB-seconds = $0.25

### 17.3 Cloud Storage
- **Storage**: ~50GB = $2.50
- **Bandwidth**: ~100GB = $12.00

### 17.4 Cloud Messaging
- Free for all messages

### 17.5 Estimated Total
- **Monthly**: ~$20-30 for 10,000 active users
- **Scaling**: Pay-as-you-grow model

---

## 18. Future Enhancements

### 18.1 Phase 2 Features
- AI-powered false alert detection
- Predictive risk mapping
- Integration with government emergency systems
- Satellite phone support for remote areas
- Blockchain-based fund transparency

### 18.2 Phase 3 Features
- IoT sensor integration (smoke, flood sensors)
- Drone coordination for emergency assessment
- Machine learning for alert prioritization
- Multi-country expansion
- Enterprise version for organizations

---

## 19. Compliance & Legal

### 19.1 Required Registrations
- Register with Cameroon Telecommunications Regulatory Board
- Comply with data protection laws
- Partner with authorized payment aggregators
- Insurance for emergency fund management

### 19.2 Terms of Service
- User responsibilities
- Liability limitations
- False alert penalties
- Data usage policies
- Fund management transparency

---

## 20. Support & Maintenance

### 20.1 User Support Channels
- In-app help center
- WhatsApp support line
- SMS hotline
- Email support
- Community forums

### 20.2 Maintenance Schedule
- Weekly: Monitor analytics and error logs
- Monthly: Database optimization and cleanup
- Quarterly: Security audits
- Annually: Major feature updates

---

**Document Version**: 1.0
**Last Updated**: 2025-10-03
**Author**: Development Team
**Status**: Draft for Review
