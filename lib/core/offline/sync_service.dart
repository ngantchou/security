import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../network/network_info.dart';
import '../utils/enums.dart';
import 'offline_storage_service.dart';
import 'models/offline_alert_model.dart';

class SyncService {
  final OfflineStorageService offlineStorage;
  final NetworkInfo networkInfo;
  final FirebaseFirestore firestore;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService({
    required this.offlineStorage,
    required this.networkInfo,
    required this.firestore,
  });

  /// Start listening to connectivity changes
  void startListening() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen(
      (isConnected) {
        if (isConnected && !_isSyncing) {
          syncPendingAlerts();
        }
      },
    );
  }

  /// Stop listening to connectivity changes
  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Manually trigger sync of all pending alerts
  Future<SyncResult> syncPendingAlerts() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        syncedCount: 0,
        failedCount: 0,
      );
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        syncedCount: 0,
        failedCount: 0,
      );
    }

    _isSyncing = true;

    try {
      final pendingAlerts = offlineStorage.getPendingAlerts();

      if (pendingAlerts.isEmpty) {
        _isSyncing = false;
        return SyncResult(
          success: true,
          message: 'No pending alerts to sync',
          syncedCount: 0,
          failedCount: 0,
        );
      }

      int syncedCount = 0;
      int failedCount = 0;

      for (final alert in pendingAlerts) {
        try {
          await _syncSingleAlert(alert);
          syncedCount++;

          // Mark as synced
          await offlineStorage.updateAlertSyncStatus(
            localId: alert.localId,
            isSynced: true,
            syncError: null,
            syncAttempts: alert.syncAttempts + 1,
          );

          // Optionally delete synced alert after successful sync
          await offlineStorage.deleteSyncedAlert(alert.localId);
        } catch (e) {
          failedCount++;

          // Update sync error
          await offlineStorage.updateAlertSyncStatus(
            localId: alert.localId,
            isSynced: false,
            syncError: e.toString(),
            syncAttempts: alert.syncAttempts + 1,
          );
        }
      }

      _isSyncing = false;

      return SyncResult(
        success: failedCount == 0,
        message: failedCount == 0
            ? 'All alerts synced successfully'
            : 'Synced $syncedCount, failed $failedCount',
        syncedCount: syncedCount,
        failedCount: failedCount,
      );
    } catch (e) {
      _isSyncing = false;
      return SyncResult(
        success: false,
        message: 'Sync error: ${e.toString()}',
        syncedCount: 0,
        failedCount: 0,
      );
    }
  }

  /// Sync a single alert to Firestore
  Future<void> _syncSingleAlert(OfflineAlertModel alert) async {
    final alertRef = firestore.collection('alerts').doc();

    // Create GeoPoint
    final geoPoint = GeoPoint(alert.latitude, alert.longitude);

    // Create geohash using GeoFlutterFire
    final geoFirePoint = GeoFirePoint(geoPoint);

    await alertRef.set({
      'alertId': alertRef.id,
      'title': alert.title,
      'description': alert.description,
      'dangerType': alert.dangerType,
      'level': alert.level,
      'location': geoPoint,
      'geohash': geoFirePoint.geohash,
      'geopoint': geoFirePoint.geopoint,
      'neighborhood': alert.neighborhood,
      'city': alert.city,
      'region': alert.region,
      'imageUrls': alert.imageUrls ?? [],
      'audioCommentUrl': alert.audioCommentUrl,
      'createdBy': alert.userId,
      'createdByName': alert.userName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': AlertStatus.active.toString().split('.').last,
      'viewCount': 0,
      'confirmationCount': 0,
      'helpOfferedCount': 0,
      'isVerified': false,
      'isFalseAlarm': false,
      'isResolved': false,
      // Offline metadata
      'createdOffline': true,
      'offlineCreatedAt': Timestamp.fromDate(alert.createdAt),
    });
  }

  /// Get current sync status
  bool get isSyncing => _isSyncing;

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    required this.failedCount,
  });
}
