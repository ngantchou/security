import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/comment_repository.dart';

class FlagComment implements UseCase<void, String> {
  final CommentRepository repository;

  FlagComment(this.repository);

  @override
  Future<Either<Failure, void>> call(String commentId) async {
    return await repository.flagComment(commentId);
  }
}
