import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserVerificationStats extends VerificationEvent {
  final String userId;

  const LoadUserVerificationStats(this.userId);

  @override
  List<Object?> get props => [userId];
}

class TrackUserContribution extends VerificationEvent {
  final String userId;
  final ContributionType type;
  final String? relatedId;
  final String? description;

  const TrackUserContribution({
    required this.userId,
    required this.type,
    this.relatedId,
    this.description,
  });

  @override
  List<Object?> get props => [userId, type, relatedId, description];
}

class AwardUserBadge extends VerificationEvent {
  final String userId;
  final BadgeType badgeType;
  final String? awardedBy;
  final String? reason;

  const AwardUserBadge({
    required this.userId,
    required this.badgeType,
    this.awardedBy,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, badgeType, awardedBy, reason];
}

class CheckAndAwardBadges extends VerificationEvent {
  final String userId;

  const CheckAndAwardBadges(this.userId);

  @override
  List<Object?> get props => [userId];
}
