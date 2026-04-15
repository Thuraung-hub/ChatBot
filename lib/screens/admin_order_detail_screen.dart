import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/responsive.dart';

class AdminOrderDetailScreen extends StatefulWidget {
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
  State<AdminOrderDetailScreen> createState() =>
      _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late Future<String?> _billSlipFuture;

  @override
  void initState() {
    super.initState();
    _billSlipFuture = _fetchBillSlipUrl();
  }

  Future<String?> _fetchBillSlipUrl() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users/${widget.customerId}/orders')
          .where('productName', isEqualTo: widget.productName)
          .orderBy('orderedAt', descending: true)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) return null;
      final data = doc.docs.first.data();
      final url = (data['billSlipUrl'] ?? '').toString().trim();
      return url.isEmpty ? null : url;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final pagePadding = context.responsivePadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<String?>(
        future: _billSlipFuture,
        builder: (context, snapshot) {
          final billSlipUrl = snapshot.data;

          return ListView(
            padding: EdgeInsets.all(pagePadding),
            children: [
              if (widget.productImageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: widget.productImageUrl,
                    height: isMobile ? 200 : 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      height: isMobile ? 200 : 240,
                      color: AppTheme.bgGray,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              if (widget.productImageUrl.isNotEmpty)
                SizedBox(height: isMobile ? 14 : 18),
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productName,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${widget.productPrice}',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DetailTile(label: 'Customer Name', value: widget.customerName),
                    _DetailTile(label: 'Customer Email', value: widget.customerEmail),
                    _DetailTile(label: 'Customer ID', value: widget.customerId),
                    _DetailTile(label: 'Order Status', value: widget.status),
                    _DetailTile(label: 'Ordered At', value: widget.orderedAt),
                    _DetailTile(label: 'Delivery Date', value: widget.deliveryDate),
                    _DetailTile(
                      label: 'Notification ID',
                      value: widget.notificationId,
                    ),
                  ],
                ),
              ),
              if (billSlipUrl != null) ...[
                SizedBox(height: isMobile ? 14 : 18),
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Payment Bill Slip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: billSlipUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            height: 200,
                            color: AppTheme.bgGray,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppTheme.textGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Customer uploaded this bill slip as proof of payment.',
                        style: TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
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
