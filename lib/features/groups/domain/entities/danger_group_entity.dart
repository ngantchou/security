import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

class DangerGroupEntity extends Equatable {
  final String groupId;
  final String name;
  final String description;
  final DangerType dangerType;
  final String region;
  final String city;
  final String? neighborhood;
  final String? coverImageUrl;
  final String creatorId;
  final String creatorName;

  // Group settings
  final GroupPrivacy privacy;
  final bool allowPosts;
  final bool allowAlerts;

  // Statistics
  final int memberCount;
  final int alertCount;
  final int postCount;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const DangerGroupEntity({
    required this.groupId,
    required this.name,
    required this.description,
    required this.dangerType,
    required this.region,
    required this.city,
    this.neighborhood,
    this.coverImageUrl,
    required this.creatorId,
    required this.creatorName,
    this.privacy = GroupPrivacy.public,
    this.allowPosts = true,
    this.allowAlerts = true,
    required this.memberCount,
    required this.alertCount,
    required this.postCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        groupId,
        name,
        description,
        dangerType,
        region,
        city,
        neighborhood,
        coverImageUrl,
        creatorId,
        creatorName,
        privacy,
        allowPosts,
        allowAlerts,
        memberCount,
        alertCount,
        postCount,
        createdAt,
        updatedAt,
      ];
}

class GroupMemberEntity extends Equatable {
  final String userId;
  final String userName;
  final String? userPhoto;
  final GroupRole role;
  final DateTime joinedAt;

  const GroupMemberEntity({
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [userId, userName, userPhoto, role, joinedAt];
}
