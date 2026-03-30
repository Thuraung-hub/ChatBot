import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // ============ CREATE ORDER ============
  Future<Map<String, dynamic>> createOrder(
    String userId,
    List<Map<String, dynamic>> items,
    double total, {
    String shippingAddress = '',
    String paymentMethod = 'card',
  }) async {
    try {
      return await _apiService.post('orders', {
        'userId': userId,
        'items': items,
        'total': total,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to create order: $e';
    }
  }

  // ============ GET USER ORDERS ============
  Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      final response = await _apiService.get('orders?userId=$userId');
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch user orders: $e';
    }
  }

  // ============ GET ORDER DETAILS ============
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await _apiService.get('orders/$orderId');
      return response['data'] ?? response;
    } catch (e) {
      throw 'Failed to fetch order: $e';
    }
  }

  // ============ CANCEL ORDER ============
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      return await _apiService.put('orders/$orderId', {
        'status': 'cancelled',
      });
    } catch (e) {
      throw 'Failed to cancel order: $e';
    }
  }

  // ============ UPDATE ORDER STATUS (ADMIN) ============
  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      return await _apiService.put('orders/$orderId', {
        'status': status,
      });
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  // ============ GET ALL ORDERS (ADMIN) ============
  Future<List<dynamic>> getAllOrders({
    String status = '',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String query = 'orders?page=$page&limit=$limit';
      if (status.isNotEmpty) {
        query += '&status=$status';
      }
      final response = await _apiService.get(query);
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  // ============ TRACK ORDER ============
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final response = await _apiService.get('orders/$orderId/track');
      return response['data'] ?? response;
    } catch (e) {
      throw 'Failed to track order: $e';
    }
  }
}
