import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class GetUserAlerts implements UseCase<List<AlertEntity>, String> {
  final AlertRepository repository;

  GetUserAlerts(this.repository);

  @override
  Future<Either<Failure, List<AlertEntity>>> call(String userId) async {
    return await repository.getUserAlerts(userId);
  }
}
