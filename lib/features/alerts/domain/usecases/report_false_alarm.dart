import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/alert_repository.dart';

class ReportFalseAlarm {
  final AlertRepository repository;

  ReportFalseAlarm(this.repository);

  Future<Either<Failure, void>> call({
    required String alertId,
    required String userId,
    required String reason,
  }) async {
    return await repository.reportFalseAlarm(
      alertId: alertId,
      userId: userId,
      reason: reason,
    );
  }
}
