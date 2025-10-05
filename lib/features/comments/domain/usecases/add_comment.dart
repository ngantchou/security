import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

class AddComment implements UseCase<CommentEntity, AddCommentParams> {
  final CommentRepository repository;

  AddComment(this.repository);

  @override
  Future<Either<Failure, CommentEntity>> call(AddCommentParams params) async {
    return await repository.addComment(
      alertId: params.alertId,
      userId: params.userId,
      userName: params.userName,
      userPhoto: params.userPhoto,
      textContent: params.textContent,
      audioUrl: params.audioUrl,
      parentCommentId: params.parentCommentId,
    );
  }
}

class AddCommentParams {
  final String alertId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? textContent;
  final String? audioUrl;
  final String? parentCommentId;

  AddCommentParams({
    required this.alertId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.textContent,
    this.audioUrl,
    this.parentCommentId,
  });
}
