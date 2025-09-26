import 'user_model.dart';

// Simple enum for auth status
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Simplified AuthState without freezed
class SimpleAuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const SimpleAuthState({
    required this.status,
    this.user,
    this.error,
  });

  factory SimpleAuthState.initial() {
    return const SimpleAuthState(status: AuthStatus.initial);
  }

  factory SimpleAuthState.loading() {
    return const SimpleAuthState(status: AuthStatus.loading);
  }

  factory SimpleAuthState.authenticated(UserModel user) {
    return SimpleAuthState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  factory SimpleAuthState.unauthenticated() {
    return const SimpleAuthState(status: AuthStatus.unauthenticated);
  }

  factory SimpleAuthState.error(String message) {
    return SimpleAuthState(
      status: AuthStatus.error,
      error: message,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  SimpleAuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return SimpleAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SimpleAuthState &&
        other.status == status &&
        other.user == user &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(status, user, error);

  @override
  String toString() {
    return 'SimpleAuthState(status: $status, user: $user, error: $error)';
  }
}
