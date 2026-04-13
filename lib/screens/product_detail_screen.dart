import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_constants.dart';
import '../config/app_validators.dart';
import '../app_theme.dart';
import '../models/product.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/monitoring_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _commentFormKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  bool _adding = false;
  bool _buyingNow = false;
  bool _postingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<bool> _addToCart(BuildContext context, Product product,
      {bool showSnack = true}) async {
    final auth = context.read<AuthService>();
    if (auth.user == null) {
      Navigator.pushNamed(context, Routes.login.path);
      return false;
    }
    setState(() => _adding = true);
    final trace = await MonitoringService.startTrace('product_add_to_cart');
    try {
      final uid = auth.user!.uid;
      final db = FirebaseFirestore.instance;
      final cartRef = db.collection('users/$uid/cart');

      final existingSnap = await cartRef
          .where('productId', isEqualTo: product.id)
          .limit(1)
          .get();

      if (existingSnap.docs.isNotEmpty) {
        await cartRef
            .doc(existingSnap.docs.first.id)
            .update({'quantity': FieldValue.increment(1)});
      } else {
        await cartRef.add({
          'productId': product.id,
          'quantity': 1,
          'productName': product.name,
          'productPrice': product.price,
          'productImageUrl': product.imageUrl,
        });
      }

      if (!context.mounted) return true;
      if (showSnack) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Added to cart'),
            action: SnackBarAction(
              label: 'Checkout Now',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, Routes.cart.path),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))));
      }
      return true;
    } catch (error, stackTrace) {
      await MonitoringService.captureException(
        error,
        stackTrace: stackTrace,
        hint: 'product_add_to_cart',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not add item to cart. Please try again.'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return false;
    } finally {
      await MonitoringService.stopTrace(trace);
      if (mounted) {
        setState(() => _adding = false);
      }
    }
  }

  Future<void> _buyNow(BuildContext context, Product product) async {
    final auth = context.read<AuthService>();
    if (auth.user == null) {
      Navigator.pushNamed(context, Routes.login.path);
      return;
    }

    final trace = await MonitoringService.startTrace('product_buy_now');
    try {
      setState(() => _buyingNow = true);
      await Future.delayed(const Duration(
          milliseconds: AppConstants.quickCheckoutDelayMilliseconds));
      if (!context.mounted) return;
      setState(() => _buyingNow = false);

      await _showBuyNowDialog(context, product, auth.user!.uid);
    } catch (error, stackTrace) {
      await MonitoringService.captureException(
        error,
        stackTrace: stackTrace,
        hint: 'product_buy_now',
      );
      if (!context.mounted) return;
      setState(() => _buyingNow = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to start checkout. Please try again.'),
          backgroundColor: AppTheme.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      await MonitoringService.stopTrace(trace);
    }
  }

  Future<void> _completePurchase(
      BuildContext context, String uid, Product product) async {
    final now = DateTime.now();
    final deliveryDate =
        now.add(const Duration(days: AppConstants.deliveryLeadDays));
    final auth = context.read<AuthService>();
    final profile = auth.profile;

    final orderData = {
      'productId': product.id,
      'productName': product.name,
      'productPrice': product.price,
      'productImageUrl': product.imageUrl,
      'customerId': uid,
      'customerName': profile?.name ?? 'Customer',
      'customerEmail': profile?.email ?? auth.user?.email ?? '',
      'orderedAt': now.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'status': AppConstants.processingOrderStatus,
    };

    await FirebaseFirestore.instance.collection('users/$uid/orders').add(orderData);

    await FirebaseFirestore.instance
        .collection(AppConstants.adminNotificationsCollection)
        .add({
      ...orderData,
      'type': 'purchase',
      'read': false,
      'createdAt': now.toIso8601String(),
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment successful! Your order is confirmed.'),
        backgroundColor: AppTheme.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _showBuyNowDialog(
      BuildContext context, Product product, String uid) async {
    final startDate = DateTime.now().add(const Duration(days: 2));
    final endDate = DateTime.now().add(
      const Duration(days: AppConstants.deliveryLeadDays),
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quick Checkout',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppTheme.royalBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Proceed with payment for this item now?',
              style: TextStyle(color: AppTheme.textGray),
            ),
            const SizedBox(height: 10),
            Text(
              'Estimated delivery: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
              style: const TextStyle(
                color: AppTheme.textGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _completePurchase(context, uid, product);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Payment failed. Please try again.'),
                    backgroundColor: AppTheme.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _postComment(BuildContext context, UserProfile profile) async {
    if (!(_commentFormKey.currentState?.validate() ?? false)) return;
    setState(() => _postingComment = true);
    final trace = await MonitoringService.startTrace('product_post_comment');
    try {
      await FirebaseFirestore.instance
          .collection('products/${widget.productId}/comments')
          .add({
        'userId': profile.id,
        'userName': profile.name,
        'text': _commentController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });
      _commentController.clear();
    } catch (error, stackTrace) {
      await MonitoringService.captureException(
        error,
        stackTrace: stackTrace,
        hint: 'product_post_comment',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to post comment. Please try again.'),
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
        setState(() => _postingComment = false);
      }
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .delete();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)));
        }
        if (!snapshot.data!.exists) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Product not found')));
        }

        final product = Product.fromMap(
            snapshot.data!.id, snapshot.data!.data() as Map<String, dynamic>);

        return Scaffold(
          backgroundColor: AppTheme.screenBg,
          bottomNavigationBar: auth.isAdmin
              ? null
              : SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.borderGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_adding || _buyingNow)
                            ? null
                            : () => _addToCart(context, product),
                        icon: _adding
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.shopping_cart_outlined),
                        label: Text(_adding ? 'Adding...' : 'Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          minimumSize: const Size.fromHeight(54),
                        ),
                      ),
                    ),
                  ),
                ),
          body: CustomScrollView(
            slivers: [
              // Hero image app bar
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  if (auth.isAdmin) ...[
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppTheme.primary, size: 20),
                          onPressed: () => _showEditDialog(context, product),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppTheme.red, size: 20),
                          onPressed: () => _confirmDelete(context),
                        ),
                      ),
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product-image-${product.id}',
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(color: AppTheme.bgGray),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(product.category.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8)),
                      ),
                      const SizedBox(height: 12),

                      Text(product.name,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1)),
                      const SizedBox(height: 8),
                      Text('\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const SizedBox(height: 16),
                      Text(product.description,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15, height: 1.6)),

                      // Trust badges
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          _Badge(
                              icon: Icons.star_rounded,
                              text: 'Top Rated',
                              color: Colors.amber),
                          SizedBox(width: 12),
                          _Badge(
                              icon: Icons.local_shipping_outlined,
                              text: 'Free Shipping',
                              color: AppTheme.green),
                          SizedBox(width: 12),
                          _Badge(
                              icon: Icons.shield_outlined,
                              text: 'Secure',
                              color: AppTheme.primary),
                        ],
                      ),

                      if (!auth.isAdmin) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: (_adding || _buyingNow)
                                ? null
                                : () => _buyNow(context, product),
                            icon: _buyingNow
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        color: AppTheme.royalBlue,
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.flash_on_rounded,
                                    color: AppTheme.royalBlue),
                            label: Text(
                              _buyingNow ? 'Processing...' : 'Buy Now',
                              style: const TextStyle(
                                color: AppTheme.royalBlue,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppTheme.royalBlue, width: 1.4),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],

                      // Comments section
                      const SizedBox(height: 40),
                      const Text('Reviews & Comments',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textGray)),
                      const SizedBox(height: 16),

                      // Post comment
                      if (auth.user != null) ...[
                        Form(
                          key: _commentFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _commentController,
                                  validator: AppValidators.comment,
                                  decoration: const InputDecoration(
                                    hintText: 'Write a comment...',
                                    prefixIcon: Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: AppTheme.textGray),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: (_postingComment ||
                                        auth.profile == null)
                                    ? null
                                    : () =>
                                        _postComment(context, auth.profile!),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  minimumSize: const Size(0, 0),
                                ),
                                child: _postingComment
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : const Icon(Icons.send_rounded, size: 20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Comments list
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products/${widget.productId}/comments')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox.shrink();
                          final comments = snap.data!.docs;
                          if (comments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('No comments yet. Be the first!',
                                    style: TextStyle(color: AppTheme.textGray)),
                              ),
                            );
                          }
                          return Column(
                            children: comments.map((d) {
                              final data = d.data() as Map<String, dynamic>;
                              return _CommentTile(
                                userName: data['userName'] ?? 'User',
                                text: data['text'] ?? '',
                                createdAt: data['createdAt'] ?? '',
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
            'Are you sure you want to delete this product? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteProduct(context);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: AppTheme.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Product product) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: product.name);
    final descCtrl = TextEditingController(text: product.description);
    final priceCtrl = TextEditingController(text: product.price.toString());
    final imageCtrl = TextEditingController(text: product.imageUrl);
    final categoryCtrl = TextEditingController(text: product.category);
    final reviewCtrl = TextEditingController(text: product.review ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Product',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EditField(
                    controller: nameCtrl,
                    label: 'Name',
                    validator: AppValidators.productName),
                const SizedBox(height: 12),
                _EditField(
                    controller: descCtrl,
                    label: 'Description',
                    maxLines: 3,
                    validator: AppValidators.description),
                const SizedBox(height: 12),
                _EditField(
                    controller: categoryCtrl,
                    label: 'Category',
                    validator: AppValidators.category),
                const SizedBox(height: 12),
                _EditField(
                    controller: reviewCtrl,
                    label: 'Review',
                    maxLines: 3,
                    validator: AppValidators.review),
                const SizedBox(height: 12),
                _EditField(
                    controller: priceCtrl,
                    label: 'Price',
                    keyboardType: TextInputType.number,
                    validator: AppValidators.price),
                const SizedBox(height: 12),
                _EditField(
                    controller: imageCtrl,
                    label: 'Image URL',
                    validator: AppValidators.url),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(product.id)
                  .update({
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'category': categoryCtrl.text.trim(),
                'review': reviewCtrl.text.trim(),
                'price': double.parse(priceCtrl.text.trim()),
                'imageUrl': imageCtrl.text.trim(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Badge({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String userName;
  final String text;
  final String createdAt;
  const _CommentTile(
      {required this.userName, required this.text, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppTheme.dark)),
              Text(
                  createdAt.length > 10
                      ? createdAt.substring(0, 10)
                      : createdAt,
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textGray)),
            ],
          ),
          const SizedBox(height: 6),
          Text(text,
              style: const TextStyle(color: AppTheme.textGray, height: 1.5)),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _EditField(
      {required this.controller,
      required this.label,
      this.maxLines,
      this.keyboardType,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(labelText: label),
    );
  }
}
