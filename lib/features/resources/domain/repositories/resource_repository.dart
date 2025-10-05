import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/resource_entity.dart';

abstract class ResourceRepository {
  Future<Either<Failure, ResourceEntity>> offerResource({
    required String ownerId,
    required String ownerName,
    String? ownerPhone,
    required ResourceType type,
    required String name,
    required String description,
    required String region,
    required String city,
    required String neighborhood,
    required double latitude,
    required double longitude,
    required DateTime availableFrom,
    DateTime? availableUntil,
    int quantity,
    String? conditions,
  });

  Future<Either<Failure, List<ResourceEntity>>> getNearbyResources({
    required double latitude,
    required double longitude,
    required double radiusKm,
    ResourceType? type,
  });

  Future<Either<Failure, ResourceRequestEntity>> requestResource({
    required String resourceId,
    required String requesterId,
    required String requesterName,
    String? requesterPhone,
    required String message,
  });

  Future<Either<Failure, void>> respondToRequest({
    required String requestId,
    required bool approved,
  });
}
