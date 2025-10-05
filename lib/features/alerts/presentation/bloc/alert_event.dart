import 'package:equatable/equatable.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

class CreateAlertRequested extends AlertEvent {
  final String creatorId;
  final String creatorName;
  final double latitude;
  final double longitude;
  final String dangerType;
  final int level;
  final String title;
  final String description;
  final String? audioCommentUrl;
  final List<String>? images;
  final String region;
  final String city;
  final String neighborhood;
  final String? address;

  const CreateAlertRequested({
    required this.creatorId,
    required this.creatorName,
    required this.latitude,
    required this.longitude,
    required this.dangerType,
    required this.level,
    required this.title,
    required this.description,
    this.audioCommentUrl,
    this.images,
    required this.region,
    required this.city,
    required this.neighborhood,
    this.address,
  });

  @override
  List<Object?> get props => [
        creatorId,
        creatorName,
        latitude,
        longitude,
        dangerType,
        level,
        title,
        description,
        audioCommentUrl,
        images,
        region,
        city,
        neighborhood,
        address,
      ];
}

class LoadNearbyAlerts extends AlertEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const LoadNearbyAlerts({
    required this.latitude,
    required this.longitude,
    this.radiusInKm = 5.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm];
}

class LoadUserAlerts extends AlertEvent {
  final String userId;

  const LoadUserAlerts(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ConfirmAlertRequested extends AlertEvent {
  final String alertId;
  final String userId;
  final String userName;
  final String? comment;
  final String? audioCommentUrl;

  const ConfirmAlertRequested({
    required this.alertId,
    required this.userId,
    required this.userName,
    this.comment,
    this.audioCommentUrl,
  });

  @override
  List<Object?> get props =>
      [alertId, userId, userName, comment, audioCommentUrl];
}

class WatchNearbyAlertsStarted extends AlertEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const WatchNearbyAlertsStarted({
    required this.latitude,
    required this.longitude,
    this.radiusInKm = 5.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm];
}

class WatchNearbyAlertsStopped extends AlertEvent {
  const WatchNearbyAlertsStopped();
}

class RefreshAlerts extends AlertEvent {
  const RefreshAlerts();
}

class OfferHelpRequested extends AlertEvent {
  final String alertId;
  final String userId;
  final String userName;
  final String helpType;
  final String? description;
  final String? phoneNumber;

  const OfferHelpRequested({
    required this.alertId,
    required this.userId,
    required this.userName,
    required this.helpType,
    this.description,
    this.phoneNumber,
  });

  @override
  List<Object?> get props =>
      [alertId, userId, userName, helpType, description, phoneNumber];
}

class MarkAlertAsResolvedRequested extends AlertEvent {
  final String alertId;
  final String userId;

  const MarkAlertAsResolvedRequested({
    required this.alertId,
    required this.userId,
  });

  @override
  List<Object?> get props => [alertId, userId];
}

class ReportFalseAlarmRequested extends AlertEvent {
  final String alertId;
  final String userId;
  final String reason;

  const ReportFalseAlarmRequested({
    required this.alertId,
    required this.userId,
    required this.reason,
  });

  @override
  List<Object?> get props => [alertId, userId, reason];
}
