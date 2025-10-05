import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/watch_group_entity.dart';
import '../../domain/usecases/create_watch_group.dart';
import '../../domain/usecases/watch_group_usecases.dart';
import 'watch_group_event.dart';
import 'watch_group_state.dart';

class WatchGroupBloc extends Bloc<WatchGroupEvent, WatchGroupState> {
  final CreateWatchGroup createWatchGroup;
  final GetNearbyWatchGroups getNearbyWatchGroups;
  final GetUserWatchGroups getUserWatchGroups;
  final JoinWatchGroup joinWatchGroup;
  final GetGroupMembers getGroupMembers;
  final ApproveMember approveMember;
  final CreateMeeting createMeeting;
  final GetGroupMeetings getGroupMeetings;
  final RsvpMeeting rsvpMeeting;

  WatchGroupBloc({
    required this.createWatchGroup,
    required this.getNearbyWatchGroups,
    required this.getUserWatchGroups,
    required this.joinWatchGroup,
    required this.getGroupMembers,
    required this.approveMember,
    required this.createMeeting,
    required this.getGroupMeetings,
    required this.rsvpMeeting,
  }) : super(WatchGroupInitial()) {
    on<CreateWatchGroupRequested>(_onCreateWatchGroupRequested);
    on<LoadNearbyWatchGroups>(_onLoadNearbyWatchGroups);
    on<LoadUserWatchGroups>(_onLoadUserWatchGroups);
    on<JoinWatchGroupRequested>(_onJoinWatchGroupRequested);
    on<LoadGroupMembers>(_onLoadGroupMembers);
    on<ApproveMemberRequested>(_onApproveMemberRequested);
    on<CreateMeetingRequested>(_onCreateMeetingRequested);
    on<LoadGroupMeetings>(_onLoadGroupMeetings);
    on<RsvpMeetingRequested>(_onRsvpMeetingRequested);
  }

  Future<void> _onCreateWatchGroupRequested(
    CreateWatchGroupRequested event,
    Emitter<WatchGroupState> emit,
  ) async {
    emit(WatchGroupLoading());
    final result = await createWatchGroup(
      CreateWatchGroupParams(
        name: event.name,
        description: event.description,
        region: event.region,
        city: event.city,
        neighborhood: event.neighborhood,
        coordinatorId: event.coordinatorId,
        coordinatorName: event.coordinatorName,
        coordinatorPhoto: event.coordinatorPhoto,
        coordinatorPhone: event.coordinatorPhone,
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
        isPrivate: event.isPrivate,
        requireApproval: event.requireApproval,
      ),
    );
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (group) => emit(WatchGroupCreated(group)),
    );
  }

  Future<void> _onLoadNearbyWatchGroups(
    LoadNearbyWatchGroups event,
    Emitter<WatchGroupState> emit,
  ) async {
    emit(WatchGroupLoading());
    final result = await getNearbyWatchGroups(
      NearbyGroupsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
      ),
    );
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (groups) => emit(WatchGroupsLoaded(groups)),
    );
  }

  Future<void> _onLoadUserWatchGroups(
    LoadUserWatchGroups event,
    Emitter<WatchGroupState> emit,
  ) async {
    emit(WatchGroupLoading());
    final result = await getUserWatchGroups(event.userId);
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (groups) => emit(WatchGroupsLoaded(groups)),
    );
  }

  Future<void> _onJoinWatchGroupRequested(
    JoinWatchGroupRequested event,
    Emitter<WatchGroupState> emit,
  ) async {
    emit(WatchGroupLoading());
    final result = await joinWatchGroup(
      JoinGroupParams(
        groupId: event.groupId,
        userId: event.userId,
        userName: event.userName,
        userPhoto: event.userPhoto,
        phoneNumber: event.phoneNumber,
        skills: event.skills,
      ),
    );
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (member) => emit(WatchGroupJoined(
        member.status == MemberStatus.approved
            ? 'Joined group successfully!'
            : 'Request sent! Waiting for coordinator approval.',
      )),
    );
  }

  Future<void> _onLoadGroupMembers(
    LoadGroupMembers event,
    Emitter<WatchGroupState> emit,
  ) async {
    emit(WatchGroupLoading());
    final result = await getGroupMembers(event.groupId);
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (members) => emit(GroupMembersLoaded(members)),
    );
  }

  Future<void> _onApproveMemberRequested(
    ApproveMemberRequested event,
    Emitter<WatchGroupState> emit,
  ) async {
    final result = await approveMember(
      ApproveMemberParams(
        groupId: event.groupId,
        memberId: event.memberId,
      ),
    );
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (_) {
        emit(const MemberApproved('Member approved successfully'));
        add(LoadGroupMembers(event.groupId));
      },
    );
  }

  Future<void> _onCreateMeetingRequested(
    CreateMeetingRequested event,
    Emitter<WatchGroupState> emit,
  ) async {
    emit(WatchGroupLoading());
    final result = await createMeeting(
      CreateMeetingParams(
        groupId: event.groupId,
        title: event.title,
        description: event.description,
        scheduledDate: event.scheduledDate,
        location: event.location,
        locationAddress: event.locationAddress,
        organizerId: event.organizerId,
        organizerName: event.organizerName,
      ),
    );
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (meeting) => emit(MeetingCreated(meeting)),
    );
  }

  Future<void> _onLoadGroupMeetings(
    LoadGroupMeetings event,
    Emitter<WatchGroupState> emit,
  ) async {
    emit(WatchGroupLoading());
    final result = await getGroupMeetings(event.groupId);
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (meetings) => emit(GroupMeetingsLoaded(meetings)),
    );
  }

  Future<void> _onRsvpMeetingRequested(
    RsvpMeetingRequested event,
    Emitter<WatchGroupState> emit,
  ) async {
    final result = await rsvpMeeting(
      RsvpMeetingParams(
        meetingId: event.meetingId,
        userId: event.userId,
      ),
    );
    result.fold(
      (failure) => emit(WatchGroupError(failure.message)),
      (_) => emit(const MeetingRsvped('RSVP confirmed!')),
    );
  }
}
