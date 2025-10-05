import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class LoadComments extends CommentEvent {
  final String alertId;

  const LoadComments(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class WatchCommentsStarted extends CommentEvent {
  final String alertId;

  const WatchCommentsStarted(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AddCommentRequested extends CommentEvent {
  final String alertId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? textContent;
  final String? audioUrl;
  final String? parentCommentId;

  const AddCommentRequested({
    required this.alertId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.textContent,
    this.audioUrl,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [
        alertId,
        userId,
        userName,
        userPhoto,
        textContent,
        audioUrl,
        parentCommentId,
      ];
}

class UpdateCommentRequested extends CommentEvent {
  final String commentId;
  final String textContent;

  const UpdateCommentRequested({
    required this.commentId,
    required this.textContent,
  });

  @override
  List<Object?> get props => [commentId, textContent];
}

class DeleteCommentRequested extends CommentEvent {
  final String commentId;

  const DeleteCommentRequested(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class ToggleLikeRequested extends CommentEvent {
  final String commentId;
  final String userId;

  const ToggleLikeRequested({
    required this.commentId,
    required this.userId,
  });

  @override
  List<Object?> get props => [commentId, userId];
}

class FlagCommentRequested extends CommentEvent {
  final String commentId;

  const FlagCommentRequested(this.commentId);

  @override
  List<Object?> get props => [commentId];
}
