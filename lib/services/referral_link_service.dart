import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/referral_link.dart';
import '../models/user.dart';

class ReferralLinkService {
  static const String _linksKey = 'referral_links';
  static const String _clicksKey = 'referral_clicks';
  
  // Generate a unique referral link for a user
  static Future<ReferralLink> generateReferralLink(User user) async {
    final linkCode = _generateLinkCode();
    // Create a copyable referral message instead of just a URL
    final fullUrl = 'Convite CloudWalk 🚀\n\n'
        'Olá! Te convido para o programa de recompensas da CloudWalk!\n\n'
        '💰 Ganhe R\$25 ao se cadastrar com meu código: $linkCode\n\n'
        '📱 Link do app: https://cloudwalk.app\n'
        '🔑 Código: $linkCode\n\n'
        '#CloudWalkRewards #InfinityPay';
    
    final link = ReferralLink(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      userName: user.fullName,
      linkCode: linkCode,
      fullUrl: fullUrl,
      createdAt: DateTime.now(),
    );
    
    await _saveReferralLink(link);
    return link;
  }
  
  // Track when someone clicks a referral link
  static Future<void> trackLinkClick(String linkCode, {String? ipAddress, String? userAgent}) async {
    final links = await getAllReferralLinks();
    final link = links.firstWhere(
      (l) => l.linkCode == linkCode,
      orElse: () => throw Exception('Referral link not found'),
    );
    
    final click = ReferralClick(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
    );
    
    final updatedClicks = [...link.clicks, click];
    final updatedLink = link.copyWith(
      clicks: updatedClicks,
      clickCount: link.clickCount + 1,
    );
    
    await _updateReferralLink(updatedLink);
  }
  
  // Track when someone completes registration from a referral link
  static Future<void> trackRegistrationCompletion(String linkCode, String registeredEmail) async {
    final links = await getAllReferralLinks();
    final linkIndex = links.indexWhere((l) => l.linkCode == linkCode);
    
    if (linkIndex == -1) return; // Link not found
    
    final link = links[linkIndex];
    final updatedCompletions = [...link.completedRegistrations, registeredEmail];
    
    // Update the most recent click to mark as completed
    final updatedClicks = link.clicks.map((click) {
      if (!click.completedRegistration && 
          DateTime.now().difference(click.timestamp).inHours < 24) {
        return ReferralClick(
          id: click.id,
          timestamp: click.timestamp,
          ipAddress: click.ipAddress,
          userAgent: click.userAgent,
          completedRegistration: true,
          registeredEmail: registeredEmail,
        );
      }
      return click;
    }).toList();
    
    final updatedLink = link.copyWith(
      clicks: updatedClicks,
      completedRegistrations: updatedCompletions,
      registrationCount: link.registrationCount + 1,
    );
    
    await _updateReferralLink(updatedLink);
  }
  
  // Get referral link by code
  static Future<ReferralLink?> getReferralLinkByCode(String linkCode) async {
    try {
      final links = await getAllReferralLinks();
      return links.firstWhere((l) => l.linkCode == linkCode);
    } catch (e) {
      return null;
    }
  }
  
  // Get all referral links for a user
  static Future<List<ReferralLink>> getUserReferralLinks(String userId) async {
    final links = await getAllReferralLinks();
    return links.where((l) => l.userId == userId).toList();
  }
  
  // Get conversion analytics for admin
  static Future<Map<String, dynamic>> getConversionAnalytics() async {
    final links = await getAllReferralLinks();
    
    final totalClicks = links.fold(0, (sum, link) => sum + link.clickCount);
    final totalRegistrations = links.fold(0, (sum, link) => sum + link.registrationCount);
    final overallConversionRate = totalClicks > 0 ? totalRegistrations / totalClicks : 0.0;
    
    // Calculate drop-off points
    final dropOffAnalysis = <String, int>{};
    int totalDropOffs = 0;
    
    for (final link in links) {
      final abandoned = link.abandonedUsers;
      totalDropOffs += abandoned;
    }
    
    // Top performing links
    final topLinks = [...links];
    topLinks.sort((a, b) => b.conversionRate.compareTo(a.conversionRate));
    
    // Recent activity (last 7 days)
    final recentClicks = links
        .expand((link) => link.clicks)
        .where((click) => DateTime.now().difference(click.timestamp).inDays <= 7)
        .length;
    
    return {
      'totalLinks': links.length,
      'totalClicks': totalClicks,
      'totalRegistrations': totalRegistrations,
      'overallConversionRate': overallConversionRate,
      'totalDropOffs': totalDropOffs,
      'topPerformingLinks': topLinks.take(5).toList(),
      'recentActivity': recentClicks,
      'averageClicksPerLink': links.isNotEmpty ? totalClicks / links.length : 0,
      'linksWithZeroConversions': links.where((l) => l.registrationCount == 0).length,
    };
  }
  
  // Get funnel analysis
  static Future<List<ConversionFunnel>> getFunnelAnalysis() async {
    final links = await getAllReferralLinks();
    
    return links.map((link) {
      // Simulate registration starts (in real app, you'd track this)
      final estimatedStarts = (link.clickCount * 0.7).round(); // 70% start registration
      
      return ConversionFunnel(
        referralLinkId: link.id,
        totalClicks: link.clickCount,
        startedRegistration: estimatedStarts,
        completedRegistration: link.registrationCount,
        analysisDate: DateTime.now(),
      );
    }).toList();
  }
  
  // Private helper methods
  
  static String _generateLinkCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
  
  static Future<void> _saveReferralLink(ReferralLink link) async {
    final links = await getAllReferralLinks();
    links.add(link);
    await _saveAllReferralLinks(links);
  }
  
  static Future<void> _updateReferralLink(ReferralLink updatedLink) async {
    final links = await getAllReferralLinks();
    final index = links.indexWhere((l) => l.id == updatedLink.id);
    if (index != -1) {
      links[index] = updatedLink;
      await _saveAllReferralLinks(links);
    }
  }
  
  static Future<List<ReferralLink>> getAllReferralLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final linksJson = prefs.getString(_linksKey);
    
    if (linksJson == null) return [];
    
    final List<dynamic> linksList = jsonDecode(linksJson);
    return linksList.map((json) => ReferralLink.fromJson(json)).toList();
  }
  
  static Future<void> _saveAllReferralLinks(List<ReferralLink> links) async {
    final prefs = await SharedPreferences.getInstance();
    final linksJson = jsonEncode(links.map((l) => l.toJson()).toList());
    await prefs.setString(_linksKey, linksJson);
  }
  
  // Simulate link clicks for testing
  static Future<void> simulateLinkActivity() async {
    final links = await getAllReferralLinks();
    final random = Random();
    
    for (int i = 0; i < links.length; i++) {
      final link = links[i];
      final clicksToAdd = random.nextInt(10) + 1; // 1-10 clicks
      final completions = (clicksToAdd * random.nextDouble() * 0.4).round(); // 0-40% conversion
      
      final newClicks = <ReferralClick>[];
      
      for (int j = 0; j < clicksToAdd; j++) {
        final isCompleted = j < completions;
        final click = ReferralClick(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i$j',
          timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(168))), // Last week
          ipAddress: '192.168.1.${random.nextInt(255)}',
          userAgent: 'Mozilla/5.0 (Mobile)',
          completedRegistration: isCompleted,
          registeredEmail: isCompleted ? 'user$i$j@example.com' : null,
        );
        newClicks.add(click);
      }
      
      final updatedLink = link.copyWith(
        clicks: [...link.clicks, ...newClicks],
        clickCount: link.clickCount + clicksToAdd,
        registrationCount: link.registrationCount + completions,
        completedRegistrations: [
          ...link.completedRegistrations,
          ...newClicks
              .where((c) => c.completedRegistration)
              .map((c) => c.registeredEmail!)
              .toList(),
        ],
      );
      
      await _updateReferralLink(updatedLink);
    }
  }
}
