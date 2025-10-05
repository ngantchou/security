import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';
import '../entities/group_post_entity.dart';
import '../repositories/group_repository.dart';

class GetFeed {
  final GroupRepository repository;

  GetFeed(this.repository);

  Future<Either<Failure, List<GroupPostEntity>>> call({
    required String userId,
    DangerType? filterByDangerType,
    String? sortBy,
    int? limit,
  }) async {
    return await repository.getFeed(
      userId: userId,
      filterByDangerType: filterByDangerType,
      sortBy: sortBy,
      limit: limit,
    );
  }
}
