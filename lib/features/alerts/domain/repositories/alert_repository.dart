import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/alert_entity.dart';

abstract class AlertRepository {
  /// Create a new alert
  Future<Either<Failure, AlertEntity>> createAlert({
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

  /// Get nearby alerts within a radius (in kilometers)
  Future<Either<Failure, List<AlertEntity>>> getNearbyAlerts({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  });

  /// Get alert by ID
  Future<Either<Failure, AlertEntity>> getAlertById(String alertId);

  /// Get alerts by danger type
  Future<Either<Failure, List<AlertEntity>>> getAlertsByDangerType(
    String dangerType,
  );

  /// Get user's created alerts
  Future<Either<Failure, List<AlertEntity>>> getUserAlerts(String userId);

  /// Update alert status
  Future<Either<Failure, void>> updateAlertStatus({
    required String alertId,
    required String status,
  });

  /// Confirm alert (add confirmation)
  Future<Either<Failure, void>> confirmAlert({
    required String alertId,
    required String userId,
    required String userName,
    String? comment,
    String? audioCommentUrl,
  });

  /// Increment view count
  Future<Either<Failure, void>> incrementViewCount(String alertId);

  /// Increment help offered count
  Future<Either<Failure, void>> incrementHelpOffered(String alertId);

  /// Offer help to alert
  Future<Either<Failure, void>> offerHelp({
    required String alertId,
    required String userId,
    required String userName,
    required String helpType,
    String? description,
    String? phoneNumber,
  });

  /// Mark alert as resolved
  Future<Either<Failure, void>> markAsResolved({
    required String alertId,
    required String userId,
  });

  /// Report alert as false alarm
  Future<Either<Failure, void>> reportFalseAlarm({
    required String alertId,
    required String userId,
    required String reason,
  });

  /// Delete alert (creator only)
  Future<Either<Failure, void>> deleteAlert(String alertId);

  /// Stream of nearby alerts (real-time updates)
  Stream<Either<Failure, List<AlertEntity>>> watchNearbyAlerts({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  });

  /// Stream of alert updates
  Stream<Either<Failure, AlertEntity>> watchAlert(String alertId);
}
