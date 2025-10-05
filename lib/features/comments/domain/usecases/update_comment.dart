import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

class UpdateComment implements UseCase<CommentEntity, UpdateCommentParams> {
  final CommentRepository repository;

  UpdateComment(this.repository);

  @override
  Future<Either<Failure, CommentEntity>> call(UpdateCommentParams params) async {
    return await repository.updateComment(
      commentId: params.commentId,
      textContent: params.textContent,
    );
  }
}

class UpdateCommentParams {
  final String commentId;
  final String? textContent;

  UpdateCommentParams({
    required this.commentId,
    this.textContent,
  });
}
