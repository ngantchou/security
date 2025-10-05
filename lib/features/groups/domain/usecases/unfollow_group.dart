import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/group_repository.dart';

class UnfollowGroup {
  final GroupRepository repository;

  UnfollowGroup(this.repository);

  Future<Either<Failure, void>> call({
    required String groupId,
    required String userId,
  }) async {
    return await repository.unfollowGroup(
      groupId: groupId,
      userId: userId,
    );
  }
}
