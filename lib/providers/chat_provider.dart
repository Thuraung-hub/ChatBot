// lib/providers/chat_provider.dart
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

class ChatProvider extends ChangeNotifier {
  // ⚠️  Replace with your actual Gemini API key or inject via env
  static const _apiKey = 'YOUR_GEMINI_API_KEY';

  late final GenerativeModel _model;
  late final ChatSession      _session;

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool              get isTyping => _isTyping;

  ChatProvider() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are the Stitch Shop AI — a stylish, concise personal shopper '
        'and tech expert for a premium e-commerce store that sells iPhones '
        'and premium apparel. Keep answers short (2–4 sentences), fashion-forward, '
        'and enthusiastic. When recommending products, mention the iPhone name '
        'and one standout feature. Never break character.',
      ),
    );
    _session = _model.startChat();

    // Seed greeting
    _messages.add(ChatMessage(
      id: 'seed',
      text: 'Hey there! 👋 I\'m your personal style & tech assistant. '
            'Shopping for a new iPhone or need outfit inspo? I\'ve got you covered.',
      isUser: false,
    ));
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(
      id: DateTime.now().toIso8601String(),
      text: text.trim(),
      isUser: true,
    ));
    _isTyping = true;
    notifyListeners();

    try {
      final response = await _session.sendMessage(Content.text(text.trim()));
      final reply = response.text ?? 'Sorry, I couldn\'t process that. Try again!';
      _messages.add(ChatMessage(
        id: '${DateTime.now().toIso8601String()}_ai',
        text: reply,
        isUser: false,
      ));
    } catch (e) {
      // Fallback if API key not configured
      await Future.delayed(const Duration(milliseconds: 800));
      _messages.add(ChatMessage(
        id: '${DateTime.now().toIso8601String()}_ai',
        text: _fallbackReply(text),
        isUser: false,
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
  String _fallbackReply(String input) {
    final q = input.toLowerCase();
    if (q.contains('iphone 15') || q.contains('latest')) {
      return 'The iPhone 15 is our crown jewel 👑 — USB-C, Dynamic Island, '
             'and a titanium Pro frame. At \$999, it\'s pure luxury tech.';
    } else if (q.contains('budget') || q.contains('cheap')) {
      return 'The iPhone 5 at \$149 is a sleek collector\'s piece, '
             'but the iPhone 11 at \$549 gives you Night Mode and 5G-ready prep.';
    } else if (q.contains('camera') || q.contains('photo')) {
      return 'For photography, the iPhone 13 or 15 are elite. '
             'Cinematic Mode + 48 MP sensor = magic. 📸';
    } else if (q.contains('hello') || q.contains('hi')) {
      return 'Hey! Great style starts with the right tech. '
             'What are you looking for today? 🛍️';
    }
    return 'Great question! Browse our full iPhone collection from the 5 to the 15. '
           'Each one tells a chapter of Apple\'s story. Which era speaks to you? ✨';
  }

  void clearChat() {
    _messages.removeWhere((m) => m.id != 'seed');
    notifyListeners();
  }
}
// Note: In a production app, never hardcode API keys. Use secure storage or environment variables.