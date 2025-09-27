import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/analytics_data.dart';
import '../services/ai_data_agent.dart';
import '../services/openai_service.dart';
import '../services/admin_service.dart';
import 'churn_analytics_screen.dart';

class AIAgentScreen extends StatefulWidget {
  const AIAgentScreen({super.key});

  @override
  State<AIAgentScreen> createState() => _AIAgentScreenState();
}

class _AIAgentScreenState extends State<AIAgentScreen>
    with TickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final List<AIResponse> _chatHistory = [];
  final ScrollController _scrollController = ScrollController();
  
  ReferralAnalytics? _analytics;
  bool _isLoading = false;
  bool _isLoadingAnalytics = true;
  bool _isAdmin = false;
  
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    _initializeAgent();
  }

  Future<void> _initializeAgent() async {
    try {
      // Check if user is admin
      _isAdmin = await AdminService.hasAdminAccess();

      await _loadAnalytics();
      await _addWelcomeMessage();
    } catch (e) {
      // Don't close the screen, just show error state
      setState(() {
        _chatHistory.add(AIResponse(
          query: "",
          response: "⚠️ There was an issue initializing the AI Agent, but I'm ready to help you. Error: $e",
          insights: ["AI Agent partially loaded"],
          suggestedQuestions: ["Try asking me a question"],
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  Future<void> _addWelcomeMessage() async {
    try {
      final isConfigured = await OpenAIService.isConfigured();

    String welcomeMessage;
    List<String> insights;
    List<String> suggestedQuestions;

    if (_isAdmin) {
      // Admin welcome message
      welcomeMessage = isConfigured
        ? "👋 Olá, Administrador! Eu sou seu Agente de Analytics Avançado da CloudWalk, powered by GPT-4o-mini. Tenho acesso completo aos dados do sistema e posso fornecer insights analíticos profundos, previsões de crescimento, análise de performance de indicações e recomendações estratégicas. Como posso ajudar a otimizar seu programa hoje?"
        : "❌ Olá, Administrador! Para acessar análises avançadas completas com GPT-4o-mini, configure sua chave da API OpenAI no arquivo .env do projeto.";

      insights = isConfigured ? [
        "Acesso completo a dados analíticos do sistema",
        "Análises de performance e ROI em tempo real",
        "Previsões de crescimento e churn",
        "Interface natural para consultas de negócio",
        "Recomendações estratégicas para o mercado brasileiro",
      ] : [
        "Configure OPENAI_API_KEY no arquivo .env",
        "Reinicie a aplicação após configurar",
        "Acesse platform.openai.com para obter sua chave",
        "GPT-4 fornece análises muito mais avançadas",
      ];

      suggestedQuestions = isConfigured ? [
        "Quais são as principais métricas de performance do programa?",
        "Qual o ROI atual e projeções para os próximos meses?",
        "Identifique usuários com alto risco de churn",
        "Gere recomendações para aumentar a taxa de conversão",
        "Analise a performance dos top performers",
        "Forneça previsões de crescimento para o trimestre",
      ] : [
        "Como configurar a chave da API OpenAI?",
        "Onde encontro o arquivo .env?",
        "Como obter uma chave da API?",
        "Quais são os benefícios do GPT-4?",
      ];
    } else {
      // Regular user welcome message
      welcomeMessage = isConfigured
        ? "👋 Hello! I'm your CloudWalk Marketing Assistant, powered by GPT-4. I can answer questions about CloudWalk and Infinity Pay, provide personalized marketing insights and help boost your account based on your data. What would you like to know?"
        : "❌ Hello! I'm your CloudWalk Marketing Assistant. To use my full intelligence with GPT-4, configure your OpenAI API key in the project's .env file.";

      insights = isConfigured ? [
        "Powered by OpenAI GPT-4 for advanced understanding",
        "Specialist in CloudWalk and Infinity Pay",
        "Personalized insights based on your data",
        "Practical tips to increase your referrals",
        "Individual performance analysis",
      ] : [
        "Configure OPENAI_API_KEY in .env file",
        "Restart the application after configuring",
        "Access platform.openai.com to get your key",
        "GPT-4 provides much more intelligent responses",
      ];

      suggestedQuestions = isConfigured ? [
        "What is CloudWalk and how does it work?",
        "How does the Infinity Pay referral program work?",
        "How can I increase my referrals?",
        "What are the best marketing strategies?",
        "Analyze my current performance",
        "Tips to engage more people",
      ] : [
        "Como configurar a chave da API OpenAI?",
        "Onde encontro o arquivo .env?",
        "Como obter uma chave da API?",
        "Quais são os benefícios do GPT-4?",
      ];
    }

    final welcomeResponse = AIResponse(
      query: "",
      response: welcomeMessage,
      insights: insights,
      suggestedQuestions: suggestedQuestions,
      timestamp: DateTime.now(),
    );

    setState(() {
      _chatHistory.add(welcomeResponse);
    });
    } catch (e) {
      // Add fallback welcome message
      setState(() {
        _chatHistory.add(AIResponse(
          query: "",
          response: "Welcome to CloudWalk AI Assistant! There was an issue loading the full welcome message, but I'm ready to help you.",
          insights: ["AI Agent ready"],
          suggestedQuestions: ["How can I help you?"],
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      const analytics = null;
      setState(() {
        _analytics = analytics;
        _isLoadingAnalytics = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAnalytics = false;
      });
    }
  }
  
  Future<void> _testOpenAIConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Testando conexão OpenAI...'),
          ],
        ),
      ),
    );
    
    try {
      final result = await OpenAIService.testConnection();
      Navigator.pop(context); // Close loading dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Teste de Conexão OpenAI'),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Test Error'),
          content: Text('Failed to test: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sendQuery(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await OpenAIService.processQuery(query);
      setState(() {
        _chatHistory.add(response);
        _isLoading = false;
      });

      _queryController.clear();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF1F2937),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Data Agent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'CloudWalk Analytics',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          FutureBuilder<bool>(
            future: OpenAIService.isConfigured(),
            builder: (context, snapshot) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: snapshot.data == true ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      snapshot.data == true ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                      Text(
                      snapshot.data == true ? 'GPT-4o' : 'Config',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Churn Analytics only for admins
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.insights),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChurnAnalyticsScreen(),
                  ),
                );
              },
              tooltip: 'Churn Analysis',
            ),
          IconButton(
            icon: const Icon(Icons.wifi_find),
            onPressed: _testOpenAIConnection,
            tooltip: 'Test OpenAI Connection',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh Analytics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Analytics Overview Card (only for admins)
          if (_isAdmin) ...[
            if (_isLoadingAnalytics)
              const LinearProgressIndicator()
            else if (_analytics != null)
              _buildAnalyticsOverview(),
          ],
          
          // Chat Interface
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _chatHistory.length && _isLoading) {
                          return _buildTypingIndicator();
                        }
                        return _buildChatMessage(_chatHistory[index]);
                      },
                    ),
                  ),
                  _buildInputArea(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview() {
    final analytics = _analytics!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Real-time Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Users',
                  '${analytics.totalUsers}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Total Referrals',
                  '${analytics.totalReferrals}',
                  Icons.share,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Conversion Rate',
                  '${(analytics.conversionRate * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'ROI',
                  '${analytics.roi.roiPercentage.toStringAsFixed(0)}%',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(AIResponse response) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User query (if not welcome message)
          if (response.query.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  response.query,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // AI response
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI Agent',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(response.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(response.response),
                
                // Insights
                if (response.insights.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Key Insights',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...response.insights.map((insight) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: Colors.blue)),
                              Expanded(child: Text(insight)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
                
                // Suggested questions
                if (response.suggestedQuestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Try asking:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: response.suggestedQuestions.map((question) {
                      return InkWell(
                        onTap: () => _sendQuery(question),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF1F2937).withOpacity(0.3)),
                          ),
                          child: Text(
                            question,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue = (_typingAnimation.value - delay).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: Transform.translate(
                        offset: Offset(0, -10 * animationValue),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937).withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              'AI is thinking...',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'Ask me anything about your referral program...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF1F2937)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: _sendQuery,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : () => _sendQuery(_queryController.text),
            backgroundColor: const Color(0xFF1F2937),
            mini: true,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
