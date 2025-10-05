import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/danger_group_entity.dart';
import '../../domain/entities/group_post_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_data_source.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GroupRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final group = await remoteDataSource.createGroup(
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
      );
      return Right(group);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, DangerGroupEntity>> getGroupById(
      String groupId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final group = await remoteDataSource.getGroupById(groupId);
      return Right(group);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DangerGroupEntity>>> getGroupsByDangerType(
      DangerType dangerType) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final groups = await remoteDataSource.getGroupsByDangerType(dangerType);
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DangerGroupEntity>>> getGroupsByLocation({
    required String region,
    String? city,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final groups = await remoteDataSource.getGroupsByLocation(
        region: region,
        city: city,
      );
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DangerGroupEntity>>> searchGroups(
      String query) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final groups = await remoteDataSource.searchGroups(query);
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DangerGroupEntity>>> getUserFollowedGroups(
      String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final groups = await remoteDataSource.getUserFollowedGroups(userId);
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> followGroup({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.followGroup(
        groupId: groupId,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowGroup({
    required String groupId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.unfollowGroup(
        groupId: groupId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserFollowing({
    required String groupId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final isFollowing = await remoteDataSource.isUserFollowing(
        groupId: groupId,
        userId: userId,
      );
      return Right(isFollowing);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GroupMemberEntity>>> getGroupMembers(
    String groupId, {
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final members = await remoteDataSource.getGroupMembers(
        groupId,
        limit: limit,
      );
      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final post = await remoteDataSource.createPost(
        groupId: groupId,
        authorId: authorId,
        authorName: authorName,
        authorPhoto: authorPhoto,
        content: content,
        images: images,
        videoUrl: videoUrl,
        type: type,
        relatedAlertId: relatedAlertId,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GroupPostEntity>>> getGroupPosts({
    required String groupId,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final posts = await remoteDataSource.getGroupPosts(
        groupId: groupId,
        limit: limit,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GroupPostEntity>>> getFeed({
    required String userId,
    DangerType? filterByDangerType,
    String? sortBy,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final posts = await remoteDataSource.getFeed(
        userId: userId,
        filterByDangerType: filterByDangerType,
        sortBy: sortBy,
        limit: limit,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> likePost({
    required String postId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.likePost(postId: postId, userId: userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost({
    required String postId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.unlikePost(postId: postId, userId: userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, PostCommentEntity>> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhoto,
    required String content,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final comment = await remoteDataSource.addComment(
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorPhoto: authorPhoto,
        content: content,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PostCommentEntity>>> getPostComments({
    required String postId,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final comments = await remoteDataSource.getPostComments(
        postId: postId,
        limit: limit,
      );
      return Right(comments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost({
    required String postId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.deletePost(postId: postId, userId: userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Stream<Either<Failure, DangerGroupEntity>> watchGroup(String groupId) {
    try {
      return remoteDataSource
          .watchGroup(groupId)
          .map((group) => Right<Failure, DangerGroupEntity>(group))
          .handleError((error) {
        if (error is ServerException) {
          return Left<Failure, DangerGroupEntity>(
              ServerFailure(error.message));
        }
        return Left<Failure, DangerGroupEntity>(
            ServerFailure('An unexpected error occurred: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to watch group: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<GroupPostEntity>>> watchGroupFeed({
    required String groupId,
    int? limit,
  }) {
    try {
      return remoteDataSource
          .watchGroupFeed(groupId: groupId, limit: limit)
          .map((posts) => Right<Failure, List<GroupPostEntity>>(posts))
          .handleError((error) {
        if (error is ServerException) {
          return Left<Failure, List<GroupPostEntity>>(
              ServerFailure(error.message));
        }
        return Left<Failure, List<GroupPostEntity>>(
            ServerFailure('An unexpected error occurred: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(ServerFailure('Failed to watch group feed: $e')));
    }
  }
}
