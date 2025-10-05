import 'package:equatable/equatable.dart';

class WatchGroupEntity extends Equatable {
  final String groupId;
  final String name;
  final String description;
  final String region;
  final String city;
  final String neighborhood;
  final String? coverImageUrl;

  // Coordinator info
  final String coordinatorId;
  final String coordinatorName;
  final String? coordinatorPhoto;
  final String? coordinatorPhone;

  // Group settings
  final bool isPrivate;
  final bool requireApproval;
  final int maxMembers;

  // Location
  final double latitude;
  final double longitude;
  final double radiusKm; // Coverage area

  // Statistics
  final int memberCount;
  final int alertCount;
  final int meetingCount;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const WatchGroupEntity({
    required this.groupId,
    required this.name,
    required this.description,
    required this.region,
    required this.city,
    required this.neighborhood,
    this.coverImageUrl,
    required this.coordinatorId,
    required this.coordinatorName,
    this.coordinatorPhoto,
    this.coordinatorPhone,
    this.isPrivate = false,
    this.requireApproval = true,
    this.maxMembers = 100,
    required this.latitude,
    required this.longitude,
    this.radiusKm = 2.0,
    this.memberCount = 1,
    this.alertCount = 0,
    this.meetingCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        groupId,
        name,
        description,
        region,
        city,
        neighborhood,
        coverImageUrl,
        coordinatorId,
        coordinatorName,
        coordinatorPhoto,
        coordinatorPhone,
        isPrivate,
        requireApproval,
        maxMembers,
        latitude,
        longitude,
        radiusKm,
        memberCount,
        alertCount,
        meetingCount,
        createdAt,
        updatedAt,
      ];
}

class WatchMemberEntity extends Equatable {
  final String memberId;
  final String groupId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? phoneNumber;
  final WatchRole role;
  final MemberStatus status;
  final DateTime joinedAt;
  final String? skills; // e.g., "First Aid, Security"

  const WatchMemberEntity({
    required this.memberId,
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.phoneNumber,
    required this.role,
    this.status = MemberStatus.pending,
    required this.joinedAt,
    this.skills,
  });

  @override
  List<Object?> get props => [
        memberId,
        groupId,
        userId,
        userName,
        userPhoto,
        phoneNumber,
        role,
        status,
        joinedAt,
        skills,
      ];
}

class MeetingEntity extends Equatable {
  final String meetingId;
  final String groupId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final String location;
  final String? locationAddress;
  final String organizerId;
  final String organizerName;
  final List<String> attendeeIds;
  final MeetingStatus status;
  final DateTime createdAt;

  const MeetingEntity({
    required this.meetingId,
    required this.groupId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.location,
    this.locationAddress,
    required this.organizerId,
    required this.organizerName,
    this.attendeeIds = const [],
    this.status = MeetingStatus.scheduled,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        meetingId,
        groupId,
        title,
        description,
        scheduledDate,
        location,
        locationAddress,
        organizerId,
        organizerName,
        attendeeIds,
        status,
        createdAt,
      ];
}

enum WatchRole {
  coordinator,
  moderator,
  member,
}

enum MemberStatus {
  pending,
  approved,
  rejected,
}

enum MeetingStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}
