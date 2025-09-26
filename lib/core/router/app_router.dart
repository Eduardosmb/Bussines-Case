import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/referrals/screens/referrals_screen.dart';
import '../../features/rewards/screens/rewards_screen.dart';
import '../screens/splash_screen.dart';

// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String referrals = '/referrals';
  static const String rewards = '/rewards';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final currentPath = state.location;

      // Show splash screen while loading
      if (isLoading && currentPath != AppRoutes.splash) {
        return AppRoutes.splash;
      }

      // Redirect to home if authenticated and on auth pages
      if (isAuthenticated) {
        final authPages = [
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.forgotPassword,
          AppRoutes.splash,
        ];
        
        if (authPages.contains(currentPath)) {
          // Check if email is verified
          final user = authState.user;
          if (user != null && !user.isEmailVerified) {
            return AppRoutes.emailVerification;
          }
          return AppRoutes.home;
        }
      }

      // Redirect to login if not authenticated and on protected pages
      if (!isAuthenticated && !isLoading) {
        final protectedPages = [
          AppRoutes.home,
          AppRoutes.profile,
          AppRoutes.referrals,
          AppRoutes.rewards,
          AppRoutes.emailVerification,
        ];
        
        if (protectedPages.contains(currentPath)) {
          return AppRoutes.login;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        name: 'email-verification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.referrals,
        name: 'referrals',
        builder: (context, state) => const ReferralsScreen(),
      ),
      GoRoute(
        path: AppRoutes.rewards,
        name: 'rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Navigation extension for easier navigation
extension AppNavigation on BuildContext {
  void pushLogin() => go(AppRoutes.login);
  void pushRegister() => go(AppRoutes.register);
  void pushForgotPassword() => go(AppRoutes.forgotPassword);
  void pushEmailVerification() => go(AppRoutes.emailVerification);
  void pushHome() => go(AppRoutes.home);
  void pushProfile() => go(AppRoutes.profile);
  void pushReferrals() => go(AppRoutes.referrals);
  void pushRewards() => go(AppRoutes.rewards);
}
