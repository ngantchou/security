import 'package:equatable/equatable.dart';

abstract class WatchGroupEvent extends Equatable {
  const WatchGroupEvent();

  @override
  List<Object?> get props => [];
}

class CreateWatchGroupRequested extends WatchGroupEvent {
  final String name;
  final String description;
  final String region;
  final String city;
  final String neighborhood;
  final String coordinatorId;
  final String coordinatorName;
  final String? coordinatorPhoto;
  final String? coordinatorPhone;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final bool isPrivate;
  final bool requireApproval;

  const CreateWatchGroupRequested({
    required this.name,
    required this.description,
    required this.region,
    required this.city,
    required this.neighborhood,
    required this.coordinatorId,
    required this.coordinatorName,
    this.coordinatorPhoto,
    this.coordinatorPhone,
    required this.latitude,
    required this.longitude,
    this.radiusKm = 2.0,
    this.isPrivate = false,
    this.requireApproval = true,
  });

  @override
  List<Object?> get props => [name, description, region, city, neighborhood, coordinatorId];
}

class LoadNearbyWatchGroups extends WatchGroupEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const LoadNearbyWatchGroups({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}

class LoadUserWatchGroups extends WatchGroupEvent {
  final String userId;

  const LoadUserWatchGroups(this.userId);

  @override
  List<Object?> get props => [userId];
}

class JoinWatchGroupRequested extends WatchGroupEvent {
  final String groupId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? phoneNumber;
  final String? skills;

  const JoinWatchGroupRequested({
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.phoneNumber,
    this.skills,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

class LoadGroupMembers extends WatchGroupEvent {
  final String groupId;

  const LoadGroupMembers(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class ApproveMemberRequested extends WatchGroupEvent {
  final String groupId;
  final String memberId;

  const ApproveMemberRequested({
    required this.groupId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [groupId, memberId];
}

class CreateMeetingRequested extends WatchGroupEvent {
  final String groupId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final String location;
  final String? locationAddress;
  final String organizerId;
  final String organizerName;

  const CreateMeetingRequested({
    required this.groupId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.location,
    this.locationAddress,
    required this.organizerId,
    required this.organizerName,
  });

  @override
  List<Object?> get props => [groupId, title, scheduledDate];
}

class LoadGroupMeetings extends WatchGroupEvent {
  final String groupId;

  const LoadGroupMeetings(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class RsvpMeetingRequested extends WatchGroupEvent {
  final String meetingId;
  final String userId;

  const RsvpMeetingRequested({
    required this.meetingId,
    required this.userId,
  });

  @override
  List<Object?> get props => [meetingId, userId];
}
