import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class GetNearbyAlerts
    implements UseCase<List<AlertEntity>, GetNearbyAlertsParams> {
  final AlertRepository repository;

  GetNearbyAlerts(this.repository);

  @override
  Future<Either<Failure, List<AlertEntity>>> call(
    GetNearbyAlertsParams params,
  ) async {
    return await repository.getNearbyAlerts(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusInKm: params.radiusInKm,
    );
  }
}

class GetNearbyAlertsParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const GetNearbyAlertsParams({
    required this.latitude,
    required this.longitude,
    this.radiusInKm = 5.0, // Default 5km radius
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm];
}
