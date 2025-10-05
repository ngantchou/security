import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

class BadgeEntity extends Equatable {
  final String badgeId;
  final String userId;
  final BadgeType badgeType;
  final DateTime awardedAt;
  final String? awardedBy; // System or admin user ID
  final String? reason;

  const BadgeEntity({
    required this.badgeId,
    required this.userId,
    required this.badgeType,
    required this.awardedAt,
    this.awardedBy,
    this.reason,
  });

  @override
  List<Object?> get props => [
        badgeId,
        userId,
        badgeType,
        awardedAt,
        awardedBy,
        reason,
      ];
}
