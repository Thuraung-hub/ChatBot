import '../models/product.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService _productService = ProductService();

  // ============ GET ALL PRODUCTS ============
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await _productService.getProducts(
        page: page,
        limit: limit,
      );
      return data
          .map((e) {
            try {
              final map = e as Map<String, dynamic>;
              final id = map['id'] as String? ?? '';
              return Product.fromMap(id, map);
            } catch (e) {
              return null;
            }
          })
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw 'Failed to load products: $e';
    }
  }

  // ============ GET SINGLE PRODUCT ============
  Future<Product> getProduct(String id) async {
    try {
      final data = await _productService.getProduct(id);
      return Product.fromMap(id, data);
    } catch (e) {
      throw 'Failed to load product: $e';
    }
  }

  // ============ SEARCH PRODUCTS ============
  Future<List<Product>> searchProducts(String query) async {
    try {
      final data = await _productService.searchProducts(query);
      return data
          .map((e) {
            try {
              final map = e as Map<String, dynamic>;
              final id = map['id'] as String? ?? '';
              return Product.fromMap(id, map);
            } catch (e) {
              return null;
            }
          })
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw 'Failed to search products: $e';
    }
  }

  // ============ GET FEATURED PRODUCTS ============
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final data = await _productService.getFeaturedProducts();
      return data
          .map((e) {
            try {
              final map = e as Map<String, dynamic>;
              final id = map['id'] as String? ?? '';
              return Product.fromMap(id, map);
            } catch (e) {
              return null;
            }
          })
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw 'Failed to load featured products: $e';
    }
  }

  // ============ GET CATEGORIES ============
  Future<List<dynamic>> getCategories() async {
    try {
      return await _productService.getCategories();
    } catch (e) {
      throw 'Failed to load categories: $e';
    }
  }
}
