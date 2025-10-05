import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_post_entity.dart';

class GroupPostModel extends GroupPostEntity {
  const GroupPostModel({
    required super.postId,
    required super.groupId,
    required super.authorId,
    required super.authorName,
    super.authorPhoto,
    required super.content,
    super.images,
    super.videoUrl,
    super.type,
    super.relatedAlertId,
    super.likes,
    super.comments,
    super.shares,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GroupPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupPostModel(
      postId: doc.id,
      groupId: data['groupId'] as String,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      authorPhoto: data['authorPhoto'] as String?,
      content: data['content'] as String,
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      videoUrl: data['videoUrl'] as String?,
      type: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => PostType.regular,
      ),
      relatedAlertId: data['relatedAlertId'] as String?,
      likes: data['likes'] as int? ?? 0,
      comments: data['comments'] as int? ?? 0,
      shares: data['shares'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhoto': authorPhoto,
      'content': content,
      'images': images,
      'videoUrl': videoUrl,
      'type': type.toString().split('.').last,
      'relatedAlertId': relatedAlertId,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory GroupPostModel.fromEntity(GroupPostEntity entity) {
    return GroupPostModel(
      postId: entity.postId,
      groupId: entity.groupId,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorPhoto: entity.authorPhoto,
      content: entity.content,
      images: entity.images,
      videoUrl: entity.videoUrl,
      type: entity.type,
      relatedAlertId: entity.relatedAlertId,
      likes: entity.likes,
      comments: entity.comments,
      shares: entity.shares,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class PostCommentModel extends PostCommentEntity {
  const PostCommentModel({
    required super.commentId,
    required super.postId,
    required super.authorId,
    required super.authorName,
    super.authorPhoto,
    required super.content,
    required super.createdAt,
  });

  factory PostCommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostCommentModel(
      commentId: doc.id,
      postId: data['postId'] as String,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      authorPhoto: data['authorPhoto'] as String?,
      content: data['content'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhoto': authorPhoto,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PostCommentModel.fromEntity(PostCommentEntity entity) {
    return PostCommentModel(
      commentId: entity.commentId,
      postId: entity.postId,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorPhoto: entity.authorPhoto,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }
}
