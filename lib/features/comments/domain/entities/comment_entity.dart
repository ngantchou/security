import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String commentId;
  final String alertId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? textContent;
  final String? audioUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final bool isFlagged;
  final String? parentCommentId; // For replies
  final int likeCount;
  final List<String> likedBy;

  const CommentEntity({
    required this.commentId,
    required this.alertId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.textContent,
    this.audioUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    this.isFlagged = false,
    this.parentCommentId,
    this.likeCount = 0,
    this.likedBy = const [],
  });

  bool get isTextComment => textContent != null && textContent!.isNotEmpty;
  bool get isAudioComment => audioUrl != null && audioUrl!.isNotEmpty;
  bool get isReply => parentCommentId != null;

  @override
  List<Object?> get props => [
        commentId,
        alertId,
        userId,
        userName,
        userPhoto,
        textContent,
        audioUrl,
        createdAt,
        updatedAt,
        isEdited,
        isFlagged,
        parentCommentId,
        likeCount,
        likedBy,
      ];
}
