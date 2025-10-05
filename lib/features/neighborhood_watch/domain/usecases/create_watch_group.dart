import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/watch_group_entity.dart';
import '../repositories/watch_group_repository.dart';

class CreateWatchGroup implements UseCase<WatchGroupEntity, CreateWatchGroupParams> {
  final WatchGroupRepository repository;

  CreateWatchGroup(this.repository);

  @override
  Future<Either<Failure, WatchGroupEntity>> call(CreateWatchGroupParams params) async {
    return await repository.createGroup(
      name: params.name,
      description: params.description,
      region: params.region,
      city: params.city,
      neighborhood: params.neighborhood,
      coordinatorId: params.coordinatorId,
      coordinatorName: params.coordinatorName,
      coordinatorPhoto: params.coordinatorPhoto,
      coordinatorPhone: params.coordinatorPhone,
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
      isPrivate: params.isPrivate,
      requireApproval: params.requireApproval,
      maxMembers: params.maxMembers,
    );
  }
}

class CreateWatchGroupParams {
  final String name;
  final String description;
  final String region;
  final String city;
  final String neighborhood;
  final String coordinatorId;
  final String coordinatorName;
  final String? coordinatorPhoto;
  final String? coordinatorPhone;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final bool isPrivate;
  final bool requireApproval;
  final int maxMembers;

  CreateWatchGroupParams({
    required this.name,
    required this.description,
    required this.region,
    required this.city,
    required this.neighborhood,
    required this.coordinatorId,
    required this.coordinatorName,
    this.coordinatorPhoto,
    this.coordinatorPhone,
    required this.latitude,
    required this.longitude,
    this.radiusKm = 2.0,
    this.isPrivate = false,
    this.requireApproval = true,
    this.maxMembers = 100,
  });
}
