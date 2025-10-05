import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  const AlertModel({
    required super.alertId,
    required super.creatorId,
    required super.creatorName,
    required super.creatorLocation,
    required super.dangerType,
    required super.dangerGroupId,
    required super.level,
    required super.title,
    required super.description,
    super.audioCommentUrl,
    super.images,
    required super.location,
    required super.geohash,
    required super.region,
    required super.city,
    required super.neighborhood,
    super.address,
    required super.status,
    required super.severity,
    required super.confirmations,
    super.confirmedBy,
    required super.authoritiesNotified,
    super.authoritiesNotifiedAt,
    super.authorityType,
    required super.viewCount,
    required super.helpOffered,
    super.helpOffers,
    super.isFalseAlarm,
    super.falseAlarmReportedBy,
    super.falseAlarmReportedAt,
    super.falseAlarmReason,
    required super.createdAt,
    required super.updatedAt,
    super.resolvedAt,
    super.resolvedBy,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertId: json['alertId'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      creatorLocation: json['creatorLocation'] as GeoPoint,
      dangerType: DangerType.values.firstWhere(
        (e) => e.toString().split('.').last == json['dangerType'],
      ),
      dangerGroupId: json['dangerGroupId'] as String,
      level: json['level'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      audioCommentUrl: json['audioCommentUrl'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as GeoPoint,
      geohash: json['geohash'] as String,
      region: json['region'] as String,
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      address: json['address'] as String?,
      status: AlertStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == json['severity'],
      ),
      confirmations: json['confirmations'] as int,
      confirmedBy: (json['confirmedBy'] as List<dynamic>?)
              ?.map((e) => AlertConfirmationModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
      authoritiesNotified: json['authoritiesNotified'] as bool,
      authoritiesNotifiedAt: json['authoritiesNotifiedAt'] != null
          ? (json['authoritiesNotifiedAt'] as Timestamp).toDate()
          : null,
      authorityType: (json['authorityType'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      viewCount: json['viewCount'] as int,
      helpOffered: json['helpOffered'] as int,
      helpOffers: (json['helpOffers'] as List<dynamic>?)
              ?.map((e) => HelpOfferModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isFalseAlarm: json['isFalseAlarm'] as bool? ?? false,
      falseAlarmReportedBy: json['falseAlarmReportedBy'] as String?,
      falseAlarmReportedAt: json['falseAlarmReportedAt'] != null
          ? (json['falseAlarmReportedAt'] as Timestamp).toDate()
          : null,
      falseAlarmReason: json['falseAlarmReason'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      resolvedAt: json['resolvedAt'] != null
          ? (json['resolvedAt'] as Timestamp).toDate()
          : null,
      resolvedBy: json['resolvedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertId': alertId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorLocation': creatorLocation,
      'dangerType': dangerType.toString().split('.').last,
      'dangerGroupId': dangerGroupId,
      'level': level,
      'title': title,
      'description': description,
      'audioCommentUrl': audioCommentUrl,
      'images': images,
      'location': location,
      'geohash': geohash,
      'region': region,
      'city': city,
      'neighborhood': neighborhood,
      'address': address,
      'status': status.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'confirmations': confirmations,
      'confirmedBy': confirmedBy
          .map((e) => (e as AlertConfirmationModel).toJson())
          .toList(),
      'authoritiesNotified': authoritiesNotified,
      'authoritiesNotifiedAt': authoritiesNotifiedAt != null
          ? Timestamp.fromDate(authoritiesNotifiedAt!)
          : null,
      'authorityType': authorityType,
      'viewCount': viewCount,
      'helpOffered': helpOffered,
      'helpOffers':
          helpOffers.map((e) => (e as HelpOfferModel).toJson()).toList(),
      'isFalseAlarm': isFalseAlarm,
      'falseAlarmReportedBy': falseAlarmReportedBy,
      'falseAlarmReportedAt': falseAlarmReportedAt != null
          ? Timestamp.fromDate(falseAlarmReportedAt!)
          : null,
      'falseAlarmReason': falseAlarmReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolvedBy': resolvedBy,
    };
  }

  factory AlertModel.fromEntity(AlertEntity entity) {
    return AlertModel(
      alertId: entity.alertId,
      creatorId: entity.creatorId,
      creatorName: entity.creatorName,
      creatorLocation: entity.creatorLocation,
      dangerType: entity.dangerType,
      dangerGroupId: entity.dangerGroupId,
      level: entity.level,
      title: entity.title,
      description: entity.description,
      audioCommentUrl: entity.audioCommentUrl,
      images: entity.images,
      location: entity.location,
      geohash: entity.geohash,
      region: entity.region,
      city: entity.city,
      neighborhood: entity.neighborhood,
      address: entity.address,
      status: entity.status,
      severity: entity.severity,
      confirmations: entity.confirmations,
      confirmedBy: entity.confirmedBy,
      authoritiesNotified: entity.authoritiesNotified,
      authoritiesNotifiedAt: entity.authoritiesNotifiedAt,
      authorityType: entity.authorityType,
      viewCount: entity.viewCount,
      helpOffered: entity.helpOffered,
      helpOffers: entity.helpOffers,
      isFalseAlarm: entity.isFalseAlarm,
      falseAlarmReportedBy: entity.falseAlarmReportedBy,
      falseAlarmReportedAt: entity.falseAlarmReportedAt,
      falseAlarmReason: entity.falseAlarmReason,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      resolvedAt: entity.resolvedAt,
      resolvedBy: entity.resolvedBy,
    );
  }
}

class AlertConfirmationModel extends AlertConfirmation {
  const AlertConfirmationModel({
    required super.userId,
    required super.userName,
    required super.timestamp,
    super.comment,
    super.audioCommentUrl,
  });

  factory AlertConfirmationModel.fromJson(Map<String, dynamic> json) {
    return AlertConfirmationModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      comment: json['comment'] as String?,
      audioCommentUrl: json['audioCommentUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'timestamp': Timestamp.fromDate(timestamp),
      'comment': comment,
      'audioCommentUrl': audioCommentUrl,
    };
  }

  factory AlertConfirmationModel.fromEntity(AlertConfirmation entity) {
    return AlertConfirmationModel(
      userId: entity.userId,
      userName: entity.userName,
      timestamp: entity.timestamp,
      comment: entity.comment,
      audioCommentUrl: entity.audioCommentUrl,
    );
  }
}

class HelpOfferModel extends HelpOffer {
  const HelpOfferModel({
    required super.userId,
    required super.userName,
    required super.timestamp,
    required super.helpType,
    super.description,
    super.phoneNumber,
  });

  factory HelpOfferModel.fromJson(Map<String, dynamic> json) {
    return HelpOfferModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      helpType: json['helpType'] as String,
      description: json['description'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'timestamp': Timestamp.fromDate(timestamp),
      'helpType': helpType,
      'description': description,
      'phoneNumber': phoneNumber,
    };
  }

  factory HelpOfferModel.fromEntity(HelpOffer entity) {
    return HelpOfferModel(
      userId: entity.userId,
      userName: entity.userName,
      timestamp: entity.timestamp,
      helpType: entity.helpType,
      description: entity.description,
      phoneNumber: entity.phoneNumber,
    );
  }
}
