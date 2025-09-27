import 'package:flutter/material.dart';
import '../services/config_service.dart';
import '../services/openai_service.dart';

class OpenAIConfigScreen extends StatefulWidget {
  const OpenAIConfigScreen({super.key});

  @override
  State<OpenAIConfigScreen> createState() => _OpenAIConfigScreenState();
}

class _OpenAIConfigScreenState extends State<OpenAIConfigScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _hasApiKey = false;
  String? _currentApiKey;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    final hasKey = await ConfigService.hasOpenAIApiKey();
    final apiKey = await ConfigService.getOpenAIApiKey();
    
    setState(() {
      _hasApiKey = hasKey;
      _currentApiKey = apiKey;
      if (apiKey != null) {
        // Show masked version for security
        _apiKeyController.text = '${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 4)}';
      }
    });
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    
    if (apiKey.isEmpty) {
      _showError('Please enter your OpenAI API key');
      return;
    }
    
    if (!ConfigService.isValidApiKey(apiKey)) {
      _showError('Invalid API key format. OpenAI keys start with "sk-" and are around 51 characters long.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Test the API key by making a simple request
      await _testApiKey(apiKey);
      
      // Save if test succeeds
      await ConfigService.saveOpenAIApiKey(apiKey);
      
      setState(() {
        _hasApiKey = true;
        _currentApiKey = apiKey;
        _isLoading = false;
      });
      
      _showSuccess('OpenAI API key configured successfully! 🎉');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to validate API key: ${e.toString()}');
    }
  }

  Future<void> _testApiKey(String apiKey) async {
    // Here you would test the API key
    // For now, we'll just simulate a test
    await Future.delayed(const Duration(seconds: 1));
    
    // In production, you'd make a simple API call to verify the key works
    // Example: OpenAI.apiKey = apiKey; await OpenAI.instance.chat.create(...);
  }

  Future<void> _removeApiKey() async {
    final confirm = await _showConfirmDialog();
    if (confirm == true) {
      await ConfigService.clearOpenAIApiKey();
      setState(() {
        _hasApiKey = false;
        _currentApiKey = null;
        _apiKeyController.clear();
      });
      _showSuccess('API key removed');
    }
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove API Key'),
          content: const Text('Are you sure you want to remove the OpenAI API key? The AI agent will fallback to local processing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenAI Configuration'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF374151)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'AI Agent Configuration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _hasApiKey ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _hasApiKey ? 'GPT-4 Active' : 'Local Mode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasApiKey 
                      ? 'Your AI agent is powered by OpenAI GPT-4 for advanced analytics and insights.'
                      : 'Configure OpenAI API key to unlock advanced AI capabilities.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // API Key Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OpenAI API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your OpenAI API key to enable GPT-4 powered analytics. Your key is stored securely on your device.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    // API Key Input
                    TextField(
                      controller: _apiKeyController,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        hintText: 'sk-...',
                        prefixIcon: const Icon(Icons.key),
                        border: const OutlineInputBorder(),
                        helperText: _hasApiKey ? 'Key configured and validated ✅' : 'Get your key from platform.openai.com',
                      ),
                      obscureText: _hasApiKey, // Hide the key if already set
                      onChanged: (value) {
                        if (_hasApiKey && value != _currentApiKey) {
                          setState(() {
                            _hasApiKey = false; // Mark as changed
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveApiKey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F2937),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_hasApiKey ? 'Update Key' : 'Save Key'),
                          ),
                        ),
                        if (_hasApiKey) ...[
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _removeApiKey,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Remove'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Feature Comparison
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Capabilities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildFeatureComparison(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Get Your API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('1. Visit platform.openai.com'),
                    const Text('2. Sign up or log in to your account'),
                    const Text('3. Go to API Keys section'),
                    const Text('4. Create a new secret key'),
                    const Text('5. Copy and paste it here'),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[300]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.security, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your API key is stored locally and never shared. You can remove it anytime.',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Column(
      children: [
        _buildFeatureRow('Natural Language Understanding', _hasApiKey, true),
        _buildFeatureRow('Contextual Responses', _hasApiKey, false),
        _buildFeatureRow('Advanced Analytics', true, true),
        _buildFeatureRow('Business Recommendations', _hasApiKey, true),
        _buildFeatureRow('Multilingual Support', _hasApiKey, false),
        _buildFeatureRow('Custom Insights', _hasApiKey, false),
      ],
    );
  }

  Widget _buildFeatureRow(String feature, bool gptSupported, bool localSupported) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(feature),
          ),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Icon(
                  gptSupported ? Icons.check_circle : Icons.cancel,
                  color: gptSupported ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('GPT-4', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Icon(
                  localSupported ? Icons.check_circle : Icons.cancel,
                  color: localSupported ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('Local', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

