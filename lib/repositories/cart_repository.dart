import '../services/cart_service.dart';

class CartRepository {
  final CartService _cartService = CartService();

  // ============ ADD TO CART ============
  Future<Map<String, dynamic>> addToCart(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      return await _cartService.addToCart(userId, productId, quantity);
    } catch (e) {
      throw 'Failed to add to cart: $e';
    }
  }

  // ============ GET CART ============
  Future<Map<String, dynamic>> getCart(String userId) async {
    try {
      return await _cartService.getCart(userId);
    } catch (e) {
      throw 'Failed to load cart: $e';
    }
  }

  // ============ UPDATE CART ITEM ============
  Future<Map<String, dynamic>> updateCartItem(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      return await _cartService.updateCartItem(userId, productId, quantity);
    } catch (e) {
      throw 'Failed to update cart item: $e';
    }
  }

  // ============ REMOVE FROM CART ============
  Future<Map<String, dynamic>> removeFromCart(
    String userId,
    String productId,
  ) async {
    try {
      return await _cartService.removeFromCart(userId, productId);
    } catch (e) {
      throw 'Failed to remove from cart: $e';
    }
  }

  // ============ CLEAR CART ============
  Future<Map<String, dynamic>> clearCart(String userId) async {
    try {
      return await _cartService.clearCart(userId);
    } catch (e) {
      throw 'Failed to clear cart: $e';
    }
  }

  // ============ GET CART TOTAL ============
  Future<double> getCartTotal(String userId) async {
    try {
      return await _cartService.getCartTotal(userId);
    } catch (e) {
      throw 'Failed to fetch cart total: $e';
    }
  }

  // ============ APPLY COUPON ============
  Future<Map<String, dynamic>> applyCoupon(
    String userId,
    String couponCode,
  ) async {
    try {
      return await _cartService.applyCoupon(userId, couponCode);
    } catch (e) {
      throw 'Failed to apply coupon: $e';
    }
  }
}
