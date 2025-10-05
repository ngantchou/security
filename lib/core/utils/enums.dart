// Alert Status
enum AlertStatus {
  active,
  resolved,
  falseAlarm,
  verified,
}

// Alert Severity
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

// Danger Groups - Organized Categories
enum DangerGroup {
  crimeAndSecurity,
  healthEmergencies,
  infrastructure,
  naturalDisasters,
  trafficAndTransport,
  publicSafety,
}

// Danger Types - Cameroon Specific
enum DangerType {
  fire,
  flood,
  armedRobbery,
  kidnapping,
  separatistConflict,
  bokoHaram,
  landslide,
  riot,
  accident,
  medicalEmergency,
  epidemic,
  livestockTheft,
  naturalDisaster,
  other,
}

// User Roles
enum UserRole {
  regular,
  volunteerResponder,
  securityProfessional,
  ngoWorker,
  coordinator,
}

// Group Privacy
enum GroupPrivacy {
  public,
  private,
  restricted,
}

// Group Member Roles
enum GroupRole {
  member,
  moderator,
  admin,
  creator,
}

// Professional Types
enum ProfessionalType {
  firefighter,
  paramedic,
  police,
  doctor,
  nurse,
}

// Blood Types
enum BloodType {
  aPositive,
  aNegative,
  bPositive,
  bNegative,
  oPositive,
  oNegative,
  abPositive,
  abNegative,
}

// Resource Types
enum ResourceType {
  generator,
  medicalSupplies,
  safeHouse,
  vehicle,
  food,
  water,
  other,
}

// Emergency Resource Types
enum EmergencyResourceType {
  hospital,
  clinic,
  pharmacy,
  fireStation,
  policeStation,
}

// Verification Method
enum VerificationMethod {
  nationalId,
  communityVouching,
}

// Verification Status
enum VerificationStatus {
  pending,
  approved,
  rejected,
}

// Fund Campaign Status
enum FundCampaignStatus {
  active,
  completed,
  cancelled,
}

// Payment Method
enum PaymentMethod {
  mtnMomo,
  orangeMoney,
}

// Transaction Status
enum TransactionStatus {
  pending,
  completed,
  failed,
}

// Disbursement Status
enum DisbursementStatus {
  pending,
  approved,
  rejected,
  disbursed,
}

// Notification Type
enum NotificationType {
  alert,
  confirmation,
  news,
  fundContribution,
  groupInvite,
  system,
}

// Languages
enum AppLanguage {
  english,
  french,
  pidgin,
  fulfulde,
  ewondo,
  duala,
}

// Certification Type
enum CertificationType {
  firstAid,
  cpr,
  firefighter,
  paramedic,
  other,
}

// NGO Type
enum NGOType {
  humanitarian,
  health,
  security,
  disasterRelief,
}

// Author Type
enum AuthorType {
  user,
  moderator,
  ngo,
  authority,
}

// Vote Type
enum VoteType {
  approve,
  reject,
}

// Verification Level
enum VerificationLevel {
  newcomer,      // 0-50 points
  bronze,        // 51-150 points
  silver,        // 151-300 points
  gold,          // 301-500 points
  platinum,      // 501+ points
}

// Badge Type
enum BadgeType {
  // Activity Badges
  earlyAdopter,
  alertMaster,
  communityGuardian,
  safetyAdvocate,
  firstResponder,

  // Contribution Badges
  helpingHand,
  lifeSaver,
  resourceProvider,
  donorHero,

  // Trust Badges
  trustedMember,
  verifiedCitizen,
  communityLeader,

  // Professional Badges
  verifiedProfessional,
  emergencyResponder,
  healthcareWorker,

  // Special Badges
  foundingMember,
  moderator,
  ambassador,
}

// Contribution Type
enum ContributionType {
  alertCreated,
  alertConfirmed,
  helpOffered,
  resourceShared,
  commentAdded,
  bloodDonated,
  fundContributed,
  memberReferred,
  communityModeration,
}
