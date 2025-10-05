import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/contribution_entity.dart';

class ContributionModel extends ContributionEntity {
  const ContributionModel({
    required super.contributionId,
    required super.userId,
    required super.type,
    required super.pointsEarned,
    super.relatedId,
    super.description,
    required super.createdAt,
  });

  // Convert from Entity
  factory ContributionModel.fromEntity(ContributionEntity entity) {
    return ContributionModel(
      contributionId: entity.contributionId,
      userId: entity.userId,
      type: entity.type,
      pointsEarned: entity.pointsEarned,
      relatedId: entity.relatedId,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }

  // Convert to Entity
  ContributionEntity toEntity() {
    return ContributionEntity(
      contributionId: contributionId,
      userId: userId,
      type: type,
      pointsEarned: pointsEarned,
      relatedId: relatedId,
      description: description,
      createdAt: createdAt,
    );
  }

  // Convert from Firestore
  factory ContributionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContributionModel(
      contributionId: doc.id,
      userId: data['userId'] as String,
      type: ContributionType.values.firstWhere(
        (e) => e.toString() == 'ContributionType.${data['type']}',
      ),
      pointsEarned: data['pointsEarned'] as int,
      relatedId: data['relatedId'] as String?,
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'pointsEarned': pointsEarned,
      'relatedId': relatedId,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert from JSON
  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      contributionId: json['contributionId'] as String,
      userId: json['userId'] as String,
      type: ContributionType.values.firstWhere(
        (e) => e.toString() == 'ContributionType.${json['type']}',
      ),
      pointsEarned: json['pointsEarned'] as int,
      relatedId: json['relatedId'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'contributionId': contributionId,
      'userId': userId,
      'type': type.toString().split('.').last,
      'pointsEarned': pointsEarned,
      'relatedId': relatedId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
