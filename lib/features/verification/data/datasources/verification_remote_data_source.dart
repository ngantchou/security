import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/enums.dart';
import '../models/contribution_model.dart';
import '../models/badge_model.dart';

abstract class VerificationRemoteDataSource {
  Future<ContributionModel> trackContribution({
    required String userId,
    required ContributionType type,
    String? relatedId,
    String? description,
  });

  Future<List<ContributionModel>> getUserContributions(
    String userId, {
    int? limit,
  });

  Future<BadgeModel> awardBadge({
    required String userId,
    required BadgeType badgeType,
    String? awardedBy,
    String? reason,
  });

  Future<List<BadgeModel>> getUserBadges(String userId);

  Future<bool> hasBadge(String userId, BadgeType badgeType);

  Future<int> calculateTotalPoints(String userId);

  Future<VerificationLevel> getVerificationLevel(String userId);

  Future<void> updateVerificationLevel({
    required String userId,
    required VerificationLevel level,
  });

  Future<void> updateUserContributionPoints({
    required String userId,
    required int points,
  });

  Future<Map<String, dynamic>> getUserStats(String userId);
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final FirebaseFirestore firestore;

  VerificationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ContributionModel> trackContribution({
    required String userId,
    required ContributionType type,
    String? relatedId,
    String? description,
  }) async {
    try {
      final pointsEarned = _getPointsForContribution(type);

      final contribution = ContributionModel(
        contributionId: '', // Will be set by Firestore
        userId: userId,
        type: type,
        pointsEarned: pointsEarned,
        relatedId: relatedId,
        description: description,
        createdAt: DateTime.now(),
      );

      // Add contribution to Firestore
      final docRef = await firestore
          .collection('contributions')
          .add(contribution.toFirestore());

      // Update user's total contribution points
      await updateUserContributionPoints(
        userId: userId,
        points: pointsEarned,
      );

      // Check if user's verification level should be updated
      final totalPoints = await calculateTotalPoints(userId);
      final newLevel = _getLevelFromPoints(totalPoints);
      await updateVerificationLevel(userId: userId, level: newLevel);

      // Return the created contribution with ID
      return ContributionModel(
        contributionId: docRef.id,
        userId: contribution.userId,
        type: contribution.type,
        pointsEarned: contribution.pointsEarned,
        relatedId: contribution.relatedId,
        description: contribution.description,
        createdAt: contribution.createdAt,
      );
    } catch (e) {
      throw ServerException('Failed to track contribution: $e');
    }
  }

  @override
  Future<List<ContributionModel>> getUserContributions(
    String userId, {
    int? limit,
  }) async {
    try {
      Query query = firestore
          .collection('contributions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ContributionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user contributions: $e');
    }
  }

  @override
  Future<BadgeModel> awardBadge({
    required String userId,
    required BadgeType badgeType,
    String? awardedBy,
    String? reason,
  }) async {
    try {
      // Check if user already has this badge
      final hasIt = await hasBadge(userId, badgeType);
      if (hasIt) {
        throw ServerException('User already has this badge');
      }

      final badge = BadgeModel(
        badgeId: '', // Will be set by Firestore
        userId: userId,
        badgeType: badgeType,
        awardedAt: DateTime.now(),
        awardedBy: awardedBy ?? 'system',
        reason: reason,
      );

      // Add badge to Firestore
      final docRef =
          await firestore.collection('badges').add(badge.toFirestore());

      // Add badge to user's earnedBadges array
      await firestore.collection('users').doc(userId).update({
        'earnedBadges': FieldValue.arrayUnion([badgeType.toString().split('.').last]),
      });

      // Award badge points to user
      final badgePoints = _getPointsForBadge(badgeType);
      await updateUserContributionPoints(
        userId: userId,
        points: badgePoints,
      );

      return BadgeModel(
        badgeId: docRef.id,
        userId: badge.userId,
        badgeType: badge.badgeType,
        awardedAt: badge.awardedAt,
        awardedBy: badge.awardedBy,
        reason: badge.reason,
      );
    } catch (e) {
      throw ServerException('Failed to award badge: $e');
    }
  }

  @override
  Future<List<BadgeModel>> getUserBadges(String userId) async {
    try {
      final snapshot = await firestore
          .collection('badges')
          .where('userId', isEqualTo: userId)
          .orderBy('awardedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => BadgeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get user badges: $e');
    }
  }

  @override
  Future<bool> hasBadge(String userId, BadgeType badgeType) async {
    try {
      final snapshot = await firestore
          .collection('badges')
          .where('userId', isEqualTo: userId)
          .where('badgeType', isEqualTo: badgeType.toString().split('.').last)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw ServerException('Failed to check badge: $e');
    }
  }

  @override
  Future<int> calculateTotalPoints(String userId) async {
    try {
      final snapshot = await firestore
          .collection('contributions')
          .where('userId', isEqualTo: userId)
          .get();

      int totalPoints = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalPoints += (data['pointsEarned'] as int? ?? 0);
      }

      return totalPoints;
    } catch (e) {
      throw ServerException('Failed to calculate total points: $e');
    }
  }

  @override
  Future<VerificationLevel> getVerificationLevel(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw ServerException('User not found');
      }

      final data = userDoc.data()!;
      final levelString = data['verificationLevel'] as String?;

      if (levelString == null) {
        return VerificationLevel.newcomer;
      }

      return VerificationLevel.values.firstWhere(
        (e) => e.toString() == 'VerificationLevel.$levelString',
        orElse: () => VerificationLevel.newcomer,
      );
    } catch (e) {
      throw ServerException('Failed to get verification level: $e');
    }
  }

  @override
  Future<void> updateVerificationLevel({
    required String userId,
    required VerificationLevel level,
  }) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'verificationLevel': level.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update verification level: $e');
    }
  }

  @override
  Future<void> updateUserContributionPoints({
    required String userId,
    required int points,
  }) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'contributionPoints': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update contribution points: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw ServerException('User not found');
      }

      final data = userDoc.data()!;
      return {
        'contributionPoints': data['contributionPoints'] ?? 0,
        'verificationLevel': data['verificationLevel'] ?? 'newcomer',
        'alertsCreated': data['alertsCreated'] ?? 0,
        'alertsConfirmed': data['alertsConfirmed'] ?? 0,
        'helpOfferedCount': data['helpOfferedCount'] ?? 0,
        'resourcesSharedCount': data['resourcesSharedCount'] ?? 0,
        'earnedBadges': data['earnedBadges'] ?? [],
      };
    } catch (e) {
      throw ServerException('Failed to get user stats: $e');
    }
  }

  // Helper methods
  int _getPointsForContribution(ContributionType type) {
    switch (type) {
      case ContributionType.alertCreated:
        return 5;
      case ContributionType.alertConfirmed:
        return 3;
      case ContributionType.helpOffered:
        return 10;
      case ContributionType.resourceShared:
        return 15;
      case ContributionType.commentAdded:
        return 1;
      case ContributionType.bloodDonated:
        return 50;
      case ContributionType.fundContributed:
        return 20;
      case ContributionType.memberReferred:
        return 10;
      case ContributionType.communityModeration:
        return 5;
    }
  }

  int _getPointsForBadge(BadgeType badgeType) {
    switch (badgeType) {
      case BadgeType.earlyAdopter:
        return 20;
      case BadgeType.alertMaster:
        return 100;
      case BadgeType.communityGuardian:
        return 150;
      case BadgeType.safetyAdvocate:
        return 75;
      case BadgeType.firstResponder:
        return 80;
      case BadgeType.helpingHand:
        return 30;
      case BadgeType.lifeSaver:
        return 200;
      case BadgeType.resourceProvider:
        return 50;
      case BadgeType.donorHero:
        return 100;
      case BadgeType.trustedMember:
        return 60;
      case BadgeType.verifiedCitizen:
        return 50;
      case BadgeType.communityLeader:
        return 120;
      case BadgeType.verifiedProfessional:
        return 150;
      case BadgeType.emergencyResponder:
        return 100;
      case BadgeType.healthcareWorker:
        return 100;
      case BadgeType.foundingMember:
        return 50;
      case BadgeType.moderator:
        return 200;
      case BadgeType.ambassador:
        return 150;
    }
  }

  VerificationLevel _getLevelFromPoints(int points) {
    if (points >= 501) return VerificationLevel.platinum;
    if (points >= 301) return VerificationLevel.gold;
    if (points >= 151) return VerificationLevel.silver;
    if (points >= 51) return VerificationLevel.bronze;
    return VerificationLevel.newcomer;
  }
}
