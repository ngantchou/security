import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/contribution_entity.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;

  VerificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ContributionEntity>> trackContribution({
    required String userId,
    required ContributionType type,
    String? relatedId,
    String? description,
  }) async {
    try {
      final result = await remoteDataSource.trackContribution(
        userId: userId,
        type: type,
        relatedId: relatedId,
        description: description,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ContributionEntity>>> getUserContributions(
    String userId, {
    int? limit,
  }) async {
    try {
      final results = await remoteDataSource.getUserContributions(
        userId,
        limit: limit,
      );
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, BadgeEntity>> awardBadge({
    required String userId,
    required BadgeType badgeType,
    String? awardedBy,
    String? reason,
  }) async {
    try {
      final result = await remoteDataSource.awardBadge(
        userId: userId,
        badgeType: badgeType,
        awardedBy: awardedBy,
        reason: reason,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BadgeEntity>>> getUserBadges(
      String userId) async {
    try {
      final results = await remoteDataSource.getUserBadges(userId);
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasBadge(
      String userId, BadgeType badgeType) async {
    try {
      final result = await remoteDataSource.hasBadge(userId, badgeType);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> calculateTotalPoints(String userId) async {
    try {
      final result = await remoteDataSource.calculateTotalPoints(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VerificationLevel>> getVerificationLevel(
      String userId) async {
    try {
      final result = await remoteDataSource.getVerificationLevel(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateVerificationLevel({
    required String userId,
    required VerificationLevel level,
  }) async {
    try {
      await remoteDataSource.updateVerificationLevel(
        userId: userId,
        level: level,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BadgeEntity>>> checkAndAwardBadges(
      String userId) async {
    try {
      final stats = await remoteDataSource.getUserStats(userId);
      final List<BadgeEntity> awardedBadges = [];

      // Check for Early Adopter (first 1000 users)
      // This would require additional logic to track user registration order

      // Check for Alert Master (50+ verified alerts)
      if (stats['alertsCreated'] >= 50) {
        final hasIt =
            await remoteDataSource.hasBadge(userId, BadgeType.alertMaster);
        if (!hasIt) {
          final badge = await remoteDataSource.awardBadge(
            userId: userId,
            badgeType: BadgeType.alertMaster,
            awardedBy: 'system',
            reason: 'Created 50+ verified alerts',
          );
          awardedBadges.add(badge.toEntity());
        }
      }

      // Check for Helping Hand (10+ help offers)
      if (stats['helpOfferedCount'] >= 10) {
        final hasIt =
            await remoteDataSource.hasBadge(userId, BadgeType.helpingHand);
        if (!hasIt) {
          final badge = await remoteDataSource.awardBadge(
            userId: userId,
            badgeType: BadgeType.helpingHand,
            awardedBy: 'system',
            reason: 'Offered help on 10+ alerts',
          );
          awardedBadges.add(badge.toEntity());
        }
      }

      // Check for Resource Provider (5+ resources shared)
      if (stats['resourcesSharedCount'] >= 5) {
        final hasIt = await remoteDataSource.hasBadge(
            userId, BadgeType.resourceProvider);
        if (!hasIt) {
          final badge = await remoteDataSource.awardBadge(
            userId: userId,
            badgeType: BadgeType.resourceProvider,
            awardedBy: 'system',
            reason: 'Shared resources during 5+ emergencies',
          );
          awardedBadges.add(badge.toEntity());
        }
      }

      // Check for Trusted Member (90%+ confirmation accuracy)
      final alertsCreated = stats['alertsCreated'] as int;
      final alertsConfirmed = stats['alertsConfirmed'] as int;
      if (alertsCreated >= 20 &&
          (alertsConfirmed / alertsCreated) >= 0.9) {
        final hasIt =
            await remoteDataSource.hasBadge(userId, BadgeType.trustedMember);
        if (!hasIt) {
          final badge = await remoteDataSource.awardBadge(
            userId: userId,
            badgeType: BadgeType.trustedMember,
            awardedBy: 'system',
            reason: '90%+ accuracy on alert confirmations',
          );
          awardedBadges.add(badge.toEntity());
        }
      }

      return Right(awardedBadges);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getLeaderboard({
    int limit = 10,
    String? region,
  }) async {
    try {
      // This would require a more complex Firestore query
      // For now, returning empty list as placeholder
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<BadgeType, double>>> getBadgeProgress(
      String userId) async {
    try {
      final stats = await remoteDataSource.getUserStats(userId);
      final Map<BadgeType, double> progress = {};

      // Calculate progress for each badge type
      progress[BadgeType.alertMaster] =
          (stats['alertsCreated'] as int).clamp(0, 50) / 50.0;
      progress[BadgeType.helpingHand] =
          (stats['helpOfferedCount'] as int).clamp(0, 10) / 10.0;
      progress[BadgeType.resourceProvider] =
          (stats['resourcesSharedCount'] as int).clamp(0, 5) / 5.0;

      final alertsCreated = stats['alertsCreated'] as int;
      final alertsConfirmed = stats['alertsConfirmed'] as int;
      if (alertsCreated > 0) {
        progress[BadgeType.trustedMember] =
            ((alertsConfirmed / alertsCreated) / 0.9).clamp(0.0, 1.0);
      }

      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
