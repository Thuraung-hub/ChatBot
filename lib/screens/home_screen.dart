import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart' as app;
import '../widgets/product_card.dart';

const _sampleProducts = [
  {
    'name': 'Premium Wireless Headphones',
    'description':
        'High-fidelity audio with active noise cancellation and 40-hour battery life.',
    'price': 299.99,
    'imageUrl':
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=1000',
    'category': 'Electronics',
  },
  {
    'name': 'Minimalist Leather Watch',
    'description':
        'Elegant timepiece with genuine Italian leather strap and sapphire crystal.',
    'price': 189.00,
    'imageUrl':
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=1000',
    'category': 'Accessories',
  },
  {
    'name': 'Smart Home Assistant',
    'description':
        'Voice-controlled hub for your smart home with premium speaker quality.',
    'price': 129.50,
    'imageUrl':
        'https://images.unsplash.com/photo-1589492477829-5e65395b66cc?auto=format&fit=crop&q=80&w=1000',
    'category': 'Electronics',
  },
  {
    'name': 'Ergonomic Office Chair',
    'description':
        'Breathable mesh back with adjustable lumbar support for all-day comfort.',
    'price': 450.00,
    'imageUrl':
        'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?auto=format&fit=crop&q=80&w=1000',
    'category': 'Furniture',
  },
  {
    'name': 'Professional Camera Lens',
    'description':
        'Ultra-wide angle prime lens for stunning landscape and architectural photography.',
    'price': 899.00,
    'imageUrl':
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=1000',
    'category': 'Photography',
  },
  {
    'name': 'Organic Cotton Hoodie',
    'description': 'Sustainable and incredibly soft hoodie for everyday comfort.',
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
    for (final p in _sampleProducts) {
      await db.collection('products').add(p);
    }
  }

  Future<void> _addToCart(BuildContext context, Product product) async {
    final auth = context.read<app.AuthProvider>();
    if (auth.user == null) {
      Navigator.pushNamed(context, '/login');
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
        content: Text('${product.name} added to cart'),
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
                                child: Container(height: 1, color: AppTheme.borderGray)),
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
    final auth = context.watch<app.AuthProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (auth.isAdmin)
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/admin'),
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
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded,
              color: AppTheme.dark),
          onPressed: () => Navigator.pushNamed(context, '/chat'),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, color: AppTheme.dark),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }
}
