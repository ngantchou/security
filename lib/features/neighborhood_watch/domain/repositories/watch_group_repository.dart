import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/watch_group_entity.dart';

abstract class WatchGroupRepository {
  /// Create a new neighborhood watch group
  Future<Either<Failure, WatchGroupEntity>> createGroup({
    required String name,
    required String description,
    required String region,
    required String city,
    required String neighborhood,
    required String coordinatorId,
    required String coordinatorName,
    String? coordinatorPhoto,
    String? coordinatorPhone,
    required double latitude,
    required double longitude,
    double radiusKm,
    bool isPrivate,
    bool requireApproval,
    int maxMembers,
  });

  /// Get groups near a location
  Future<Either<Failure, List<WatchGroupEntity>>> getNearbyGroups({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  /// Get user's groups
  Future<Either<Failure, List<WatchGroupEntity>>> getUserGroups(String userId);

  /// Get single group details
  Future<Either<Failure, WatchGroupEntity>> getGroup(String groupId);

  /// Update group
  Future<Either<Failure, WatchGroupEntity>> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? coverImageUrl,
  });

  /// Delete group
  Future<Either<Failure, void>> deleteGroup(String groupId);

  /// Join group (request to join)
  Future<Either<Failure, WatchMemberEntity>> joinGroup({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? phoneNumber,
    String? skills,
  });

  /// Leave group
  Future<Either<Failure, void>> leaveGroup({
    required String groupId,
    required String userId,
  });

  /// Approve member (coordinator/moderator only)
  Future<Either<Failure, void>> approveMember({
    required String groupId,
    required String memberId,
  });

  /// Reject member (coordinator/moderator only)
  Future<Either<Failure, void>> rejectMember({
    required String groupId,
    required String memberId,
  });

  /// Get group members
  Future<Either<Failure, List<WatchMemberEntity>>> getMembers(String groupId);

  /// Get pending members (for approval)
  Future<Either<Failure, List<WatchMemberEntity>>> getPendingMembers(
      String groupId);

  /// Update member role
  Future<Either<Failure, void>> updateMemberRole({
    required String groupId,
    required String memberId,
    required WatchRole role,
  });

  /// Create meeting
  Future<Either<Failure, MeetingEntity>> createMeeting({
    required String groupId,
    required String title,
    required String description,
    required DateTime scheduledDate,
    required String location,
    String? locationAddress,
    required String organizerId,
    required String organizerName,
  });

  /// Get group meetings
  Future<Either<Failure, List<MeetingEntity>>> getMeetings(String groupId);

  /// RSVP to meeting
  Future<Either<Failure, void>> rsvpMeeting({
    required String meetingId,
    required String userId,
  });

  /// Cancel meeting
  Future<Either<Failure, void>> cancelMeeting(String meetingId);
}
