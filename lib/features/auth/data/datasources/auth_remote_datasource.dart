import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/enums.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Sign in with phone number
  Future<String> signInWithPhoneNumber(String phoneNumber);

  /// Verify OTP
  Future<UserModel> verifyOTP({
    required String verificationId,
    required String smsCode,
  });

  /// Get current Firebase user
  Future<User?> getCurrentFirebaseUser();

  /// Sign out
  Future<void> signOut();

  /// Check if user exists in Firestore
  Future<bool> userExists(String uid);

  /// Create user in Firestore
  Future<UserModel> createUser(UserModel user);

  /// Get user from Firestore
  Future<UserModel> getUserById(String uid);

  /// Update user in Firestore
  Future<UserModel> updateUser(UserModel user);

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  String? _verificationId;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<String> signInWithPhoneNumber(String phoneNumber) async {
    try {
      // Format phone number for Cameroon if needed
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+237$phoneNumber';
      }

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (not used in manual flow)
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthenticationException(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait a bit for verification ID to be set
      await Future.delayed(const Duration(milliseconds: 500));

      if (_verificationId == null) {
        throw const AuthenticationException('Failed to send verification code');
      }

      return _verificationId!;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthenticationException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthenticationException('Sign in failed');
      }

      final uid = userCredential.user!.uid;
      final phoneNumber = userCredential.user!.phoneNumber!;

      // Check if user exists in Firestore
      final exists = await userExists(uid);

      if (exists) {
        // Return existing user
        return await getUserById(uid);
      } else {
        // Create new user
        final newUser = UserModel(
          uid: uid,
          phoneNumber: phoneNumber,
          displayName: phoneNumber,
          preferredLanguage: 'fr', // Default to French for Cameroon
          nationalIdVerified: false,
          alertRadius: 5.0,
          notificationPreferences: const NotificationPreferencesModel(
            pushEnabled: true,
            smsEnabled: true,
            alertLevels: [1, 2, 3, 4, 5],
          ),
          roles: const UserRolesModel(
            isVolunteerResponder: false,
            isSecurityProfessional: false,
            isNGOWorker: false,
          ),
          alertsCreated: 0,
          alertsConfirmed: 0,
          credibilityScore: 50, // Starting credibility
          falseAlertCount: 0,
          verificationLevel: VerificationLevel.newcomer,
          contributionPoints: 0,
          helpOfferedCount: 0,
          resourcesSharedCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        return await createUser(newUser);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Verification failed');
    } catch (e) {
      throw AuthenticationException(e.toString());
    }
  }

  @override
  Future<User?> getCurrentFirebaseUser() async {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthenticationException(e.toString());
    }
  }

  @override
  Future<bool> userExists(String uid) async {
    try {
      final doc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(user.toJson());
      return user;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getUserById(String uid) async {
    try {
      final doc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw const ServerException('User not found');
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final updatedUser = UserModel.fromEntity(user);
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update(updatedUser.toJson());
      return updatedUser;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
}
