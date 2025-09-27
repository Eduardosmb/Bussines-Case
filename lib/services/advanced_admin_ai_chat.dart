import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics_data.dart';
import '../models/user.dart';
import 'supabase_service.dart';
import 'openai_service.dart';
import 'smart_analytics_service.dart';

class AdvancedAdminAIChat extends StatefulWidget {
  final User user;

  const AdvancedAdminAIChat({Key? key, required this.user}) : super(key: key);

  @override
  State<AdvancedAdminAIChat> createState() => _AdvancedAdminAIChatState();
}

class _AdvancedAdminAIChatState extends State<AdvancedAdminAIChat> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic>? _analyticsData;
  Map<String, dynamic>? _advancedMetrics;

  @override
  void initState() {
    super.initState();
    _loadAdvancedAnalytics();
    _addWelcomeMessage();
  }

  Future<void> _loadAdvancedAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      // Load REAL intelligent analytics from actual user data
      final smartAnalytics = await SmartAnalyticsService.getIntelligentAnalytics();
      
      // Load basic analytics for compatibility
      final basicAnalytics = await SupabaseService.getAdvancedAnalytics(widget.user.id);
      
      setState(() {
        _analyticsData = basicAnalytics;
        _advancedMetrics = smartAnalytics; // Now contains REAL intelligent analysis
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading smart analytics: $e');
    }
  }

  // This method is now replaced by SmartAnalyticsService.getIntelligentAnalytics()
  // which analyzes REAL data instead of simulated data

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'text': '''🤖 CloudWalk Admin AI Assistant

🔴 EXCLUSIVE ADMIN ACCESS

I analyze your real user data from the database and provide intelligent business insights.

What I do:
• Analyze ${_advancedMetrics?['overview']?['total_users'] ?? 'your'} users and their behavior
• Calculate churn risk based on real signup dates and activity
• Identify which users are most likely to stop using the platform
• Calculate actual conversion rates from your data
• Provide specific recommendations to improve retention

Ask me questions like:
• "Who are my highest churn risk users?"
• "What is our conversion rate?" 
• "Give me retention recommendations"
• "Which users should I focus on?"
• "What patterns predict success?"

I give you text-based analysis and recommendations using your real business data.''',
        'isUser': false,
        'timestamp': DateTime.now(),
        'hasCharts': false,
      });
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final response = await _processAdvancedAdminQuery(text);
      setState(() {
        _messages.add({
          'text': response,
          'isUser': false,
          'timestamp': DateTime.now(),
          'hasCharts': false, // NEVER show charts
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'Sorry, I encountered an error processing your advanced analytics request. Please try again.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }
  }

  bool _shouldShowCharts(String query) {
    final chartKeywords = [
      'chart', 'graph', 'trend', 'funnel', 'breakdown', 
      'analysis', 'revenue', 'conversion', 'growth'
    ];
    return chartKeywords.any((keyword) => 
      query.toLowerCase().contains(keyword));
  }

  Future<String> _processAdvancedAdminQuery(String query) async {
    // REAL DATA INTELLIGENCE - No fake data, only sophisticated analysis
    final enhancedContext = '''
You are CloudWalk's Advanced AI Analytics Assistant with REAL-TIME analysis of actual user data.

🧠 INTELLIGENT USER SEGMENTATION (REAL DATA):
${_buildUserSegmentationContext()}

⚠️ SOPHISTICATED CHURN RISK ANALYSIS (REAL BEHAVIORAL PATTERNS):
${_buildChurnAnalysisContext()}

📈 PERFORMANCE INTELLIGENCE (ACTUAL USER BEHAVIOR):
${_buildPerformanceContext()}

💰 FINANCIAL INTELLIGENCE (REAL EARNINGS DATA):
${_buildFinancialContext()}

🔮 PREDICTIVE ANALYTICS (DATA-DRIVEN FORECASTING):
${_buildPredictiveContext()}

🎯 ACTIONABLE RECOMMENDATIONS (BASED ON REAL PATTERNS):
${_buildRecommendationsContext()}

REAL DATA OVERVIEW:
${_buildRealDataOverview()}

Your REAL capabilities:
- Analyze actual user behavior patterns from database
- Detect real churn risk based on signup dates and referral activity
- Calculate genuine financial metrics from earnings data
- Identify actual performance trends from user segments
- Provide data-driven recommendations based on real user behavior
- Predict future trends using statistical analysis of real data
- Always respond in English with insights backed by REAL data

Question: $query
''';

    // Use enhanced OpenAI service for more intelligent responses
    final aiResponse = await OpenAIService.processQuery(enhancedContext + '\n\nUser Question: $query');

    return aiResponse.response;
  }

  String _buildUserSegmentationContext() {
    if (_advancedMetrics?['user_segmentation'] == null) return 'Analyzing user segments...';
    
    final segments = _advancedMetrics!['user_segmentation']?['segment_counts'] as Map<String, dynamic>? ?? {};
    final analysis = _advancedMetrics!['user_segmentation']?['segment_analysis'] as Map<String, dynamic>? ?? {};
    
    return '''
• Champions: ${segments['champions'] ?? 0} users (10+ referrals) - Top performers
• Loyal Customers: ${segments['loyal_customers'] ?? 0} users (5-9 referrals) - Consistent performers  
• Potential Loyalists: ${segments['potential_loyalists'] ?? 0} users (2-4 referrals) - Growth opportunity
• New Customers: ${segments['new_customers'] ?? 0} users (1 referral) - Recent converters
• Hibernating: ${segments['hibernating'] ?? 0} users (0 referrals, 30+ days) - Need reactivation
• At Risk: ${segments['at_risk'] ?? 0} users (0 referrals, recent) - Need immediate attention

Most Valuable Segment: ${analysis['most_valuable'] ?? 'Unknown'}
Needs Attention: ${analysis['needs_attention'] ?? 'Unknown'}
Conversion Potential: ${analysis['conversion_potential']?['total_convertible'] ?? 0} users
''';
  }

  String _buildChurnAnalysisContext() {
    if (_advancedMetrics?['churn_intelligence'] == null) return 'Analyzing churn risk...';
    
    final churn = _advancedMetrics!['churn_intelligence'];
    final atRiskUsers = churn?['at_risk_users'] as List? ?? [];
    
    return '''
• Total At Risk: ${churn?['total_at_risk'] ?? 0} users (${churn?['churn_risk_percentage'] ?? '0'}% of user base)
• High Risk: ${churn?['high_risk_count'] ?? 0} users - Immediate action needed
• Medium Risk: ${churn?['medium_risk_count'] ?? 0} users - Monitor closely  
• Low Risk: ${churn?['low_risk_count'] ?? 0} users - Preventive measures

TOP RISK USERS (REAL DATA):
${atRiskUsers.take(3).map((user) => '• ${user?['name'] ?? 'Unknown'} (${user?['email'] ?? 'Unknown'}): ${user?['risk_score'] ?? 0}% risk, ${user?['days_since_joined'] ?? 0} days, ${user?['total_referrals'] ?? 0} referrals').join('\n')}

Risk Factors Distribution:
${(churn?['risk_factor_distribution'] as Map<String, dynamic>?)?.entries.map((e) => '• ${e.key}: ${e.value} users').join('\n') ?? 'No risk factors data'}
''';
  }

  String _buildPerformanceContext() {
    if (_advancedMetrics?['performance_insights'] == null) return 'Analyzing performance...';
    
    final performance = _advancedMetrics!['performance_insights'];
    final topPerformers = performance?['top_performers'] as List? ?? [];
    final distribution = performance?['performance_distribution'] as Map<String, dynamic>? ?? {};
    
    return '''
• Conversion Rate: ${performance?['conversion_rate'] ?? '0'}% (users who made ≥1 referral)
• Active Users: ${performance?['total_active_users'] ?? 0} out of total users

Performance Distribution:
• 0 referrals: ${distribution['0_referrals'] ?? 0} users
• 1 referral: ${distribution['1_referral'] ?? 0} users  
• 2-5 referrals: ${distribution['2_5_referrals'] ?? 0} users
• 6-10 referrals: ${distribution['6_10_referrals'] ?? 0} users
• 10+ referrals: ${distribution['10plus_referrals'] ?? 0} users

TOP PERFORMERS (REAL DATA):
${topPerformers.take(3).map((user) => '• ${user?['name'] ?? 'Unknown'}: ${user?['referrals'] ?? 0} referrals, \$${user?['earnings'] ?? 0}, efficiency: ${(user?['efficiency'] as num?)?.toStringAsFixed(2) ?? '0.00'}').join('\n')}
''';
  }

  String _buildFinancialContext() {
    if (_advancedMetrics?['financial_intelligence'] == null) return 'Analyzing financials...';
    
    final financial = _advancedMetrics!['financial_intelligence'];
    final insights = financial?['financial_insights'] as List? ?? [];
    
    return '''
• Total Earnings: \$${financial?['total_earnings'] ?? '0.00'} (actual user earnings)
• Average LTV: \$${financial?['average_ltv'] ?? '0.00'} per active user
• Estimated CAC: \$${financial?['estimated_cac'] ?? '0.00'} per user
• ROI: ${financial?['roi_percentage'] ?? '0.0'}% return on investment
• Net Profit: \$${financial?['net_profit'] ?? '0.00'} 
• Revenue per User: \$${financial?['revenue_per_user'] ?? '0.00'}
• Financial Health: ${financial?['financial_health'] ?? 'Unknown'}

Insights: ${insights.join('. ')}
''';
  }

  String _buildPredictiveContext() {
    if (_advancedMetrics?['predictive_analytics'] == null) return 'Generating predictions...';
    
    final predictive = _advancedMetrics!['predictive_analytics'];
    
    return '''
• 30-Day Growth Prediction: ${predictive?['predicted_30_day_growth'] ?? 'Calculating...'}
• Predicted Churn Rate: ${predictive?['predicted_churn_rate'] ?? 'Calculating...'} 
• Revenue Forecast (Next Month): ${predictive?['predicted_revenue_next_month'] ?? 'Calculating...'}
• Confidence Level: ${predictive?['confidence_level'] ?? 'LOW'} (based on data volume)
''';
  }

  String _buildRecommendationsContext() {
    if (_advancedMetrics?['actionable_recommendations'] == null) return 'Generating recommendations...';
    
    final recommendations = _advancedMetrics!['actionable_recommendations'] as List? ?? [];
    
    return '''
${recommendations.take(5).map((rec) => '• $rec').join('\n')}
''';
  }

  String _buildRealDataOverview() {
    if (_advancedMetrics?['overview'] == null) return 'Loading real data overview...';
    
    final overview = _advancedMetrics!['overview'];
    
    return '''
📊 REAL DATA SUMMARY:
• Total Users in Database: ${overview?['total_users'] ?? 0}
• Total Referrals Made: ${overview?['total_referrals'] ?? 0}  
• Total Earnings Generated: \$${overview?['total_earnings'] ?? '0.00'}
• Analysis Timestamp: ${overview?['analysis_timestamp'] ?? DateTime.now().toIso8601String()}
• Data Source: Live database (users table)
''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[900]!, Colors.red[700]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Advanced Analytics Command Center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'AI ENHANCED',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Metrics Dashboard - only show when data is loaded and charts are requested
          // if (_advancedMetrics != null) _buildQuickMetricsDashboard(),

          // Chat Messages
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator();
                  }
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),

          // Enhanced Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border(top: BorderSide(color: Colors.red[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about advanced analytics, predictions, trends...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.red[300]!),
                      ),
                      prefixIcon: Icon(Icons.psychology, color: Colors.red[600]),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading 
                    ? null 
                    : () => _handleSubmitted(_messageController.text),
                  backgroundColor: Colors.red[700],
                  mini: true,
                  child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetricsDashboard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: Row(
        children: [
          _buildQuickMetric(
            'Conversion',
            '${_advancedMetrics?['performance_insights']?['conversion_rate'] ?? 0}%',
            Icons.trending_up,
            Colors.green,
          ),
          _buildQuickMetric(
            'Total Users',
            '${_advancedMetrics?['overview']?['total_users'] ?? 0}',
            Icons.people,
            Colors.blue,
          ),
          _buildQuickMetric(
            'LTV',
            '\$${_advancedMetrics?['financial_intelligence']?['average_ltv'] ?? '0.00'}',
            Icons.monetization_on,
            Colors.orange,
          ),
          _buildQuickMetric(
            'High Risk',
            '${_advancedMetrics?['churn_intelligence']?['high_risk_count'] ?? 0}',
            Icons.warning,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetric(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final hasCharts = message['hasCharts'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: 
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser ? Colors.red[700] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message['text'],
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          // Charts completely disabled
        ],
      ),
    );
  }

  Widget _buildSampleChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 4),
                FlSpot(2, 6),
                FlSpot(3, 8),
              ],
              isCurved: true,
              color: Colors.red[600],
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Analyzing data with AI...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
