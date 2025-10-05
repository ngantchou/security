import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/danger_group_entity.dart';

class DangerGroupModel extends DangerGroupEntity {
  const DangerGroupModel({
    required super.groupId,
    required super.name,
    required super.description,
    required super.dangerType,
    required super.region,
    required super.city,
    super.neighborhood,
    super.coverImageUrl,
    required super.creatorId,
    required super.creatorName,
    super.privacy,
    super.allowPosts,
    super.allowAlerts,
    required super.memberCount,
    required super.alertCount,
    required super.postCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DangerGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DangerGroupModel(
      groupId: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      dangerType: DangerType.values.firstWhere(
        (e) => e.toString().split('.').last == data['dangerType'],
      ),
      region: data['region'] as String,
      city: data['city'] as String,
      neighborhood: data['neighborhood'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      creatorId: data['creatorId'] as String,
      creatorName: data['creatorName'] as String,
      privacy: GroupPrivacy.values.firstWhere(
        (e) => e.toString().split('.').last == data['privacy'],
        orElse: () => GroupPrivacy.public,
      ),
      allowPosts: data['allowPosts'] as bool? ?? true,
      allowAlerts: data['allowAlerts'] as bool? ?? true,
      memberCount: data['memberCount'] as int? ?? 0,
      alertCount: data['alertCount'] as int? ?? 0,
      postCount: data['postCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'dangerType': dangerType.toString().split('.').last,
      'region': region,
      'city': city,
      'neighborhood': neighborhood,
      'coverImageUrl': coverImageUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'privacy': privacy.toString().split('.').last,
      'allowPosts': allowPosts,
      'allowAlerts': allowAlerts,
      'memberCount': memberCount,
      'alertCount': alertCount,
      'postCount': postCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory DangerGroupModel.fromEntity(DangerGroupEntity entity) {
    return DangerGroupModel(
      groupId: entity.groupId,
      name: entity.name,
      description: entity.description,
      dangerType: entity.dangerType,
      region: entity.region,
      city: entity.city,
      neighborhood: entity.neighborhood,
      coverImageUrl: entity.coverImageUrl,
      creatorId: entity.creatorId,
      creatorName: entity.creatorName,
      privacy: entity.privacy,
      allowPosts: entity.allowPosts,
      allowAlerts: entity.allowAlerts,
      memberCount: entity.memberCount,
      alertCount: entity.alertCount,
      postCount: entity.postCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class GroupMemberModel extends GroupMemberEntity {
  const GroupMemberModel({
    required super.userId,
    required super.userName,
    super.userPhoto,
    required super.role,
    required super.joinedAt,
  });

  factory GroupMemberModel.fromFirestore(Map<String, dynamic> data) {
    return GroupMemberModel(
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      userPhoto: data['userPhoto'] as String?,
      role: GroupRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
      ),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'role': role.toString().split('.').last,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  factory GroupMemberModel.fromEntity(GroupMemberEntity entity) {
    return GroupMemberModel(
      userId: entity.userId,
      userName: entity.userName,
      userPhoto: entity.userPhoto,
      role: entity.role,
      joinedAt: entity.joinedAt,
    );
  }
}
