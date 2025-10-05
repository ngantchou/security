import 'package:equatable/equatable.dart';
import '../../domain/entities/danger_group_entity.dart';
import '../../domain/entities/group_post_entity.dart';

abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

// Group States
class UserGroupsLoaded extends GroupState {
  final List<DangerGroupEntity> groups;

  const UserGroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class GroupsSearchResults extends GroupState {
  final List<DangerGroupEntity> groups;
  final String query;

  const GroupsSearchResults({
    required this.groups,
    required this.query,
  });

  @override
  List<Object?> get props => [groups, query];
}

class GroupFollowed extends GroupState {
  final String groupId;
  final String message;

  const GroupFollowed(this.groupId, [this.message = 'Successfully joined group']);

  @override
  List<Object?> get props => [groupId, message];
}

class GroupUnfollowed extends GroupState {
  final String groupId;
  final String message;

  const GroupUnfollowed(this.groupId, [this.message = 'Successfully left group']);

  @override
  List<Object?> get props => [groupId, message];
}

// Feed States
class FeedLoaded extends GroupState {
  final List<GroupPostEntity> posts;
  final bool isFiltered;
  final String? filterType;

  const FeedLoaded({
    required this.posts,
    this.isFiltered = false,
    this.filterType,
  });

  @override
  List<Object?> get props => [posts, isFiltered, filterType];
}

class FeedEmpty extends GroupState {
  final String message;

  const FeedEmpty([this.message = 'No posts in your feed.\nFollow some groups to see updates!']);

  @override
  List<Object?> get props => [message];
}

class FeedRefreshing extends GroupState {}

// Post States
class PostCreated extends GroupState {
  final GroupPostEntity post;
  final String message;

  const PostCreated(this.post, [this.message = 'Post created successfully']);

  @override
  List<Object?> get props => [post, message];
}

class PostLiked extends GroupState {
  final String postId;

  const PostLiked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostUnliked extends GroupState {
  final String postId;

  const PostUnliked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class GroupPostsLoaded extends GroupState {
  final List<GroupPostEntity> posts;
  final String groupId;

  const GroupPostsLoaded({
    required this.posts,
    required this.groupId,
  });

  @override
  List<Object?> get props => [posts, groupId];
}

// Error State
class GroupError extends GroupState {
  final String message;

  const GroupError(this.message);

  @override
  List<Object?> get props => [message];
}
