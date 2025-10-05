import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataSeedService {
  final FirebaseFirestore _firestore;
  final Random _random = Random();

  DataSeedService(this._firestore);

  /// Seed all data
  Future<void> seedAllData() async {
    final userIds = await seedUsers();
    await seedAlerts(userIds);
    await seedWatchGroups(userIds);
    await seedHospitals();
    await seedBloodDonors(userIds);
    await seedNGOs();
    await seedEmergencyResources(userIds);
    await seedCommunityFunds(userIds);
  }

  /// Seed sample users
  Future<List<String>> seedUsers() async {
    final users = [
      {
        'phoneNumber': '+237670000001',
        'displayName': 'Jean Mbarga',
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
        'phoneNumber': '+237680000002',
        'displayName': 'Marie Ngoue',
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
        'phoneNumber': '+237690000003',
        'displayName': 'Paul Kamga',
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
        'phoneNumber': '+237670000004',
        'displayName': 'Aminata Sow',
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
        'phoneNumber': '+237680000005',
        'displayName': 'Bernard Tchoua',
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
      final docRef = await _firestore.collection('users').add(user);
      userIds.add(docRef.id);
    }

    return userIds;
  }

  /// Seed sample alerts
  Future<void> seedAlerts(List<String> userIds) async {
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
    ];

    for (int i = 0; i < 15; i++) {
      final location = locations[_random.nextInt(locations.length)];
      final dangerType = dangerTypes[_random.nextInt(dangerTypes.length)];
      final level = severityLevels[_random.nextInt(severityLevels.length)];
      final creatorId = userIds[_random.nextInt(userIds.length)];
      final isResolved = _random.nextBool();

      final alert = {
        'dangerType': dangerType,
        'level': level,
        'latitude': location['lat'],
        'longitude': location['lng'],
        'address': '${location['area']}, Yaoundé, Cameroon',
        'description': _getAlertDescription(dangerType, location['area'] as String),
        'creatorId': creatorId,
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(hours: _random.nextInt(72))),
        ),
        'confirmations': List.generate(
          _random.nextInt(5),
          (index) => userIds[_random.nextInt(userIds.length)],
        ),
        'isResolved': isResolved,
        'resolvedAt': isResolved ? Timestamp.now() : null,
        'isFalseAlarm': false,
        'photoUrl': null,
        'helpOffered': _random.nextInt(3),
        'viewCount': _random.nextInt(50),
      };

      await _firestore.collection('alerts').add(alert);
    }
  }

  /// Seed neighborhood watch groups
  Future<void> seedWatchGroups(List<String> userIds) async {
    final groups = [
      {
        'name': 'Bastos Neighborhood Watch',
        'description': 'Keeping our Bastos community safe and connected',
        'coordinatorId': userIds[0],
        'administratorIds': [userIds[0], userIds[1]],
        'memberIds': userIds.take(3).toList(),
        'isPrivate': false,
        'createdAt': Timestamp.now(),
        'memberCount': 3,
        'radius': 2.0,
        'centerLatitude': 3.8480,
        'centerLongitude': 11.5021,
      },
      {
        'name': 'Melen Security Network',
        'description': 'United for a safer Melen',
        'coordinatorId': userIds[1],
        'administratorIds': [userIds[1]],
        'memberIds': userIds.take(2).toList(),
        'isPrivate': false,
        'createdAt': Timestamp.now(),
        'memberCount': 2,
        'radius': 3.0,
        'centerLatitude': 3.8667,
        'centerLongitude': 11.5167,
      },
    ];

    for (final group in groups) {
      await _firestore.collection('watch_groups').add(group);
    }
  }

  /// Seed hospitals
  Future<void> seedHospitals() async {
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
    ];

    for (final hospital in hospitals) {
      await _firestore.collection('hospitals').add(hospital);
    }
  }

  /// Seed blood donors
  Future<void> seedBloodDonors(List<String> userIds) async {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    for (int i = 0; i < 3; i++) {
      final donor = {
        'userId': userIds[i],
        'bloodType': bloodTypes[_random.nextInt(bloodTypes.length)],
        'isAvailable': _random.nextBool(),
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: _random.nextInt(180))),
        ),
        'donationCount': _random.nextInt(10) + 1,
        'latitude': 3.8480 + (_random.nextDouble() - 0.5) * 0.1,
        'longitude': 11.5021 + (_random.nextDouble() - 0.5) * 0.1,
        'contactPreference': 'phone',
        'emergencyOnly': false,
        'createdAt': Timestamp.now(),
      };

      await _firestore.collection('blood_donors').add(donor);
    }
  }

  /// Seed NGOs
  Future<void> seedNGOs() async {
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
    ];

    for (final ngo in ngos) {
      await _firestore.collection('ngos').add(ngo);
    }
  }

  /// Seed emergency resources
  Future<void> seedEmergencyResources(List<String> userIds) async {
    final resources = [
      {
        'type': 'fire_extinguisher',
        'location': 'Community Center, Bastos',
        'latitude': 3.8480,
        'longitude': 11.5021,
        'quantity': 5,
        'isAvailable': true,
        'providerId': userIds[0],
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
        'providerId': userIds[1],
        'contactNumber': '+237680000002',
        'createdAt': Timestamp.now(),
      },
    ];

    for (final resource in resources) {
      await _firestore.collection('emergency_resources').add(resource);
    }
  }

  /// Seed community funds
  Future<void> seedCommunityFunds(List<String> userIds) async {
    final funds = [
      {
        'name': 'Bastos Emergency Fund',
        'description': 'Community fund for emergency assistance',
        'targetAmount': 1000000.0,
        'currentAmount': 650000.0,
        'administratorIds': [userIds[0], userIds[1]],
        'createdAt': Timestamp.now(),
        'isActive': true,
        'contributors': userIds.take(3).toList(),
        'contributionCount': 12,
      },
    ];

    for (final fund in funds) {
      await _firestore.collection('community_funds').add(fund);
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
}
