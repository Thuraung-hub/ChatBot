import 'package:flutter_test/flutter_test.dart';
import 'package:pinky_shop/providers/chat_provider.dart';
import 'package:pinky_shop/services/gemini_client.dart';

class _SuccessGeminiClient implements GeminiClient {
  @override
  Future<String> generateReply(String prompt) async {
    return 'Gemini says hello';
  }
}

class _FailedGeminiClient implements GeminiClient {
  @override
  Future<String> generateReply(String prompt) async {
    throw Exception('Gemini unavailable');
  }
}

void main() {
  group('ChatProvider', () {
    test('returns Gemini reply on successful API response', () async {
      final provider = ChatProvider(geminiClient: _SuccessGeminiClient());

      final reply = await provider.ask('Tell me about iphone 15');

      expect(reply, 'Gemini says hello');
      expect(provider.lastReply, 'Gemini says hello');
      expect(provider.loading, false);
    });

    test('returns local fallback reply on failed API response', () async {
      final provider = ChatProvider(geminiClient: _FailedGeminiClient());

      final reply = await provider.ask('Do you have iphone 15 in stock?');

      expect(reply, contains('Local Catalog Match'));
      expect(reply, contains('Category: iPhone'));
      expect(reply, contains('iPhone 15'));
      expect(provider.loading, false);
    });
  });
}
