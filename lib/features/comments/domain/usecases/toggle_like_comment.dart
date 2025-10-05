import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/comment_repository.dart';

class ToggleLikeComment implements UseCase<void, ToggleLikeParams> {
  final CommentRepository repository;

  ToggleLikeComment(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleLikeParams params) async {
    return await repository.toggleLike(
      commentId: params.commentId,
      userId: params.userId,
    );
  }
}

class ToggleLikeParams {
  final String commentId;
  final String userId;

  ToggleLikeParams({
    required this.commentId,
    required this.userId,
  });
}
