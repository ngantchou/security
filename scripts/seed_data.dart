import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Data seeding script for Safety Alert Application
/// Run with: dart run scripts/seed_data.dart
void main() async {
  print('🌱 Starting data seeding for Safety Alert...\n');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      storageBucket: 'YOUR_STORAGE_BUCKET',
    ),
  );

  final firestore = FirebaseFirestore.instance;
  final random = Random();

  try {
    // Seed Users
    print('👥 Seeding users...');
    final userIds = await seedUsers(firestore, random);
    print('✅ Created ${userIds.length} users\n');

    // Seed Alerts
    print('🚨 Seeding alerts...');
    final alertIds = await seedAlerts(firestore, random, userIds);
    print('✅ Created ${alertIds.length} alerts\n');

    // Seed Watch Groups
    print('👁️ Seeding neighborhood watch groups...');
    final groupIds = await seedWatchGroups(firestore, random, userIds);
    print('✅ Created ${groupIds.length} watch groups\n');

    // Seed Meetings
    print('📅 Seeding meetings...');
    await seedMeetings(firestore, random, groupIds, userIds);
    print('✅ Created meetings\n');

    // Seed Hospitals
    print('🏥 Seeding hospitals...');
    await seedHospitals(firestore, random);
    print('✅ Created hospitals\n');

    // Seed Blood Donors
    print('🩸 Seeding blood donors...');
    await seedBloodDonors(firestore, random, userIds);
    print('✅ Created blood donors\n');

    // Seed NGOs
    print('🤝 Seeding NGOs...');
    await seedNGOs(firestore, random);
    print('✅ Created NGOs\n');

    // Seed Emergency Resources
    print('🆘 Seeding emergency resources...');
    await seedEmergencyResources(firestore, random);
    print('✅ Created emergency resources\n');

    // Seed Community Funds
    print('💰 Seeding community funds...');
    await seedCommunityFunds(firestore, random, userIds);
    print('✅ Created community funds\n');

    print('\n🎉 Data seeding completed successfully!');
    exit(0);
  } catch (e, stackTrace) {
    print('❌ Error seeding data: $e');
    print(stackTrace);
    exit(1);
  }
}

/// Seed sample users
Future<List<String>> seedUsers(FirebaseFirestore firestore, Random random) async {
  final users = [
    {
      'id': 'user_001',
      'phoneNumber': '+237670000001',
      'fullName': 'Jean Mbarga',
      'email': 'jean.mbarga@example.cm',
      'trustScore': 85,
      'alertsCreated': 12,
      'alertsConfirmed': 45,
      'falseReportsCount': 0,
      'badges': ['verified', 'top_contributor'],
      'isVolunteer': true,
      'volunteerSkills': ['first_aid', 'firefighting'],
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'user_002',
      'phoneNumber': '+237680000002',
      'fullName': 'Marie Ngoue',
      'email': 'marie.ngoue@example.cm',
      'trustScore': 92,
      'alertsCreated': 8,
      'alertsConfirmed': 67,
      'falseReportsCount': 0,
      'badges': ['verified', 'community_hero', 'blood_donor'],
      'isVolunteer': true,
      'volunteerSkills': ['medical', 'counseling'],
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'user_003',
      'phoneNumber': '+237690000003',
      'fullName': 'Paul Kamga',
      'email': 'paul.kamga@example.cm',
      'trustScore': 78,
      'alertsCreated': 5,
      'alertsConfirmed': 23,
      'falseReportsCount': 1,
      'badges': ['verified'],
      'isVolunteer': false,
      'volunteerSkills': [],
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'user_004',
      'phoneNumber': '+237670000004',
      'fullName': 'Aminata Sow',
      'email': 'aminata.sow@example.cm',
      'trustScore': 95,
      'alertsCreated': 15,
      'alertsConfirmed': 89,
      'falseReportsCount': 0,
      'badges': ['verified', 'top_contributor', 'community_hero'],
      'isVolunteer': true,
      'volunteerSkills': ['search_rescue', 'translation'],
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'user_005',
      'phoneNumber': '+237680000005',
      'fullName': 'Bernard Tchoua',
      'email': 'bernard.tchoua@example.cm',
      'trustScore': 70,
      'alertsCreated': 3,
      'alertsConfirmed': 15,
      'falseReportsCount': 0,
      'badges': [],
      'isVolunteer': false,
      'volunteerSkills': [],
      'createdAt': Timestamp.now(),
    },
  ];

  final userIds = <String>[];
  for (final user in users) {
    final userId = user['id'] as String;
    await firestore.collection('users').doc(userId).set(user);
    userIds.add(userId);
  }

  return userIds;
}

/// Seed sample alerts
Future<List<String>> seedAlerts(
  FirebaseFirestore firestore,
  Random random,
  List<String> userIds,
) async {
  final dangerTypes = ['fire', 'accident', 'crime', 'medical', 'natural_disaster', 'other'];
  final severityLevels = [1, 2, 3, 4, 5];

  // Coordinates around Yaoundé, Cameroon
  final locations = [
    {'lat': 3.8480, 'lng': 11.5021, 'area': 'Bastos'},
    {'lat': 3.8667, 'lng': 11.5167, 'area': 'Melen'},
    {'lat': 3.8578, 'lng': 11.5203, 'area': 'Nlongkak'},
    {'lat': 3.8460, 'lng': 11.5024, 'area': 'Essos'},
    {'lat': 3.8890, 'lng': 11.5213, 'area': 'Ngoa-Ekelle'},
    {'lat': 3.8322, 'lng': 11.4956, 'area': 'Mvog-Ada'},
    {'lat': 3.8712, 'lng': 11.5179, 'area': 'Mokolo'},
    {'lat': 3.8556, 'lng': 11.5089, 'area': 'Centre-ville'},
  ];

  final alerts = <Map<String, dynamic>>[];

  // Create 20 alerts
  for (int i = 0; i < 20; i++) {
    final location = locations[random.nextInt(locations.length)];
    final dangerType = dangerTypes[random.nextInt(dangerTypes.length)];
    final level = severityLevels[random.nextInt(severityLevels.length)];
    final creatorId = userIds[random.nextInt(userIds.length)];
    final isResolved = random.nextBool();
    final confirmationsCount = random.nextInt(10);

    final alert = {
      'dangerType': dangerType,
      'level': level,
      'latitude': location['lat'],
      'longitude': location['lng'],
      'address': '${location['area']}, Yaoundé, Cameroon',
      'description': _getAlertDescription(dangerType, location['area'] as String),
      'creatorId': creatorId,
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(hours: random.nextInt(72))),
      ),
      'confirmations': List.generate(
        confirmationsCount,
        (index) => userIds[random.nextInt(userIds.length)],
      ),
      'isResolved': isResolved,
      'resolvedAt': isResolved ? Timestamp.now() : null,
      'isFalseAlarm': false,
      'photoUrl': null,
      'helpOffered': random.nextInt(5),
      'viewCount': random.nextInt(100),
    };

    alerts.add(alert);
  }

  final alertIds = <String>[];
  for (final alert in alerts) {
    final docRef = await firestore.collection('alerts').add(alert);
    alertIds.add(docRef.id);
  }

  return alertIds;
}

/// Seed neighborhood watch groups
Future<List<String>> seedWatchGroups(
  FirebaseFirestore firestore,
  Random random,
  List<String> userIds,
) async {
  final groups = [
    {
      'name': 'Bastos Neighborhood Watch',
      'description': 'Keeping our Bastos community safe and connected',
      'coordinatorId': userIds[0],
      'administratorIds': [userIds[0], userIds[1]],
      'memberIds': userIds.take(4).toList(),
      'isPrivate': false,
      'createdAt': Timestamp.now(),
      'memberCount': 4,
      'radius': 2.0,
      'centerLatitude': 3.8480,
      'centerLongitude': 11.5021,
    },
    {
      'name': 'Melen Security Network',
      'description': 'United for a safer Melen',
      'coordinatorId': userIds[1],
      'administratorIds': [userIds[1]],
      'memberIds': userIds.take(3).toList(),
      'isPrivate': false,
      'createdAt': Timestamp.now(),
      'memberCount': 3,
      'radius': 3.0,
      'centerLatitude': 3.8667,
      'centerLongitude': 11.5167,
    },
    {
      'name': 'Nlongkak Community Guard',
      'description': 'Protecting our Nlongkak neighborhood together',
      'coordinatorId': userIds[3],
      'administratorIds': [userIds[3]],
      'memberIds': [userIds[3], userIds[4]],
      'isPrivate': true,
      'createdAt': Timestamp.now(),
      'memberCount': 2,
      'radius': 1.5,
      'centerLatitude': 3.8578,
      'centerLongitude': 11.5203,
    },
  ];

  final groupIds = <String>[];
  for (final group in groups) {
    final docRef = await firestore.collection('watch_groups').add(group);
    groupIds.add(docRef.id);
  }

  return groupIds;
}

/// Seed meetings
Future<void> seedMeetings(
  FirebaseFirestore firestore,
  Random random,
  List<String> groupIds,
  List<String> userIds,
) async {
  for (final groupId in groupIds) {
    final meetings = [
      {
        'groupId': groupId,
        'title': 'Monthly Community Safety Meeting',
        'description': 'Review recent incidents and discuss prevention strategies',
        'scheduledAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'location': 'Community Center',
        'latitude': 3.8480,
        'longitude': 11.5021,
        'organizerId': userIds[0],
        'attendeeIds': userIds.take(3).toList(),
        'createdAt': Timestamp.now(),
      },
      {
        'groupId': groupId,
        'title': 'Emergency Response Training',
        'description': 'First aid and emergency response workshop',
        'scheduledAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 14)),
        ),
        'location': 'Local School',
        'latitude': 3.8490,
        'longitude': 11.5031,
        'organizerId': userIds[1],
        'attendeeIds': userIds.take(2).toList(),
        'createdAt': Timestamp.now(),
      },
    ];

    for (final meeting in meetings) {
      await firestore.collection('meetings').add(meeting);
    }
  }
}

/// Seed hospitals
Future<void> seedHospitals(FirebaseFirestore firestore, Random random) async {
  final hospitals = [
    {
      'name': 'Centre Hospitalier et Universitaire (CHU)',
      'type': 'public',
      'address': 'Avenue Henri Dunant, Yaoundé',
      'latitude': 3.8667,
      'longitude': 11.5167,
      'phoneNumber': '+237222234050',
      'emergencyContact': '+237222234050',
      'specialties': ['emergency', 'surgery', 'pediatrics', 'cardiology'],
      'hasEmergencyRoom': true,
      'hasAmbulance': true,
      'acceptsInsurance': true,
      'rating': 4.2,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Hôpital Central de Yaoundé',
      'type': 'public',
      'address': 'Centre-ville, Yaoundé',
      'latitude': 3.8556,
      'longitude': 11.5089,
      'phoneNumber': '+237222231034',
      'emergencyContact': '+237222231034',
      'specialties': ['emergency', 'general_medicine', 'obstetrics'],
      'hasEmergencyRoom': true,
      'hasAmbulance': true,
      'acceptsInsurance': true,
      'rating': 3.8,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Clinique de l\'Aéroport',
      'type': 'private',
      'address': 'Bastos, Yaoundé',
      'latitude': 3.8480,
      'longitude': 11.5021,
      'phoneNumber': '+237222210987',
      'emergencyContact': '+237222210987',
      'specialties': ['emergency', 'surgery', 'laboratory'],
      'hasEmergencyRoom': true,
      'hasAmbulance': false,
      'acceptsInsurance': true,
      'rating': 4.5,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Hôpital Gynéco-Obstétrique et Pédiatrique',
      'type': 'public',
      'address': 'Mvog-Ada, Yaoundé',
      'latitude': 3.8322,
      'longitude': 11.4956,
      'phoneNumber': '+237222229876',
      'emergencyContact': '+237222229876',
      'specialties': ['obstetrics', 'pediatrics', 'neonatology'],
      'hasEmergencyRoom': true,
      'hasAmbulance': true,
      'acceptsInsurance': true,
      'rating': 4.0,
      'createdAt': Timestamp.now(),
    },
  ];

  for (final hospital in hospitals) {
    await firestore.collection('hospitals').add(hospital);
  }
}

/// Seed blood donors
Future<void> seedBloodDonors(
  FirebaseFirestore firestore,
  Random random,
  List<String> userIds,
) async {
  final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  for (int i = 0; i < 4; i++) {
    final donor = {
      'userId': userIds[i],
      'bloodType': bloodTypes[random.nextInt(bloodTypes.length)],
      'isAvailable': random.nextBool(),
      'lastDonationDate': Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: random.nextInt(180))),
      ),
      'donationCount': random.nextInt(10) + 1,
      'latitude': 3.8480 + (random.nextDouble() - 0.5) * 0.1,
      'longitude': 11.5021 + (random.nextDouble() - 0.5) * 0.1,
      'contactPreference': 'phone',
      'emergencyOnly': false,
      'createdAt': Timestamp.now(),
    };

    await firestore.collection('blood_donors').add(donor);
  }
}

/// Seed NGOs
Future<void> seedNGOs(FirebaseFirestore firestore, Random random) async {
  final ngos = [
    {
      'name': 'Cameroon Red Cross',
      'description': 'Humanitarian aid and disaster relief',
      'category': 'emergency_response',
      'address': 'Rue Nachtigal, Yaoundé',
      'latitude': 3.8556,
      'longitude': 11.5089,
      'phoneNumber': '+237222223976',
      'email': 'contact@redcross-cm.org',
      'website': 'https://www.redcross-cm.org',
      'services': ['emergency_relief', 'first_aid', 'blood_bank'],
      'isVerified': true,
      'rating': 4.8,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Plan Cameroun',
      'description': 'Child protection and development',
      'category': 'child_protection',
      'address': 'Bastos, Yaoundé',
      'latitude': 3.8480,
      'longitude': 11.5021,
      'phoneNumber': '+237222214567',
      'email': 'info@plan-cameroun.org',
      'website': 'https://www.plan-international.org/cameroon',
      'services': ['education', 'health', 'protection'],
      'isVerified': true,
      'rating': 4.6,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Doctors Without Borders Cameroon',
      'description': 'Medical humanitarian assistance',
      'category': 'medical',
      'address': 'Nlongkak, Yaoundé',
      'latitude': 3.8578,
      'longitude': 11.5203,
      'phoneNumber': '+237222234567',
      'email': 'msf-cameroon@msf.org',
      'website': 'https://www.msf.org',
      'services': ['medical_care', 'emergency_response', 'mental_health'],
      'isVerified': true,
      'rating': 4.9,
      'createdAt': Timestamp.now(),
    },
  ];

  for (final ngo in ngos) {
    await firestore.collection('ngos').add(ngo);
  }
}

/// Seed emergency resources
Future<void> seedEmergencyResources(FirebaseFirestore firestore, Random random) async {
  final resources = [
    {
      'type': 'fire_extinguisher',
      'location': 'Community Center, Bastos',
      'latitude': 3.8480,
      'longitude': 11.5021,
      'quantity': 5,
      'isAvailable': true,
      'providerId': 'user_001',
      'contactNumber': '+237670000001',
      'createdAt': Timestamp.now(),
    },
    {
      'type': 'first_aid_kit',
      'location': 'School, Melen',
      'latitude': 3.8667,
      'longitude': 11.5167,
      'quantity': 3,
      'isAvailable': true,
      'providerId': 'user_002',
      'contactNumber': '+237680000002',
      'createdAt': Timestamp.now(),
    },
    {
      'type': 'defibrillator',
      'location': 'Clinique de l\'Aéroport',
      'latitude': 3.8480,
      'longitude': 11.5021,
      'quantity': 2,
      'isAvailable': true,
      'providerId': 'user_004',
      'contactNumber': '+237670000004',
      'createdAt': Timestamp.now(),
    },
    {
      'type': 'emergency_generator',
      'location': 'Municipal Building, Centre-ville',
      'latitude': 3.8556,
      'longitude': 11.5089,
      'quantity': 1,
      'isAvailable': true,
      'providerId': 'user_001',
      'contactNumber': '+237670000001',
      'createdAt': Timestamp.now(),
    },
  ];

  for (final resource in resources) {
    await firestore.collection('emergency_resources').add(resource);
  }
}

/// Seed community funds
Future<void> seedCommunityFunds(
  FirebaseFirestore firestore,
  Random random,
  List<String> userIds,
) async {
  final funds = [
    {
      'name': 'Bastos Emergency Fund',
      'description': 'Community fund for emergency assistance',
      'targetAmount': 1000000.0, // 1,000,000 FCFA
      'currentAmount': 650000.0, // 650,000 FCFA
      'administratorIds': [userIds[0], userIds[1]],
      'createdAt': Timestamp.now(),
      'isActive': true,
      'contributors': userIds.take(4).toList(),
      'contributionCount': 12,
    },
    {
      'name': 'Medical Emergency Support',
      'description': 'Fund to help community members with medical emergencies',
      'targetAmount': 2000000.0, // 2,000,000 FCFA
      'currentAmount': 450000.0, // 450,000 FCFA
      'administratorIds': [userIds[1]],
      'createdAt': Timestamp.now(),
      'isActive': true,
      'contributors': userIds.take(3).toList(),
      'contributionCount': 8,
    },
  ];

  for (final fund in funds) {
    await firestore.collection('community_funds').add(fund);
  }
}

/// Get alert description based on danger type
String _getAlertDescription(String dangerType, String area) {
  switch (dangerType) {
    case 'fire':
      return 'Fire reported in $area. Multiple buildings affected. Fire services notified.';
    case 'accident':
      return 'Traffic accident in $area. Multiple vehicles involved. Ambulance requested.';
    case 'crime':
      return 'Security incident reported in $area. Please stay vigilant and avoid the area.';
    case 'medical':
      return 'Medical emergency in $area. Individual needs immediate assistance.';
    case 'natural_disaster':
      return 'Flooding reported in $area due to heavy rainfall. Roads may be impassable.';
    case 'other':
      return 'Emergency situation in $area. Please exercise caution.';
    default:
      return 'Alert in $area. Please stay safe.';
  }
}
