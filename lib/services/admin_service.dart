import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/referral_link.dart';

class AdminService {
  static const String _adminsKey = 'admin_users';
  static const String _currentAdminKey = 'current_admin';
  
  // Default admin credentials (in production, this would be more secure)
  static const String defaultAdminEmail = 'admin@cloudwalk.com';
  static const String defaultAdminPassword = 'cloudwalk123';
  
  // Initialize default admin user
  static Future<void> initializeDefaultAdmin() async {
    final admins = await _getAllAdmins();
    
    // Check if default admin already exists
    final adminExists = admins.any((admin) => admin.email == defaultAdminEmail);
    
    if (!adminExists) {
      final defaultAdmin = AdminUser(
        id: 'admin_001',
        email: defaultAdminEmail,
        name: 'CloudWalk Administrator',
        role: AdminRole.superAdmin,
        permissions: [
          'view_analytics',
          'manage_users',
          'export_data',
          'system_settings',
          'ai_agent_access',
        ],
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      await _saveAdmin(defaultAdmin, defaultAdminPassword);
    }
  }
  
  // Admin login
  static Future<AdminUser?> adminLogin(String email, String password) async {
    // Simple authentication (in production, use proper hashing)
    if (email == defaultAdminEmail && password == defaultAdminPassword) {
      final admins = await _getAllAdmins();
      final admin = admins.firstWhere(
        (a) => a.email == email,
        orElse: () => throw Exception('Admin not found'),
      );
      
      // Update last login
      final updatedAdmin = AdminUser(
        id: admin.id,
        email: admin.email,
        name: admin.name,
        role: admin.role,
        permissions: admin.permissions,
        createdAt: admin.createdAt,
        lastLogin: DateTime.now(),
      );
      
      await _updateAdmin(updatedAdmin);
      await _setCurrentAdmin(updatedAdmin);
      
      return updatedAdmin;
    }
    
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
  
  // Check if user has admin access
  static Future<bool> hasAdminAccess() async {
    final admin = await getCurrentAdmin();
    return admin != null;
  }
  
  // Check specific permission
  static Future<bool> hasPermission(String permission) async {
    final admin = await getCurrentAdmin();
    return admin?.hasPermission(permission) ?? false;
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

