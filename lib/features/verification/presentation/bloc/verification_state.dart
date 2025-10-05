import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_user_verification_stats.dart';

abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationStatsLoaded extends VerificationState {
  final UserVerificationStats stats;

  const VerificationStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class ContributionTracked extends VerificationState {
  final String message;
  final int pointsEarned;

  const ContributionTracked({
    required this.message,
    required this.pointsEarned,
  });

  @override
  List<Object?> get props => [message, pointsEarned];
}

class BadgeAwarded extends VerificationState {
  final String badgeName;
  final int pointsEarned;

  const BadgeAwarded({
    required this.badgeName,
    required this.pointsEarned,
  });

  @override
  List<Object?> get props => [badgeName, pointsEarned];
}

class LevelUpAchieved extends VerificationState {
  final String newLevel;
  final String message;

  const LevelUpAchieved({
    required this.newLevel,
    required this.message,
  });

  @override
  List<Object?> get props => [newLevel, message];
}

class VerificationError extends VerificationState {
  final String message;

  const VerificationError(this.message);

  @override
  List<Object?> get props => [message];
}
