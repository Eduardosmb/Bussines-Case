import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _openaiApiKeyKey = 'openai_api_key';
  
  /// Save OpenAI API key securely
  static Future<void> saveOpenAIApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_openaiApiKeyKey, apiKey);
  }
  
  /// Get saved OpenAI API key
  static Future<String?> getOpenAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_openaiApiKeyKey);
  }
  
  /// Check if API key is configured
  static Future<bool> hasOpenAIApiKey() async {
    final apiKey = await getOpenAIApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  /// Clear API key
  static Future<void> clearOpenAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_openaiApiKeyKey);
  }
  
  /// Validate API key format
  static bool isValidApiKey(String apiKey) {
    // OpenAI API keys typically start with 'sk-' and are around 51 characters
    return apiKey.startsWith('sk-') && apiKey.length >= 40;
  }
}

