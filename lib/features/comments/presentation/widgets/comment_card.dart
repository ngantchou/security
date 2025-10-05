import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/comment_entity.dart';
import '../../../../core/widgets/audio_player_widget.dart';

class CommentCard extends Widget {
  final CommentEntity comment;
  final String currentUserId;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onFlag;
  final bool isReply;

  const CommentCard({
    super.key,
    required this.comment,
    required this.currentUserId,
    this.onLike,
    this.onReply,
    this.onDelete,
    this.onFlag,
    this.isReply = false,
  });

  @override
  Element createElement() => _CommentCardElement(this);
}

class _CommentCardElement extends ComponentElement {
  _CommentCardElement(CommentCard super.widget);

  @override
  CommentCard get widget => super.widget as CommentCard;

  @override
  Widget build() {
    final comment = widget.comment;
    final isLikedByUser = comment.likedBy.contains(widget.currentUserId);
    final isOwnComment = comment.userId == widget.currentUserId;

    return Padding(
      padding: EdgeInsets.only(
        left: widget.isReply ? 32.0 : 0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Card(
        elevation: widget.isReply ? 1 : 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info header
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: comment.userPhoto != null
                        ? NetworkImage(comment.userPhoto!)
                        : null,
                    child: comment.userPhoto == null
                        ? Text(comment.userName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDateTime(comment.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More options menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete' && widget.onDelete != null) {
                        widget.onDelete!();
                      } else if (value == 'flag' && widget.onFlag != null) {
                        widget.onFlag!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (isOwnComment)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      if (!isOwnComment)
                        const PopupMenuItem(
                          value: 'flag',
                          child: Row(
                            children: [
                              Icon(Icons.flag, size: 20),
                              SizedBox(width: 8),
                              Text('Report'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Comment content
              if (comment.isTextComment)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    comment.textContent!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

              if (comment.isAudioComment)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: AudioPlayerWidget(audioUrl: comment.audioUrl!),
                ),

              if (comment.isEdited)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Edited',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Action buttons
              Row(
                children: [
                  // Like button
                  InkWell(
                    onTap: widget.onLike,
                    child: Row(
                      children: [
                        Icon(
                          isLikedByUser ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isLikedByUser ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${comment.likeCount}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Reply button (hide for replies)
                  if (!widget.isReply)
                    InkWell(
                      onTap: widget.onReply,
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Reply',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
}
