import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/flag_comment.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/toggle_like_comment.dart';
import '../../domain/usecases/update_comment.dart';
import '../../domain/usecases/watch_comments.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetComments getComments;
  final WatchComments watchComments;
  final AddComment addComment;
  final UpdateComment updateComment;
  final DeleteComment deleteComment;
  final ToggleLikeComment toggleLikeComment;
  final FlagComment flagComment;

  StreamSubscription? _commentsSubscription;

  CommentBloc({
    required this.getComments,
    required this.watchComments,
    required this.addComment,
    required this.updateComment,
    required this.deleteComment,
    required this.toggleLikeComment,
    required this.flagComment,
  }) : super(CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<WatchCommentsStarted>(_onWatchCommentsStarted);
    on<AddCommentRequested>(_onAddCommentRequested);
    on<UpdateCommentRequested>(_onUpdateCommentRequested);
    on<DeleteCommentRequested>(_onDeleteCommentRequested);
    on<ToggleLikeRequested>(_onToggleLikeRequested);
    on<FlagCommentRequested>(_onFlagCommentRequested);
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    final result = await getComments(event.alertId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentsLoaded(comments)),
    );
  }

  Future<void> _onWatchCommentsStarted(
    WatchCommentsStarted event,
    Emitter<CommentState> emit,
  ) async {
    await _commentsSubscription?.cancel();
    _commentsSubscription = watchComments(event.alertId).listen(
      (result) {
        result.fold(
          (failure) => add(LoadComments(event.alertId)),
          (comments) => emit(CommentsLoaded(comments)),
        );
      },
    );
  }

  Future<void> _onAddCommentRequested(
    AddCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentAdding());
    final result = await addComment(
      AddCommentParams(
        alertId: event.alertId,
        userId: event.userId,
        userName: event.userName,
        userPhoto: event.userPhoto,
        textContent: event.textContent,
        audioUrl: event.audioUrl,
        parentCommentId: event.parentCommentId,
      ),
    );
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comment) {
        emit(CommentAdded(comment));
        // Reload comments to show the new one
        add(LoadComments(event.alertId));
      },
    );
  }

  Future<void> _onUpdateCommentRequested(
    UpdateCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentUpdating());
    final result = await updateComment(
      UpdateCommentParams(
        commentId: event.commentId,
        textContent: event.textContent,
      ),
    );
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comment) {
        emit(CommentUpdated(comment));
        emit(const CommentActionSuccess('Comment updated'));
      },
    );
  }

  Future<void> _onDeleteCommentRequested(
    DeleteCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentDeleting());
    final result = await deleteComment(event.commentId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (_) {
        emit(CommentDeleted());
        emit(const CommentActionSuccess('Comment deleted'));
      },
    );
  }

  Future<void> _onToggleLikeRequested(
    ToggleLikeRequested event,
    Emitter<CommentState> emit,
  ) async {
    final result = await toggleLikeComment(
      ToggleLikeParams(
        commentId: event.commentId,
        userId: event.userId,
      ),
    );
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (_) => null, // UI will update via stream
    );
  }

  Future<void> _onFlagCommentRequested(
    FlagCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    final result = await flagComment(event.commentId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (_) => emit(const CommentActionSuccess('Comment flagged for review')),
    );
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }
}
