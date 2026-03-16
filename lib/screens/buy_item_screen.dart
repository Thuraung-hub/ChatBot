import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart' as app;

class BuyItemScreen extends StatelessWidget {
  const BuyItemScreen({super.key});

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app.AuthProvider>();
    final uid = auth.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Item'),
      ),
      body: uid == null
          ? const Center(
              child: Text(
                'Please log in to see your purchased items.',
                style: TextStyle(color: AppTheme.textGray),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users/$uid/orders')
                  .orderBy('orderedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.royalBlue),
                  );
                }

                final orders = snapshot.data!.docs;

                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No purchased items yet.',
                      style: TextStyle(color: AppTheme.textGray),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final data = orders[index].data() as Map<String, dynamic>;
                    final name = (data['productName'] ?? 'Unknown Item').toString();
                    final price = (data['productPrice'] ?? 0).toDouble();
                    final image = (data['productImageUrl'] ?? '').toString();
                    final deliveryDate =
                        _formatDate((data['deliveryDate'] ?? '').toString());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderGray),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: image.isEmpty
                                ? Container(
                                    width: 64,
                                    height: 64,
                                    color: AppTheme.bgGray,
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppTheme.textGray,
                                    ),
                                  )
                                : Image.network(
                                    image,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 64,
                                      height: 64,
                                      color: AppTheme.bgGray,
                                      child: const Icon(
                                        Icons.broken_image_outlined,
                                        color: AppTheme.textGray,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: AppTheme.dark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Price: \$${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppTheme.royalBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Delivery Date: $deliveryDate',
                                  style: const TextStyle(
                                    color: AppTheme.textGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
