import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

class AlertEntity extends Equatable {
  final String alertId;
  final String creatorId;
  final String creatorName;
  final GeoPoint creatorLocation;

  // Alert Details
  final DangerType dangerType;
  final String dangerGroupId;
  final int level;
  final String title;
  final String description;
  final String? audioCommentUrl;
  final List<String> images;

  // Location
  final GeoPoint location;
  final String geohash;
  final String region;
  final String city;
  final String neighborhood;
  final String? address;

  // Status
  final AlertStatus status;
  final AlertSeverity severity;

  // Confirmation
  final int confirmations;
  final List<AlertConfirmation> confirmedBy;

  // Authority Alert
  final bool authoritiesNotified;
  final DateTime? authoritiesNotifiedAt;
  final List<String> authorityType;

  // Engagement
  final int viewCount;
  final int helpOffered;
  final List<HelpOffer> helpOffers;

  // Resolution
  final bool isFalseAlarm;
  final String? falseAlarmReportedBy;
  final DateTime? falseAlarmReportedAt;
  final String? falseAlarmReason;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  const AlertEntity({
    required this.alertId,
    required this.creatorId,
    required this.creatorName,
    required this.creatorLocation,
    required this.dangerType,
    required this.dangerGroupId,
    required this.level,
    required this.title,
    required this.description,
    this.audioCommentUrl,
    this.images = const [],
    required this.location,
    required this.geohash,
    required this.region,
    required this.city,
    required this.neighborhood,
    this.address,
    required this.status,
    required this.severity,
    required this.confirmations,
    this.confirmedBy = const [],
    required this.authoritiesNotified,
    this.authoritiesNotifiedAt,
    this.authorityType = const [],
    required this.viewCount,
    required this.helpOffered,
    this.helpOffers = const [],
    this.isFalseAlarm = false,
    this.falseAlarmReportedBy,
    this.falseAlarmReportedAt,
    this.falseAlarmReason,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  @override
  List<Object?> get props => [
        alertId,
        creatorId,
        creatorName,
        creatorLocation,
        dangerType,
        dangerGroupId,
        level,
        title,
        description,
        audioCommentUrl,
        images,
        location,
        geohash,
        region,
        city,
        neighborhood,
        address,
        status,
        severity,
        confirmations,
        confirmedBy,
        authoritiesNotified,
        authoritiesNotifiedAt,
        authorityType,
        viewCount,
        helpOffered,
        helpOffers,
        isFalseAlarm,
        falseAlarmReportedBy,
        falseAlarmReportedAt,
        falseAlarmReason,
        createdAt,
        updatedAt,
        resolvedAt,
        resolvedBy,
      ];
}

class AlertConfirmation extends Equatable {
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String? comment;
  final String? audioCommentUrl;

  const AlertConfirmation({
    required this.userId,
    required this.userName,
    required this.timestamp,
    this.comment,
    this.audioCommentUrl,
  });

  @override
  List<Object?> get props =>
      [userId, userName, timestamp, comment, audioCommentUrl];
}

class HelpOffer extends Equatable {
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String helpType; // e.g., "transportation", "medical", "shelter", "other"
  final String? description;
  final String? phoneNumber;

  const HelpOffer({
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.helpType,
    this.description,
    this.phoneNumber,
  });

  @override
  List<Object?> get props =>
      [userId, userName, timestamp, helpType, description, phoneNumber];
}
