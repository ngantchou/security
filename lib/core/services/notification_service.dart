import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final SharedPreferences _prefs;

  NotificationService({
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    required SharedPreferences prefs,
  })  : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _prefs = prefs;

  static const String _notificationRadiusKey = 'notification_radius';
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _dndModeKey = 'dnd_mode';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';

  /// Initialize notification services
  Future<void> initialize() async {
    // Configure Firebase Messaging
    await _configureFirebaseMessaging();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request permission
    await requestPermission();
  }

  Future<void> _configureFirebaseMessaging() async {
    // Set foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // High priority channel for critical alerts
    const highPriorityChannel = AndroidNotificationChannel(
      'alert_high_priority',
      'Critical Alerts',
      description: 'High priority danger alerts (Level 4-5)',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Medium priority channel for moderate alerts
    const mediumPriorityChannel = AndroidNotificationChannel(
      'alert_medium_priority',
      'Moderate Alerts',
      description: 'Medium priority danger alerts (Level 2-3)',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Low priority channel for informational alerts
    const lowPriorityChannel = AndroidNotificationChannel(
      'alert_low_priority',
      'Informational Alerts',
      description: 'Low priority danger alerts (Level 1)',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: false,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highPriorityChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(mediumPriorityChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(lowPriorityChannel);
  }

  /// Request notification permission
  Future<NotificationSettings> requestPermission() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) async {
    if (!isNotificationEnabled()) return;
    if (isDndModeEnabled()) return;

    final data = message.data;
    final alertLevel = int.tryParse(data['level'] ?? '3') ?? 3;
    final dangerType = data['dangerType'] ?? 'other';
    final latitude = double.tryParse(data['latitude'] ?? '0') ?? 0;
    final longitude = double.tryParse(data['longitude'] ?? '0') ?? 0;

    // Check if alert is within notification radius
    final isWithinRadius = await _isWithinNotificationRadius(
      latitude,
      longitude,
    );

    if (!isWithinRadius) return;

    // Check if user wants notifications for this danger type
    if (!isDangerTypeEnabled(dangerType)) return;

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'Safety Alert',
      body: message.notification?.body ?? 'A new alert has been reported nearby',
      payload: message.data.toString(),
      level: alertLevel,
    );
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    required int level,
  }) async {
    final channelId = _getChannelIdForLevel(level);
    final soundEnabled = isSoundEnabled();
    final vibrationEnabled = isVibrationEnabled();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForLevel(level),
      channelDescription: _getChannelDescriptionForLevel(level),
      importance: _getImportanceForLevel(level),
      priority: Priority.high,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Handle notification tap (FCM)
  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to alert detail
    print('Notification tapped: ${message.data}');
    // TODO: Implement navigation
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    // Navigate to alert detail
    print('Local notification tapped: ${response.payload}');
    // TODO: Implement navigation
  }

  /// Check if location is within notification radius
  Future<bool> _isWithinNotificationRadius(
    double latitude,
    double longitude,
  ) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        latitude,
        longitude,
      );

      final radiusInMeters = getNotificationRadius() * 1000;
      return distance <= radiusInMeters;
    } catch (e) {
      return false;
    }
  }

  /// Get channel ID based on alert level
  String _getChannelIdForLevel(int level) {
    if (level >= 4) return 'alert_high_priority';
    if (level >= 2) return 'alert_medium_priority';
    return 'alert_low_priority';
  }

  /// Get channel name based on alert level
  String _getChannelNameForLevel(int level) {
    if (level >= 4) return 'Critical Alerts';
    if (level >= 2) return 'Moderate Alerts';
    return 'Informational Alerts';
  }

  /// Get channel description based on alert level
  String _getChannelDescriptionForLevel(int level) {
    if (level >= 4) return 'High priority danger alerts (Level 4-5)';
    if (level >= 2) return 'Medium priority danger alerts (Level 2-3)';
    return 'Low priority danger alerts (Level 1)';
  }

  /// Get importance based on alert level
  Importance _getImportanceForLevel(int level) {
    if (level >= 4) return Importance.max;
    if (level >= 2) return Importance.high;
    return Importance.defaultImportance;
  }

  // Preferences getters and setters

  /// Get notification radius in km
  double getNotificationRadius() {
    return _prefs.getDouble(_notificationRadiusKey) ?? 5.0;
  }

  /// Set notification radius in km
  Future<void> setNotificationRadius(double radiusKm) async {
    await _prefs.setDouble(_notificationRadiusKey, radiusKm);
  }

  /// Check if notifications are enabled
  bool isNotificationEnabled() {
    return _prefs.getBool(_notificationEnabledKey) ?? true;
  }

  /// Enable/disable notifications
  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs.setBool(_notificationEnabledKey, enabled);
  }

  /// Check if DND mode is enabled
  bool isDndModeEnabled() {
    return _prefs.getBool(_dndModeKey) ?? false;
  }

  /// Enable/disable DND mode
  Future<void> setDndMode(bool enabled) async {
    await _prefs.setBool(_dndModeKey, enabled);
  }

  /// Check if sound is enabled
  bool isSoundEnabled() {
    return _prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Enable/disable sound
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundEnabledKey, enabled);
  }

  /// Check if vibration is enabled
  bool isVibrationEnabled() {
    return _prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  /// Enable/disable vibration
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_vibrationEnabledKey, enabled);
  }

  /// Check if danger type notifications are enabled
  bool isDangerTypeEnabled(String dangerType) {
    final key = 'danger_type_$dangerType';
    return _prefs.getBool(key) ?? true;
  }

  /// Enable/disable danger type notifications
  Future<void> setDangerTypeEnabled(String dangerType, bool enabled) async {
    final key = 'danger_type_$dangerType';
    await _prefs.setBool(key, enabled);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
