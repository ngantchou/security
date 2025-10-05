import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Get current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Sign in with phone number
  Future<Either<Failure, String>> signInWithPhoneNumber(String phoneNumber);

  /// Verify OTP code
  Future<Either<Failure, UserEntity>> verifyOTP({
    required String verificationId,
    required String smsCode,
  });

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user);

  /// Check if user exists in Firestore
  Future<Either<Failure, bool>> userExists(String uid);

  /// Create user profile in Firestore
  Future<Either<Failure, UserEntity>> createUserProfile(UserEntity user);

  /// Get user by ID
  Future<Either<Failure, UserEntity>> getUserById(String uid);

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;
}
