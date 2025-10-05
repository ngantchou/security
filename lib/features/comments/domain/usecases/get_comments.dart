import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

class GetComments implements UseCase<List<CommentEntity>, String> {
  final CommentRepository repository;

  GetComments(this.repository);

  @override
  Future<Either<Failure, List<CommentEntity>>> call(String alertId) async {
    return await repository.getComments(alertId);
  }
}
