import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/follow_group.dart';
import '../../domain/usecases/get_feed.dart';
import '../../domain/usecases/get_user_groups.dart';
import '../../domain/usecases/search_groups.dart';
import '../../domain/usecases/unfollow_group.dart';
import '../../domain/repositories/group_repository.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GetUserGroups getUserGroups;
  final SearchGroups searchGroups;
  final FollowGroup followGroup;
  final UnfollowGroup unfollowGroup;
  final GetFeed getFeed;
  final CreatePost createPost;
  final GroupRepository groupRepository;

  GroupBloc({
    required this.getUserGroups,
    required this.searchGroups,
    required this.followGroup,
    required this.unfollowGroup,
    required this.getFeed,
    required this.createPost,
    required this.groupRepository,
  }) : super(GroupInitial()) {
    on<LoadUserGroups>(_onLoadUserGroups);
    on<SearchGroupsRequested>(_onSearchGroupsRequested);
    on<FollowGroupRequested>(_onFollowGroupRequested);
    on<UnfollowGroupRequested>(_onUnfollowGroupRequested);
    on<LoadFeed>(_onLoadFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<FilterFeedByDangerType>(_onFilterFeedByDangerType);
    on<SortFeedBy>(_onSortFeedBy);
    on<CreatePostRequested>(_onCreatePostRequested);
    on<LikePostRequested>(_onLikePostRequested);
    on<UnlikePostRequested>(_onUnlikePostRequested);
    on<LoadGroupPosts>(_onLoadGroupPosts);
  }

  Future<void> _onLoadUserGroups(
    LoadUserGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    final result = await getUserGroups(event.userId);

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (groups) => emit(UserGroupsLoaded(groups)),
    );
  }

  Future<void> _onSearchGroupsRequested(
    SearchGroupsRequested event,
    Emitter<GroupState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      return;
    }

    emit(GroupLoading());

    final result = await searchGroups(event.query);

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (groups) => emit(GroupsSearchResults(
        groups: groups,
        query: event.query,
      )),
    );
  }

  Future<void> _onFollowGroupRequested(
    FollowGroupRequested event,
    Emitter<GroupState> emit,
  ) async {
    final result = await followGroup(
      groupId: event.groupId,
      userId: event.userId,
      userName: event.userName,
      userPhoto: event.userPhoto,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) {
        emit(GroupFollowed(event.groupId));
        // Reload user groups
        add(LoadUserGroups(event.userId));
      },
    );
  }

  Future<void> _onUnfollowGroupRequested(
    UnfollowGroupRequested event,
    Emitter<GroupState> emit,
  ) async {
    final result = await unfollowGroup(
      groupId: event.groupId,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) {
        emit(GroupUnfollowed(event.groupId));
        // Reload user groups
        add(LoadUserGroups(event.userId));
      },
    );
  }

  Future<void> _onLoadFeed(
    LoadFeed event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    final result = await getFeed(
      userId: event.userId,
      filterByDangerType: event.filterByDangerType,
      sortBy: event.sortBy,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (posts) {
        if (posts.isEmpty) {
          emit(const FeedEmpty());
        } else {
          emit(FeedLoaded(
            posts: posts,
            isFiltered: event.filterByDangerType != null,
            filterType: event.filterByDangerType?.toString(),
          ));
        }
      },
    );
  }

  Future<void> _onRefreshFeed(
    RefreshFeed event,
    Emitter<GroupState> emit,
  ) async {
    emit(FeedRefreshing());

    final result = await getFeed(
      userId: event.userId,
      filterByDangerType: event.filterByDangerType,
      sortBy: event.sortBy,
      limit: 50,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (posts) {
        if (posts.isEmpty) {
          emit(const FeedEmpty());
        } else {
          emit(FeedLoaded(
            posts: posts,
            isFiltered: event.filterByDangerType != null,
            filterType: event.filterByDangerType?.toString(),
          ));
        }
      },
    );
  }

  Future<void> _onFilterFeedByDangerType(
    FilterFeedByDangerType event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    final result = await getFeed(
      userId: event.userId,
      filterByDangerType: event.dangerType,
      limit: 50,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (posts) {
        if (posts.isEmpty) {
          emit(const FeedEmpty('No posts found for this danger type'));
        } else {
          emit(FeedLoaded(
            posts: posts,
            isFiltered: event.dangerType != null,
            filterType: event.dangerType?.toString(),
          ));
        }
      },
    );
  }

  Future<void> _onSortFeedBy(
    SortFeedBy event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    final result = await getFeed(
      userId: event.userId,
      sortBy: event.sortBy,
      limit: 50,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (posts) {
        if (posts.isEmpty) {
          emit(const FeedEmpty());
        } else {
          emit(FeedLoaded(posts: posts));
        }
      },
    );
  }

  Future<void> _onCreatePostRequested(
    CreatePostRequested event,
    Emitter<GroupState> emit,
  ) async {
    final result = await createPost(
      groupId: event.groupId,
      authorId: event.authorId,
      authorName: event.authorName,
      authorPhoto: event.authorPhoto,
      content: event.content,
      images: event.images,
      videoUrl: event.videoUrl,
      type: event.type,
      relatedAlertId: event.relatedAlertId,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (post) {
        emit(PostCreated(post));
        // Reload feed to show the new post
        add(LoadFeed(userId: event.authorId, limit: 50));
      },
    );
  }

  Future<void> _onLikePostRequested(
    LikePostRequested event,
    Emitter<GroupState> emit,
  ) async {
    final result = await groupRepository.likePost(
      postId: event.postId,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(PostLiked(event.postId)),
    );
  }

  Future<void> _onUnlikePostRequested(
    UnlikePostRequested event,
    Emitter<GroupState> emit,
  ) async {
    final result = await groupRepository.unlikePost(
      postId: event.postId,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(PostUnliked(event.postId)),
    );
  }

  Future<void> _onLoadGroupPosts(
    LoadGroupPosts event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    final result = await groupRepository.getGroupPosts(
      groupId: event.groupId,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (posts) => emit(GroupPostsLoaded(
        posts: posts,
        groupId: event.groupId,
      )),
    );
  }
}
