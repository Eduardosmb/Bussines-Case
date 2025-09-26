import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase Auth Stream Provider
final firebaseAuthStreamProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  
  await for (final user in authService.authStateChanges) {
    if (user == null) {
      yield null;
    } else {
      try {
        final userData = await authService.getCurrentUserData();
        yield userData;
      } catch (e) {
        yield null;
      }
    }
  }
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, SimpleAuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService, ref);
});

class AuthStateNotifier extends StateNotifier<SimpleAuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthStateNotifier(this._authService, this._ref) : super(SimpleAuthState.initial()) {
    _initializeAuthState();
  }

  // Initialize auth state by listening to Firebase auth changes
  void _initializeAuthState() {
    _authService.authStateChanges.listen((user) async {
      if (user == null) {
        state = SimpleAuthState.unauthenticated();
      } else {
        try {
          final userData = await _authService.getCurrentUserData();
          if (userData != null) {
            state = SimpleAuthState.authenticated(userData);
          } else {
            state = SimpleAuthState.unauthenticated();
          }
        } catch (e) {
          state = SimpleAuthState.error('Failed to load user data');
        }
      }
    });
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? referralCode,
  }) async {
    state = SimpleAuthState.loading();
    
    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        referredByCode: referralCode,
      );
      
      state = SimpleAuthState.authenticated(user);
    } on AuthException catch (e) {
      state = SimpleAuthState.error(e.message);
    } catch (e) {
      state = SimpleAuthState.error('An unexpected error occurred');
    }
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = SimpleAuthState.loading();
    
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      state = SimpleAuthState.authenticated(user);
    } on AuthException catch (e) {
      state = SimpleAuthState.error(e.message);
    } catch (e) {
      state = SimpleAuthState.error('An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = SimpleAuthState.unauthenticated();
    } catch (e) {
      state = SimpleAuthState.error('Failed to sign out');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      state = SimpleAuthState.error(e.message);
      rethrow;
    } catch (e) {
      state = SimpleAuthState.error('Failed to send reset email');
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } on AuthException catch (e) {
      state = SimpleAuthState.error(e.message);
      rethrow;
    } catch (e) {
      state = SimpleAuthState.error('Failed to send verification email');
      rethrow;
    }
  }

  // Reload user data
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      final userData = await _authService.getCurrentUserData();
      if (userData != null) {
        state = SimpleAuthState.authenticated(userData);
      }
    } catch (e) {
      // Don't change state on reload failure
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (!state.isAuthenticated) return;

    try {
      final updatedUser = await _authService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );
      
      state = SimpleAuthState.authenticated(updatedUser);
    } on AuthException catch (e) {
      state = SimpleAuthState.error(e.message);
      rethrow;
    } catch (e) {
      state = SimpleAuthState.error('Failed to update profile');
      rethrow;
    }
  }

  // Clear error state
  void clearError() {
    if (state.hasError) {
      state = SimpleAuthState.unauthenticated();
    }
  }
}

// Form validation providers
final emailValidationProvider = StateProvider<String?>((ref) => null);
final passwordValidationProvider = StateProvider<String?>((ref) => null);
final confirmPasswordValidationProvider = StateProvider<String?>((ref) => null);

// Loading states for individual operations
final signUpLoadingProvider = StateProvider<bool>((ref) => false);
final signInLoadingProvider = StateProvider<bool>((ref) => false);
final passwordResetLoadingProvider = StateProvider<bool>((ref) => false);

// Password visibility providers
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => false);
