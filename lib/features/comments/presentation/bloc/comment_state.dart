import 'package:equatable/equatable.dart';
import '../../domain/entities/comment_entity.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentsLoaded extends CommentState {
  final List<CommentEntity> comments;

  const CommentsLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentAdding extends CommentState {}

class CommentAdded extends CommentState {
  final CommentEntity comment;

  const CommentAdded(this.comment);

  @override
  List<Object?> get props => [comment];
}

class CommentUpdating extends CommentState {}

class CommentUpdated extends CommentState {
  final CommentEntity comment;

  const CommentUpdated(this.comment);

  @override
  List<Object?> get props => [comment];
}

class CommentDeleting extends CommentState {}

class CommentDeleted extends CommentState {}

class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentActionSuccess extends CommentState {
  final String message;

  const CommentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
