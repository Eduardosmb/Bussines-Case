import 'package:flutter/material.dart';
import '../models/user.dart';
import 'supabase_service.dart';
import 'openai_ai_service.dart';

// Classe para o Chat Admin AI
class AdminAIChat extends StatefulWidget {
  final User user;

  const AdminAIChat({Key? key, required this.user}) : super(key: key);

  @override
  AdminAIChatState createState() => AdminAIChatState();
}

class AdminAIChatState extends State<AdminAIChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic>? _analyticsData;
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'text': '''🎯 **Welcome to CloudWalk Admin AI Assistant!**

I'm your exclusive business intelligence agent with access to advanced analytics. Here's what I can help you with:

📊 **Real-time Analytics**
• User acquisition metrics
• Referral performance analysis  
• Conversion rate tracking
• Revenue & ROI calculations

📈 **Growth Insights**
• User growth forecasts
• Churn risk analysis
• Performance benchmarking
• Market opportunity identification

🎯 **Strategic Recommendations**
• Marketing optimization strategies
• User engagement improvements
• Revenue maximization tactics
• Risk mitigation plans

🗣️ **Natural Language Queries**
Ask me anything about your business data:
- "How many users joined this month?"
- "What's our conversion rate?"
- "Which users are at risk of churning?"
- "What's our ROI on referral campaigns?"

**Ready to dive into your data? Ask me anything!** 🚀''',
        'isUser': false,
        'timestamp': DateTime.now(),
        'type': 'welcome'
      });
    });
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analytics = await SupabaseService.getAdvancedAnalytics(widget.user.id);
      setState(() {
        _analyticsData = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading analytics: $e');
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await _processAdminQuery(text);
      setState(() {
        _messages.add({
          'text': response,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'Sorry, I encountered an error processing your request. Please try again.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }
  }

  Future<String> _processAdminQuery(String query) async {
    try {
      // Refresh analytics data
      if (_analyticsData == null) {
        await _loadAnalytics();
      }

      // Prepare comprehensive business context for GPT
      final businessContext = '''
You are CloudWalk's exclusive Admin AI Assistant with access to real-time business analytics. 

Current Business Data:
📊 OVERVIEW:
• Total Users: ${_analyticsData?['overview']?['total_users'] ?? 0}
• Total Referrals: ${_analyticsData?['overview']?['total_referrals'] ?? 0}  
• Total Earnings: \$${_analyticsData?['overview']?['total_earnings'] ?? '0'}
• Avg Earnings per User: \$${_analyticsData?['overview']?['avg_earnings_per_user'] ?? '0'}

📈 PERFORMANCE:
• Conversion Rate: ${_analyticsData?['performance']?['conversion_rate'] ?? '0'}%
• Users with Referrals: ${_analyticsData?['performance']?['users_with_referrals'] ?? 0}

🚀 GROWTH:
• Monthly Growth Rate: ${_analyticsData?['growth']?['growth_rate'] ?? '0'}%
• New Users (30 days): ${_analyticsData?['growth']?['new_users_30_days'] ?? 0}

⚠️ RISK ANALYSIS:
• Churn Risk: ${_analyticsData?['risk_analysis']?['churn_risk_percentage'] ?? '0'}%
• Inactive Users: ${_analyticsData?['risk_analysis']?['inactive_users'] ?? 0}

💰 FINANCIAL:
• ROI: ${_analyticsData?['financial']?['roi_percentage'] ?? '0'}%
• Net Profit: \$${_analyticsData?['financial']?['net_profit'] ?? '0'}
• Total Acquisition Cost: \$${_analyticsData?['financial']?['total_acquisition_cost'] ?? '0'}

🔮 FORECASTS:
• Projected Users Next Month: ${_analyticsData?['forecasts']?['projected_users_next_month'] ?? 0}
• Projected Earnings Next Month: \$${_analyticsData?['forecasts']?['projected_earnings_next_month'] ?? '0'}

🏆 TOP PERFORMERS:
${(_analyticsData?['performance']?['top_performers'] as List?)?.take(3).map((user) => '• ${user['first_name']} ${user['last_name']}: ${user['total_referrals']} referrals, \$${user['total_earnings']}').join('\n') ?? 'No top performers data'}

📋 AI RECOMMENDATIONS:
${(_analyticsData?['forecasts']?['recommendations'] as List?)?.join('\n• ') ?? 'No specific recommendations available'}

Your role:
- Provide intelligent analysis of business metrics
- Explain concepts clearly (like conversion rate, churn, ROI) 
- Give actionable insights and strategic recommendations
- Use emojis and formatting to make responses engaging
- Reference the real data provided above in your answers
- Be conversational but professional
- Focus on growth, optimization, and business intelligence

Answer the following admin question using the business context above:
''';

      final fullPrompt = businessContext + '\n\nQuestion: $query';

      print('🤖 Sending query to GPT: ${query.substring(0, query.length > 50 ? 50 : query.length)}...');
      
      // Use the existing processQuery method but adapted for admin
      final aiResponse = await OpenAIService.processQuery(query, isAdmin: true, contextData: _analyticsData);
      
      print('✅ GPT response received');
      
      return aiResponse.response;
      
    } catch (e) {
      print('❌ Error in admin AI query: $e');
      
      // Fallback to basic response if AI fails
      return '''❌ **AI Assistant Temporarily Unavailable**

I'm having trouble accessing the advanced AI features right now. Here's a basic overview of your business metrics:

📊 **Current Stats:**
• Total Users: ${_analyticsData?['overview']?['total_users'] ?? 0}
• Conversion Rate: ${_analyticsData?['performance']?['conversion_rate'] ?? '0'}%
• Total Earnings: \$${_analyticsData?['overview']?['total_earnings'] ?? '0'}
• Monthly Growth: ${_analyticsData?['growth']?['growth_rate'] ?? '0'}%

💡 **Try asking simpler questions like:**
• "What's our current performance?"
• "Show me the growth metrics" 
• "What are the top recommendations?"

The AI service should be back online shortly. Please try your question again in a moment.''';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages area
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
        ),
        
        // Loading indicator
        if (_isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[300]!),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analyzing data...',
                  style: TextStyle(color: Colors.red[200]),
                ),
              ],
            ),
          ),
        
        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[800],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask about analytics, forecasts, or recommendations...',
                    hintStyle: TextStyle(color: Colors.red[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.red[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.red[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.red[800],
                onPressed: _sendMessage,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;
    final isWelcome = message['type'] == 'welcome';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isWelcome ? Colors.red[600] : Colors.red[700],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWelcome ? Icons.admin_panel_settings : Icons.analytics,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? Colors.red[600] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isWelcome ? Border.all(color: Colors.red[300]!, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: isWelcome ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
