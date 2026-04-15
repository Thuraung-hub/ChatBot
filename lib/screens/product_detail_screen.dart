import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../config/app_constants.dart';
import '../config/app_validators.dart';
import '../app_theme.dart';
import '../models/product.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/monitoring_service.dart';
import '../utils/responsive.dart';
import '../widgets/app_dialogs.dart';

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

  Future<bool> _addToCart(BuildContext context, Product product) async {
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
      await AppDialog.showCartAddedDialog(
        context,
        onCheckoutNow: () => Navigator.pushNamed(context, Routes.cart.path),
      );
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

    try {
      setState(() => _buyingNow = true);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      setState(() => _buyingNow = false);
      if (!context.mounted) return;
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
      if (mounted) {
        setState(() => _buyingNow = false);
      }
    }
  }

    Future<void> _completePurchase(
      BuildContext context, String uid, Product product,
      {String? billSlipUrl}) async {
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
      'billSlipUrl': billSlipUrl,
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

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _QuickCheckoutPage(
          product: product,
          uid: uid,
          startDate: startDate,
          endDate: endDate,
          onComplete: (billSlipUrl) async {
            if (!mounted || !context.mounted) return;
            await _completePurchase(
              context,
              uid,
              product,
              billSlipUrl: billSlipUrl,
            );
          },
        ),
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
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

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
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 10 : 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.borderGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Buy Now Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (_adding || _buyingNow)
                                ? null
                                : () => _buyNow(context, product),
                            icon: _buyingNow
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.flash_on_rounded),
                            label: Text(
                              _buyingNow ? 'Processing...' : 'Buy Now',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.royalBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: (_adding || _buyingNow)
                                ? null
                                : () => _addToCart(context, product),
                            icon: _adding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.shopping_cart_outlined),
                            label: Text(
                              _adding ? 'Adding...' : 'Add to Cart',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.primary,
                                width: 1.5,
                              ),
                              foregroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          body: CustomScrollView(
            slivers: [
              // Hero image app bar
              SliverAppBar(
                expandedHeight: isMobile ? 280 : (isTablet ? 320 : 360),
                pinned: true,
                leading: Padding(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
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
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
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
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
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
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8)),
                      ),
                      const SizedBox(height: 12),

                        Text(product.name,
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1)),
                      const SizedBox(height: 8),
                        Text('\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const SizedBox(height: 16),
                        Text(product.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 15,
                            height: 1.6)),

                      // Trust badges
                      const SizedBox(height: 24),
                        Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _Badge(
                              icon: Icons.star_rounded,
                              text: 'Top Rated',
                              color: Colors.amber),
                          _Badge(
                              icon: Icons.local_shipping_outlined,
                              text: 'Free Shipping',
                              color: AppTheme.green),
                          _Badge(
                              icon: Icons.shield_outlined,
                              text: 'Secure',
                              color: AppTheme.primary),
                        ],
                      ),

                      // Comments section
                      const SizedBox(height: 40),
                        Text('Reviews & Comments',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textGray)),
                      const SizedBox(height: 16),

                      // Post comment
                      if (auth.user != null) ...[
                        Form(
                          key: _commentFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: isMobile
                              ? Column(
                                  children: [
                                    TextFormField(
                                      controller: _commentController,
                                      validator: AppValidators.comment,
                                      decoration: const InputDecoration(
                                        hintText: 'Write a comment...',
                                        prefixIcon: Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            color: AppTheme.textGray),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: (_postingComment ||
                                                auth.profile == null)
                                            ? null
                                            : () => _postComment(
                                                context, auth.profile!),
                                        icon: _postingComment
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2))
                                            : const Icon(Icons.send_rounded,
                                                size: 20),
                                        label: const Text('Post Comment'),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
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
                                          : const Icon(Icons.send_rounded,
                                              size: 20),
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

class _QuickCheckoutPage extends StatefulWidget {
  final Product product;
  final String uid;
  final DateTime startDate;
  final DateTime endDate;
  final Future<void> Function(String? billSlipUrl) onComplete;

  const _QuickCheckoutPage({
    required this.product,
    required this.uid,
    required this.startDate,
    required this.endDate,
    required this.onComplete,
  });

  @override
  State<_QuickCheckoutPage> createState() => _QuickCheckoutPageState();
}

class _QuickCheckoutPageState extends State<_QuickCheckoutPage> {
  Uint8List? _billSlipBytes;
  bool _submitting = false;
  double? _uploadProgress;
  String _loadingText = 'Processing payment...';

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickBillSlip(ImageSource source) async {
    try {
      Uint8List? bytes;

      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
          allowMultiple: false,
        );
        if (result == null || result.files.isEmpty) return;
        bytes = result.files.single.bytes;
      } else {
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: source,
          imageQuality: 45,
          maxWidth: 800,
          maxHeight: 800,
        );
        if (image == null) return;
        bytes = await image.readAsBytes();
      }

      if (bytes == null) return;
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
      if (!mounted) return;
      setState(() => _billSlipBytes = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? 'Failed to select image from this browser. Try Choose File again.'
                : 'Failed to pick image. Please try again.',
          ),
          backgroundColor: AppTheme.red,
        ),
      );
    }
  }

  Future<String?> _uploadBillSlip(Uint8List bytes) async {
    final fileName =
        'quick_checkout_bill_slips/${widget.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref(fileName);
    final task = ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    try {
      await task.timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          await task.cancel();
          throw TimeoutException('Bill slip upload timed out.');
        },
      );
      return ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> _payNow() async {
    if (_submitting) return;
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _submitting = true;
      _uploadProgress = null;
      _loadingText = _billSlipBytes != null
          ? 'Uploading bill slip...'
          : 'Processing payment...';
    });
    try {
      String? billSlipUrl;
      if (_billSlipBytes != null) {
        billSlipUrl = await _uploadBillSlip(_billSlipBytes!);
        if (billSlipUrl == null) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Bill slip upload is slow. Checkout continued without slip.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      if (mounted) {
        setState(() {
          _uploadProgress = null;
          _loadingText = 'Finalizing order...';
        });
      }
      await widget.onComplete(billSlipUrl);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Payment failed. Please try again.'),
          backgroundColor: AppTheme.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _uploadProgress = null;
          _loadingText = 'Processing payment...';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        title: const Text('Quick Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _submitting ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF121826),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF27324A)),
              ),
              child: const Row(
                children: [
                  _StepPill(number: '1', label: 'Upload slip'),
                  SizedBox(width: 10),
                  Icon(Icons.chevron_right_rounded, color: Color(0xFFB6C2D9)),
                  SizedBox(width: 10),
                  _StepPill(number: '2', label: 'Pay now'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Estimated delivery: ${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
              style: const TextStyle(
                color: Color(0xFFB6C2D9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121826),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF27324A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Payment Bill Slip (Optional)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_billSlipBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _billSlipBytes!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_billSlipBytes != null) const SizedBox(height: 10),
                  Row(
                    children: [
                      if (!kIsWeb) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF2A3550)),
                            ),
                            onPressed: () => _pickBillSlip(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF2A3550)),
                          ),
                          onPressed: () => _pickBillSlip(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(kIsWeb ? 'Choose File' : 'Gallery'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Admin can review this slip for payment verification.',
                    style: TextStyle(color: Color(0xFFB6C2D9), fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_submitting) ...[
              const SizedBox(height: 16),
              Text(
                _uploadProgress != null
                    ? 'Uploading slip: ${(_uploadProgress! * 100).clamp(0, 100).toStringAsFixed(0)}%'
                    : _loadingText,
                style: const TextStyle(
                  color: Color(0xFFB6C2D9),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _uploadProgress,
                minHeight: 8,
                backgroundColor: const Color(0xFF27324A),
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.dark,
              disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.85),
              disabledForegroundColor: AppTheme.dark,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _submitting ? null : _payNow,
            child: _submitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.dark),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _uploadProgress != null
                            ? 'Uploading...'
                            : 'Processing...',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  )
                : const Text(
                    'Pay Now',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final String number;
  final String label;

  const _StepPill({required this.number, required this.label});

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
