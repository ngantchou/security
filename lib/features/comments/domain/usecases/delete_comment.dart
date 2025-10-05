import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/comment_repository.dart';

class DeleteComment implements UseCase<void, String> {
  final CommentRepository repository;

  DeleteComment(this.repository);

  @override
  Future<Either<Failure, void>> call(String commentId) async {
    return await repository.deleteComment(commentId);
  }
}
