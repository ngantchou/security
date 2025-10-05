class AppConstants {
  // App Info
  static const String appName = 'Safety Alert';
  static const String appVersion = '1.0.0';

  // Alert Levels
  static const int minAlertLevel = 1;
  static const int maxAlertLevel = 5;
  static const int criticalAlertLevel = 3;

  // Radius
  static const double defaultAlertRadiusKm = 5.0;
  static const double maxAlertRadiusKm = 50.0;

  // Limits
  static const int maxAudioDurationSeconds = 60;
  static const int maxImageCount = 5;
  static const int maxCommentLength = 500;

  // Timeouts
  static const int defaultTimeoutSeconds = 30;
  static const int uploadTimeoutSeconds = 120;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache Duration
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);

  // Credibility
  static const int initialCredibilityScore = 50;
  static const int maxCredibilityScore = 100;
  static const int minCredibilityScore = 0;
  static const int falseAlertPenalty = -10;
  static const int confirmationReward = 5;
  static const int maxFalseAlertsBeforeSuspension = 3;

  // Payment
  static const String currencyCode = 'XAF';
  static const String currencySymbol = 'FCFA';
  static const int minContributionAmount = 100;
}
