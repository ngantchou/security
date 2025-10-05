import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_phone.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithPhone signInWithPhone;
  final VerifyOTP verifyOTP;
  final GetCurrentUser getCurrentUser;
  final SignOut signOut;
  final AuthRepository authRepository;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this.signInWithPhone,
    required this.verifyOTP,
    required this.getCurrentUser,
    required this.signOut,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<VerifyOTPRequested>(_onVerifyOTPRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<ContinueAsGuest>(_onContinueAsGuest);
    on<UpdateUserProfile>(_onUpdateUserProfile);

    // Listen to auth state changes
    _authStateSubscription = authRepository.authStateChanges.listen((user) {
      add(AuthStateChanged(user));
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await getCurrentUser(NoParams());

    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signInWithPhone(
      SignInWithPhoneParams(phoneNumber: event.phoneNumber),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (verificationId) => emit(PhoneNumberSubmitted(
        verificationId: verificationId,
        phoneNumber: event.phoneNumber,
      )),
    );
  }

  Future<void> _onVerifyOTPRequested(
      VerifyOTPRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await verifyOTP(
      VerifyOTPParams(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signOut(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      // Don't change state if already in guest mode
      if (state is! GuestMode) {
        emit(Unauthenticated());
      }
    }
  }

  void _onContinueAsGuest(ContinueAsGuest event, Emitter<AuthState> emit) {
    emit(GuestMode());
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<AuthState> emit) async {
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;

    // Create updated user entity with new values
    final updatedUser = UserEntity(
      uid: currentUser.uid,
      phoneNumber: currentUser.phoneNumber,
      email: currentUser.email,
      displayName: event.displayName ?? currentUser.displayName,
      bio: event.bio ?? currentUser.bio,
      preferredLanguage: currentUser.preferredLanguage,
      profilePhoto: event.profilePhoto ?? currentUser.profilePhoto,
      nationalIdVerified: currentUser.nationalIdVerified,
      verificationMethod: currentUser.verificationMethod,
      verificationDate: currentUser.verificationDate,
      location: currentUser.location,
      region: event.region ?? currentUser.region,
      city: event.city ?? currentUser.city,
      neighborhood: event.neighborhood ?? currentUser.neighborhood,
      emergencyContacts: currentUser.emergencyContacts,
      alertRadius: currentUser.alertRadius,
      notificationPreferences: currentUser.notificationPreferences,
      roles: currentUser.roles,
      bloodDonor: currentUser.bloodDonor,
      sharedResources: currentUser.sharedResources,
      alertsCreated: currentUser.alertsCreated,
      alertsConfirmed: currentUser.alertsConfirmed,
      credibilityScore: currentUser.credibilityScore,
      falseAlertCount: currentUser.falseAlertCount,
      verificationLevel: currentUser.verificationLevel,
      contributionPoints: currentUser.contributionPoints,
      earnedBadges: currentUser.earnedBadges,
      helpOfferedCount: currentUser.helpOfferedCount,
      resourcesSharedCount: currentUser.resourcesSharedCount,
      followedDangerGroups: currentUser.followedDangerGroups,
      joinedNeighborhoodGroups: currentUser.joinedNeighborhoodGroups,
      createdAt: currentUser.createdAt,
      updatedAt: DateTime.now(),
    );

    // Update in repository
    final result = await authRepository.updateUserProfile(updatedUser);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
