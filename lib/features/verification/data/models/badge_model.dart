import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/badge_entity.dart';

class BadgeModel extends BadgeEntity {
  const BadgeModel({
    required super.badgeId,
    required super.userId,
    required super.badgeType,
    required super.awardedAt,
    super.awardedBy,
    super.reason,
  });

  // Convert from Entity
  factory BadgeModel.fromEntity(BadgeEntity entity) {
    return BadgeModel(
      badgeId: entity.badgeId,
      userId: entity.userId,
      badgeType: entity.badgeType,
      awardedAt: entity.awardedAt,
      awardedBy: entity.awardedBy,
      reason: entity.reason,
    );
  }

  // Convert to Entity
  BadgeEntity toEntity() {
    return BadgeEntity(
      badgeId: badgeId,
      userId: userId,
      badgeType: badgeType,
      awardedAt: awardedAt,
      awardedBy: awardedBy,
      reason: reason,
    );
  }

  // Convert from Firestore
  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BadgeModel(
      badgeId: doc.id,
      userId: data['userId'] as String,
      badgeType: BadgeType.values.firstWhere(
        (e) => e.toString() == 'BadgeType.${data['badgeType']}',
      ),
      awardedAt: (data['awardedAt'] as Timestamp).toDate(),
      awardedBy: data['awardedBy'] as String?,
      reason: data['reason'] as String?,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'badgeType': badgeType.toString().split('.').last,
      'awardedAt': Timestamp.fromDate(awardedAt),
      'awardedBy': awardedBy,
      'reason': reason,
    };
  }

  // Convert from JSON
  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      badgeId: json['badgeId'] as String,
      userId: json['userId'] as String,
      badgeType: BadgeType.values.firstWhere(
        (e) => e.toString() == 'BadgeType.${json['badgeType']}',
      ),
      awardedAt: DateTime.parse(json['awardedAt'] as String),
      awardedBy: json['awardedBy'] as String?,
      reason: json['reason'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'userId': userId,
      'badgeType': badgeType.toString().split('.').last,
      'awardedAt': awardedAt.toIso8601String(),
      'awardedBy': awardedBy,
      'reason': reason,
    };
  }
}
