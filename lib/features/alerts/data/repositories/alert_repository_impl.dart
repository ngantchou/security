import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_datasource.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AlertRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AlertEntity>> createAlert({
    required String creatorId,
    required String creatorName,
    required double latitude,
    required double longitude,
    required String dangerType,
    required int level,
    required String title,
    required String description,
    String? audioCommentUrl,
    List<String>? images,
    required String region,
    required String city,
    required String neighborhood,
    String? address,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final alert = await remoteDataSource.createAlert(
        creatorId: creatorId,
        creatorName: creatorName,
        latitude: latitude,
        longitude: longitude,
        dangerType: dangerType,
        level: level,
        title: title,
        description: description,
        audioCommentUrl: audioCommentUrl,
        images: images,
        region: region,
        city: city,
        neighborhood: neighborhood,
        address: address,
      );

      return Right(alert);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AlertEntity>>> getNearbyAlerts({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final alerts = await remoteDataSource.getNearbyAlerts(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
      );

      return Right(alerts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AlertEntity>> getAlertById(String alertId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final alert = await remoteDataSource.getAlertById(alertId);
      return Right(alert);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AlertEntity>>> getAlertsByDangerType(
    String dangerType,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final alerts = await remoteDataSource.getAlertsByDangerType(dangerType);
      return Right(alerts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AlertEntity>>> getUserAlerts(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final alerts = await remoteDataSource.getUserAlerts(userId);
      return Right(alerts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAlertStatus({
    required String alertId,
    required String status,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.updateAlertStatus(
        alertId: alertId,
        status: status,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmAlert({
    required String alertId,
    required String userId,
    required String userName,
    String? comment,
    String? audioCommentUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.confirmAlert(
        alertId: alertId,
        userId: userId,
        userName: userName,
        comment: comment,
        audioCommentUrl: audioCommentUrl,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String alertId) async {
    try {
      await remoteDataSource.incrementViewCount(alertId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementHelpOffered(String alertId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.incrementHelpOffered(alertId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> offerHelp({
    required String alertId,
    required String userId,
    required String userName,
    required String helpType,
    String? description,
    String? phoneNumber,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.offerHelp(
        alertId: alertId,
        userId: userId,
        userName: userName,
        helpType: helpType,
        description: description,
        phoneNumber: phoneNumber,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsResolved({
    required String alertId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.markAsResolved(
        alertId: alertId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reportFalseAlarm({
    required String alertId,
    required String userId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.reportFalseAlarm(
        alertId: alertId,
        userId: userId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlert(String alertId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.deleteAlert(alertId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<AlertEntity>>> watchNearbyAlerts({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) {
    try {
      return remoteDataSource
          .watchNearbyAlerts(
            latitude: latitude,
            longitude: longitude,
            radiusInKm: radiusInKm,
          )
          .map((alerts) => Right<Failure, List<AlertEntity>>(alerts))
          .handleError((error) {
        if (error is ServerException) {
          return Left<Failure, List<AlertEntity>>(ServerFailure(error.message));
        }
        return Left<Failure, List<AlertEntity>>(
            ServerFailure('An unexpected error occurred: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(ServerFailure('Failed to watch nearby alerts: $e')));
    }
  }

  @override
  Stream<Either<Failure, AlertEntity>> watchAlert(String alertId) {
    try {
      return remoteDataSource
          .watchAlert(alertId)
          .map((alert) => Right<Failure, AlertEntity>(alert))
          .handleError((error) {
        if (error is ServerException) {
          return Left<Failure, AlertEntity>(ServerFailure(error.message));
        }
        return Left<Failure, AlertEntity>(
            ServerFailure('An unexpected error occurred: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to watch alert: $e')));
    }
  }
}
