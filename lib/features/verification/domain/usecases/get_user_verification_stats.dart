import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../entities/badge_entity.dart';
import '../entities/contribution_entity.dart';
import '../repositories/verification_repository.dart';

class GetUserVerificationStats implements UseCase<UserVerificationStats, String> {
  final VerificationRepository repository;

  GetUserVerificationStats(this.repository);

  @override
  Future<Either<Failure, UserVerificationStats>> call(String userId) async {
    try {
      final pointsResult = await repository.calculateTotalPoints(userId);
      final levelResult = await repository.getVerificationLevel(userId);
      final badgesResult = await repository.getUserBadges(userId);
      final contributionsResult = await repository.getUserContributions(userId, limit: 10);

      if (pointsResult.isLeft() || levelResult.isLeft() ||
          badgesResult.isLeft() || contributionsResult.isLeft()) {
        return Left(ServerFailure());
      }

      int points = 0;
      VerificationLevel level = VerificationLevel.newcomer;
      List<BadgeEntity> badges = [];
      List<ContributionEntity> contributions = [];

      pointsResult.fold((l) => null, (r) => points = r);
      levelResult.fold((l) => null, (r) => level = r);
      badgesResult.fold((l) => null, (r) => badges = r);
      contributionsResult.fold((l) => null, (r) => contributions = r);

      return Right(UserVerificationStats(
        totalPoints: points,
        verificationLevel: level,
        badges: badges,
        recentContributions: contributions,
      ));
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

class UserVerificationStats {
  final int totalPoints;
  final VerificationLevel verificationLevel;
  final List<BadgeEntity> badges;
  final List<ContributionEntity> recentContributions;

  UserVerificationStats({
    required this.totalPoints,
    required this.verificationLevel,
    required this.badges,
    required this.recentContributions,
  });

  int get pointsToNextLevel {
    switch (verificationLevel) {
      case VerificationLevel.newcomer:
        return 51 - totalPoints;
      case VerificationLevel.bronze:
        return 151 - totalPoints;
      case VerificationLevel.silver:
        return 301 - totalPoints;
      case VerificationLevel.gold:
        return 501 - totalPoints;
      case VerificationLevel.platinum:
        return 0; // Max level
    }
  }

  double get progressToNextLevel {
    switch (verificationLevel) {
      case VerificationLevel.newcomer:
        return (totalPoints / 50).clamp(0.0, 1.0);
      case VerificationLevel.bronze:
        return ((totalPoints - 51) / 100).clamp(0.0, 1.0);
      case VerificationLevel.silver:
        return ((totalPoints - 151) / 150).clamp(0.0, 1.0);
      case VerificationLevel.gold:
        return ((totalPoints - 301) / 200).clamp(0.0, 1.0);
      case VerificationLevel.platinum:
        return 1.0; // Max level
    }
  }
}
