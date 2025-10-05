import 'enums.dart';

// String Extensions
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPhone {
    // Cameroon phone format: +237 6XX XXX XXX
    return RegExp(r'^\+?237?[26]\d{8}$').hasMatch(replaceAll(' ', ''));
  }
}

// DateTime Extensions
extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}

// Enum Extensions
extension DangerGroupExtension on DangerGroup {
  String get displayName {
    switch (this) {
      case DangerGroup.crimeAndSecurity:
        return 'Crime & Security';
      case DangerGroup.healthEmergencies:
        return 'Health Emergencies';
      case DangerGroup.infrastructure:
        return 'Infrastructure';
      case DangerGroup.naturalDisasters:
        return 'Natural Disasters';
      case DangerGroup.trafficAndTransport:
        return 'Traffic & Transport';
      case DangerGroup.publicSafety:
        return 'Public Safety';
    }
  }

  String get icon {
    switch (this) {
      case DangerGroup.crimeAndSecurity:
        return '🔫';
      case DangerGroup.healthEmergencies:
        return '🏥';
      case DangerGroup.infrastructure:
        return '⚡';
      case DangerGroup.naturalDisasters:
        return '🌪️';
      case DangerGroup.trafficAndTransport:
        return '🚗';
      case DangerGroup.publicSafety:
        return '🚨';
    }
  }

  String get description {
    switch (this) {
      case DangerGroup.crimeAndSecurity:
        return 'Theft, robbery, kidnapping, assault, and security threats';
      case DangerGroup.healthEmergencies:
        return 'Medical emergencies, epidemics, and health hazards';
      case DangerGroup.infrastructure:
        return 'Power outages, water shortage, and infrastructure issues';
      case DangerGroup.naturalDisasters:
        return 'Flooding, landslides, fires, and natural disasters';
      case DangerGroup.trafficAndTransport:
        return 'Accidents, road closures, and transport issues';
      case DangerGroup.publicSafety:
        return 'Riots, demonstrations, and public disturbances';
    }
  }

  List<DangerType> get dangerTypes {
    switch (this) {
      case DangerGroup.crimeAndSecurity:
        return [
          DangerType.armedRobbery,
          DangerType.kidnapping,
          DangerType.livestockTheft,
          DangerType.separatistConflict,
          DangerType.bokoHaram,
        ];
      case DangerGroup.healthEmergencies:
        return [
          DangerType.medicalEmergency,
          DangerType.epidemic,
        ];
      case DangerGroup.infrastructure:
        return [];
      case DangerGroup.naturalDisasters:
        return [
          DangerType.fire,
          DangerType.flood,
          DangerType.landslide,
          DangerType.naturalDisaster,
        ];
      case DangerGroup.trafficAndTransport:
        return [
          DangerType.accident,
        ];
      case DangerGroup.publicSafety:
        return [
          DangerType.riot,
        ];
    }
  }
}

extension DangerTypeExtension on DangerType {
  String get displayName {
    switch (this) {
      case DangerType.fire:
        return 'Fire';
      case DangerType.flood:
        return 'Flood';
      case DangerType.armedRobbery:
        return 'Armed Robbery';
      case DangerType.kidnapping:
        return 'Kidnapping';
      case DangerType.separatistConflict:
        return 'Separatist Conflict';
      case DangerType.bokoHaram:
        return 'Boko Haram Activity';
      case DangerType.landslide:
        return 'Landslide';
      case DangerType.riot:
        return 'Riot';
      case DangerType.accident:
        return 'Accident';
      case DangerType.medicalEmergency:
        return 'Medical Emergency';
      case DangerType.epidemic:
        return 'Epidemic';
      case DangerType.livestockTheft:
        return 'Livestock Theft';
      case DangerType.naturalDisaster:
        return 'Natural Disaster';
      case DangerType.other:
        return 'Other';
    }
  }

  // Alias for displayName to support different naming conventions
  String get localizedName => displayName;

  String get icon {
    switch (this) {
      case DangerType.fire:
        return '🔥';
      case DangerType.flood:
        return '🌊';
      case DangerType.armedRobbery:
        return '🔫';
      case DangerType.kidnapping:
        return '⚠️';
      case DangerType.separatistConflict:
        return '⚔️';
      case DangerType.bokoHaram:
        return '🚨';
      case DangerType.landslide:
        return '🏔️';
      case DangerType.riot:
        return '👥';
      case DangerType.accident:
        return '🚗';
      case DangerType.medicalEmergency:
        return '🏥';
      case DangerType.epidemic:
        return '🦠';
      case DangerType.livestockTheft:
        return '🐄';
      case DangerType.naturalDisaster:
        return '🌪️';
      case DangerType.other:
        return '📍';
    }
  }

  DangerGroup? get group {
    switch (this) {
      case DangerType.armedRobbery:
      case DangerType.kidnapping:
      case DangerType.livestockTheft:
      case DangerType.separatistConflict:
      case DangerType.bokoHaram:
        return DangerGroup.crimeAndSecurity;
      case DangerType.medicalEmergency:
      case DangerType.epidemic:
        return DangerGroup.healthEmergencies;
      case DangerType.fire:
      case DangerType.flood:
      case DangerType.landslide:
      case DangerType.naturalDisaster:
        return DangerGroup.naturalDisasters;
      case DangerType.accident:
        return DangerGroup.trafficAndTransport;
      case DangerType.riot:
        return DangerGroup.publicSafety;
      case DangerType.other:
        return null;
    }
  }
}

extension BloodTypeExtension on BloodType {
  String get displayName {
    switch (this) {
      case BloodType.aPositive:
        return 'A+';
      case BloodType.aNegative:
        return 'A-';
      case BloodType.bPositive:
        return 'B+';
      case BloodType.bNegative:
        return 'B-';
      case BloodType.oPositive:
        return 'O+';
      case BloodType.oNegative:
        return 'O-';
      case BloodType.abPositive:
        return 'AB+';
      case BloodType.abNegative:
        return 'AB-';
    }
  }
}

extension AlertStatusExtension on AlertStatus {
  String get displayName {
    switch (this) {
      case AlertStatus.active:
        return 'Active';
      case AlertStatus.resolved:
        return 'Resolved';
      case AlertStatus.falseAlarm:
        return 'False Alarm';
      case AlertStatus.verified:
        return 'Verified';
    }
  }

  String get color {
    switch (this) {
      case AlertStatus.active:
        return '#FF3B30'; // Red
      case AlertStatus.resolved:
        return '#34C759'; // Green
      case AlertStatus.falseAlarm:
        return '#FF9500'; // Orange
      case AlertStatus.verified:
        return '#007AFF'; // Blue
    }
  }
}

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.pidgin:
        return 'pidgin';
      case AppLanguage.fulfulde:
        return 'ff';
      case AppLanguage.ewondo:
        return 'ewo';
      case AppLanguage.duala:
        return 'dua';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.pidgin:
        return 'Pidgin';
      case AppLanguage.fulfulde:
        return 'Fulfulde';
      case AppLanguage.ewondo:
        return 'Ewondo';
      case AppLanguage.duala:
        return 'Duala';
    }
  }
}

extension VerificationLevelExtension on VerificationLevel {
  String get displayName {
    switch (this) {
      case VerificationLevel.newcomer:
        return 'Newcomer';
      case VerificationLevel.bronze:
        return 'Bronze';
      case VerificationLevel.silver:
        return 'Silver';
      case VerificationLevel.gold:
        return 'Gold';
      case VerificationLevel.platinum:
        return 'Platinum';
    }
  }

  String get icon {
    switch (this) {
      case VerificationLevel.newcomer:
        return '🌱';
      case VerificationLevel.bronze:
        return '🥉';
      case VerificationLevel.silver:
        return '🥈';
      case VerificationLevel.gold:
        return '🥇';
      case VerificationLevel.platinum:
        return '💎';
    }
  }

  String get color {
    switch (this) {
      case VerificationLevel.newcomer:
        return '#8E8E93'; // Gray
      case VerificationLevel.bronze:
        return '#CD7F32'; // Bronze
      case VerificationLevel.silver:
        return '#C0C0C0'; // Silver
      case VerificationLevel.gold:
        return '#FFD700'; // Gold
      case VerificationLevel.platinum:
        return '#E5E4E2'; // Platinum
    }
  }

  int get minPoints {
    switch (this) {
      case VerificationLevel.newcomer:
        return 0;
      case VerificationLevel.bronze:
        return 51;
      case VerificationLevel.silver:
        return 151;
      case VerificationLevel.gold:
        return 301;
      case VerificationLevel.platinum:
        return 501;
    }
  }

  int get maxPoints {
    switch (this) {
      case VerificationLevel.newcomer:
        return 50;
      case VerificationLevel.bronze:
        return 150;
      case VerificationLevel.silver:
        return 300;
      case VerificationLevel.gold:
        return 500;
      case VerificationLevel.platinum:
        return 999999; // No upper limit
    }
  }

  static VerificationLevel fromPoints(int points) {
    if (points >= 501) return VerificationLevel.platinum;
    if (points >= 301) return VerificationLevel.gold;
    if (points >= 151) return VerificationLevel.silver;
    if (points >= 51) return VerificationLevel.bronze;
    return VerificationLevel.newcomer;
  }
}

extension BadgeTypeExtension on BadgeType {
  String get displayName {
    switch (this) {
      // Activity Badges
      case BadgeType.earlyAdopter:
        return 'Early Adopter';
      case BadgeType.alertMaster:
        return 'Alert Master';
      case BadgeType.communityGuardian:
        return 'Community Guardian';
      case BadgeType.safetyAdvocate:
        return 'Safety Advocate';
      case BadgeType.firstResponder:
        return 'First Responder';

      // Contribution Badges
      case BadgeType.helpingHand:
        return 'Helping Hand';
      case BadgeType.lifeSaver:
        return 'Life Saver';
      case BadgeType.resourceProvider:
        return 'Resource Provider';
      case BadgeType.donorHero:
        return 'Donor Hero';

      // Trust Badges
      case BadgeType.trustedMember:
        return 'Trusted Member';
      case BadgeType.verifiedCitizen:
        return 'Verified Citizen';
      case BadgeType.communityLeader:
        return 'Community Leader';

      // Professional Badges
      case BadgeType.verifiedProfessional:
        return 'Verified Professional';
      case BadgeType.emergencyResponder:
        return 'Emergency Responder';
      case BadgeType.healthcareWorker:
        return 'Healthcare Worker';

      // Special Badges
      case BadgeType.foundingMember:
        return 'Founding Member';
      case BadgeType.moderator:
        return 'Moderator';
      case BadgeType.ambassador:
        return 'Ambassador';
    }
  }

  String get icon {
    switch (this) {
      // Activity Badges
      case BadgeType.earlyAdopter:
        return '🌟';
      case BadgeType.alertMaster:
        return '🚨';
      case BadgeType.communityGuardian:
        return '🛡️';
      case BadgeType.safetyAdvocate:
        return '🦺';
      case BadgeType.firstResponder:
        return '🚑';

      // Contribution Badges
      case BadgeType.helpingHand:
        return '🤝';
      case BadgeType.lifeSaver:
        return '❤️';
      case BadgeType.resourceProvider:
        return '📦';
      case BadgeType.donorHero:
        return '💉';

      // Trust Badges
      case BadgeType.trustedMember:
        return '✅';
      case BadgeType.verifiedCitizen:
        return '🎖️';
      case BadgeType.communityLeader:
        return '👑';

      // Professional Badges
      case BadgeType.verifiedProfessional:
        return '💼';
      case BadgeType.emergencyResponder:
        return '🚒';
      case BadgeType.healthcareWorker:
        return '⚕️';

      // Special Badges
      case BadgeType.foundingMember:
        return '🏆';
      case BadgeType.moderator:
        return '🔰';
      case BadgeType.ambassador:
        return '🌍';
    }
  }

  String get description {
    switch (this) {
      // Activity Badges
      case BadgeType.earlyAdopter:
        return 'Joined the community in its early days';
      case BadgeType.alertMaster:
        return 'Created 50+ verified alerts';
      case BadgeType.communityGuardian:
        return 'Actively protecting the community for 6+ months';
      case BadgeType.safetyAdvocate:
        return 'Shared safety tips and helped 100+ people';
      case BadgeType.firstResponder:
        return 'First to respond to 20+ emergencies';

      // Contribution Badges
      case BadgeType.helpingHand:
        return 'Offered help on 10+ alerts';
      case BadgeType.lifeSaver:
        return 'Saved lives through timely alerts';
      case BadgeType.resourceProvider:
        return 'Shared resources during 5+ emergencies';
      case BadgeType.donorHero:
        return 'Donated blood 3+ times';

      // Trust Badges
      case BadgeType.trustedMember:
        return '90%+ accuracy on alert confirmations';
      case BadgeType.verifiedCitizen:
        return 'Identity verified with national ID';
      case BadgeType.communityLeader:
        return 'Leading a neighborhood watch group';

      // Professional Badges
      case BadgeType.verifiedProfessional:
        return 'Verified emergency services professional';
      case BadgeType.emergencyResponder:
        return 'Certified first responder';
      case BadgeType.healthcareWorker:
        return 'Verified healthcare professional';

      // Special Badges
      case BadgeType.foundingMember:
        return 'One of the first 1000 members';
      case BadgeType.moderator:
        return 'Trusted community moderator';
      case BadgeType.ambassador:
        return 'Community ambassador';
    }
  }

  int get pointValue {
    switch (this) {
      // Activity Badges
      case BadgeType.earlyAdopter:
        return 20;
      case BadgeType.alertMaster:
        return 100;
      case BadgeType.communityGuardian:
        return 150;
      case BadgeType.safetyAdvocate:
        return 75;
      case BadgeType.firstResponder:
        return 80;

      // Contribution Badges
      case BadgeType.helpingHand:
        return 30;
      case BadgeType.lifeSaver:
        return 200;
      case BadgeType.resourceProvider:
        return 50;
      case BadgeType.donorHero:
        return 100;

      // Trust Badges
      case BadgeType.trustedMember:
        return 60;
      case BadgeType.verifiedCitizen:
        return 50;
      case BadgeType.communityLeader:
        return 120;

      // Professional Badges
      case BadgeType.verifiedProfessional:
        return 150;
      case BadgeType.emergencyResponder:
        return 100;
      case BadgeType.healthcareWorker:
        return 100;

      // Special Badges
      case BadgeType.foundingMember:
        return 50;
      case BadgeType.moderator:
        return 200;
      case BadgeType.ambassador:
        return 150;
    }
  }
}

extension ContributionTypeExtension on ContributionType {
  int get points {
    switch (this) {
      case ContributionType.alertCreated:
        return 5;
      case ContributionType.alertConfirmed:
        return 3;
      case ContributionType.helpOffered:
        return 10;
      case ContributionType.resourceShared:
        return 15;
      case ContributionType.commentAdded:
        return 1;
      case ContributionType.bloodDonated:
        return 50;
      case ContributionType.fundContributed:
        return 20;
      case ContributionType.memberReferred:
        return 10;
      case ContributionType.communityModeration:
        return 5;
    }
  }

  String get displayName {
    switch (this) {
      case ContributionType.alertCreated:
        return 'Alert Created';
      case ContributionType.alertConfirmed:
        return 'Alert Confirmed';
      case ContributionType.helpOffered:
        return 'Help Offered';
      case ContributionType.resourceShared:
        return 'Resource Shared';
      case ContributionType.commentAdded:
        return 'Comment Added';
      case ContributionType.bloodDonated:
        return 'Blood Donated';
      case ContributionType.fundContributed:
        return 'Fund Contributed';
      case ContributionType.memberReferred:
        return 'Member Referred';
      case ContributionType.communityModeration:
        return 'Community Moderation';
    }
  }
}
