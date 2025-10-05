import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/watch_group_entity.dart';
import '../repositories/watch_group_repository.dart';

// Get nearby groups
class GetNearbyWatchGroups implements UseCase<List<WatchGroupEntity>, NearbyGroupsParams> {
  final WatchGroupRepository repository;
  GetNearbyWatchGroups(this.repository);

  @override
  Future<Either<Failure, List<WatchGroupEntity>>> call(NearbyGroupsParams params) async {
    return await repository.getNearbyGroups(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
    );
  }
}

class NearbyGroupsParams {
  final double latitude;
  final double longitude;
  final double radiusKm;

  NearbyGroupsParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
  });
}

// Get user's groups
class GetUserWatchGroups implements UseCase<List<WatchGroupEntity>, String> {
  final WatchGroupRepository repository;
  GetUserWatchGroups(this.repository);

  @override
  Future<Either<Failure, List<WatchGroupEntity>>> call(String userId) async {
    return await repository.getUserGroups(userId);
  }
}

// Join group
class JoinWatchGroup implements UseCase<WatchMemberEntity, JoinGroupParams> {
  final WatchGroupRepository repository;
  JoinWatchGroup(this.repository);

  @override
  Future<Either<Failure, WatchMemberEntity>> call(JoinGroupParams params) async {
    return await repository.joinGroup(
      groupId: params.groupId,
      userId: params.userId,
      userName: params.userName,
      userPhoto: params.userPhoto,
      phoneNumber: params.phoneNumber,
      skills: params.skills,
    );
  }
}

class JoinGroupParams {
  final String groupId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? phoneNumber;
  final String? skills;

  JoinGroupParams({
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.phoneNumber,
    this.skills,
  });
}

// Get group members
class GetGroupMembers implements UseCase<List<WatchMemberEntity>, String> {
  final WatchGroupRepository repository;
  GetGroupMembers(this.repository);

  @override
  Future<Either<Failure, List<WatchMemberEntity>>> call(String groupId) async {
    return await repository.getMembers(groupId);
  }
}

// Approve member
class ApproveMember implements UseCase<void, ApproveMemberParams> {
  final WatchGroupRepository repository;
  ApproveMember(this.repository);

  @override
  Future<Either<Failure, void>> call(ApproveMemberParams params) async {
    return await repository.approveMember(
      groupId: params.groupId,
      memberId: params.memberId,
    );
  }
}

class ApproveMemberParams {
  final String groupId;
  final String memberId;

  ApproveMemberParams({required this.groupId, required this.memberId});
}

// Create meeting
class CreateMeeting implements UseCase<MeetingEntity, CreateMeetingParams> {
  final WatchGroupRepository repository;
  CreateMeeting(this.repository);

  @override
  Future<Either<Failure, MeetingEntity>> call(CreateMeetingParams params) async {
    return await repository.createMeeting(
      groupId: params.groupId,
      title: params.title,
      description: params.description,
      scheduledDate: params.scheduledDate,
      location: params.location,
      locationAddress: params.locationAddress,
      organizerId: params.organizerId,
      organizerName: params.organizerName,
    );
  }
}

class CreateMeetingParams {
  final String groupId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final String location;
  final String? locationAddress;
  final String organizerId;
  final String organizerName;

  CreateMeetingParams({
    required this.groupId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.location,
    this.locationAddress,
    required this.organizerId,
    required this.organizerName,
  });
}

// Get meetings
class GetGroupMeetings implements UseCase<List<MeetingEntity>, String> {
  final WatchGroupRepository repository;
  GetGroupMeetings(this.repository);

  @override
  Future<Either<Failure, List<MeetingEntity>>> call(String groupId) async {
    return await repository.getMeetings(groupId);
  }
}

// RSVP to meeting
class RsvpMeeting implements UseCase<void, RsvpMeetingParams> {
  final WatchGroupRepository repository;
  RsvpMeeting(this.repository);

  @override
  Future<Either<Failure, void>> call(RsvpMeetingParams params) async {
    return await repository.rsvpMeeting(
      meetingId: params.meetingId,
      userId: params.userId,
    );
  }
}

class RsvpMeetingParams {
  final String meetingId;
  final String userId;

  RsvpMeetingParams({required this.meetingId, required this.userId});
}
