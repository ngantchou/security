import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/group_post_entity.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

// Group Events
class LoadUserGroups extends GroupEvent {
  final String userId;

  const LoadUserGroups(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SearchGroupsRequested extends GroupEvent {
  final String query;

  const SearchGroupsRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class FollowGroupRequested extends GroupEvent {
  final String groupId;
  final String userId;
  final String userName;
  final String? userPhoto;

  const FollowGroupRequested({
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userPhoto,
  });

  @override
  List<Object?> get props => [groupId, userId, userName, userPhoto];
}

class UnfollowGroupRequested extends GroupEvent {
  final String groupId;
  final String userId;

  const UnfollowGroupRequested({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

// Feed Events
class LoadFeed extends GroupEvent {
  final String userId;
  final DangerType? filterByDangerType;
  final String? sortBy;
  final int? limit;

  const LoadFeed({
    required this.userId,
    this.filterByDangerType,
    this.sortBy,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, filterByDangerType, sortBy, limit];
}

class RefreshFeed extends GroupEvent {
  final String userId;
  final DangerType? filterByDangerType;
  final String? sortBy;

  const RefreshFeed({
    required this.userId,
    this.filterByDangerType,
    this.sortBy,
  });

  @override
  List<Object?> get props => [userId, filterByDangerType, sortBy];
}

class FilterFeedByDangerType extends GroupEvent {
  final String userId;
  final DangerType? dangerType;

  const FilterFeedByDangerType({
    required this.userId,
    this.dangerType,
  });

  @override
  List<Object?> get props => [userId, dangerType];
}

class SortFeedBy extends GroupEvent {
  final String userId;
  final String sortBy; // 'time', 'proximity', 'severity'

  const SortFeedBy({
    required this.userId,
    required this.sortBy,
  });

  @override
  List<Object?> get props => [userId, sortBy];
}

// Post Events
class CreatePostRequested extends GroupEvent {
  final String groupId;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final String content;
  final List<String>? images;
  final String? videoUrl;
  final PostType type;
  final String? relatedAlertId;

  const CreatePostRequested({
    required this.groupId,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    required this.content,
    this.images,
    this.videoUrl,
    this.type = PostType.regular,
    this.relatedAlertId,
  });

  @override
  List<Object?> get props => [
        groupId,
        authorId,
        authorName,
        authorPhoto,
        content,
        images,
        videoUrl,
        type,
        relatedAlertId,
      ];
}

class LikePostRequested extends GroupEvent {
  final String postId;
  final String userId;

  const LikePostRequested({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

class UnlikePostRequested extends GroupEvent {
  final String postId;
  final String userId;

  const UnlikePostRequested({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

class LoadGroupPosts extends GroupEvent {
  final String groupId;
  final int? limit;

  const LoadGroupPosts({
    required this.groupId,
    this.limit,
  });

  @override
  List<Object?> get props => [groupId, limit];
}
