import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../entities/contribution_entity.dart';
import '../repositories/verification_repository.dart';

class TrackContribution implements UseCase<ContributionEntity, TrackContributionParams> {
  final VerificationRepository repository;

  TrackContribution(this.repository);

  @override
  Future<Either<Failure, ContributionEntity>> call(TrackContributionParams params) async {
    return await repository.trackContribution(
      userId: params.userId,
      type: params.type,
      relatedId: params.relatedId,
      description: params.description,
    );
  }
}

class TrackContributionParams {
  final String userId;
  final ContributionType type;
  final String? relatedId;
  final String? description;

  TrackContributionParams({
    required this.userId,
    required this.type,
    this.relatedId,
    this.description,
  });
}
