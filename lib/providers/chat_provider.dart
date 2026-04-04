import 'package:flutter/foundation.dart';

import '../services/chat_fallback_handler.dart';
import '../services/gemini_client.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiClient _geminiClient;

  ChatProvider({required GeminiClient geminiClient})
      : _geminiClient = geminiClient;

  bool _loading = false;
  String? _lastReply;

  bool get loading => _loading;
  String? get lastReply => _lastReply;

  Future<String> ask(String query) async {
    _loading = true;
    notifyListeners();

    try {
      final aiReply = (await _geminiClient.generateReply(query)).trim();
      if (aiReply.isNotEmpty) {
        _lastReply = aiReply;
        return aiReply;
      }

      final fallbackReply = ChatFallbackHandler.buildReply(query) ??
          'Sorry, I could not process your request right now.';
      _lastReply = fallbackReply;
      return fallbackReply;
    } catch (_) {
      final fallbackReply = ChatFallbackHandler.buildReply(query) ??
          'Sorry, I could not process your request right now.';
      _lastReply = fallbackReply;
      return fallbackReply;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
