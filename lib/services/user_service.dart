import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // ============ GET USER PROFILE ============
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('users/$userId');
      return response['data'] ?? response;
    } catch (e) {
      throw 'Failed to fetch user profile: $e';
    }
  }

  // ============ UPDATE USER PROFILE ============
  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      return await _apiService.put('users/$userId', profileData);
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // ============ GET USER ADDRESSES ============
  Future<List<dynamic>> getUserAddresses(String userId) async {
    try {
      final response = await _apiService.get('users/$userId/addresses');
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch user addresses: $e';
    }
  }

  // ============ ADD USER ADDRESS ============
  Future<Map<String, dynamic>> addUserAddress(
    String userId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      return await _apiService.post('users/$userId/addresses', addressData);
    } catch (e) {
      throw 'Failed to add address: $e';
    }
  }

  // ============ UPDATE USER ADDRESS ============
  Future<Map<String, dynamic>> updateUserAddress(
    String userId,
    String addressId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      return await _apiService.put(
        'users/$userId/addresses/$addressId',
        addressData,
      );
    } catch (e) {
      throw 'Failed to update address: $e';
    }
  }

  // ============ DELETE USER ADDRESS ============
  Future<Map<String, dynamic>> deleteUserAddress(
    String userId,
    String addressId,
  ) async {
    try {
      return await _apiService.delete('users/$userId/addresses/$addressId');
    } catch (e) {
      throw 'Failed to delete address: $e';
    }
  }

  // ============ GET USER WISHLIST ============
  Future<List<dynamic>> getUserWishlist(String userId) async {
    try {
      final response = await _apiService.get('users/$userId/wishlist');
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch wishlist: $e';
    }
  }

  // ============ ADD TO WISHLIST ============
  Future<Map<String, dynamic>> addToWishlist(
    String userId,
    String productId,
  ) async {
    try {
      return await _apiService.post('users/$userId/wishlist', {
        'productId': productId,
      });
    } catch (e) {
      throw 'Failed to add to wishlist: $e';
    }
  }

  // ============ REMOVE FROM WISHLIST ============
  Future<Map<String, dynamic>> removeFromWishlist(
    String userId,
    String productId,
  ) async {
    try {
      return await _apiService.post('users/$userId/wishlist/remove', {
        'productId': productId,
      });
    } catch (e) {
      throw 'Failed to remove from wishlist: $e';
    }
  }

  // ============ GET USER REVIEWS ============
  Future<List<dynamic>> getUserReviews(String userId) async {
    try {
      final response = await _apiService.get('users/$userId/reviews');
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch user reviews: $e';
    }
  }

  // ============ CREATE REVIEW ============
  Future<Map<String, dynamic>> createReview(
    String userId,
    String productId,
    int rating,
    String comment,
  ) async {
    try {
      return await _apiService.post('reviews', {
        'userId': userId,
        'productId': productId,
        'rating': rating,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to create review: $e';
    }
  }
}
