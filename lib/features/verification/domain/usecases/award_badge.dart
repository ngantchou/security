import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../entities/badge_entity.dart';
import '../repositories/verification_repository.dart';

class AwardBadge implements UseCase<BadgeEntity, AwardBadgeParams> {
  final VerificationRepository repository;

  AwardBadge(this.repository);

  @override
  Future<Either<Failure, BadgeEntity>> call(AwardBadgeParams params) async {
    return await repository.awardBadge(
      userId: params.userId,
      badgeType: params.badgeType,
      awardedBy: params.awardedBy,
      reason: params.reason,
    );
  }
}

class AwardBadgeParams {
  final String userId;
  final BadgeType badgeType;
  final String? awardedBy;
  final String? reason;

  AwardBadgeParams({
    required this.userId,
    required this.badgeType,
    this.awardedBy,
    this.reason,
  });
}
