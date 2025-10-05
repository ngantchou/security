import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment_entity.dart';

abstract class CommentRepository {
  /// Get all comments for an alert
  Future<Either<Failure, List<CommentEntity>>> getComments(String alertId);

  /// Watch comments stream for real-time updates
  Stream<Either<Failure, List<CommentEntity>>> watchComments(String alertId);

  /// Add a new comment
  Future<Either<Failure, CommentEntity>> addComment({
    required String alertId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? textContent,
    String? audioUrl,
    String? parentCommentId,
  });

  /// Update a comment
  Future<Either<Failure, CommentEntity>> updateComment({
    required String commentId,
    String? textContent,
  });

  /// Delete a comment
  Future<Either<Failure, void>> deleteComment(String commentId);

  /// Like/unlike a comment
  Future<Either<Failure, void>> toggleLike({
    required String commentId,
    required String userId,
  });

  /// Flag a comment for moderation
  Future<Either<Failure, void>> flagComment(String commentId);
}
