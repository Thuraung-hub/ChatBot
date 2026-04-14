import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pinky_shop/main.dart' as app;
import 'package:pinky_shop/widgets/product_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('open product and launch quick checkout', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Assumes test user is authenticated and product list is visible.
    final firstProductCard = find.byType(ProductCard).first;
    expect(firstProductCard, findsOneWidget);

    await tester.tap(firstProductCard);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final buyNowButton = find.text('Buy Now');
    expect(buyNowButton, findsOneWidget);

    await tester.tap(buyNowButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Quick Checkout'), findsOneWidget);
  });
}
