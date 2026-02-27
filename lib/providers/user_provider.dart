// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';

// ─── User / Auth ──────────────────────────────────────────────────────────────
class UserProvider extends ChangeNotifier {
  String? _name;
  String? _email;
  bool    _twoFactorEnabled  = false;
  bool    _dataSharing       = true;
  bool    _securityAlerts    = true;

  String? get name  => _name;
  String? get email => _email;
  bool    get isLoggedIn       => _name != null;
  bool    get twoFactorEnabled => _twoFactorEnabled;
  bool    get dataSharing      => _dataSharing;
  bool    get securityAlerts   => _securityAlerts;

  void login(String name, String email) {
    _name  = name;
    _email = email;
    notifyListeners();
  }

  void logout() {
    _name  = null;
    _email = null;
    notifyListeners();
  }

  void deleteAccount() => logout();

  void setTwoFactor(bool v)       { _twoFactorEnabled = v; notifyListeners(); }
  void setDataSharing(bool v)     { _dataSharing = v;      notifyListeners(); }
  void setSecurityAlerts(bool v)  { _securityAlerts = v;   notifyListeners(); }
}

// ─── Cart ─────────────────────────────────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items  => _items.values.toList();
  int            get count  => _items.values.fold(0, (s, e) => s + e.quantity);
  double         get total  => _items.values
      .fold(0.0, (s, e) => s + e.product.price * e.quantity);

  void add(Product p) {
    if (_items.containsKey(p.id)) {
      _items[p.id]!.quantity++;
    } else {
      _items[p.id] = CartItem(product: p);
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool contains(String id) => _items.containsKey(id);
}
