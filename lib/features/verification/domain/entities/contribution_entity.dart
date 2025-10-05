import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

class ContributionEntity extends Equatable {
  final String contributionId;
  final String userId;
  final ContributionType type;
  final int pointsEarned;
  final String? relatedId; // Alert ID, comment ID, etc.
  final String? description;
  final DateTime createdAt;

  const ContributionEntity({
    required this.contributionId,
    required this.userId,
    required this.type,
    required this.pointsEarned,
    this.relatedId,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        contributionId,
        userId,
        type,
        pointsEarned,
        relatedId,
        description,
        createdAt,
      ];
}
