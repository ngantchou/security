import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

class WatchComments {
  final CommentRepository repository;

  WatchComments(this.repository);

  Stream<Either<Failure, List<CommentEntity>>> call(String alertId) {
    return repository.watchComments(alertId);
  }
}
