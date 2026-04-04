import 'package:flutter_test/flutter_test.dart';
import 'package:pinky_shop/models/cart_item.dart';
import 'package:pinky_shop/providers/cart_provider.dart';

void main() {
  group('CartProvider total price calculations', () {
    test('empty cart starts with zero total and no items', () {
      final provider = CartProvider();

      expect(provider.totalAmount, 0.0);
      expect(provider.items, isEmpty);
    });

    test('adding items updates total price correctly', () {
      final provider = CartProvider();

      provider.addItem(CartItem(
        id: '1',
        productId: 'p1',
        quantity: 1,
        productName: 'T-Shirt',
        productPrice: 20.0,
        productImageUrl: '',
      ));
      provider.addItem(CartItem(
        id: '2',
        productId: 'p2',
        quantity: 2,
        productName: 'Jeans',
        productPrice: 30.0,
        productImageUrl: '',
      ));

      expect(provider.totalAmount, 80.0);
    });

    test('removing an item updates total price correctly', () {
      final provider = CartProvider();

      provider.addItem(CartItem(
        id: '1',
        productId: 'p1',
        quantity: 1,
        productName: 'T-Shirt',
        productPrice: 20.0,
        productImageUrl: '',
      ));
      provider.addItem(CartItem(
        id: '2',
        productId: 'p2',
        quantity: 2,
        productName: 'Jeans',
        productPrice: 30.0,
        productImageUrl: '',
      ));

      provider.removeItem('p1');

      expect(provider.totalAmount, 60.0);
      expect(provider.items.length, 1);
    });

    test('clearing items resets total price to zero', () {
      final provider = CartProvider();

      provider.addItem(CartItem(
        id: '1',
        productId: 'p1',
        quantity: 3,
        productName: 'Hoodie',
        productPrice: 25.0,
        productImageUrl: '',
      ));

      provider.clearItems();

      expect(provider.totalAmount, 0.0);
      expect(provider.items, isEmpty);
    });
  });
}
