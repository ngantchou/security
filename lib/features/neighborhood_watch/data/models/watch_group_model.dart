import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/watch_group_entity.dart';

class WatchGroupModel extends WatchGroupEntity {
  const WatchGroupModel({
    required super.groupId,
    required super.name,
    required super.description,
    required super.region,
    required super.city,
    required super.neighborhood,
    super.coverImageUrl,
    required super.coordinatorId,
    required super.coordinatorName,
    super.coordinatorPhoto,
    super.coordinatorPhone,
    super.isPrivate,
    super.requireApproval,
    super.maxMembers,
    required super.latitude,
    required super.longitude,
    super.radiusKm,
    super.memberCount,
    super.alertCount,
    super.meetingCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WatchGroupModel.fromJson(Map<String, dynamic> json) {
    return WatchGroupModel(
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      region: json['region'] as String,
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      coordinatorId: json['coordinatorId'] as String,
      coordinatorName: json['coordinatorName'] as String,
      coordinatorPhoto: json['coordinatorPhoto'] as String?,
      coordinatorPhone: json['coordinatorPhone'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      requireApproval: json['requireApproval'] as bool? ?? true,
      maxMembers: json['maxMembers'] as int? ?? 100,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 2.0,
      memberCount: json['memberCount'] as int? ?? 1,
      alertCount: json['alertCount'] as int? ?? 0,
      meetingCount: json['meetingCount'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'region': region,
      'city': city,
      'neighborhood': neighborhood,
      'coverImageUrl': coverImageUrl,
      'coordinatorId': coordinatorId,
      'coordinatorName': coordinatorName,
      'coordinatorPhoto': coordinatorPhoto,
      'coordinatorPhone': coordinatorPhone,
      'isPrivate': isPrivate,
      'requireApproval': requireApproval,
      'maxMembers': maxMembers,
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
      'memberCount': memberCount,
      'alertCount': alertCount,
      'meetingCount': meetingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class WatchMemberModel extends WatchMemberEntity {
  const WatchMemberModel({
    required super.memberId,
    required super.groupId,
    required super.userId,
    required super.userName,
    super.userPhoto,
    super.phoneNumber,
    required super.role,
    super.status,
    required super.joinedAt,
    super.skills,
  });

  factory WatchMemberModel.fromJson(Map<String, dynamic> json) {
    return WatchMemberModel(
      memberId: json['memberId'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhoto: json['userPhoto'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: WatchRole.values.firstWhere(
        (e) => e.toString() == 'WatchRole.${json['role']}',
        orElse: () => WatchRole.member,
      ),
      status: MemberStatus.values.firstWhere(
        (e) => e.toString() == 'MemberStatus.${json['status']}',
        orElse: () => MemberStatus.pending,
      ),
      joinedAt: (json['joinedAt'] as Timestamp).toDate(),
      skills: json['skills'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'skills': skills,
    };
  }
}

class MeetingModel extends MeetingEntity {
  const MeetingModel({
    required super.meetingId,
    required super.groupId,
    required super.title,
    required super.description,
    required super.scheduledDate,
    required super.location,
    super.locationAddress,
    required super.organizerId,
    required super.organizerName,
    super.attendeeIds,
    super.status,
    required super.createdAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      meetingId: json['meetingId'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledDate: (json['scheduledDate'] as Timestamp).toDate(),
      location: json['location'] as String,
      locationAddress: json['locationAddress'] as String?,
      organizerId: json['organizerId'] as String,
      organizerName: json['organizerName'] as String,
      attendeeIds: (json['attendeeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: MeetingStatus.values.firstWhere(
        (e) => e.toString() == 'MeetingStatus.${json['status']}',
        orElse: () => MeetingStatus.scheduled,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingId': meetingId,
      'groupId': groupId,
      'title': title,
      'description': description,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'location': location,
      'locationAddress': locationAddress,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'attendeeIds': attendeeIds,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
