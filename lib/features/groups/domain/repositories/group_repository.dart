import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';
import '../entities/danger_group_entity.dart';
import '../entities/group_post_entity.dart';

abstract class GroupRepository {
  /// Create a new danger group
  Future<Either<Failure, DangerGroupEntity>> createGroup({
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

  /// Get group by ID
  Future<Either<Failure, DangerGroupEntity>> getGroupById(String groupId);

  /// Get all groups by danger type
  Future<Either<Failure, List<DangerGroupEntity>>> getGroupsByDangerType(
    DangerType dangerType,
  );

  /// Get groups by location
  Future<Either<Failure, List<DangerGroupEntity>>> getGroupsByLocation({
    required String region,
    String? city,
  });

  /// Search groups
  Future<Either<Failure, List<DangerGroupEntity>>> searchGroups(String query);

  /// Get user's followed groups
  Future<Either<Failure, List<DangerGroupEntity>>> getUserFollowedGroups(
    String userId,
  );

  /// Follow/Join a group
  Future<Either<Failure, void>> followGroup({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
  });

  /// Unfollow/Leave a group
  Future<Either<Failure, void>> unfollowGroup({
    required String groupId,
    required String userId,
  });

  /// Check if user is following a group
  Future<Either<Failure, bool>> isUserFollowing({
    required String groupId,
    required String userId,
  });

  /// Get group members
  Future<Either<Failure, List<GroupMemberEntity>>> getGroupMembers(
    String groupId, {
    int? limit,
  });

  /// Create a post in a group
  Future<Either<Failure, GroupPostEntity>> createPost({
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

  /// Get posts from a group
  Future<Either<Failure, List<GroupPostEntity>>> getGroupPosts({
    required String groupId,
    int? limit,
  });

  /// Get feed from all followed groups
  Future<Either<Failure, List<GroupPostEntity>>> getFeed({
    required String userId,
    DangerType? filterByDangerType,
    String? sortBy, // 'time', 'proximity', 'severity'
    int? limit,
  });

  /// Like a post
  Future<Either<Failure, void>> likePost({
    required String postId,
    required String userId,
  });

  /// Unlike a post
  Future<Either<Failure, void>> unlikePost({
    required String postId,
    required String userId,
  });

  /// Add comment to post
  Future<Either<Failure, PostCommentEntity>> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhoto,
    required String content,
  });

  /// Get post comments
  Future<Either<Failure, List<PostCommentEntity>>> getPostComments({
    required String postId,
    int? limit,
  });

  /// Delete post (author or admin only)
  Future<Either<Failure, void>> deletePost({
    required String postId,
    required String userId,
  });

  /// Stream of group updates
  Stream<Either<Failure, DangerGroupEntity>> watchGroup(String groupId);

  /// Stream of group feed
  Stream<Either<Failure, List<GroupPostEntity>>> watchGroupFeed({
    required String groupId,
    int? limit,
  });
}
