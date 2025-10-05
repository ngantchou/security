import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class PhoneNumberSubmitted extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const PhoneNumberSubmitted({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileUpdateSuccess extends AuthState {
  final UserEntity user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class GuestMode extends AuthState {}
