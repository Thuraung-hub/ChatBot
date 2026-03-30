import 'api_service.dart';

class CartService {
  final ApiService _apiService = ApiService();

  // ============ ADD TO CART ============
  Future<Map<String, dynamic>> addToCart(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      return await _apiService.post('cart/add', {
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      });
    } catch (e) {
      throw 'Failed to add to cart: $e';
    }
  }

  // ============ GET CART ============
  Future<Map<String, dynamic>> getCart(String userId) async {
    try {
      final response = await _apiService.get('cart/$userId');
      return response['data'] ?? response;
    } catch (e) {
      throw 'Failed to fetch cart: $e';
    }
  }

  // ============ UPDATE CART ITEM ============
  Future<Map<String, dynamic>> updateCartItem(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      return await _apiService.put('cart/update', {
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      });
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
      return await _apiService.post('cart/remove', {
        'userId': userId,
        'productId': productId,
      });
    } catch (e) {
      throw 'Failed to remove from cart: $e';
    }
  }

  // ============ CLEAR CART ============
  Future<Map<String, dynamic>> clearCart(String userId) async {
    try {
      return await _apiService.post('cart/clear', {
        'userId': userId,
      });
    } catch (e) {
      throw 'Failed to clear cart: $e';
    }
  }

  // ============ GET CART TOTAL ============
  Future<double> getCartTotal(String userId) async {
    try {
      final response = await _apiService.get('cart/$userId/total');
      return (response['total'] as num?)?.toDouble() ?? 0.0;
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
      return await _apiService.post('cart/coupon', {
        'userId': userId,
        'couponCode': couponCode,
      });
    } catch (e) {
      throw 'Failed to apply coupon: $e';
    }
  }
}
