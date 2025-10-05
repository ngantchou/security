import 'package:equatable/equatable.dart';

class GroupPostEntity extends Equatable {
  final String postId;
  final String groupId;
  final String authorId;
  final String authorName;
  final String? authorPhoto;

  // Post content
  final String content;
  final List<String> images;
  final String? videoUrl;
  final PostType type;

  // Related alert (if post is about an alert)
  final String? relatedAlertId;

  // Engagement
  final int likes;
  final int comments;
  final int shares;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupPostEntity({
    required this.postId,
    required this.groupId,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    required this.content,
    this.images = const [],
    this.videoUrl,
    this.type = PostType.regular,
    this.relatedAlertId,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        postId,
        groupId,
        authorId,
        authorName,
        authorPhoto,
        content,
        images,
        videoUrl,
        type,
        relatedAlertId,
        likes,
        comments,
        shares,
        createdAt,
        updatedAt,
      ];
}

enum PostType {
  regular,
  alert,
  announcement,
  resource,
}

class PostCommentEntity extends Equatable {
  final String commentId;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final String content;
  final DateTime createdAt;

  const PostCommentEntity({
    required this.commentId,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        commentId,
        postId,
        authorId,
        authorName,
        authorPhoto,
        content,
        createdAt,
      ];
}
