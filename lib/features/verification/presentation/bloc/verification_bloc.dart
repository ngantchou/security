import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/usecases/award_badge.dart';
import '../../domain/usecases/get_user_verification_stats.dart';
import '../../domain/usecases/track_contribution.dart';
import '../../domain/repositories/verification_repository.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final GetUserVerificationStats getUserVerificationStats;
  final TrackContribution trackContribution;
  final AwardBadge awardBadge;
  final VerificationRepository repository;

  VerificationBloc({
    required this.getUserVerificationStats,
    required this.trackContribution,
    required this.awardBadge,
    required this.repository,
  }) : super(VerificationInitial()) {
    on<LoadUserVerificationStats>(_onLoadUserVerificationStats);
    on<TrackUserContribution>(_onTrackUserContribution);
    on<AwardUserBadge>(_onAwardUserBadge);
    on<CheckAndAwardBadges>(_onCheckAndAwardBadges);
  }

  Future<void> _onLoadUserVerificationStats(
    LoadUserVerificationStats event,
    Emitter<VerificationState> emit,
  ) async {
    emit(VerificationLoading());

    final result = await getUserVerificationStats(event.userId);

    result.fold(
      (failure) => emit(VerificationError('Failed to load verification stats')),
      (stats) => emit(VerificationStatsLoaded(stats)),
    );
  }

  Future<void> _onTrackUserContribution(
    TrackUserContribution event,
    Emitter<VerificationState> emit,
  ) async {
    final result = await trackContribution(TrackContributionParams(
      userId: event.userId,
      type: event.type,
      relatedId: event.relatedId,
      description: event.description,
    ));

    result.fold(
      (failure) => emit(VerificationError('Failed to track contribution')),
      (contribution) {
        emit(ContributionTracked(
          message: '${contribution.type.displayName} tracked!',
          pointsEarned: contribution.pointsEarned,
        ));

        // Reload stats after contribution
        add(LoadUserVerificationStats(event.userId));

        // Check if user deserves new badges
        add(CheckAndAwardBadges(event.userId));
      },
    );
  }

  Future<void> _onAwardUserBadge(
    AwardUserBadge event,
    Emitter<VerificationState> emit,
  ) async {
    final result = await awardBadge(AwardBadgeParams(
      userId: event.userId,
      badgeType: event.badgeType,
      awardedBy: event.awardedBy,
      reason: event.reason,
    ));

    result.fold(
      (failure) => emit(VerificationError('Failed to award badge')),
      (badge) {
        emit(BadgeAwarded(
          badgeName: badge.badgeType.displayName,
          pointsEarned: badge.badgeType.pointValue,
        ));

        // Reload stats after badge award
        add(LoadUserVerificationStats(event.userId));
      },
    );
  }

  Future<void> _onCheckAndAwardBadges(
    CheckAndAwardBadges event,
    Emitter<VerificationState> emit,
  ) async {
    final result = await repository.checkAndAwardBadges(event.userId);

    result.fold(
      (failure) => null, // Silently fail, this is a background check
      (badges) {
        if (badges.isNotEmpty) {
          // User earned new badges!
          for (final badge in badges) {
            emit(BadgeAwarded(
              badgeName: badge.badgeType.displayName,
              pointsEarned: badge.badgeType.pointValue,
            ));
          }

          // Reload stats
          add(LoadUserVerificationStats(event.userId));
        }
      },
    );
  }
}
