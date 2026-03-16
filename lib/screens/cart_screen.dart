import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/cart_item.dart';
import '../providers/auth_provider.dart' as app;
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<app.AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users/$uid/cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const _EmptyCart();

          final items = docs
              .map((d) =>
                  CartItem.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList();

            final total = items.fold<double>(
              0, (runningTotal, item) => runningTotal + item.subtotal);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _CartItemTile(item: items[i], uid: uid),
                ),
              ),
              _OrderSummary(total: total),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final String uid;

  const _CartItemTile({required this.item, required this.uid});

  Future<void> _updateQty(int delta) async {
    final ref = FirebaseFirestore.instance
        .collection('users/$uid/cart')
        .doc(item.id);
    if (item.quantity + delta <= 0) {
      await ref.delete();
    } else {
      await ref.update({'quantity': FieldValue.increment(delta)});
    }
  }

  Future<void> _remove() async {
    await FirebaseFirestore.instance
        .collection('users/$uid/cart')
        .doc(item.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 84,
              height: 84,
              child: CachedNetworkImage(
                imageUrl: item.productImageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                    color: AppTheme.bgGray,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppTheme.textGray)),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.productName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppTheme.dark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    GestureDetector(
                      onTap: _remove,
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppTheme.textGray, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('\$${item.productPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bgGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderGray),
                      ),
                      child: Row(
                        children: [
                          _QtyBtn(icon: Icons.remove, onTap: () => _updateQty(-1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('${item.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.dark)),
                          ),
                          _QtyBtn(icon: Icons.add, onTap: () => _updateQty(1)),
                        ],
                      ),
                    ),
                    Text('Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppTheme.dark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, size: 16, color: AppTheme.dark),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double total;
  const _OrderSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.borderGray)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _Row('Subtotal', '\$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const _Row('Shipping', 'Free', valueColor: AppTheme.green),
            const SizedBox(height: 8),
            const _Row('Tax', '\$0.00'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppTheme.borderGray),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.dark)),
                Text('\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dark,
                    padding: const EdgeInsets.symmetric(vertical: 18)),
                child: const Text('Checkout Now',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('SECURE SSL ENCRYPTION',
                style: TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.w500)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? AppTheme.textGray,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.bgGray,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 64, color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),
            const Text('Your cart is empty',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.dark)),
            const SizedBox(height: 8),
            const Text(
                "Looks like you haven't added anything to your cart yet.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textGray)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
