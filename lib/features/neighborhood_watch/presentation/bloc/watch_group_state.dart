import 'package:equatable/equatable.dart';
import '../../domain/entities/watch_group_entity.dart';

abstract class WatchGroupState extends Equatable {
  const WatchGroupState();

  @override
  List<Object?> get props => [];
}

class WatchGroupInitial extends WatchGroupState {}

class WatchGroupLoading extends WatchGroupState {}

class WatchGroupsLoaded extends WatchGroupState {
  final List<WatchGroupEntity> groups;

  const WatchGroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class WatchGroupCreated extends WatchGroupState {
  final WatchGroupEntity group;

  const WatchGroupCreated(this.group);

  @override
  List<Object?> get props => [group];
}

class WatchGroupJoined extends WatchGroupState {
  final String message;

  const WatchGroupJoined(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupMembersLoaded extends WatchGroupState {
  final List<WatchMemberEntity> members;

  const GroupMembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class MemberApproved extends WatchGroupState {
  final String message;

  const MemberApproved(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupMeetingsLoaded extends WatchGroupState {
  final List<MeetingEntity> meetings;

  const GroupMeetingsLoaded(this.meetings);

  @override
  List<Object?> get props => [meetings];
}

class MeetingCreated extends WatchGroupState {
  final MeetingEntity meeting;

  const MeetingCreated(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

class MeetingRsvped extends WatchGroupState {
  final String message;

  const MeetingRsvped(this.message);

  @override
  List<Object?> get props => [message];
}

class WatchGroupError extends WatchGroupState {
  final String message;

  const WatchGroupError(this.message);

  @override
  List<Object?> get props => [message];
}
