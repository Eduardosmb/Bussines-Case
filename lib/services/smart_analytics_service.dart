import 'dart:math';
import 'supabase_service.dart';

/// Smart Analytics Service - Analyzes REAL data intelligently
/// No fake data - only sophisticated analysis of existing user data
class SmartAnalyticsService {
  
  /// Get advanced analytics by analyzing real user behavior patterns
  static Future<Map<String, dynamic>> getIntelligentAnalytics() async {
    try {
      // Get ALL real users from database
      final client = SupabaseService.client;
      final allUsers = await client
          .from('users')
          .select('id, email, first_name, last_name, total_referrals, total_earnings, created_at, is_admin')
          .order('created_at', ascending: true);

      if (allUsers.isEmpty) {
        return _getEmptyAnalytics();
      }

      // REAL DATA ANALYSIS
      final analysis = await _analyzeRealUserData(allUsers);
      
      return analysis;
    } catch (e) {
      print('Error in smart analytics: $e');
      return _getEmptyAnalytics();
    }
  }

  /// Analyze real user data with sophisticated algorithms
  static Future<Map<String, dynamic>> _analyzeRealUserData(List<dynamic> users) async {
    final now = DateTime.now();
    
    // === USER SEGMENTATION ANALYSIS ===
    final segments = _analyzeUserSegments(users);
    
    // === CHURN RISK ANALYSIS (REAL BEHAVIORAL PATTERNS) ===
    final churnAnalysis = _analyzeRealChurnRisk(users, now);
    
    // === PERFORMANCE ANALYSIS ===
    final performanceAnalysis = _analyzePerformancePatterns(users);
    
    // === GROWTH TREND ANALYSIS ===
    final growthAnalysis = _analyzeGrowthTrends(users, now);
    
    // === FINANCIAL INTELLIGENCE ===
    final financialAnalysis = _analyzeFinancialMetrics(users);
    
    // === BEHAVIORAL INSIGHTS ===
    final behaviorAnalysis = _analyzeBehavioralPatterns(users, now);

    return {
      'overview': {
        'total_users': users.length,
        'total_referrals': users.fold<int>(0, (sum, user) => sum + (user['total_referrals'] as int)),
        'total_earnings': users.fold<double>(0, (sum, user) => sum + (user['total_earnings'] as num).toDouble()),
        'analysis_timestamp': now.toIso8601String(),
      },
      'user_segmentation': segments,
      'churn_intelligence': churnAnalysis,
      'performance_insights': performanceAnalysis,
      'growth_intelligence': growthAnalysis,
      'financial_intelligence': financialAnalysis,
      'behavioral_insights': behaviorAnalysis,
      'predictive_analytics': _generatePredictiveInsights(users, now),
      'actionable_recommendations': _generateActionableRecommendations(users, churnAnalysis, segments),
    };
  }

  /// Analyze user segments based on real behavior
  static Map<String, dynamic> _analyzeUserSegments(List<dynamic> users) {
    final segments = {
      'champions': 0,          // 10+ referrals
      'loyal_customers': 0,    // 5-9 referrals  
      'potential_loyalists': 0, // 2-4 referrals
      'new_customers': 0,      // 1 referral
      'hibernating': 0,        // 0 referrals, old users
      'at_risk': 0,            // 0 referrals, recent users
    };

    final segmentDetails = <String, List<Map<String, dynamic>>>{};

    for (final user in users) {
      final referrals = user['total_referrals'] as int;
      final createdAt = DateTime.parse(user['created_at'] as String);
      final daysSinceJoined = DateTime.now().difference(createdAt).inDays;
      
      final userInfo = {
        'name': '${user['first_name']} ${user['last_name']}',
        'email': user['email'],
        'referrals': referrals,
        'earnings': user['total_earnings'],
        'days_active': daysSinceJoined,
      };

      String segment;
      if (referrals >= 10) {
        segment = 'champions';
        segments['champions'] = segments['champions']! + 1;
      } else if (referrals >= 5) {
        segment = 'loyal_customers';
        segments['loyal_customers'] = segments['loyal_customers']! + 1;
      } else if (referrals >= 2) {
        segment = 'potential_loyalists';
        segments['potential_loyalists'] = segments['potential_loyalists']! + 1;
      } else if (referrals == 1) {
        segment = 'new_customers';
        segments['new_customers'] = segments['new_customers']! + 1;
      } else if (daysSinceJoined > 30) {
        segment = 'hibernating';
        segments['hibernating'] = segments['hibernating']! + 1;
      } else {
        segment = 'at_risk';
        segments['at_risk'] = segments['at_risk']! + 1;
      }

      segmentDetails.putIfAbsent(segment, () => []).add(userInfo);
    }

    return {
      'segment_counts': segments,
      'segment_details': segmentDetails,
      'segment_analysis': {
        'most_valuable': _findMostValuableSegment(segments),
        'needs_attention': _findSegmentNeedsAttention(segments),
        'conversion_potential': _analyzeConversionPotential(segmentDetails),
      }
    };
  }

  /// Advanced churn risk analysis based on real user behavior
  static Map<String, dynamic> _analyzeRealChurnRisk(List<dynamic> users, DateTime now) {
    final churnUsers = <Map<String, dynamic>>[];
    final riskFactors = <String, int>{};
    
    for (final user in users) {
      final createdAt = DateTime.parse(user['created_at'] as String);
      final daysSinceJoined = now.difference(createdAt).inDays;
      final referrals = user['total_referrals'] as int;
      final earnings = (user['total_earnings'] as num).toDouble();
      
      // SOPHISTICATED CHURN RISK CALCULATION
      double riskScore = 0.0;
      final factors = <String>[];
      
      // Time-based risk
      if (daysSinceJoined > 30 && referrals == 0) {
        riskScore += 0.4;
        factors.add('Long-term inactive (${daysSinceJoined} days, 0 referrals)');
        riskFactors['long_term_inactive'] = (riskFactors['long_term_inactive'] ?? 0) + 1;
      } else if (daysSinceJoined > 14 && referrals == 0) {
        riskScore += 0.3;
        factors.add('Medium-term inactive (${daysSinceJoined} days, 0 referrals)');
        riskFactors['medium_term_inactive'] = (riskFactors['medium_term_inactive'] ?? 0) + 1;
      } else if (daysSinceJoined > 7 && referrals == 0) {
        riskScore += 0.2;
        factors.add('Short-term inactive (${daysSinceJoined} days, 0 referrals)');
        riskFactors['short_term_inactive'] = (riskFactors['short_term_inactive'] ?? 0) + 1;
      }
      
      // Engagement-based risk
      if (referrals == 0 && daysSinceJoined > 3) {
        riskScore += 0.2;
        factors.add('Never made a referral');
        riskFactors['never_referred'] = (riskFactors['never_referred'] ?? 0) + 1;
      }
      
      // Earnings-based risk (might indicate frustration)
      if (earnings < 25 && daysSinceJoined > 7) {
        riskScore += 0.1;
        factors.add('Low earnings (\$${earnings.toStringAsFixed(2)})');
        riskFactors['low_earnings'] = (riskFactors['low_earnings'] ?? 0) + 1;
      }

      // Only include users with significant risk
      if (riskScore >= 0.2) {
        churnUsers.add({
          'user_id': user['id'],
          'name': '${user['first_name']} ${user['last_name']}',
          'email': user['email'],
          'risk_score': (riskScore * 100).round(),
          'risk_level': riskScore >= 0.5 ? 'HIGH' : riskScore >= 0.3 ? 'MEDIUM' : 'LOW',
          'days_since_joined': daysSinceJoined,
          'total_referrals': referrals,
          'total_earnings': earnings,
          'risk_factors': factors,
          'recommended_actions': _generateChurnPreventionActions(riskScore, factors),
        });
      }
    }

    // Sort by risk score descending
    churnUsers.sort((a, b) => (b['risk_score'] as int).compareTo(a['risk_score'] as int));

    return {
      'total_at_risk': churnUsers.length,
      'high_risk_count': churnUsers.where((u) => u['risk_level'] == 'HIGH').length,
      'medium_risk_count': churnUsers.where((u) => u['risk_level'] == 'MEDIUM').length,
      'low_risk_count': churnUsers.where((u) => u['risk_level'] == 'LOW').length,
      'churn_risk_percentage': users.isNotEmpty ? ((churnUsers.length / users.length) * 100).toStringAsFixed(1) : '0.0',
      'at_risk_users': churnUsers.take(10).toList(), // Top 10 most at risk
      'risk_factor_distribution': riskFactors,
      'churn_prevention_strategy': _generateChurnPreventionStrategy(churnUsers, riskFactors),
    };
  }

  /// Analyze performance patterns in real data
  static Map<String, dynamic> _analyzePerformancePatterns(List<dynamic> users) {
    if (users.isEmpty) return {};

    final activeUsers = users.where((u) => (u['total_referrals'] as int) > 0).toList();
    final topPerformers = List<dynamic>.from(users)
      ..sort((a, b) => (b['total_referrals'] as int).compareTo(a['total_referrals'] as int))
      ..take(5);

    // Calculate performance distribution
    final performanceDistribution = {
      '0_referrals': users.where((u) => (u['total_referrals'] as int) == 0).length,
      '1_referral': users.where((u) => (u['total_referrals'] as int) == 1).length,
      '2_5_referrals': users.where((u) => (u['total_referrals'] as int) >= 2 && (u['total_referrals'] as int) <= 5).length,
      '6_10_referrals': users.where((u) => (u['total_referrals'] as int) >= 6 && (u['total_referrals'] as int) <= 10).length,
      '10plus_referrals': users.where((u) => (u['total_referrals'] as int) > 10).length,
    };

    final conversionRate = users.isNotEmpty ? (activeUsers.length / users.length * 100) : 0.0;
    
    return {
      'conversion_rate': conversionRate.toStringAsFixed(1),
      'total_active_users': activeUsers.length,
      'performance_distribution': performanceDistribution,
      'top_performers': topPerformers.map((user) => {
        'name': '${user['first_name']} ${user['last_name']}',
        'referrals': user['total_referrals'],
        'earnings': user['total_earnings'],
        'efficiency': _calculateUserEfficiency(user),
      }).toList(),
      'performance_insights': _generatePerformanceInsights(performanceDistribution, conversionRate),
    };
  }

  /// Analyze growth trends from real signup dates
  static Map<String, dynamic> _analyzeGrowthTrends(List<dynamic> users, DateTime now) {
    if (users.isEmpty) return {};

    // Group users by signup month
    final monthlySignups = <String, int>{};
    final monthlyReferrals = <String, int>{};
    
    for (final user in users) {
      final createdAt = DateTime.parse(user['created_at'] as String);
      final monthKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
      
      monthlySignups[monthKey] = (monthlySignups[monthKey] ?? 0) + 1;
      monthlyReferrals[monthKey] = (monthlyReferrals[monthKey] ?? 0) + (user['total_referrals'] as int);
    }

    // Calculate growth rate
    final sortedMonths = monthlySignups.keys.toList()..sort();
    double growthRate = 0.0;
    if (sortedMonths.length >= 2) {
      final lastMonth = monthlySignups[sortedMonths.last] ?? 0;
      final previousMonth = monthlySignups[sortedMonths[sortedMonths.length - 2]] ?? 1;
      growthRate = previousMonth > 0 ? ((lastMonth - previousMonth) / previousMonth * 100) : 0.0;
    }

    return {
      'monthly_signups': monthlySignups,
      'monthly_referrals': monthlyReferrals,
      'growth_rate': growthRate.toStringAsFixed(1),
      'total_months_active': sortedMonths.length,
      'average_signups_per_month': sortedMonths.isNotEmpty ? (users.length / sortedMonths.length).toStringAsFixed(1) : '0',
      'growth_trend': growthRate > 10 ? 'ACCELERATING' : growthRate > 0 ? 'GROWING' : growthRate > -10 ? 'STABLE' : 'DECLINING',
      'growth_insights': _generateGrowthInsights(monthlySignups, growthRate),
    };
  }

  /// Calculate financial metrics from real earnings data
  static Map<String, dynamic> _analyzeFinancialMetrics(List<dynamic> users) {
    if (users.isEmpty) return {};

    final totalEarnings = users.fold<double>(0, (sum, user) => sum + (user['total_earnings'] as num).toDouble());
    final totalReferrals = users.fold<int>(0, (sum, user) => sum + (user['total_referrals'] as int));
    
    // Calculate Customer Lifetime Value (based on current earnings)
    final activeUsers = users.where((u) => (u['total_referrals'] as int) > 0).toList();
    final avgLTV = activeUsers.isNotEmpty 
        ? (activeUsers.fold<double>(0, (sum, user) => sum + (user['total_earnings'] as num).toDouble()) / activeUsers.length)
        : 0.0;

    // Estimate Customer Acquisition Cost (assuming $25 per referred user)
    const estimatedCAC = 25.0;
    final totalUsers = users.length;
    final totalAcquisitionCost = totalUsers * estimatedCAC;
    
    // Calculate ROI
    final roi = totalAcquisitionCost > 0 ? ((totalEarnings - totalAcquisitionCost) / totalAcquisitionCost * 100) : 0.0;

    return {
      'total_earnings': totalEarnings.toStringAsFixed(2),
      'average_ltv': avgLTV.toStringAsFixed(2),
      'estimated_cac': estimatedCAC.toStringAsFixed(2),
      'roi_percentage': roi.toStringAsFixed(1),
      'total_acquisition_cost': totalAcquisitionCost.toStringAsFixed(2),
      'net_profit': (totalEarnings - totalAcquisitionCost).toStringAsFixed(2),
      'revenue_per_user': users.isNotEmpty ? (totalEarnings / users.length).toStringAsFixed(2) : '0.00',
      'financial_health': roi > 100 ? 'EXCELLENT' : roi > 50 ? 'GOOD' : roi > 0 ? 'FAIR' : 'POOR',
      'financial_insights': _generateFinancialInsights(roi, avgLTV, estimatedCAC),
    };
  }

  /// Analyze behavioral patterns from real user data
  static Map<String, dynamic> _analyzeBehavioralPatterns(List<dynamic> users, DateTime now) {
    // Analyze signup timing patterns
    final signupHours = <int, int>{};
    final signupDaysOfWeek = <int, int>{};
    
    for (final user in users) {
      final createdAt = DateTime.parse(user['created_at'] as String);
      final hour = createdAt.hour;
      final dayOfWeek = createdAt.weekday;
      
      signupHours[hour] = (signupHours[hour] ?? 0) + 1;
      signupDaysOfWeek[dayOfWeek] = (signupDaysOfWeek[dayOfWeek] ?? 0) + 1;
    }

    return {
      'signup_hour_distribution': signupHours,
      'signup_day_distribution': signupDaysOfWeek,
      'peak_signup_hour': _findPeakHour(signupHours),
      'peak_signup_day': _findPeakDay(signupDaysOfWeek),
      'behavioral_insights': _generateBehavioralInsights(signupHours, signupDaysOfWeek),
    };
  }

  // Helper methods for generating insights and recommendations
  static List<String> _generateChurnPreventionActions(double riskScore, List<String> factors) {
    final actions = <String>[];
    
    if (factors.any((f) => f.contains('inactive'))) {
      actions.add('Send personalized re-engagement email');
      actions.add('Offer bonus referral reward');
    }
    
    if (factors.any((f) => f.contains('Never made'))) {
      actions.add('Provide step-by-step referral guide');
      actions.add('Reduce first referral threshold');
    }
    
    if (factors.any((f) => f.contains('Low earnings'))) {
      actions.add('Explain earning potential');
      actions.add('Share success stories');
    }
    
    return actions.isNotEmpty ? actions : ['Monitor user activity', 'Send general engagement content'];
  }

  static Map<String, dynamic> _generatePredictiveInsights(List<dynamic> users, DateTime now) {
    // Simple predictive model based on current trends
    final activeUsers = users.where((u) => (u['total_referrals'] as int) > 0).length;
    final totalUsers = users.length;
    
    return {
      'predicted_30_day_growth': _predictGrowth(users, 30),
      'predicted_churn_rate': _predictChurnRate(users),
      'predicted_revenue_next_month': _predictRevenue(users),
      'confidence_level': totalUsers > 20 ? 'HIGH' : totalUsers > 10 ? 'MEDIUM' : 'LOW',
    };
  }

  static List<String> _generateActionableRecommendations(
    List<dynamic> users, 
    Map<String, dynamic> churnAnalysis,
    Map<String, dynamic> segments
  ) {
    final recommendations = <String>[];
    
    final churnRate = double.tryParse(churnAnalysis['churn_risk_percentage'] ?? '0') ?? 0.0;
    final segmentCounts = segments['segment_counts'] as Map<String, dynamic>;
    
    if (churnRate > 30) {
      recommendations.add('🚨 URGENT: Implement immediate retention campaign - ${churnRate.toStringAsFixed(1)}% churn risk');
    }
    
    if ((segmentCounts['hibernating'] as int) > (users.length * 0.4)) {
      recommendations.add('💤 Too many hibernating users - launch reactivation sequence');
    }
    
    if ((segmentCounts['champions'] as int) < (users.length * 0.1)) {
      recommendations.add('🏆 Nurture more champions - only ${segmentCounts['champions']} super performers');
    }
    
    recommendations.add('🎯 Focus on converting ${segmentCounts['potential_loyalists']} potential loyalists');
    recommendations.add('📈 Optimize onboarding for ${segmentCounts['at_risk']} at-risk new users');
    
    return recommendations;
  }

  // Additional helper methods for calculations
  static double _calculateUserEfficiency(dynamic user) {
    final referrals = user['total_referrals'] as int;
    final earnings = (user['total_earnings'] as num).toDouble();
    final daysSinceJoined = DateTime.now().difference(DateTime.parse(user['created_at'] as String)).inDays;
    
    return daysSinceJoined > 0 ? (referrals / daysSinceJoined) : 0.0;
  }

  static String _findMostValuableSegment(Map<String, int> segments) {
    return segments.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static String _findSegmentNeedsAttention(Map<String, int> segments) {
    final hibernating = segments['hibernating'] ?? 0;
    final atRisk = segments['at_risk'] ?? 0;
    return hibernating > atRisk ? 'hibernating' : 'at_risk';
  }

  static Map<String, dynamic> _analyzeConversionPotential(Map<String, List<Map<String, dynamic>>> segmentDetails) {
    final potential = segmentDetails['potential_loyalists']?.length ?? 0;
    final newCustomers = segmentDetails['new_customers']?.length ?? 0;
    
    return {
      'high_potential_count': potential,
      'new_customer_count': newCustomers,
      'total_convertible': potential + newCustomers,
    };
  }

  static int _findPeakHour(Map<int, int> hourDistribution) {
    if (hourDistribution.isEmpty) return 12;
    return hourDistribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static int _findPeakDay(Map<int, int> dayDistribution) {
    if (dayDistribution.isEmpty) return 1;
    return dayDistribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static List<String> _generatePerformanceInsights(Map<String, int> distribution, double conversionRate) {
    final insights = <String>[];
    
    final zeroReferrals = distribution['0_referrals'] ?? 0;
    final total = distribution.values.fold(0, (sum, count) => sum + count);
    
    if (zeroReferrals > total * 0.6) {
      insights.add('High percentage of non-converting users - improve onboarding');
    }
    
    if (conversionRate < 20) {
      insights.add('Below average conversion rate - optimize referral process');
    } else if (conversionRate > 40) {
      insights.add('Excellent conversion rate - scale current strategies');
    }
    
    return insights;
  }

  static List<String> _generateGrowthInsights(Map<String, int> monthlySignups, double growthRate) {
    final insights = <String>[];
    
    if (growthRate > 20) {
      insights.add('Exceptional growth momentum - prepare for scaling');
    } else if (growthRate < 0) {
      insights.add('Declining growth - investigate user acquisition channels');
    }
    
    return insights;
  }

  static List<String> _generateFinancialInsights(double roi, double avgLTV, double estimatedCAC) {
    final insights = <String>[];
    
    final ltvCacRatio = estimatedCAC > 0 ? (avgLTV / estimatedCAC) : 0;
    
    if (ltvCacRatio > 3) {
      insights.add('Excellent LTV:CAC ratio - profitable user acquisition');
    } else if (ltvCacRatio < 1) {
      insights.add('Poor LTV:CAC ratio - optimize acquisition or increase retention');
    }
    
    if (roi > 200) {
      insights.add('Outstanding ROI - consider increasing marketing spend');
    }
    
    return insights;
  }

  static List<String> _generateBehavioralInsights(Map<int, int> hourDist, Map<int, int> dayDist) {
    final insights = <String>[];
    
    final peakHour = _findPeakHour(hourDist);
    final peakDay = _findPeakDay(dayDist);
    
    insights.add('Peak signup time: ${peakHour}:00 on ${_getDayName(peakDay)}');
    insights.add('Optimize marketing campaigns for peak times');
    
    return insights;
  }

  static String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1];
  }

  static Map<String, dynamic> _generateChurnPreventionStrategy(List<Map<String, dynamic>> churnUsers, Map<String, int> riskFactors) {
    return {
      'immediate_actions': [
        'Contact ${churnUsers.where((u) => u['risk_level'] == 'HIGH').length} high-risk users',
        'Send re-engagement campaign to inactive users',
        'Implement referral tutorial for zero-referral users',
      ],
      'long_term_strategy': [
        'Improve onboarding experience',
        'Create engagement scoring system',
        'Implement proactive support outreach',
      ],
    };
  }

  static String _predictGrowth(List<dynamic> users, int days) {
    // Simple linear prediction based on recent growth
    if (users.length < 10) return 'Insufficient data';
    
    final recent = users.where((u) {
      final created = DateTime.parse(u['created_at'] as String);
      return DateTime.now().difference(created).inDays <= 30;
    }).length;
    
    final predicted = (recent / 30 * days).round();
    return '$predicted new users';
  }

  static String _predictChurnRate(List<dynamic> users) {
    // Based on current patterns
    final inactive = users.where((u) => (u['total_referrals'] as int) == 0).length;
    final rate = users.isNotEmpty ? (inactive / users.length * 100) : 0.0;
    return '${rate.toStringAsFixed(1)}%';
  }

  static String _predictRevenue(List<dynamic> users) {
    final avgEarnings = users.isNotEmpty 
        ? users.fold<double>(0, (sum, u) => sum + (u['total_earnings'] as num).toDouble()) / users.length
        : 0.0;
    
    return '\$${(avgEarnings * users.length * 0.1).toStringAsFixed(2)}'; // 10% growth assumption
  }

  static Map<String, dynamic> _getEmptyAnalytics() {
    return {
      'overview': {'total_users': 0, 'total_referrals': 0, 'total_earnings': '0.00'},
      'message': 'No user data available for analysis',
    };
  }
}
