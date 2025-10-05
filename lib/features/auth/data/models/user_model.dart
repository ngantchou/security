import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.phoneNumber,
    super.email,
    required super.displayName,
    super.bio,
    required super.preferredLanguage,
    super.profilePhoto,
    required super.nationalIdVerified,
    super.verificationMethod,
    super.verificationDate,
    super.location,
    super.region,
    super.city,
    super.neighborhood,
    super.emergencyContacts,
    required super.alertRadius,
    required super.notificationPreferences,
    required super.roles,
    super.bloodDonor,
    super.sharedResources,
    required super.alertsCreated,
    required super.alertsConfirmed,
    required super.credibilityScore,
    required super.falseAlertCount,
    required super.verificationLevel,
    required super.contributionPoints,
    super.earnedBadges,
    required super.helpOfferedCount,
    required super.resourcesSharedCount,
    super.followedDangerGroups,
    super.joinedNeighborhoodGroups,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      preferredLanguage: json['preferredLanguage'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      nationalIdVerified: json['nationalIdVerified'] as bool,
      verificationMethod: json['verificationMethod'] != null
          ? VerificationMethod.values.firstWhere(
              (e) => e.toString().split('.').last == json['verificationMethod'],
            )
          : null,
      verificationDate: json['verificationDate'] != null
          ? (json['verificationDate'] as Timestamp).toDate()
          : null,
      location: json['location'] as GeoPoint?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      neighborhood: json['neighborhood'] as String?,
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContactModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      alertRadius: (json['alertRadius'] as num).toDouble(),
      notificationPreferences: NotificationPreferencesModel.fromJson(
        json['notificationPreferences'] as Map<String, dynamic>,
      ),
      roles: UserRolesModel.fromJson(json['roles'] as Map<String, dynamic>),
      bloodDonor: json['bloodDonor'] != null
          ? BloodDonorInfoModel.fromJson(json['bloodDonor'] as Map<String, dynamic>)
          : null,
      sharedResources: (json['sharedResources'] as List<dynamic>?)
              ?.map((e) => SharedResourceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      alertsCreated: json['alertsCreated'] as int,
      alertsConfirmed: json['alertsConfirmed'] as int,
      credibilityScore: json['credibilityScore'] as int,
      falseAlertCount: json['falseAlertCount'] as int,
      verificationLevel: json['verificationLevel'] != null
          ? VerificationLevel.values.firstWhere(
              (e) => e.toString().split('.').last == json['verificationLevel'],
            )
          : VerificationLevel.newcomer,
      contributionPoints: json['contributionPoints'] as int? ?? 0,
      earnedBadges: (json['earnedBadges'] as List<dynamic>?)
              ?.map((e) => BadgeType.values.firstWhere(
                    (b) => b.toString().split('.').last == e,
                  ))
              .toList() ??
          [],
      helpOfferedCount: json['helpOfferedCount'] as int? ?? 0,
      resourcesSharedCount: json['resourcesSharedCount'] as int? ?? 0,
      followedDangerGroups: (json['followedDangerGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      joinedNeighborhoodGroups: (json['joinedNeighborhoodGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'preferredLanguage': preferredLanguage,
      'profilePhoto': profilePhoto,
      'nationalIdVerified': nationalIdVerified,
      'verificationMethod': verificationMethod?.toString().split('.').last,
      'verificationDate': verificationDate != null
          ? Timestamp.fromDate(verificationDate!)
          : null,
      'location': location,
      'region': region,
      'city': city,
      'neighborhood': neighborhood,
      'emergencyContacts': emergencyContacts
          .map((e) => EmergencyContactModel.fromEntity(e).toJson())
          .toList(),
      'alertRadius': alertRadius,
      'notificationPreferences':
          NotificationPreferencesModel.fromEntity(notificationPreferences)
              .toJson(),
      'roles': UserRolesModel.fromEntity(roles).toJson(),
      'bloodDonor': bloodDonor != null
          ? BloodDonorInfoModel.fromEntity(bloodDonor!).toJson()
          : null,
      'sharedResources': sharedResources
          .map((e) => SharedResourceModel.fromEntity(e).toJson())
          .toList(),
      'alertsCreated': alertsCreated,
      'alertsConfirmed': alertsConfirmed,
      'credibilityScore': credibilityScore,
      'falseAlertCount': falseAlertCount,
      'verificationLevel': verificationLevel.toString().split('.').last,
      'contributionPoints': contributionPoints,
      'earnedBadges': earnedBadges.map((e) => e.toString().split('.').last).toList(),
      'helpOfferedCount': helpOfferedCount,
      'resourcesSharedCount': resourcesSharedCount,
      'followedDangerGroups': followedDangerGroups,
      'joinedNeighborhoodGroups': joinedNeighborhoodGroups,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      displayName: entity.displayName,
      preferredLanguage: entity.preferredLanguage,
      profilePhoto: entity.profilePhoto,
      nationalIdVerified: entity.nationalIdVerified,
      verificationMethod: entity.verificationMethod,
      verificationDate: entity.verificationDate,
      location: entity.location,
      region: entity.region,
      city: entity.city,
      neighborhood: entity.neighborhood,
      emergencyContacts: entity.emergencyContacts,
      alertRadius: entity.alertRadius,
      notificationPreferences: entity.notificationPreferences,
      roles: entity.roles,
      bloodDonor: entity.bloodDonor,
      sharedResources: entity.sharedResources,
      alertsCreated: entity.alertsCreated,
      alertsConfirmed: entity.alertsConfirmed,
      credibilityScore: entity.credibilityScore,
      falseAlertCount: entity.falseAlertCount,
      verificationLevel: entity.verificationLevel,
      contributionPoints: entity.contributionPoints,
      earnedBadges: entity.earnedBadges,
      helpOfferedCount: entity.helpOfferedCount,
      resourcesSharedCount: entity.resourcesSharedCount,
      followedDangerGroups: entity.followedDangerGroups,
      joinedNeighborhoodGroups: entity.joinedNeighborhoodGroups,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

// Supporting models
class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    required super.name,
    required super.phoneNumber,
    required super.relationship,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
    };
  }

  factory EmergencyContactModel.fromEntity(EmergencyContact entity) {
    return EmergencyContactModel(
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      relationship: entity.relationship,
    );
  }
}

class NotificationPreferencesModel extends NotificationPreferences {
  const NotificationPreferencesModel({
    required super.pushEnabled,
    required super.smsEnabled,
    required super.alertLevels,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      pushEnabled: json['pushEnabled'] as bool,
      smsEnabled: json['smsEnabled'] as bool,
      alertLevels: (json['alertLevels'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'smsEnabled': smsEnabled,
      'alertLevels': alertLevels,
    };
  }

  factory NotificationPreferencesModel.fromEntity(
      NotificationPreferences entity) {
    return NotificationPreferencesModel(
      pushEnabled: entity.pushEnabled,
      smsEnabled: entity.smsEnabled,
      alertLevels: entity.alertLevels,
    );
  }
}

class UserRolesModel extends UserRoles {
  const UserRolesModel({
    required super.isVolunteerResponder,
    required super.isSecurityProfessional,
    super.professionalType,
    required super.isNGOWorker,
    super.ngoId,
  });

  factory UserRolesModel.fromJson(Map<String, dynamic> json) {
    return UserRolesModel(
      isVolunteerResponder: json['isVolunteerResponder'] as bool,
      isSecurityProfessional: json['isSecurityProfessional'] as bool,
      professionalType: json['professionalType'] != null
          ? ProfessionalType.values.firstWhere(
              (e) => e.toString().split('.').last == json['professionalType'],
            )
          : null,
      isNGOWorker: json['isNGOWorker'] as bool,
      ngoId: json['ngoId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVolunteerResponder': isVolunteerResponder,
      'isSecurityProfessional': isSecurityProfessional,
      'professionalType': professionalType?.toString().split('.').last,
      'isNGOWorker': isNGOWorker,
      'ngoId': ngoId,
    };
  }

  factory UserRolesModel.fromEntity(UserRoles entity) {
    return UserRolesModel(
      isVolunteerResponder: entity.isVolunteerResponder,
      isSecurityProfessional: entity.isSecurityProfessional,
      professionalType: entity.professionalType,
      isNGOWorker: entity.isNGOWorker,
      ngoId: entity.ngoId,
    );
  }
}

class BloodDonorInfoModel extends BloodDonorInfo {
  const BloodDonorInfoModel({
    required super.isAvailable,
    required super.bloodType,
    super.lastDonationDate,
    required super.willingToTravel,
  });

  factory BloodDonorInfoModel.fromJson(Map<String, dynamic> json) {
    return BloodDonorInfoModel(
      isAvailable: json['isAvailable'] as bool,
      bloodType: BloodType.values.firstWhere(
        (e) => e.toString().split('.').last == json['bloodType'],
      ),
      lastDonationDate: json['lastDonationDate'] != null
          ? (json['lastDonationDate'] as Timestamp).toDate()
          : null,
      willingToTravel: (json['willingToTravel'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'bloodType': bloodType.toString().split('.').last,
      'lastDonationDate': lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      'willingToTravel': willingToTravel,
    };
  }

  factory BloodDonorInfoModel.fromEntity(BloodDonorInfo entity) {
    return BloodDonorInfoModel(
      isAvailable: entity.isAvailable,
      bloodType: entity.bloodType,
      lastDonationDate: entity.lastDonationDate,
      willingToTravel: entity.willingToTravel,
    );
  }
}

class SharedResourceModel extends SharedResource {
  const SharedResourceModel({
    required super.resourceType,
    required super.description,
    required super.availability,
  });

  factory SharedResourceModel.fromJson(Map<String, dynamic> json) {
    return SharedResourceModel(
      resourceType: ResourceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['resourceType'],
      ),
      description: json['description'] as String,
      availability: json['availability'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType.toString().split('.').last,
      'description': description,
      'availability': availability,
    };
  }

  factory SharedResourceModel.fromEntity(SharedResource entity) {
    return SharedResourceModel(
      resourceType: entity.resourceType,
      description: entity.description,
      availability: entity.availability,
    );
  }
}
