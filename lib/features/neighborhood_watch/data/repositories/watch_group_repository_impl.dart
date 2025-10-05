import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/watch_group_entity.dart';
import '../../domain/repositories/watch_group_repository.dart';
import '../datasources/watch_group_remote_data_source.dart';

class WatchGroupRepositoryImpl implements WatchGroupRepository {
  final WatchGroupRemoteDataSource remoteDataSource;

  WatchGroupRepositoryImpl({required this.remoteDataSource});

  @override
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
    double radiusKm = 2.0,
    bool isPrivate = false,
    bool requireApproval = true,
    int maxMembers = 100,
  }) async {
    try {
      final group = await remoteDataSource.createGroup(
        name: name,
        description: description,
        region: region,
        city: city,
        neighborhood: neighborhood,
        coordinatorId: coordinatorId,
        coordinatorName: coordinatorName,
        coordinatorPhoto: coordinatorPhoto,
        coordinatorPhone: coordinatorPhone,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        isPrivate: isPrivate,
        requireApproval: requireApproval,
        maxMembers: maxMembers,
      );
      return Right(group);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WatchGroupEntity>>> getNearbyGroups({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final groups = await remoteDataSource.getNearbyGroups(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WatchGroupEntity>>> getUserGroups(
      String userId) async {
    try {
      final groups = await remoteDataSource.getUserGroups(userId);
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WatchGroupEntity>> getGroup(String groupId) async {
    try {
      final group = await remoteDataSource.getGroup(groupId);
      return Right(group);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WatchGroupEntity>> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? coverImageUrl,
  }) async {
    try {
      final group = await remoteDataSource.updateGroup(
        groupId: groupId,
        name: name,
        description: description,
        coverImageUrl: coverImageUrl,
      );
      return Right(group);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String groupId) async {
    try {
      await remoteDataSource.deleteGroup(groupId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WatchMemberEntity>> joinGroup({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? phoneNumber,
    String? skills,
  }) async {
    try {
      final member = await remoteDataSource.joinGroup(
        groupId: groupId,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        phoneNumber: phoneNumber,
        skills: skills,
      );
      return Right(member);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.leaveGroup(groupId: groupId, userId: userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveMember({
    required String groupId,
    required String memberId,
  }) async {
    try {
      await remoteDataSource.approveMember(
        groupId: groupId,
        memberId: memberId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectMember({
    required String groupId,
    required String memberId,
  }) async {
    try {
      await remoteDataSource.rejectMember(
        groupId: groupId,
        memberId: memberId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WatchMemberEntity>>> getMembers(
      String groupId) async {
    try {
      final members = await remoteDataSource.getMembers(groupId);
      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WatchMemberEntity>>> getPendingMembers(
      String groupId) async {
    try {
      final members = await remoteDataSource.getPendingMembers(groupId);
      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemberRole({
    required String groupId,
    required String memberId,
    required WatchRole role,
  }) async {
    try {
      await remoteDataSource.updateMemberRole(
        groupId: groupId,
        memberId: memberId,
        role: role,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MeetingEntity>> createMeeting({
    required String groupId,
    required String title,
    required String description,
    required DateTime scheduledDate,
    required String location,
    String? locationAddress,
    required String organizerId,
    required String organizerName,
  }) async {
    try {
      final meeting = await remoteDataSource.createMeeting(
        groupId: groupId,
        title: title,
        description: description,
        scheduledDate: scheduledDate,
        location: location,
        locationAddress: locationAddress,
        organizerId: organizerId,
        organizerName: organizerName,
      );
      return Right(meeting);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MeetingEntity>>> getMeetings(
      String groupId) async {
    try {
      final meetings = await remoteDataSource.getMeetings(groupId);
      return Right(meetings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rsvpMeeting({
    required String meetingId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.rsvpMeeting(
        meetingId: meetingId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelMeeting(String meetingId) async {
    try {
      await remoteDataSource.cancelMeeting(meetingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
