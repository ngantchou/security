import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/usecases/create_alert.dart';
import '../../domain/usecases/get_nearby_alerts.dart';
import '../../domain/usecases/get_user_alerts.dart';
import '../../domain/usecases/confirm_alert.dart';
import '../../domain/usecases/offer_help.dart';
import '../../domain/usecases/mark_as_resolved.dart';
import '../../domain/usecases/report_false_alarm.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../../verification/domain/usecases/track_contribution.dart';
import 'alert_event.dart';
import 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final CreateAlert createAlert;
  final GetNearbyAlerts getNearbyAlerts;
  final GetUserAlerts getUserAlerts;
  final ConfirmAlert confirmAlert;
  final OfferHelp offerHelp;
  final MarkAsResolved markAsResolved;
  final ReportFalseAlarm reportFalseAlarm;
  final AlertRepository alertRepository;
  final TrackContribution? trackContribution;

  StreamSubscription? _nearbyAlertsSubscription;

  AlertBloc({
    required this.createAlert,
    required this.getNearbyAlerts,
    required this.getUserAlerts,
    required this.confirmAlert,
    required this.offerHelp,
    required this.markAsResolved,
    required this.reportFalseAlarm,
    required this.alertRepository,
    this.trackContribution,
  }) : super(AlertInitial()) {
    on<CreateAlertRequested>(_onCreateAlertRequested);
    on<LoadNearbyAlerts>(_onLoadNearbyAlerts);
    on<LoadUserAlerts>(_onLoadUserAlerts);
    on<ConfirmAlertRequested>(_onConfirmAlertRequested);
    on<OfferHelpRequested>(_onOfferHelpRequested);
    on<MarkAlertAsResolvedRequested>(_onMarkAlertAsResolvedRequested);
    on<ReportFalseAlarmRequested>(_onReportFalseAlarmRequested);
    on<WatchNearbyAlertsStarted>(_onWatchNearbyAlertsStarted);
    on<WatchNearbyAlertsStopped>(_onWatchNearbyAlertsStopped);
    on<RefreshAlerts>(_onRefreshAlerts);
  }

  Future<void> _onCreateAlertRequested(
    CreateAlertRequested event,
    Emitter<AlertState> emit,
  ) async {
    emit(const AlertCreating());

    final result = await createAlert(CreateAlertParams(
      creatorId: event.creatorId,
      creatorName: event.creatorName,
      latitude: event.latitude,
      longitude: event.longitude,
      dangerType: event.dangerType,
      level: event.level,
      title: event.title,
      description: event.description,
      audioCommentUrl: event.audioCommentUrl,
      images: event.images,
      region: event.region,
      city: event.city,
      neighborhood: event.neighborhood,
      address: event.address,
    ));

    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alert) {
        emit(AlertCreated(alert));

        // Track contribution for creating alert
        if (trackContribution != null) {
          trackContribution!(TrackContributionParams(
            userId: event.creatorId,
            type: ContributionType.alertCreated,
            relatedId: alert.alertId,
            description: 'Created alert: ${alert.title}',
          ));
        }
      },
    );
  }

  Future<void> _onLoadNearbyAlerts(
    LoadNearbyAlerts event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());

    final result = await getNearbyAlerts(GetNearbyAlertsParams(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusInKm: event.radiusInKm,
    ));

    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alerts) {
        if (alerts.isEmpty) {
          emit(const AlertEmpty());
        } else {
          emit(AlertsLoaded(alerts));
        }
      },
    );
  }

  Future<void> _onLoadUserAlerts(
    LoadUserAlerts event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());

    final result = await getUserAlerts(event.userId);

    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alerts) {
        if (alerts.isEmpty) {
          emit(const AlertEmpty('You have not created any alerts yet'));
        } else {
          emit(UserAlertsLoaded(alerts));
        }
      },
    );
  }

  Future<void> _onConfirmAlertRequested(
    ConfirmAlertRequested event,
    Emitter<AlertState> emit,
  ) async {
    final result = await confirmAlert(ConfirmAlertParams(
      alertId: event.alertId,
      userId: event.userId,
      userName: event.userName,
      comment: event.comment,
      audioCommentUrl: event.audioCommentUrl,
    ));

    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (_) {
        emit(AlertConfirmed(event.alertId));

        // Track contribution for confirming alert
        if (trackContribution != null) {
          trackContribution!(TrackContributionParams(
            userId: event.userId,
            type: ContributionType.alertConfirmed,
            relatedId: event.alertId,
            description: event.comment,
          ));
        }
      },
    );
  }

  Future<void> _onWatchNearbyAlertsStarted(
    WatchNearbyAlertsStarted event,
    Emitter<AlertState> emit,
  ) async {
    await _nearbyAlertsSubscription?.cancel();

    emit(AlertLoading());

    _nearbyAlertsSubscription = alertRepository
        .watchNearbyAlerts(
          latitude: event.latitude,
          longitude: event.longitude,
          radiusInKm: event.radiusInKm,
        )
        .listen(
          (either) {
            either.fold(
              (failure) => add(const RefreshAlerts()),
              (alerts) {
                if (!isClosed) {
                  if (alerts.isEmpty) {
                    emit(const AlertEmpty());
                  } else {
                    emit(AlertsLoaded(alerts, isRealtime: true));
                  }
                }
              },
            );
          },
          onError: (error) {
            if (!isClosed) {
              emit(AlertError('Failed to watch alerts: $error'));
            }
          },
        );
  }

  Future<void> _onWatchNearbyAlertsStopped(
    WatchNearbyAlertsStopped event,
    Emitter<AlertState> emit,
  ) async {
    await _nearbyAlertsSubscription?.cancel();
    _nearbyAlertsSubscription = null;
  }

  Future<void> _onOfferHelpRequested(
    OfferHelpRequested event,
    Emitter<AlertState> emit,
  ) async {
    final result = await offerHelp(OfferHelpParams(
      alertId: event.alertId,
      userId: event.userId,
      userName: event.userName,
      helpType: event.helpType,
      description: event.description,
      phoneNumber: event.phoneNumber,
    ));

    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (_) {
        emit(HelpOffered(event.alertId));

        // Track contribution for offering help
        if (trackContribution != null) {
          trackContribution!(TrackContributionParams(
            userId: event.userId,
            type: ContributionType.helpOffered,
            relatedId: event.alertId,
            description: 'Offered ${event.helpType} help',
          ));
        }
      },
    );
  }

  Future<void> _onMarkAlertAsResolvedRequested(
    MarkAlertAsResolvedRequested event,
    Emitter<AlertState> emit,
  ) async {
    final result = await markAsResolved(
      alertId: event.alertId,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (_) => emit(AlertMarkedAsResolved(event.alertId)),
    );
  }

  Future<void> _onReportFalseAlarmRequested(
    ReportFalseAlarmRequested event,
    Emitter<AlertState> emit,
  ) async {
    final result = await reportFalseAlarm(
      alertId: event.alertId,
      userId: event.userId,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (_) => emit(FalseAlarmReported(event.alertId)),
    );
  }

  Future<void> _onRefreshAlerts(
    RefreshAlerts event,
    Emitter<AlertState> emit,
  ) async {
    // This event is used to trigger UI refresh from stream updates
    // The actual state emission is handled in the stream listener
  }

  @override
  Future<void> close() {
    _nearbyAlertsSubscription?.cancel();
    return super.close();
  }
}
