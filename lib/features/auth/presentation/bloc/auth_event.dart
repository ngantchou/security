import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String phoneNumber;

  const SignInRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOTPRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyOTPRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}

class SignOutRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final UserEntity user;

  const UpdateProfileRequested(this.user);

  @override
  List<Object> get props => [user];
}

class UpdateUserProfile extends AuthEvent {
  final String? displayName;
  final String? bio;
  final String? profilePhoto;
  final String? region;
  final String? city;
  final String? neighborhood;

  const UpdateUserProfile({
    this.displayName,
    this.bio,
    this.profilePhoto,
    this.region,
    this.city,
    this.neighborhood,
  });

  @override
  List<Object?> get props => [
        displayName,
        bio,
        profilePhoto,
        region,
        city,
        neighborhood,
      ];
}

class AuthStateChanged extends AuthEvent {
  final UserEntity? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class ContinueAsGuest extends AuthEvent {}
