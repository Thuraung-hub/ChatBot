import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  final String notificationId;
  final String customerName;
  final String customerEmail;
  final String customerId;
  final String productName;
  final String productPrice;
  final String productImageUrl;
  final String orderedAt;
  final String deliveryDate;
  final String status;

  const AdminOrderDetailScreen({
    super.key,
    required this.notificationId,
    required this.customerName,
    required this.customerEmail,
    required this.customerId,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    required this.orderedAt,
    required this.deliveryDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (productImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: productImageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 240,
                  color: AppTheme.bgGray,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          if (productImageUrl.isNotEmpty) const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$$productPrice',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                _DetailTile(label: 'Customer Name', value: customerName),
                _DetailTile(label: 'Customer Email', value: customerEmail),
                _DetailTile(label: 'Customer ID', value: customerId),
                _DetailTile(label: 'Order Status', value: status),
                _DetailTile(label: 'Ordered At', value: orderedAt),
                _DetailTile(label: 'Delivery Date', value: deliveryDate),
                _DetailTile(label: 'Notification ID', value: notificationId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textGray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}