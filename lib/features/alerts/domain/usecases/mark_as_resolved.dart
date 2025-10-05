import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/alert_repository.dart';

class MarkAsResolved {
  final AlertRepository repository;

  MarkAsResolved(this.repository);

  Future<Either<Failure, void>> call({
    required String alertId,
    required String userId,
  }) async {
    return await repository.markAsResolved(
      alertId: alertId,
      userId: userId,
    );
  }
}
