import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/alert_repository.dart';

class ConfirmAlert implements UseCase<void, ConfirmAlertParams> {
  final AlertRepository repository;

  ConfirmAlert(this.repository);

  @override
  Future<Either<Failure, void>> call(ConfirmAlertParams params) async {
    return await repository.confirmAlert(
      alertId: params.alertId,
      userId: params.userId,
      userName: params.userName,
      comment: params.comment,
      audioCommentUrl: params.audioCommentUrl,
    );
  }
}

class ConfirmAlertParams extends Equatable {
  final String alertId;
  final String userId;
  final String userName;
  final String? comment;
  final String? audioCommentUrl;

  const ConfirmAlertParams({
    required this.alertId,
    required this.userId,
    required this.userName,
    this.comment,
    this.audioCommentUrl,
  });

  @override
  List<Object?> get props =>
      [alertId, userId, userName, comment, audioCommentUrl];
}
