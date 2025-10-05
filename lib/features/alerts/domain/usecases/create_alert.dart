import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class CreateAlert implements UseCase<AlertEntity, CreateAlertParams> {
  final AlertRepository repository;

  CreateAlert(this.repository);

  @override
  Future<Either<Failure, AlertEntity>> call(CreateAlertParams params) async {
    return await repository.createAlert(
      creatorId: params.creatorId,
      creatorName: params.creatorName,
      latitude: params.latitude,
      longitude: params.longitude,
      dangerType: params.dangerType,
      level: params.level,
      title: params.title,
      description: params.description,
      audioCommentUrl: params.audioCommentUrl,
      images: params.images,
      region: params.region,
      city: params.city,
      neighborhood: params.neighborhood,
      address: params.address,
    );
  }
}

class CreateAlertParams extends Equatable {
  final String creatorId;
  final String creatorName;
  final double latitude;
  final double longitude;
  final String dangerType;
  final int level;
  final String title;
  final String description;
  final String? audioCommentUrl;
  final List<String>? images;
  final String region;
  final String city;
  final String neighborhood;
  final String? address;

  const CreateAlertParams({
    required this.creatorId,
    required this.creatorName,
    required this.latitude,
    required this.longitude,
    required this.dangerType,
    required this.level,
    required this.title,
    required this.description,
    this.audioCommentUrl,
    this.images,
    required this.region,
    required this.city,
    required this.neighborhood,
    this.address,
  });

  @override
  List<Object?> get props => [
        creatorId,
        creatorName,
        latitude,
        longitude,
        dangerType,
        level,
        title,
        description,
        audioCommentUrl,
        images,
        region,
        city,
        neighborhood,
        address,
      ];
}
