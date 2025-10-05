import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import 'comment_card.dart';
import 'comment_input_with_audio.dart';

class CommentsSection extends StatefulWidget {
  final String alertId;

  const CommentsSection({
    super.key,
    required this.alertId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  String? _replyToCommentId;
  String? _replyToUserName;

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(WatchCommentsStarted(widget.alertId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Comments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // Comments list
        BlocBuilder<CommentBloc, CommentState>(
          builder: (context, state) {
            if (state is CommentLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is CommentError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error loading comments: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            if (state is CommentsLoaded) {
              if (state.comments.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('No comments yet. Be the first to comment!'),
                  ),
                );
              }

              // Separate top-level comments and replies
              final topLevelComments = state.comments
                  .where((c) => c.parentCommentId == null)
                  .toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topLevelComments.length,
                itemBuilder: (context, index) {
                  final comment = topLevelComments[index];
                  final replies = state.comments
                      .where((c) => c.parentCommentId == comment.commentId)
                      .toList();

                  return Column(
                    children: [
                      // Top-level comment
                      CommentCard(
                        comment: comment,
                        currentUserId: authState is Authenticated
                            ? authState.user.uid
                            : '',
                        onLike: () => _toggleLike(comment.commentId),
                        onReply: () => _setReply(comment.commentId, comment.userName),
                        onDelete: comment.userId == (authState is Authenticated ? authState.user.uid : '')
                            ? () => _deleteComment(comment.commentId)
                            : null,
                        onFlag: comment.userId != (authState is Authenticated ? authState.user.uid : '')
                            ? () => _flagComment(comment.commentId)
                            : null,
                      ),

                      // Replies
                      ...replies.map(
                        (reply) => CommentCard(
                          comment: reply,
                          currentUserId: authState is Authenticated
                              ? authState.user.uid
                              : '',
                          onLike: () => _toggleLike(reply.commentId),
                          onDelete: reply.userId == (authState is Authenticated ? authState.user.uid : '')
                              ? () => _deleteComment(reply.commentId)
                              : null,
                          onFlag: reply.userId != (authState is Authenticated ? authState.user.uid : '')
                              ? () => _flagComment(reply.commentId)
                              : null,
                          isReply: true,
                        ),
                      ),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 16),

        // Comment input with audio support
        if (authState is Authenticated)
          CommentInputWithAudio(
            onSubmit: (textContent, audioUrl) => _addCommentWithMedia(
              textContent,
              audioUrl,
              authState,
            ),
            userId: authState.user.uid,
            alertId: widget.alertId,
            storageService: di.sl<StorageService>(),
            replyToName: _replyToUserName,
            onCancelReply: () {
              setState(() {
                _replyToCommentId = null;
                _replyToUserName = null;
              });
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Please sign in to comment',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  void _addCommentWithMedia(
    String? textContent,
    String? audioUrl,
    Authenticated authState,
  ) {
    context.read<CommentBloc>().add(
          AddCommentRequested(
            alertId: widget.alertId,
            userId: authState.user.uid,
            userName: authState.user.displayName,
            userPhoto: authState.user.profilePhoto,
            textContent: textContent,
            audioUrl: audioUrl,
            parentCommentId: _replyToCommentId,
          ),
        );

    // Clear reply state
    if (_replyToCommentId != null) {
      setState(() {
        _replyToCommentId = null;
        _replyToUserName = null;
      });
    }
  }

  void _toggleLike(String commentId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<CommentBloc>().add(
            ToggleLikeRequested(
              commentId: commentId,
              userId: authState.user.uid,
            ),
          );
    }
  }

  void _setReply(String commentId, String userName) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUserName = userName;
    });
  }

  void _deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CommentBloc>().add(
                    DeleteCommentRequested(commentId),
                  );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _flagComment(String commentId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Comment'),
        content: const Text(
          'Are you sure you want to report this comment for moderation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CommentBloc>().add(
                    FlagCommentRequested(commentId),
                  );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment reported for review'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
