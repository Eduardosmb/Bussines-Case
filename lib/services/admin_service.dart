import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/referral_link.dart';
import '../models/user.dart';

class AdminService {
  static const String _adminsKey = 'admin_users';
  static const String _currentAdminKey = 'current_admin';
  
  // Admin users by email (in production, this would be more secure)
  static const List<String> adminEmails = ['test@cloudwalk.com'];
  
  // Initialize default admin user (deprecated - now admin is based on user email)
  static Future<void> initializeDefaultAdmin() async {
    // No longer needed since admin is determined by user email
    // This function is kept for backward compatibility
  }
  
  // Admin login (deprecated - now admin is based on user email)
  static Future<AdminUser?> adminLogin(String email, String password) async {
    // This function is deprecated since admin is now determined by user email
    // Kept for backward compatibility
    return null;
  }
  
  // Get current logged-in admin
  static Future<AdminUser?> getCurrentAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final adminJson = prefs.getString(_currentAdminKey);
    
    if (adminJson == null) return null;
    
    try {
      return AdminUser.fromJson(jsonDecode(adminJson));
    } catch (e) {
      return null;
    }
  }
  
  // Check if user has admin access based on email
  static Future<bool> hasAdminAccess() async {
    // Import AuthService to check current user email
    final prefs = await SharedPreferences.getInstance();
    final currentUserJson = prefs.getString('current_user');

    if (currentUserJson != null) {
      try {
        final userData = jsonDecode(currentUserJson);
        final userEmail = userData['email'] as String?;
        return adminEmails.contains(userEmail);
      } catch (e) {
        return false;
      }
    }
    return false;
  }
  
  // Check specific permission
  static Future<bool> hasPermission(String permission) async {
    // For now, if user is admin, they have all permissions
    return await hasAdminAccess();
  }
  
  // Admin logout
  static Future<void> adminLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentAdminKey);
  }
  
  // Create new admin (superAdmin only)
  static Future<bool> createAdmin({
    required String email,
    required String name,
    required AdminRole role,
    required List<String> permissions,
    required String password,
  }) async {
    final currentAdmin = await getCurrentAdmin();
    if (currentAdmin?.role != AdminRole.superAdmin) {
      return false; // Only super admin can create admins
    }
    
    final newAdmin = AdminUser(
      id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      permissions: permissions,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    
    await _saveAdmin(newAdmin, password);
    return true;
  }
  
  // Get admin analytics dashboard data
  static Future<Map<String, dynamic>> getAdminDashboardData() async {
    final admin = await getCurrentAdmin();
    if (admin == null || !admin.hasPermission('view_analytics')) {
      throw Exception('Unauthorized access');
    }
    
    // This would integrate with your analytics services
    return {
      'totalUsers': 10, // From user service
      'totalAdmins': (await _getAllAdmins()).length,
      'systemStatus': 'healthy',
      'lastDataUpdate': DateTime.now().toIso8601String(),
      'activeFeatures': [
        'Referral Links',
        'AI Analytics',
        'User Management',
        'Performance Tracking',
      ],
    };
  }
  
  // Private helper methods
  
  static Future<void> _saveAdmin(AdminUser admin, String password) async {
    final admins = await _getAllAdmins();
    
    // Remove existing admin with same email
    admins.removeWhere((a) => a.email == admin.email);
    admins.add(admin);
    
    final prefs = await SharedPreferences.getInstance();
    final adminsData = {
      'admins': admins.map((a) => a.toJson()).toList(),
      'passwords': {admin.email: password}, // In production, hash this!
    };
    
    await prefs.setString(_adminsKey, jsonEncode(adminsData));
  }
  
  static Future<void> _updateAdmin(AdminUser admin) async {
    final admins = await _getAllAdmins();
    final index = admins.indexWhere((a) => a.id == admin.id);
    
    if (index != -1) {
      admins[index] = admin;
      
      final prefs = await SharedPreferences.getInstance();
      final currentData = prefs.getString(_adminsKey);
      Map<String, dynamic> adminsData;
      
      if (currentData != null) {
        adminsData = jsonDecode(currentData);
        adminsData['admins'] = admins.map((a) => a.toJson()).toList();
      } else {
        adminsData = {
          'admins': admins.map((a) => a.toJson()).toList(),
          'passwords': {},
        };
      }
      
      await prefs.setString(_adminsKey, jsonEncode(adminsData));
    }
  }
  
  static Future<List<AdminUser>> _getAllAdmins() async {
    final prefs = await SharedPreferences.getInstance();
    final adminsJson = prefs.getString(_adminsKey);
    
    if (adminsJson == null) return [];
    
    try {
      final adminsData = jsonDecode(adminsJson);
      final List<dynamic> adminsList = adminsData['admins'] ?? [];
      return adminsList.map((json) => AdminUser.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> _setCurrentAdmin(AdminUser admin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentAdminKey, jsonEncode(admin.toJson()));
  }
}

