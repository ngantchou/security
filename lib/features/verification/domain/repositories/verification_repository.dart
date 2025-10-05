import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';
import '../entities/contribution_entity.dart';
import '../entities/badge_entity.dart';

abstract class VerificationRepository {
  /// Track a user contribution
  Future<Either<Failure, ContributionEntity>> trackContribution({
    required String userId,
    required ContributionType type,
    String? relatedId,
    String? description,
  });

  /// Get user contributions
  Future<Either<Failure, List<ContributionEntity>>> getUserContributions(
    String userId, {
    int? limit,
  });

  /// Award a badge to a user
  Future<Either<Failure, BadgeEntity>> awardBadge({
    required String userId,
    required BadgeType badgeType,
    String? awardedBy,
    String? reason,
  });

  /// Get user badges
  Future<Either<Failure, List<BadgeEntity>>> getUserBadges(String userId);

  /// Check if user has a specific badge
  Future<Either<Failure, bool>> hasBadge(String userId, BadgeType badgeType);

  /// Calculate total contribution points for a user
  Future<Either<Failure, int>> calculateTotalPoints(String userId);

  /// Get verification level based on points
  Future<Either<Failure, VerificationLevel>> getVerificationLevel(
    String userId,
  );

  /// Update user verification level
  Future<Either<Failure, void>> updateVerificationLevel({
    required String userId,
    required VerificationLevel level,
  });

  /// Check and auto-award badges based on criteria
  Future<Either<Failure, List<BadgeEntity>>> checkAndAwardBadges(
    String userId,
  );

  /// Get contribution leaderboard
  Future<Either<Failure, List<Map<String, dynamic>>>> getLeaderboard({
    int limit = 10,
    String? region,
  });

  /// Get badge progress (how close to earning a badge)
  Future<Either<Failure, Map<BadgeType, double>>> getBadgeProgress(
    String userId,
  );
}
