import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/danger_group_entity.dart';
import '../repositories/group_repository.dart';

class GetUserGroups {
  final GroupRepository repository;

  GetUserGroups(this.repository);

  Future<Either<Failure, List<DangerGroupEntity>>> call(String userId) async {
    return await repository.getUserFollowedGroups(userId);
  }
}
