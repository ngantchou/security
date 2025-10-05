import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(
      String alertId) async {
    try {
      final comments = await remoteDataSource.getComments(alertId);
      return Right(comments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<CommentEntity>>> watchComments(String alertId) {
    try {
      return remoteDataSource.watchComments(alertId).map(
            (comments) => Right<Failure, List<CommentEntity>>(comments),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> addComment({
    required String alertId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? textContent,
    String? audioUrl,
    String? parentCommentId,
  }) async {
    try {
      final comment = await remoteDataSource.addComment(
        alertId: alertId,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        textContent: textContent,
        audioUrl: audioUrl,
        parentCommentId: parentCommentId,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment({
    required String commentId,
    String? textContent,
  }) async {
    try {
      final comment = await remoteDataSource.updateComment(
        commentId: commentId,
        textContent: textContent,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike({
    required String commentId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.toggleLike(
        commentId: commentId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> flagComment(String commentId) async {
    try {
      await remoteDataSource.flagComment(commentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
