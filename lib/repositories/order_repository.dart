import '../services/order_service.dart';

class OrderRepository {
  final OrderService _orderService = OrderService();

  // ============ CREATE ORDER ============
  Future<Map<String, dynamic>> createOrder(
    String userId,
    List<Map<String, dynamic>> items,
    double total, {
    String shippingAddress = '',
    String paymentMethod = 'card',
  }) async {
    try {
      return await _orderService.createOrder(
        userId,
        items,
        total,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      throw 'Failed to create order: $e';
    }
  }

  // ============ GET USER ORDERS ============
  Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      return await _orderService.getUserOrders(userId);
    } catch (e) {
      throw 'Failed to load user orders: $e';
    }
  }

  // ============ GET ORDER DETAILS ============
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      return await _orderService.getOrder(orderId);
    } catch (e) {
      throw 'Failed to load order: $e';
    }
  }

  // ============ CANCEL ORDER ============
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      return await _orderService.cancelOrder(orderId);
    } catch (e) {
      throw 'Failed to cancel order: $e';
    }
  }

  // ============ TRACK ORDER ============
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      return await _orderService.trackOrder(orderId);
    } catch (e) {
      throw 'Failed to track order: $e';
    }
  }
}
