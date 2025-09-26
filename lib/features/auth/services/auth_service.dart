import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/string_utils.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(AppConfig.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      throw AuthException('Failed to get user data: ${e.toString()}');
    }
  }

  // Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? referredByCode,
  }) async {
    try {
      // Validate referral code if provided
      if (referredByCode != null && referredByCode.isNotEmpty) {
        final isValidReferral = await _validateReferralCode(referredByCode);
        if (!isValidReferral) {
          throw AuthException('Invalid referral code');
        }
      }

      // Create user account
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Failed to create user account');
      }

      // Generate unique referral code
      final referralCode = await _generateUniqueReferralCode();

      // Create user data
      final userData = UserModel(
        id: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        referralCode: referralCode,
        referredByCode: referredByCode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: user.emailVerified,
        stats: UserStats(),
      );

      // Save user data to Firestore
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(user.uid)
          .set(userData.toJson());

      // Send email verification
      await user.sendEmailVerification();

      // Process referral if applicable
      if (referredByCode != null && referredByCode.isNotEmpty) {
        await _processReferral(referredByCode, user.uid);
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Failed to sign in');
      }

      // Get user data from Firestore
      final userData = await getCurrentUserData();
      if (userData == null) {
        throw AuthException('User data not found');
      }

      // Update last login time
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(user.uid)
          .update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return userData;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _secureStorage.deleteAll();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException('No user signed in');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw AuthException('Failed to send verification email: ${e.toString()}');
    }
  }

  // Reload user and check email verification
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      throw AuthException('Failed to reload user: ${e.toString()}');
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException('No user signed in');
      }

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(user.uid)
          .update(updateData);

      final updatedUser = await getCurrentUserData();
      if (updatedUser == null) {
        throw AuthException('Failed to get updated user data');
      }

      return updatedUser;
    } catch (e) {
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  // Generate unique referral code
  Future<String> _generateUniqueReferralCode() async {
    String code;
    bool isUnique = false;

    do {
      code = StringUtils.generateReferralCode(AppConfig.referralCodeLength);
      
      final existingUser = await _firestore
          .collection(AppConfig.usersCollection)
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();

      isUnique = existingUser.docs.isEmpty;
    } while (!isUnique);

    return code;
  }

  // Validate referral code
  Future<bool> _validateReferralCode(String code) async {
    try {
      final result = await _firestore
          .collection(AppConfig.usersCollection)
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Process referral
  Future<void> _processReferral(String referralCode, String newUserId) async {
    try {
      // Find referrer
      final referrerQuery = await _firestore
          .collection(AppConfig.usersCollection)
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (referrerQuery.docs.isEmpty) return;

      final referrerId = referrerQuery.docs.first.id;

      // Create referral record
      await _firestore.collection(AppConfig.referralsCollection).add({
        'referrerId': referrerId,
        'referredUserId': newUserId,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'rewardAmount': AppConfig.referralReward,
      });

      // Update referrer stats
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(referrerId)
          .update({
        'stats.totalReferrals': FieldValue.increment(1),
        'stats.lastReferralDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // Log error but don't fail registration
      print('Failed to process referral: $e');
    }
  }

  // Get auth error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
