import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/chat_fallback_handler.dart';
import '../services/gemini_client.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiClient _geminiClient;

  ChatProvider({required GeminiClient geminiClient})
      : _geminiClient = geminiClient;

  bool _loading = false;
  bool _clearing = false;
  String? _lastReply;

  bool get loading => _loading;
  bool get clearing => _clearing;
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

  Future<void> clearChatHistory(String uid) async {
    if (uid.isEmpty) return;

    _clearing = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chat')
          .where('userId', isEqualTo: uid)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _lastReply = null;
    } catch (e) {
      rethrow;
    } finally {
      _clearing = false;
      notifyListeners();
    }
  }
}
