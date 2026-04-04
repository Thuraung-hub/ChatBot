import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_constants.dart';
import '../config/app_config.dart';

abstract class GeminiClient {
  Future<String> generateReply(String prompt);
}

class HttpGeminiClient implements GeminiClient {
  @override
  Future<String> generateReply(String prompt) async {
    final apiKey = Config.geminiApiKey;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    ).timeout(
      const Duration(seconds: AppConstants.apiTimeoutSeconds),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return '';
    }

    final first = candidates.first as Map<String, dynamic>;
    final content = first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return '';
    }

    final text = (parts.first as Map<String, dynamic>)['text'] as String?;
    return text?.trim() ?? '';
  }
}
