import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: user?.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user!.profileImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Name
                  Text(
                    user?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Email
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Profile Actions
            _buildProfileSection(
              context,
              'Account',
              [
                _buildProfileItem(
                  context,
                  'Personal Information',
                  'Update your name, email, and phone',
                  Icons.person_outline,
                  () {
                    // TODO: Navigate to edit profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile feature coming soon!')),
                    );
                  },
                ),
                _buildProfileItem(
                  context,
                  'Email Verification',
                  user?.isEmailVerified == true ? 'Verified' : 'Not verified',
                  Icons.email_outlined,
                  user?.isEmailVerified == true 
                      ? null 
                      : () => context.push(AppRoutes.emailVerification),
                  trailing: user?.isEmailVerified == true 
                      ? const Icon(Icons.check_circle, color: AppTheme.successColor)
                      : const Icon(Icons.warning, color: AppTheme.warningColor),
                ),
                _buildProfileItem(
                  context,
                  'Change Password',
                  'Update your account password',
                  Icons.lock_outline,
                  () {
                    // TODO: Navigate to change password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change password feature coming soon!')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildProfileSection(
              context,
              'Referral',
              [
                _buildProfileItem(
                  context,
                  'My Referral Code',
                  user?.referralCode ?? 'Loading...',
                  Icons.qr_code,
                  () {
                    // TODO: Show QR code
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR code feature coming soon!')),
                    );
                  },
                ),
                _buildProfileItem(
                  context,
                  'Referral History',
                  'View all your referrals',
                  Icons.history,
                  () => context.push(AppRoutes.referrals),
                ),
                _buildProfileItem(
                  context,
                  'Earnings',
                  '\$${user?.stats.totalEarnings.toStringAsFixed(2) ?? '0.00'}',
                  Icons.attach_money,
                  () => context.push(AppRoutes.rewards),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildProfileSection(
              context,
              'Settings',
              [
                _buildProfileItem(
                  context,
                  'Notifications',
                  'Manage your notification preferences',
                  Icons.notifications_outline,
                  () {
                    // TODO: Navigate to notifications settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification settings coming soon!')),
                    );
                  },
                ),
                _buildProfileItem(
                  context,
                  'Privacy',
                  'Privacy settings and data control',
                  Icons.privacy_tip_outline,
                  () {
                    // TODO: Navigate to privacy settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy settings coming soon!')),
                    );
                  },
                ),
                _buildProfileItem(
                  context,
                  'Help & Support',
                  'Get help and contact support',
                  Icons.help_outline,
                  () {
                    // TODO: Navigate to help
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & support coming soon!')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final shouldSignOut = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldSignOut == true) {
                    await ref.read(authStateProvider.notifier).signOut();
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? (onTap != null 
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null),
        onTap: onTap,
      ),
    );
  }
}
