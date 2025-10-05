import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.commentId,
    required super.alertId,
    required super.userId,
    required super.userName,
    super.userPhoto,
    super.textContent,
    super.audioUrl,
    required super.createdAt,
    required super.updatedAt,
    super.isEdited,
    super.isFlagged,
    super.parentCommentId,
    super.likeCount,
    super.likedBy,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'] as String,
      alertId: json['alertId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhoto: json['userPhoto'] as String?,
      textContent: json['textContent'] as String?,
      audioUrl: json['audioUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isEdited: json['isEdited'] as bool? ?? false,
      isFlagged: json['isFlagged'] as bool? ?? false,
      parentCommentId: json['parentCommentId'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      likedBy: (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'alertId': alertId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'textContent': textContent,
      'audioUrl': audioUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEdited': isEdited,
      'isFlagged': isFlagged,
      'parentCommentId': parentCommentId,
      'likeCount': likeCount,
      'likedBy': likedBy,
    };
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      commentId: entity.commentId,
      alertId: entity.alertId,
      userId: entity.userId,
      userName: entity.userName,
      userPhoto: entity.userPhoto,
      textContent: entity.textContent,
      audioUrl: entity.audioUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isEdited: entity.isEdited,
      isFlagged: entity.isFlagged,
      parentCommentId: entity.parentCommentId,
      likeCount: entity.likeCount,
      likedBy: entity.likedBy,
    );
  }
}
