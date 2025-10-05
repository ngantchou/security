import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/group_post_entity.dart';
import '../models/danger_group_model.dart';
import '../models/group_post_model.dart';

abstract class GroupRemoteDataSource {
  Future<DangerGroupModel> createGroup({
    required String name,
    required String description,
    required DangerType dangerType,
    required String region,
    required String city,
    String? neighborhood,
    String? coverImageUrl,
    required String creatorId,
    required String creatorName,
    GroupPrivacy privacy = GroupPrivacy.public,
  });

  Future<DangerGroupModel> getGroupById(String groupId);
  Future<List<DangerGroupModel>> getGroupsByDangerType(DangerType dangerType);
  Future<List<DangerGroupModel>> getGroupsByLocation({
    required String region,
    String? city,
  });
  Future<List<DangerGroupModel>> searchGroups(String query);
  Future<List<DangerGroupModel>> getUserFollowedGroups(String userId);

  Future<void> followGroup({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
  });
  Future<void> unfollowGroup({
    required String groupId,
    required String userId,
  });
  Future<bool> isUserFollowing({
    required String groupId,
    required String userId,
  });
  Future<List<GroupMemberModel>> getGroupMembers(String groupId, {int? limit});

  Future<GroupPostModel> createPost({
    required String groupId,
    required String authorId,
    required String authorName,
    String? authorPhoto,
    required String content,
    List<String>? images,
    String? videoUrl,
    PostType type = PostType.regular,
    String? relatedAlertId,
  });

  Future<List<GroupPostModel>> getGroupPosts({
    required String groupId,
    int? limit,
  });
  Future<List<GroupPostModel>> getFeed({
    required String userId,
    DangerType? filterByDangerType,
    String? sortBy,
    int? limit,
  });

  Future<void> likePost({required String postId, required String userId});
  Future<void> unlikePost({required String postId, required String userId});

  Future<PostCommentModel> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhoto,
    required String content,
  });
  Future<List<PostCommentModel>> getPostComments({
    required String postId,
    int? limit,
  });

  Future<void> deletePost({required String postId, required String userId});

  Stream<DangerGroupModel> watchGroup(String groupId);
  Stream<List<GroupPostModel>> watchGroupFeed({
    required String groupId,
    int? limit,
  });
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final FirebaseFirestore firestore;

  GroupRemoteDataSourceImpl({required this.firestore});

  @override
  Future<DangerGroupModel> createGroup({
    required String name,
    required String description,
    required DangerType dangerType,
    required String region,
    required String city,
    String? neighborhood,
    String? coverImageUrl,
    required String creatorId,
    required String creatorName,
    GroupPrivacy privacy = GroupPrivacy.public,
  }) async {
    try {
      final docRef = firestore.collection('groups').doc();
      final now = DateTime.now();

      final group = DangerGroupModel(
        groupId: docRef.id,
        name: name,
        description: description,
        dangerType: dangerType,
        region: region,
        city: city,
        neighborhood: neighborhood,
        coverImageUrl: coverImageUrl,
        creatorId: creatorId,
        creatorName: creatorName,
        privacy: privacy,
        allowPosts: true,
        allowAlerts: true,
        memberCount: 1,
        alertCount: 0,
        postCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(group.toFirestore());

      // Auto-follow creator
      await followGroup(
        groupId: docRef.id,
        userId: creatorId,
        userName: creatorName,
      );

      return group;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create group');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<DangerGroupModel> getGroupById(String groupId) async {
    try {
      final doc = await firestore.collection('groups').doc(groupId).get();
      if (!doc.exists) {
        throw ServerException('Group not found');
      }
      return DangerGroupModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get group');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<DangerGroupModel>> getGroupsByDangerType(
      DangerType dangerType) async {
    try {
      final snapshot = await firestore
          .collection('groups')
          .where('dangerType', isEqualTo: dangerType.toString().split('.').last)
          .orderBy('memberCount', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => DangerGroupModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get groups');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<DangerGroupModel>> getGroupsByLocation({
    required String region,
    String? city,
  }) async {
    try {
      Query query = firestore.collection('groups').where('region', isEqualTo: region);

      if (city != null) {
        query = query.where('city', isEqualTo: city);
      }

      final snapshot = await query
          .orderBy('memberCount', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => DangerGroupModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get groups');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<DangerGroupModel>> searchGroups(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation searching by name prefix
      final snapshot = await firestore
          .collection('groups')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => DangerGroupModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to search groups');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<DangerGroupModel>> getUserFollowedGroups(String userId) async {
    try {
      // Get user's followed group IDs
      final membershipSnapshot = await firestore
          .collection('group_members')
          .where('userId', isEqualTo: userId)
          .get();

      if (membershipSnapshot.docs.isEmpty) {
        return [];
      }

      final groupIds = membershipSnapshot.docs
          .map((doc) => doc.data()['groupId'] as String)
          .toList();

      // Fetch groups (Firestore has a limit of 10 for 'in' queries)
      final groups = <DangerGroupModel>[];
      for (int i = 0; i < groupIds.length; i += 10) {
        final batch = groupIds.skip(i).take(10).toList();
        final snapshot = await firestore
            .collection('groups')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        groups.addAll(
          snapshot.docs.map((doc) => DangerGroupModel.fromFirestore(doc)),
        );
      }

      return groups;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get followed groups');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> followGroup({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
  }) async {
    try {
      final memberDoc = firestore.collection('group_members').doc('${groupId}_$userId');

      final member = GroupMemberModel(
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        role: GroupRole.member,
        joinedAt: DateTime.now(),
      );

      await memberDoc.set(member.toFirestore()..['groupId'] = groupId);

      // Increment member count
      await firestore.collection('groups').doc(groupId).update({
        'memberCount': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to follow group');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> unfollowGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await firestore.collection('group_members').doc('${groupId}_$userId').delete();

      // Decrement member count
      await firestore.collection('groups').doc(groupId).update({
        'memberCount': FieldValue.increment(-1),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to unfollow group');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<bool> isUserFollowing({
    required String groupId,
    required String userId,
  }) async {
    try {
      final doc = await firestore
          .collection('group_members')
          .doc('${groupId}_$userId')
          .get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to check follow status');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<GroupMemberModel>> getGroupMembers(String groupId,
      {int? limit}) async {
    try {
      Query query = firestore
          .collection('group_members')
          .where('groupId', isEqualTo: groupId)
          .orderBy('joinedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => GroupMemberModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get group members');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<GroupPostModel> createPost({
    required String groupId,
    required String authorId,
    required String authorName,
    String? authorPhoto,
    required String content,
    List<String>? images,
    String? videoUrl,
    PostType type = PostType.regular,
    String? relatedAlertId,
  }) async {
    try {
      final docRef = firestore.collection('group_posts').doc();
      final now = DateTime.now();

      final post = GroupPostModel(
        postId: docRef.id,
        groupId: groupId,
        authorId: authorId,
        authorName: authorName,
        authorPhoto: authorPhoto,
        content: content,
        images: images ?? [],
        videoUrl: videoUrl,
        type: type,
        relatedAlertId: relatedAlertId,
        likes: 0,
        comments: 0,
        shares: 0,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(post.toFirestore());

      // Increment group post count
      await firestore.collection('groups').doc(groupId).update({
        'postCount': FieldValue.increment(1),
      });

      return post;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create post');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<GroupPostModel>> getGroupPosts({
    required String groupId,
    int? limit,
  }) async {
    try {
      Query query = firestore
          .collection('group_posts')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => GroupPostModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get group posts');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<GroupPostModel>> getFeed({
    required String userId,
    DangerType? filterByDangerType,
    String? sortBy,
    int? limit,
  }) async {
    try {
      // Get user's followed groups
      final followedGroups = await getUserFollowedGroups(userId);

      if (followedGroups.isEmpty) {
        return [];
      }

      final groupIds = followedGroups.map((g) => g.groupId).toList();

      // Filter by danger type if specified
      final filteredGroupIds = filterByDangerType != null
          ? followedGroups
              .where((g) => g.dangerType == filterByDangerType)
              .map((g) => g.groupId)
              .toList()
          : groupIds;

      if (filteredGroupIds.isEmpty) {
        return [];
      }

      // Fetch posts from groups (batch by 10)
      final posts = <GroupPostModel>[];
      for (int i = 0; i < filteredGroupIds.length; i += 10) {
        final batch = filteredGroupIds.skip(i).take(10).toList();

        Query query = firestore
            .collection('group_posts')
            .where('groupId', whereIn: batch);

        // Sort by time (default) or other criteria
        if (sortBy == 'time' || sortBy == null) {
          query = query.orderBy('createdAt', descending: true);
        }

        if (limit != null) {
          query = query.limit(limit);
        }

        final snapshot = await query.get();
        posts.addAll(
          snapshot.docs.map((doc) => GroupPostModel.fromFirestore(doc)),
        );
      }

      // Sort all posts by created time
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return limit != null ? posts.take(limit).toList() : posts;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get feed');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    try {
      await firestore.collection('post_likes').doc('${postId}_$userId').set({
        'postId': postId,
        'userId': userId,
        'likedAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('group_posts').doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to like post');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> unlikePost({
    required String postId,
    required String userId,
  }) async {
    try {
      await firestore.collection('post_likes').doc('${postId}_$userId').delete();

      await firestore.collection('group_posts').doc(postId).update({
        'likes': FieldValue.increment(-1),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to unlike post');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<PostCommentModel> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhoto,
    required String content,
  }) async {
    try {
      final docRef = firestore.collection('post_comments').doc();

      final comment = PostCommentModel(
        commentId: docRef.id,
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorPhoto: authorPhoto,
        content: content,
        createdAt: DateTime.now(),
      );

      await docRef.set(comment.toFirestore());

      // Increment comment count
      await firestore.collection('group_posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });

      return comment;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to add comment');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<PostCommentModel>> getPostComments({
    required String postId,
    int? limit,
  }) async {
    try {
      Query query = firestore
          .collection('post_comments')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostCommentModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get comments');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      // Verify user is author
      final postDoc = await firestore.collection('group_posts').doc(postId).get();
      final post = GroupPostModel.fromFirestore(postDoc);

      if (post.authorId != userId) {
        throw ServerException('Not authorized to delete this post');
      }

      await firestore.collection('group_posts').doc(postId).delete();

      // Decrement post count
      await firestore.collection('groups').doc(post.groupId).update({
        'postCount': FieldValue.increment(-1),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete post');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Stream<DangerGroupModel> watchGroup(String groupId) {
    try {
      return firestore
          .collection('groups')
          .doc(groupId)
          .snapshots()
          .map((doc) => DangerGroupModel.fromFirestore(doc));
    } catch (e) {
      throw ServerException('Failed to watch group: $e');
    }
  }

  @override
  Stream<List<GroupPostModel>> watchGroupFeed({
    required String groupId,
    int? limit,
  }) {
    try {
      Query query = firestore
          .collection('group_posts')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => GroupPostModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw ServerException('Failed to watch group feed: $e');
    }
  }
}
