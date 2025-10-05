import 'package:hive_flutter/hive_flutter.dart';
import 'models/offline_alert_model.dart';

class OfflineStorageService {
  static const String _alertsBoxName = 'offline_alerts';
  static const String _cachedAlertsBoxName = 'cached_alerts';

  Box<OfflineAlertModel>? _alertsBox;
  Box<Map>? _cachedAlertsBox;

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineAlertModelAdapter());
    }

    // Open boxes
    _alertsBox = await Hive.openBox<OfflineAlertModel>(_alertsBoxName);
    _cachedAlertsBox = await Hive.openBox<Map>(_cachedAlertsBoxName);
  }

  /// Save an alert for offline creation (to be synced later)
  Future<void> savePendingAlert(OfflineAlertModel alert) async {
    await _alertsBox!.put(alert.localId, alert);
  }

  /// Get all pending alerts (not synced yet)
  List<OfflineAlertModel> getPendingAlerts() {
    return _alertsBox!.values.where((alert) => !alert.isSynced).toList();
  }

  /// Get all alerts (including synced ones for offline viewing)
  List<OfflineAlertModel> getAllOfflineAlerts() {
    return _alertsBox!.values.toList();
  }

  /// Update an alert's sync status
  Future<void> updateAlertSyncStatus({
    required String localId,
    required bool isSynced,
    String? syncError,
    int? syncAttempts,
  }) async {
    final alert = _alertsBox!.get(localId);
    if (alert != null) {
      final updatedAlert = alert.copyWith(
        isSynced: isSynced,
        syncError: syncError,
        syncAttempts: syncAttempts,
      );
      await _alertsBox!.put(localId, updatedAlert);
    }
  }

  /// Delete a synced alert
  Future<void> deleteSyncedAlert(String localId) async {
    final alert = _alertsBox!.get(localId);
    if (alert != null && alert.isSynced) {
      await _alertsBox!.delete(localId);
    }
  }

  /// Cache alerts for offline viewing
  Future<void> cacheAlerts(List<Map<String, dynamic>> alerts) async {
    await _cachedAlertsBox!.clear();
    for (var i = 0; i < alerts.length; i++) {
      await _cachedAlertsBox!.put(i, alerts[i]);
    }
  }

  /// Get cached alerts
  List<Map<String, dynamic>> getCachedAlerts() {
    return _cachedAlertsBox!.values
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Clear all cached alerts
  Future<void> clearCachedAlerts() async {
    await _cachedAlertsBox!.clear();
  }

  /// Clear all offline data
  Future<void> clearAllData() async {
    await _alertsBox!.clear();
    await _cachedAlertsBox!.clear();
  }

  /// Get count of pending alerts
  int getPendingAlertsCount() {
    return getPendingAlerts().length;
  }

  /// Close all boxes
  Future<void> close() async {
    await _alertsBox?.close();
    await _cachedAlertsBox?.close();
  }
}
