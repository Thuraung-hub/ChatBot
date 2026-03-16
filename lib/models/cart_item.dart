class CartItem {
  final String id;
  final String productId;
  int quantity;
  final String productName;
  final double productPrice;
  final String productImageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
  });

  factory CartItem.fromMap(String id, Map<String, dynamic> data) {
    return CartItem(
      id: id,
      productId: data['productId'] ?? '',
      quantity: data['quantity'] ?? 1,
      productName: data['productName'] ?? '',
      productPrice: (data['productPrice'] ?? 0).toDouble(),
      productImageUrl: data['productImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'productName': productName,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
    };
  }

  double get subtotal => productPrice * quantity;
}
