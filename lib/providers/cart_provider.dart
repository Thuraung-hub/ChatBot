import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice =>
      _items.fold<double>(0, (sum, item) => sum + item.subtotal);

  void addItem(CartItem item) {
    final index = _items.indexWhere((existing) => existing.productId == item.productId);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    notifyListeners();
  }
}
