import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/app_constants.dart';
import '../app_theme.dart';
import '../models/cart_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import '../services/monitoring_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
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
              _OrderSummary(total: total, uid: uid, items: items),
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
    final ref =
        FirebaseFirestore.instance.collection('users/$uid/cart').doc(item.id);
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
                          _QtyBtn(
                              icon: Icons.remove, onTap: () => _updateQty(-1)),
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

class _OrderSummary extends StatefulWidget {
  final double total;
  final String uid;
  final List<CartItem> items;

  const _OrderSummary(
      {required this.total, required this.uid, required this.items});

  @override
  State<_OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<_OrderSummary> {
  XFile? _billSlipImage;
  Uint8List? _billSlipBytes;
  bool _uploading = false;

  Future<void> _pickBillSlip() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 45,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        if (bytes.lengthInBytes > 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image is too large. Please choose a smaller image.'),
              backgroundColor: AppTheme.red,
            ),
          );
          return;
        }
        setState(() {
          _billSlipImage = image;
          _billSlipBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadBillSlip(String orderId) async {
    if (_billSlipBytes == null) return null;

    try {
      final fileName =
          'bill_slips/${widget.uid}/$orderId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref(fileName);
      final task = ref.putData(
        _billSlipBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      await task.timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          await task.cancel();
          throw TimeoutException('Bill slip upload timed out.');
        },
      );
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> _checkoutNow(BuildContext context) async {
    if (widget.items.isEmpty) return;

    // Show checkout dialog with bill slip option
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121826),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Complete Your Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF27324A)),
                ),
                child: const Row(
                  children: [
                    _CartStepPill(number: '1', label: 'Upload slip'),
                    SizedBox(width: 10),
                    Icon(Icons.chevron_right_rounded,
                        color: Color(0xFFB6C2D9)),
                    SizedBox(width: 10),
                    _CartStepPill(number: '2', label: 'Confirm order'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Upload Payment Bill Slip (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _billSlipImage != null
                  ? Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _billSlipBytes!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Change Image'),
                          onPressed: _pickBillSlip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.dark,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Upload Bill Slip'),
                      onPressed: _pickBillSlip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.dark,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
              const SizedBox(height: 16),
              const Text(
                'Note: You can upload a payment bill slip to expedite verification. This is optional.',
                style: TextStyle(
                  color: Color(0xFF9AA4B2),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9AA4B2)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.dark,
            ),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final trace = await MonitoringService.startTrace('cart_checkout_now');
    try {
      setState(() => _uploading = true);

      final now = DateTime.now();
      final deliveryDate =
          now.add(const Duration(days: AppConstants.deliveryLeadDays));
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      for (final item in widget.items) {
        final orderRef = db.collection('users/${widget.uid}/orders').doc();
        final orderId = orderRef.id;
        final cartRef = db.collection('users/${widget.uid}/cart').doc(item.id);

        // Upload bill slip if provided
        String? billSlipUrl;
        if (_billSlipImage != null) {
          billSlipUrl = await _uploadBillSlip(orderId);
          if (billSlipUrl == null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Bill slip upload is slow. Checkout continued without slip.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        batch.set(orderRef, {
          'productId': item.productId,
          'productName': item.productName,
          'productPrice': item.productPrice,
          'productImageUrl': item.productImageUrl,
          'quantity': item.quantity,
          'orderedAt': now.toIso8601String(),
          'deliveryDate': deliveryDate.toIso8601String(),
          'status': AppConstants.processingOrderStatus,
          'billSlipUrl': billSlipUrl,
          'customerId': widget.uid,
        });
        batch.delete(cartRef);
      }

      await batch.commit();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Checkout successful! ${widget.items.length} item(s) ordered.',
          ),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Clear bill slip after successful checkout
      setState(() {
        _billSlipImage = null;
        _billSlipBytes = null;
      });
    } catch (error, stackTrace) {
      await MonitoringService.captureException(
        error,
        stackTrace: stackTrace,
        hint: 'cart_checkout_now',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Checkout failed. Please try again.'),
          backgroundColor: AppTheme.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      await MonitoringService.stopTrace(trace);
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.local_shipping_outlined,
                      color: AppTheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order summary',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.dark)),
                      SizedBox(height: 2),
                      Text('Free shipping and fast checkout are included.',
                          style: TextStyle(color: AppTheme.textGray, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _Row('Subtotal', '\$${widget.total.toStringAsFixed(2)}'),
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
                Text('\$${widget.total.toStringAsFixed(2)}',
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
                onPressed: _uploading ? null : () => _checkoutNow(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _uploading ? Colors.grey : AppTheme.dark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _uploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Checkout Now',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text('SECURE SSL ENCRYPTION',
                  style: TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartStepPill extends StatelessWidget {
  final String number;
  final String label;

  const _CartStepPill({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: AppTheme.dark,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
            style: const TextStyle(
                color: AppTheme.textGray, fontWeight: FontWeight.w500)),
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
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 64, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            const Text('Your cart is empty',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.dark)),
            const SizedBox(height: 8),
            const Text(
              "Looks like you haven't added anything yet. Browse the catalog or ask the assistant for help choosing a product.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGray, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, Routes.home.path),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
