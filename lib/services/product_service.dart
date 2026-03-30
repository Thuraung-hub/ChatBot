import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // ============ GET ALL PRODUCTS ============
  Future<List<dynamic>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        'products?page=$page&limit=$limit',
      );
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  // ============ GET SINGLE PRODUCT ============
  Future<Map<String, dynamic>> getProduct(String id) async {
    try {
      final response = await _apiService.get('products/$id');
      return response['data'] ?? response;
    } catch (e) {
      throw 'Failed to fetch product: $e';
    }
  }

  // ============ SEARCH PRODUCTS ============
  Future<List<dynamic>> searchProducts(String query) async {
    try {
      final response = await _apiService.get(
        'products/search?q=$query',
      );
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to search products: $e';
    }
  }

  // ============ GET CATEGORIES ============
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _apiService.get('categories');
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch categories: $e';
    }
  }

  // ============ GET PRODUCTS BY CATEGORY ============
  Future<List<dynamic>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _apiService.get(
        'products?category=$categoryId',
      );
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch products by category: $e';
    }
  }

  // ============ GET FEATURED PRODUCTS ============
  Future<List<dynamic>> getFeaturedProducts() async {
    try {
      final response = await _apiService.get('products/featured');
      return response['data'] ?? [];
    } catch (e) {
      throw 'Failed to fetch featured products: $e';
    }
  }

  // ============ CREATE PRODUCT (ADMIN) ============
  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> productData,
  ) async {
    try {
      return await _apiService.post('products', productData);
    } catch (e) {
      throw 'Failed to create product: $e';
    }
  }

  // ============ UPDATE PRODUCT (ADMIN) ============
  Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
      return await _apiService.put('products/$id', productData);
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  // ============ DELETE PRODUCT (ADMIN) ============
  Future<Map<String, dynamic>> deleteProduct(String id) async {
    try {
      return await _apiService.delete('products/$id');
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }
}
