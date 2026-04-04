import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../app_theme.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../widgets/product_card.dart';

const _sampleProducts = [
  {
    'id': 'sample-premium-wireless-headphones',
    'name': 'Premium Wireless Headphones',
    'description':
        'High-fidelity audio with active noise cancellation and 40-hour battery life.',
    'price': 299.99,
    'imageUrl':
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=1000',
    'category': 'Electronics',
  },
  {
    'id': 'sample-minimalist-leather-watch',
    'name': 'Minimalist Leather Watch',
    'description':
        'Elegant timepiece with genuine Italian leather strap and sapphire crystal.',
    'price': 189.00,
    'imageUrl':
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=1000',
    'category': 'Accessories',
  },
  {
    'id': 'sample-smart-home-assistant',
    'name': 'Smart Home Assistant',
    'description':
        'Voice-controlled hub for your smart home with premium speaker quality.',
    'price': 129.50,
    'imageUrl':
        'https://images.unsplash.com/photo-1589492477829-5e65395b66cc?auto=format&fit=crop&q=80&w=1000',
    'category': 'Electronics',
  },
  {
    'id': 'sample-ergonomic-office-chair',
    'name': 'Ergonomic Office Chair',
    'description':
        'Breathable mesh back with adjustable lumbar support for all-day comfort.',
    'price': 450.00,
    'imageUrl':
        'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?auto=format&fit=crop&q=80&w=1000',
    'category': 'Furniture',
  },
  {
    'id': 'sample-professional-camera-lens',
    'name': 'Professional Camera Lens',
    'description':
        'Ultra-wide angle prime lens for stunning landscape and architectural photography.',
    'price': 899.00,
    'imageUrl':
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=1000',
    'category': 'Photography',
  },
  {
    'id': 'sample-organic-cotton-hoodie',
    'name': 'Organic Cotton Hoodie',
    'description':
        'Sustainable and incredibly soft hoodie for everyday comfort.',
    'price': 75.00,
    'imageUrl':
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&q=80&w=1000',
    'category': 'Apparel',
  },
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _seedProducts() async {
    final db = FirebaseFirestore.instance;

    final existing = await db.collection('products').limit(1).get();
    if (existing.docs.isNotEmpty) {
      return;
    }

    final batch = db.batch();
    for (final p in _sampleProducts) {
      final data = Map<String, dynamic>.from(p);
      final id = data.remove('id') as String;
      batch.set(db.collection('products').doc(id), data);
    }
    await batch.commit();
  }

  Future<void> _addToCart(BuildContext context, Product product) async {
    final auth = context.read<AuthService>();
    if (auth.user == null) {
      Navigator.pushNamed(context, Routes.login.path);
      return;
    }
    final uid = auth.user!.uid;
    final db = FirebaseFirestore.instance;
    final cartSnap = await db.collection('users/$uid/cart').get();
    final existing =
        cartSnap.docs.where((d) => d.data()['productId'] == product.id);

    if (existing.isNotEmpty) {
      await db.collection('users/$uid/cart').doc(existing.first.id).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await db.collection('users/$uid/cart').add({
        'productId': product.id,
        'quantity': 1,
        'productName': product.name,
        'productPrice': product.price,
        'productImageUrl': product.imageUrl,
      });
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart'),
        action: SnackBarAction(
          label: 'Checkout Now',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, Routes.cart.path),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_bag_rounded, color: AppTheme.primary, size: 28),
            SizedBox(width: 8),
            Text('Pinky Shop',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        actions: [
          _NavActions(),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          // Seed if empty
          if (docs.isEmpty) {
            _seedProducts();
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final products = docs
              .map((d) =>
                  Product.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList();

          // Group by category
          final Map<String, List<Product>> grouped = {};
          for (final p in products) {
            grouped.putIfAbsent(p.category, () => []).add(p);
          }

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Discover Products',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textGray)),
                      const SizedBox(height: 4),
                      Text('Explore our curated collection of premium goods.',
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),

              // Categories
              ...grouped.entries.map((entry) {
                final category = entry.key;
                final categoryProducts = entry.value;
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(category,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textGray)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Container(
                                    height: 1, color: AppTheme.borderGray)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${categoryProducts.length} Items',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: categoryProducts.length,
                        itemBuilder: (context, i) {
                          final product = categoryProducts[i];
                          return ProductCard(
                            product: product,
                            onAddToCart: () => _addToCart(context, product),
                            onDelete: () => _deleteProduct(product.id),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),

              // Footer
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      '© 2026 Pinky Shop. Built with Flutter.',
                      style: TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (auth.isAdmin)
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, Routes.admin.path),
            icon: const Icon(Icons.shield_outlined,
                color: AppTheme.primary, size: 18),
            label: const Text('Admin',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        if (!auth.isAdmin)
          IconButton(
            icon:
                const Icon(Icons.shopping_cart_outlined, color: AppTheme.dark),
            onPressed: () => Navigator.pushNamed(context, Routes.cart.path),
          ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded,
              color: AppTheme.dark),
          onPressed: () => Navigator.pushNamed(context, Routes.chat.path),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, color: AppTheme.dark),
          onPressed: () => Navigator.pushNamed(context, Routes.profile.path),
        ),
      ],
    );
  }
}
