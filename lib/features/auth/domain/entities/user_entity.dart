import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

class UserEntity extends Equatable {
  final String uid;
  final String phoneNumber;
  final String? email;
  final String displayName;
  final String? bio;
  final String preferredLanguage;
  final String? profilePhoto;
  final bool nationalIdVerified;
  final VerificationMethod? verificationMethod;
  final DateTime? verificationDate;

  // Location
  final GeoPoint? location;
  final String? region;
  final String? city;
  final String? neighborhood;

  // Emergency Contacts
  final List<EmergencyContact> emergencyContacts;

  // Preferences
  final double alertRadius;
  final NotificationPreferences notificationPreferences;

  // Roles
  final UserRoles roles;

  // Blood Donor
  final BloodDonorInfo? bloodDonor;

  // Resources
  final List<SharedResource> sharedResources;

  // Stats
  final int alertsCreated;
  final int alertsConfirmed;
  final int credibilityScore;
  final int falseAlertCount;

  // Verification & Reputation
  final VerificationLevel verificationLevel;
  final int contributionPoints;
  final List<BadgeType> earnedBadges;
  final int helpOfferedCount;
  final int resourcesSharedCount;

  // Subscriptions
  final List<String> followedDangerGroups;
  final List<String> joinedNeighborhoodGroups;

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.uid,
    required this.phoneNumber,
    this.email,
    required this.displayName,
    this.bio,
    required this.preferredLanguage,
    this.profilePhoto,
    required this.nationalIdVerified,
    this.verificationMethod,
    this.verificationDate,
    this.location,
    this.region,
    this.city,
    this.neighborhood,
    this.emergencyContacts = const [],
    required this.alertRadius,
    required this.notificationPreferences,
    required this.roles,
    this.bloodDonor,
    this.sharedResources = const [],
    required this.alertsCreated,
    required this.alertsConfirmed,
    required this.credibilityScore,
    required this.falseAlertCount,
    required this.verificationLevel,
    required this.contributionPoints,
    this.earnedBadges = const [],
    required this.helpOfferedCount,
    required this.resourcesSharedCount,
    this.followedDangerGroups = const [],
    this.joinedNeighborhoodGroups = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        uid,
        phoneNumber,
        email,
        displayName,
        bio,
        preferredLanguage,
        profilePhoto,
        nationalIdVerified,
        verificationMethod,
        verificationDate,
        location,
        region,
        city,
        neighborhood,
        emergencyContacts,
        alertRadius,
        notificationPreferences,
        roles,
        bloodDonor,
        sharedResources,
        alertsCreated,
        alertsConfirmed,
        credibilityScore,
        falseAlertCount,
        verificationLevel,
        contributionPoints,
        earnedBadges,
        helpOfferedCount,
        resourcesSharedCount,
        followedDangerGroups,
        joinedNeighborhoodGroups,
        createdAt,
        updatedAt,
      ];
}

class EmergencyContact extends Equatable {
  final String name;
  final String phoneNumber;
  final String relationship;

  const EmergencyContact({
    required this.name,
    required this.phoneNumber,
    required this.relationship,
  });

  @override
  List<Object?> get props => [name, phoneNumber, relationship];
}

class NotificationPreferences extends Equatable {
  final bool pushEnabled;
  final bool smsEnabled;
  final List<int> alertLevels;

  const NotificationPreferences({
    required this.pushEnabled,
    required this.smsEnabled,
    required this.alertLevels,
  });

  @override
  List<Object?> get props => [pushEnabled, smsEnabled, alertLevels];
}

class UserRoles extends Equatable {
  final bool isVolunteerResponder;
  final bool isSecurityProfessional;
  final ProfessionalType? professionalType;
  final bool isNGOWorker;
  final String? ngoId;

  const UserRoles({
    required this.isVolunteerResponder,
    required this.isSecurityProfessional,
    this.professionalType,
    required this.isNGOWorker,
    this.ngoId,
  });

  @override
  List<Object?> get props => [
        isVolunteerResponder,
        isSecurityProfessional,
        professionalType,
        isNGOWorker,
        ngoId,
      ];
}

class BloodDonorInfo extends Equatable {
  final bool isAvailable;
  final BloodType bloodType;
  final DateTime? lastDonationDate;
  final double willingToTravel;

  const BloodDonorInfo({
    required this.isAvailable,
    required this.bloodType,
    this.lastDonationDate,
    required this.willingToTravel,
  });

  @override
  List<Object?> get props =>
      [isAvailable, bloodType, lastDonationDate, willingToTravel];
}

class SharedResource extends Equatable {
  final ResourceType resourceType;
  final String description;
  final bool availability;

  const SharedResource({
    required this.resourceType,
    required this.description,
    required this.availability,
  });

  @override
  List<Object?> get props => [resourceType, description, availability];
}
