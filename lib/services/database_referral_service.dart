import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/referral_link.dart';
import '../models/analytics_data.dart';
import 'database_service.dart';

class DatabaseReferralService {
  static final Random _random = Random();
  static const Uuid _uuid = Uuid();

  /// Generate referral link for user
  static Future<ReferralLink> generateReferralLink(User user) async {
    final linkCode = _generateLinkCode();
    final fullUrl = '''Convite CloudWalk 🚀

Olá! Te convido para o programa de recompensas da CloudWalk!

💰 Ganhe R\$25 ao se cadastrar com meu código: $linkCode

📱 Link do app: https://cloudwalk.app
🔑 Código: $linkCode

#CloudWalkRewards #InfinityPay''';

    final link = ReferralLink(
      id: _uuid.v4(),
      userId: user.id,
      userName: user.fullName,
      linkCode: linkCode,
      fullUrl: fullUrl,
      createdAt: DateTime.now(),
    );

    await DatabaseService.createReferralLink(link);
    return link;
  }

  /// Get all referral links
  static Future<List<ReferralLink>> getAllReferralLinks() async {
    return await DatabaseService.getAllReferralLinks();
  }

  /// Get referral links by user
  static Future<List<ReferralLink>> getUserReferralLinks(String userId) async {
    return await DatabaseService.getReferralLinksByUser(userId);
  }

  /// Track link click
  static Future<bool> trackLinkClick(String linkCode, {String? ipAddress, String? userAgent}) async {
    return await DatabaseService.trackReferralClick(linkCode, ipAddress, userAgent);
  }

  /// Track registration completion
  static Future<bool> trackRegistrationCompletion(String linkCode, String email) async {
    return await DatabaseService.trackRegistrationCompletion(linkCode, email);
  }

  /// Get conversion analytics
  static Future<Map<String, dynamic>> getConversionAnalytics() async {
    if (!DatabaseService.isAvailable) {
      return {
        'totalLinks': 0,
        'totalClicks': 0,
        'totalRegistrations': 0,
        'totalDropOffs': 0,
        'overallConversionRate': 0.0,
        'averageClicksPerLink': 0.0,
        'linksWithZeroConversions': 0,
        'recentActivity': 0,
        'topPerformingLinks': <Map<String, dynamic>>[],
      };
    }

    final stats = await DatabaseService.getDatabaseStats();
    final links = await getAllReferralLinks();

    final totalClicks = stats['totalClicks'] as int;
    final totalRegistrations = stats['totalCompletions'] as int;
    final totalDropOffs = totalClicks - totalRegistrations;

    final topPerformingLinks = links
        .where((link) => link.clickCount > 0)
        .map((link) => {
          'referralLinkId': link.id,
          'linkCode': link.linkCode,
          'userName': link.userName,
          'totalClicks': link.clickCount,
          'startedRegistration': link.clickCount,
          'completedRegistration': link.registrationCount,
          'overallConversionRate': link.clickCount > 0 ? link.registrationCount / link.clickCount : 0.0,
          'dropOffAfterClick': link.clickCount - link.registrationCount,
          'dropOffDuringRegistration': 0,
        })
        .toList();

    topPerformingLinks.sort((a, b) => (b['overallConversionRate'] as double).compareTo(a['overallConversionRate'] as double));

    return {
      'totalLinks': links.length,
      'totalClicks': totalClicks,
      'totalRegistrations': totalRegistrations,
      'totalDropOffs': totalDropOffs,
      'overallConversionRate': totalClicks > 0 ? totalRegistrations / totalClicks : 0.0,
      'averageClicksPerLink': links.isNotEmpty ? totalClicks / links.length : 0.0,
      'linksWithZeroConversions': links.where((l) => l.registrationCount == 0).length,
      'recentActivity': totalClicks, // Simplified
      'topPerformingLinks': topPerformingLinks.take(5).toList(),
    };
  }

  /// Get funnel analysis
  static Future<List<Map<String, dynamic>>> getFunnelAnalysis() async {
    if (!DatabaseService.isAvailable) return [];

    final links = await getAllReferralLinks();
    
    return links.map((link) => {
      'referralLinkId': link.id,
      'linkCode': link.linkCode,
      'userName': link.userName,
      'totalClicks': link.clickCount,
      'startedRegistration': link.clickCount,
      'completedRegistration': link.registrationCount,
      'overallConversionRate': link.clickCount > 0 ? link.registrationCount / link.clickCount : 0.0,
      'dropOffAfterClick': link.clickCount - link.registrationCount,
      'dropOffDuringRegistration': 0,
    }).toList();
  }

  /// Generate link code
  static String _generateLinkCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    String code = '';
    
    for (int i = 0; i < 8; i++) {
      code += chars[_random.nextInt(chars.length)];
    }
    
    return code;
  }

  /// Simulate sample referral activity (for testing)
  static Future<void> simulateSampleActivity() async {
    if (!DatabaseService.isAvailable) return;

    print('📈 Simulating referral link activity...');
    
    final links = await getAllReferralLinks();
    
    for (final link in links) {
      final clicks = _random.nextInt(8) + 2; // 2-9 clicks
      
      for (int i = 0; i < clicks; i++) {
        await trackLinkClick(
          link.linkCode,
          ipAddress: '192.168.1.${_random.nextInt(255)}',
          userAgent: 'CloudWalk Mobile App ${_random.nextBool() ? 'Android' : 'iOS'}',
        );
      }
      
      // Some clicks convert to registrations
      final conversions = _random.nextInt(clicks ~/ 2);
      for (int i = 0; i < conversions; i++) {
        await trackRegistrationCompletion(
          link.linkCode,
          'test_${_random.nextInt(1000)}@email.com',
        );
      }
      
      print('  📊 ${link.userName}: $clicks cliques, $conversions conversões');
    }
    
    print('✅ Sample activity simulation complete!');
  }
}
