import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pinky_shop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('open chat, send message, and verify response appears',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Assumes test user is already authenticated and lands on HomeScreen.
    final chatIcon = find.byIcon(Icons.chat_bubble_outline_rounded).first;
    expect(chatIcon, findsOneWidget);

    await tester.tap(chatIcon);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final input = find.byType(TextFormField).first;
    await tester.enterText(input, 'show me iphone 15 review');

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // User message should appear.
    expect(find.text('show me iphone 15 review'), findsOneWidget);

    // Bot response should also appear in chat.
    final botNameFinder = find.text('Shop Bot');
    expect(botNameFinder, findsWidgets);
  });
}
