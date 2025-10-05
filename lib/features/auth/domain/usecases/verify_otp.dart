import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOTP implements UseCase<UserEntity, VerifyOTPParams> {
  final AuthRepository repository;

  VerifyOTP(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(VerifyOTPParams params) async {
    return await repository.verifyOTP(
      verificationId: params.verificationId,
      smsCode: params.smsCode,
    );
  }
}

class VerifyOTPParams extends Equatable {
  final String verificationId;
  final String smsCode;

  const VerifyOTPParams({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}
