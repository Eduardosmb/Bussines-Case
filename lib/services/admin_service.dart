import '../models/user.dart';

class AdminService {
  static Future<bool> hasAdminAccess() async {
    try {
      // Simple admin check - if user email is admin@cloudwalk.com
      return true; // Simplified for now
    } catch (e) {
      return false;
    }
  }
}
