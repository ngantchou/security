import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/utils/enums.dart';
import '../models/alert_model.dart';

abstract class AlertRemoteDataSource {
  Future<AlertModel> createAlert({
    required String creatorId,
    required String creatorName,
    required double latitude,
    required double longitude,
    required String dangerType,
    required int level,
    required String title,
    required String description,
    String? audioCommentUrl,
    List<String>? images,
    required String region,
    required String city,
    required String neighborhood,
    String? address,
  });

  Future<List<AlertModel>> getNearbyAlerts({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  });

  Future<AlertModel> getAlertById(String alertId);

  Future<List<AlertModel>> getAlertsByDangerType(String dangerType);

  Future<List<AlertModel>> getUserAlerts(String userId);

  Future<void> updateAlertStatus({
    required String alertId,
    required String status,
  });

  Future<void> confirmAlert({
    required String alertId,
    required String userId,
    required String userName,
    String? comment,
    String? audioCommentUrl,
  });

  Future<void> incrementViewCount(String alertId);

  Future<void> incrementHelpOffered(String alertId);

  Future<void> offerHelp({
    required String alertId,
    required String userId,
    required String userName,
    required String helpType,
    String? description,
    String? phoneNumber,
  });

  Future<void> markAsResolved({
    required String alertId,
    required String userId,
  });

  Future<void> reportFalseAlarm({
    required String alertId,
    required String userId,
    required String reason,
  });

  Future<void> deleteAlert(String alertId);

  Stream<List<AlertModel>> watchNearbyAlerts({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  });

  Stream<AlertModel> watchAlert(String alertId);
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final FirebaseFirestore firestore;

  AlertRemoteDataSourceImpl({required this.firestore});

  @override
  Future<AlertModel> createAlert({
    required String creatorId,
    required String creatorName,
    required double latitude,
    required double longitude,
    required String dangerType,
    required int level,
    required String title,
    required String description,
    String? audioCommentUrl,
    List<String>? images,
    required String region,
    required String city,
    required String neighborhood,
    String? address,
  }) async {
    try {
      // Generate GeoFirePoint for geolocation queries
      final geoFirePoint = GeoFirePoint(GeoPoint(latitude, longitude));

      // Get user's location for creator location
      final creatorLocation = GeoPoint(latitude, longitude);

      // Generate alert ID
      final docRef = firestore.collection(FirebaseConstants.alertsCollection).doc();
      final alertId = docRef.id;

      // Determine danger group ID (for now, use danger type as group ID)
      final dangerGroupId = dangerType;

      // Determine severity based on level
      AlertSeverity severity;
      if (level <= 1) {
        severity = AlertSeverity.low;
      } else if (level == 2) {
        severity = AlertSeverity.medium;
      } else if (level == 3) {
        severity = AlertSeverity.high;
      } else {
        severity = AlertSeverity.critical;
      }

      // Create alert model
      final now = DateTime.now();
      final alert = AlertModel(
        alertId: alertId,
        creatorId: creatorId,
        creatorName: creatorName,
        creatorLocation: creatorLocation,
        dangerType: DangerType.values.firstWhere(
          (e) => e.toString().split('.').last == dangerType,
        ),
        dangerGroupId: dangerGroupId,
        level: level,
        title: title,
        description: description,
        audioCommentUrl: audioCommentUrl,
        images: images ?? [],
        location: GeoPoint(latitude, longitude),
        geohash: geoFirePoint.geohash,
        region: region,
        city: city,
        neighborhood: neighborhood,
        address: address,
        status: AlertStatus.active,
        severity: severity,
        confirmations: 0,
        confirmedBy: const [],
        authoritiesNotified: false,
        authorityType: const [],
        viewCount: 0,
        helpOffered: 0,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore
      await docRef.set(alert.toJson());

      return alert;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create alert');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<AlertModel>> getNearbyAlerts({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      // Use GeoFlutterFire to query nearby alerts
      final center = GeoFirePoint(GeoPoint(latitude, longitude));

      final collectionRef =
          firestore.collection(FirebaseConstants.alertsCollection);

      // Get all active alerts within radius
      final stream = GeoCollectionReference(collectionRef)
          .subscribeWithin(
            center: center,
            radiusInKm: radiusInKm,
            field: 'location',
            geopointFrom: (data) => (data)['location'] as GeoPoint,
            strictMode: true,
          )
          .first;

      final snapshots = await stream;

      return snapshots
          .map((doc) => AlertModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get nearby alerts');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AlertModel> getAlertById(String alertId) async {
    try {
      final doc = await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .get();

      if (!doc.exists) {
        throw ServerException('Alert not found');
      }

      return AlertModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get alert');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<AlertModel>> getAlertsByDangerType(String dangerType) async {
    try {
      final querySnapshot = await firestore
          .collection(FirebaseConstants.alertsCollection)
          .where('dangerType', isEqualTo: dangerType)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => AlertModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get alerts by danger type');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<AlertModel>> getUserAlerts(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(FirebaseConstants.alertsCollection)
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AlertModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get user alerts');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> updateAlertStatus({
    required String alertId,
    required String status,
  }) async {
    try {
      await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'resolved') 'resolvedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update alert status');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> confirmAlert({
    required String alertId,
    required String userId,
    required String userName,
    String? comment,
    String? audioCommentUrl,
  }) async {
    try {
      final confirmation = AlertConfirmationModel(
        userId: userId,
        userName: userName,
        timestamp: DateTime.now(),
        comment: comment,
        audioCommentUrl: audioCommentUrl,
      );

      await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .update({
        'confirmedBy': FieldValue.arrayUnion([confirmation.toJson()]),
        'confirmations': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to confirm alert');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> incrementViewCount(String alertId) async {
    try {
      await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .update({
        'viewCount': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to increment view count');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> incrementHelpOffered(String alertId) async {
    try {
      await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .update({
        'helpOffered': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to increment help offered');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> offerHelp({
    required String alertId,
    required String userId,
    required String userName,
    required String helpType,
    String? description,
    String? phoneNumber,
  }) async {
    try {
      final helpOffer = HelpOfferModel(
        userId: userId,
        userName: userName,
        timestamp: DateTime.now(),
        helpType: helpType,
        description: description,
        phoneNumber: phoneNumber,
      );

      await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .update({
        'helpOffers': FieldValue.arrayUnion([helpOffer.toJson()]),
        'helpOffered': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to offer help');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> markAsResolved({
    required String alertId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .update({
        'status': AlertStatus.resolved.toString().split('.').last,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to mark as resolved');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> reportFalseAlarm({
    required String alertId,
    required String userId,
    required String reason,
  }) async {
    try {
      await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .update({
        'isFalseAlarm': true,
        'falseAlarmReportedBy': userId,
        'falseAlarmReportedAt': FieldValue.serverTimestamp(),
        'falseAlarmReason': reason,
        'status': AlertStatus.falseAlarm.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to report false alarm');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    try {
      await firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete alert');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Stream<List<AlertModel>> watchNearbyAlerts({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) {
    try {
      final center = GeoFirePoint(GeoPoint(latitude, longitude));

      final collectionRef =
          firestore.collection(FirebaseConstants.alertsCollection);

      return GeoCollectionReference(collectionRef)
          .subscribeWithin(
            center: center,
            radiusInKm: radiusInKm,
            field: 'location',
            geopointFrom: (data) => (data)['location'] as GeoPoint,
            strictMode: true,
          )
          .map((snapshots) => snapshots
              .map((doc) =>
                  AlertModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      return Stream.error(
          ServerException('Failed to watch nearby alerts: $e'));
    }
  }

  @override
  Stream<AlertModel> watchAlert(String alertId) {
    try {
      return firestore
          .collection(FirebaseConstants.alertsCollection)
          .doc(alertId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          throw ServerException('Alert not found');
        }
        return AlertModel.fromJson(doc.data()!);
      });
    } catch (e) {
      return Stream.error(ServerException('Failed to watch alert: $e'));
    }
  }
}
