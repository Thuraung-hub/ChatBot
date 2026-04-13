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
    if (apiKey.trim().isEmpty) {
      throw Exception('AI assistant is not configured right now.');
    }

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

    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response shape');
      }
      data = decoded;
    } catch (_) {
      throw Exception('AI service returned an unexpected response.');
    }

    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return '';
    }

    final first = candidates.first;
    if (first is! Map<String, dynamic>) {
      return '';
    }

    final content = first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return '';
    }

    final firstPart = parts.first;
    if (firstPart is! Map<String, dynamic>) {
      return '';
    }

    final text = firstPart['text'] as String?;
    return text?.trim() ?? '';
  }
}
