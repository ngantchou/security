import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/group_repository.dart';

class FollowGroup {
  final GroupRepository repository;

  FollowGroup(this.repository);

  Future<Either<Failure, void>> call({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
  }) async {
    return await repository.followGroup(
      groupId: groupId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
    );
  }
}
