import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure([super.message = 'Invalid input provided']);
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure([super.message = 'Location permission denied']);
}

class MicrophonePermissionFailure extends Failure {
  const MicrophonePermissionFailure([super.message = 'Microphone permission denied']);
}

class CameraPermissionFailure extends Failure {
  const CameraPermissionFailure([super.message = 'Camera permission denied']);
}

// Firebase failures
class FirebaseFailure extends Failure {
  const FirebaseFailure([super.message = 'Firebase error occurred']);
}

class FirestoreFailure extends Failure {
  const FirestoreFailure([super.message = 'Firestore error occurred']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error occurred']);
}

// Alert specific failures
class AlertCreationFailure extends Failure {
  const AlertCreationFailure([super.message = 'Failed to create alert']);
}

class AlertNotFoundFailure extends Failure {
  const AlertNotFoundFailure([super.message = 'Alert not found']);
}

class CredibilityTooLowFailure extends Failure {
  const CredibilityTooLowFailure([super.message = 'Credibility score too low to create alerts']);
}

class SuspendedUserFailure extends Failure {
  const SuspendedUserFailure([super.message = 'User account is suspended']);
}

// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Payment failed']);
}

class InsufficientFundsFailure extends Failure {
  const InsufficientFundsFailure([super.message = 'Insufficient funds']);
}

// General
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
