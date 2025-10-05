import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';

abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertCreating extends AlertState {
  final String message;

  const AlertCreating([this.message = 'Creating alert...']);

  @override
  List<Object?> get props => [message];
}

class AlertCreated extends AlertState {
  final AlertEntity alert;

  const AlertCreated(this.alert);

  @override
  List<Object?> get props => [alert];
}

class AlertsLoaded extends AlertState {
  final List<AlertEntity> alerts;
  final bool isRealtime;

  const AlertsLoaded(this.alerts, {this.isRealtime = false});

  @override
  List<Object?> get props => [alerts, isRealtime];
}

class UserAlertsLoaded extends AlertState {
  final List<AlertEntity> alerts;

  const UserAlertsLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

class AlertConfirmed extends AlertState {
  final String alertId;
  final String message;

  const AlertConfirmed(this.alertId, [this.message = 'Alert confirmed']);

  @override
  List<Object?> get props => [alertId, message];
}

class AlertError extends AlertState {
  final String message;

  const AlertError(this.message);

  @override
  List<Object?> get props => [message];
}

class AlertEmpty extends AlertState {
  final String message;

  const AlertEmpty([this.message = 'No alerts found nearby']);

  @override
  List<Object?> get props => [message];
}

class HelpOffered extends AlertState {
  final String alertId;
  final String message;

  const HelpOffered(this.alertId, [this.message = 'Help offered successfully']);

  @override
  List<Object?> get props => [alertId, message];
}

class AlertMarkedAsResolved extends AlertState {
  final String alertId;
  final String message;

  const AlertMarkedAsResolved(this.alertId,
      [this.message = 'Alert marked as resolved']);

  @override
  List<Object?> get props => [alertId, message];
}

class FalseAlarmReported extends AlertState {
  final String alertId;
  final String message;

  const FalseAlarmReported(this.alertId,
      [this.message = 'False alarm reported']);

  @override
  List<Object?> get props => [alertId, message];
}
