import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/alert_repository.dart';

class OfferHelp implements UseCase<void, OfferHelpParams> {
  final AlertRepository repository;

  OfferHelp(this.repository);

  @override
  Future<Either<Failure, void>> call(OfferHelpParams params) async {
    return await repository.offerHelp(
      alertId: params.alertId,
      userId: params.userId,
      userName: params.userName,
      helpType: params.helpType,
      description: params.description,
      phoneNumber: params.phoneNumber,
    );
  }
}

class OfferHelpParams {
  final String alertId;
  final String userId;
  final String userName;
  final String helpType;
  final String? description;
  final String? phoneNumber;

  OfferHelpParams({
    required this.alertId,
    required this.userId,
    required this.userName,
    required this.helpType,
    this.description,
    this.phoneNumber,
  });
}
