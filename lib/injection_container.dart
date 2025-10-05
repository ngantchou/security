import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/offline/offline_storage_service.dart';
import 'core/offline/sync_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in_with_phone.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/alerts/data/datasources/alert_remote_datasource.dart';
import 'features/alerts/data/repositories/alert_repository_impl.dart';
import 'features/alerts/domain/repositories/alert_repository.dart';
import 'features/alerts/domain/usecases/create_alert.dart';
import 'features/alerts/domain/usecases/get_nearby_alerts.dart';
import 'features/alerts/domain/usecases/get_user_alerts.dart';
import 'features/alerts/domain/usecases/confirm_alert.dart';
import 'features/alerts/domain/usecases/offer_help.dart';
import 'features/alerts/domain/usecases/mark_as_resolved.dart';
import 'features/alerts/domain/usecases/report_false_alarm.dart';
import 'features/alerts/presentation/bloc/alert_bloc.dart';
import 'features/verification/data/datasources/verification_remote_data_source.dart';
import 'features/verification/data/repositories/verification_repository_impl.dart';
import 'features/verification/domain/repositories/verification_repository.dart';
import 'features/verification/domain/usecases/award_badge.dart';
import 'features/verification/domain/usecases/get_user_verification_stats.dart';
import 'features/verification/domain/usecases/track_contribution.dart';
import 'features/verification/presentation/bloc/verification_bloc.dart';
import 'features/groups/data/datasources/group_remote_data_source.dart';
import 'features/groups/data/repositories/group_repository_impl.dart';
import 'features/groups/domain/repositories/group_repository.dart';
import 'features/groups/domain/usecases/create_post.dart';
import 'features/groups/domain/usecases/follow_group.dart';
import 'features/groups/domain/usecases/get_feed.dart';
import 'features/groups/domain/usecases/get_user_groups.dart';
import 'features/groups/domain/usecases/search_groups.dart';
import 'features/groups/domain/usecases/unfollow_group.dart';
import 'features/groups/presentation/bloc/group_bloc.dart';
import 'features/comments/data/datasources/comment_remote_data_source.dart';
import 'features/comments/data/repositories/comment_repository_impl.dart';
import 'features/comments/domain/repositories/comment_repository.dart';
import 'features/comments/domain/usecases/add_comment.dart';
import 'features/comments/domain/usecases/delete_comment.dart';
import 'features/comments/domain/usecases/flag_comment.dart';
import 'features/comments/domain/usecases/get_comments.dart';
import 'features/comments/domain/usecases/toggle_like_comment.dart';
import 'features/comments/domain/usecases/update_comment.dart';
import 'features/comments/domain/usecases/watch_comments.dart';
import 'features/comments/presentation/bloc/comment_bloc.dart';
import 'features/neighborhood_watch/data/datasources/watch_group_remote_data_source.dart';
import 'features/neighborhood_watch/data/repositories/watch_group_repository_impl.dart';
import 'features/neighborhood_watch/domain/repositories/watch_group_repository.dart';
import 'features/neighborhood_watch/domain/usecases/create_watch_group.dart';
import 'features/neighborhood_watch/domain/usecases/watch_group_usecases.dart';
import 'features/neighborhood_watch/presentation/bloc/watch_group_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Authentication
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInWithPhone: sl(),
      verifyOTP: sl(),
      getCurrentUser: sl(),
      signOut: sl(),
      authRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithPhone(sl()));
  sl.registerLazySingleton(() => VerifyOTP(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  //! Features - Alerts
  // Bloc
  sl.registerFactory(
    () => AlertBloc(
      createAlert: sl(),
      getNearbyAlerts: sl(),
      getUserAlerts: sl(),
      confirmAlert: sl(),
      offerHelp: sl(),
      markAsResolved: sl(),
      reportFalseAlarm: sl(),
      alertRepository: sl(),
      trackContribution: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateAlert(sl()));
  sl.registerLazySingleton(() => GetNearbyAlerts(sl()));
  sl.registerLazySingleton(() => GetUserAlerts(sl()));
  sl.registerLazySingleton(() => ConfirmAlert(sl()));
  sl.registerLazySingleton(() => OfferHelp(sl()));
  sl.registerLazySingleton(() => MarkAsResolved(sl()));
  sl.registerLazySingleton(() => ReportFalseAlarm(sl()));

  // Repository
  sl.registerLazySingleton<AlertRepository>(
    () => AlertRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AlertRemoteDataSource>(
    () => AlertRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! Features - Verification
  // Bloc
  sl.registerFactory(
    () => VerificationBloc(
      getUserVerificationStats: sl(),
      trackContribution: sl(),
      awardBadge: sl(),
      repository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => TrackContribution(sl()));
  sl.registerLazySingleton(() => AwardBadge(sl()));
  sl.registerLazySingleton(() => GetUserVerificationStats(sl()));

  // Repository
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! Features - Groups
  // Bloc
  sl.registerFactory(
    () => GroupBloc(
      getUserGroups: sl(),
      searchGroups: sl(),
      followGroup: sl(),
      unfollowGroup: sl(),
      getFeed: sl(),
      createPost: sl(),
      groupRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserGroups(sl()));
  sl.registerLazySingleton(() => SearchGroups(sl()));
  sl.registerLazySingleton(() => FollowGroup(sl()));
  sl.registerLazySingleton(() => UnfollowGroup(sl()));
  sl.registerLazySingleton(() => GetFeed(sl()));
  sl.registerLazySingleton(() => CreatePost(sl()));

  // Repository
  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<GroupRemoteDataSource>(
    () => GroupRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! Features - Comments
  // Bloc
  sl.registerFactory(
    () => CommentBloc(
      getComments: sl(),
      watchComments: sl(),
      addComment: sl(),
      updateComment: sl(),
      deleteComment: sl(),
      toggleLikeComment: sl(),
      flagComment: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetComments(sl()));
  sl.registerLazySingleton(() => WatchComments(sl()));
  sl.registerLazySingleton(() => AddComment(sl()));
  sl.registerLazySingleton(() => UpdateComment(sl()));
  sl.registerLazySingleton(() => DeleteComment(sl()));
  sl.registerLazySingleton(() => ToggleLikeComment(sl()));
  sl.registerLazySingleton(() => FlagComment(sl()));

  // Repository
  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CommentRemoteDataSource>(
    () => CommentRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! Features - Neighborhood Watch
  // Bloc
  sl.registerFactory(
    () => WatchGroupBloc(
      createWatchGroup: sl(),
      getNearbyWatchGroups: sl(),
      getUserWatchGroups: sl(),
      joinWatchGroup: sl(),
      getGroupMembers: sl(),
      approveMember: sl(),
      createMeeting: sl(),
      getGroupMeetings: sl(),
      rsvpMeeting: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateWatchGroup(sl()));
  sl.registerLazySingleton(() => GetNearbyWatchGroups(sl()));
  sl.registerLazySingleton(() => GetUserWatchGroups(sl()));
  sl.registerLazySingleton(() => JoinWatchGroup(sl()));
  sl.registerLazySingleton(() => GetGroupMembers(sl()));
  sl.registerLazySingleton(() => ApproveMember(sl()));
  sl.registerLazySingleton(() => CreateMeeting(sl()));
  sl.registerLazySingleton(() => GetGroupMeetings(sl()));
  sl.registerLazySingleton(() => RsvpMeeting(sl()));

  // Repository
  sl.registerLazySingleton<WatchGroupRepository>(
    () => WatchGroupRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<WatchGroupRemoteDataSource>(
    () => WatchGroupRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  sl.registerLazySingleton<StorageService>(
    () => StorageService(storage: sl()),
  );

  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(prefs: sl()),
  );

  sl.registerLazySingleton<OfflineStorageService>(
    () => OfflineStorageService(),
  );

  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      offlineStorage: sl(),
      networkInfo: sl(),
      firestore: sl(),
    ),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => Connectivity());
}
