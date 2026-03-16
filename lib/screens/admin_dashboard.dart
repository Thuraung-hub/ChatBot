import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();

  bool _loading = false;
  bool _success = false;
  String? _newProductId;
  bool _showSuccessDialog = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    _categoryCtrl.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameCtrl.text.isEmpty ||
        _descCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty ||
        _imageCtrl.text.isEmpty ||
        _categoryCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    final parsedPrice = double.tryParse(_priceCtrl.text);
    if (parsedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() { _loading = true; _success = false; });

    try {
      final docRef = await FirebaseFirestore.instance.collection('products').add({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': parsedPrice,
        'imageUrl': _imageCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'review': _reviewCtrl.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _newProductId = docRef.id;
        _showSuccessDialog = true;
        _success = true;
      });

      _nameCtrl.clear();
      _descCtrl.clear();
      _priceCtrl.clear();
      _imageCtrl.clear();
      _categoryCtrl.clear();
      _reviewCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text('Admin Dashboard',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textGray)),
                const SizedBox(height: 4),
                const Text('Manage your store inventory and add new products.',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 15)),
                const SizedBox(height: 28),

                // Form card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderGray),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.06),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
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
                            child: const Icon(Icons.add_rounded,
                                color: AppTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text('Add New Product',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.dark)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (_success) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.green.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  color: AppTheme.green, size: 18),
                              SizedBox(width: 8),
                              Text('Product added successfully!',
                                  style: TextStyle(
                                      color: AppTheme.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Row 1: Name + Category
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              controller: _nameCtrl,
                              label: 'Product Name *',
                              hint: 'e.g. Wireless Mouse',
                              icon: Icons.inventory_2_outlined,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _FormField(
                              controller: _categoryCtrl,
                              label: 'Category *',
                              hint: 'e.g. Electronics',
                              icon: Icons.label_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price
                      _FormField(
                        controller: _priceCtrl,
                        label: 'Price (\$) *',
                        hint: '99.99',
                        icon: Icons.attach_money_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),

                      // Image URL
                      _FormField(
                        controller: _imageCtrl,
                        label: 'Image URL *',
                        hint: 'https://images.unsplash.com/...',
                        icon: Icons.image_outlined,
                        keyboardType: TextInputType.url,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Live preview if image URL provided
                      if (_imageCtrl.text.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.bgGray,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderGray),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: CachedNetworkImage(
                                    imageUrl: _imageCtrl.text,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppTheme.borderGray,
                                      child: const Icon(Icons.broken_image_outlined,
                                          color: AppTheme.textGray),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('LIVE PREVIEW',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textGray,
                                            letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(
                                      _nameCtrl.text.isEmpty ? 'Product Name' : _nameCtrl.text,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.dark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '\$${_priceCtrl.text.isEmpty ? '0.00' : _priceCtrl.text}',
                                      style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      _FormField(
                        controller: _descCtrl,
                        label: 'Description *',
                        hint: 'Tell us about the product...',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),

                      // Review (optional)
                      _FormField(
                        controller: _reviewCtrl,
                        label: 'Featured Review (Optional)',
                        hint: 'Add a featured review or testimonial...',
                        icon: Icons.star_outline_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _handleSubmit,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Icon(Icons.add_rounded),
                          label: Text(_loading ? 'Adding...' : 'Add Product to Store',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tips card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quick Tips',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      ...[
                        'Use high-quality Unsplash URLs for product images.',
                        'Keep descriptions concise but informative.',
                        'Categories help users filter products easily.',
                      ].map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 6, right: 10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(tip,
                                      style: const TextStyle(
                                          color: Color(0xFFc7d2fe),
                                          fontSize: 13,
                                          height: 1.5)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Success dialog overlay
          if (_showSuccessDialog)
            _SuccessDialog(
              productId: _newProductId ?? '',
              onViewProduct: () {
                setState(() => _showSuccessDialog = false);
                Navigator.pushNamed(context, '/product',
                    arguments: _newProductId);
              },
              onAddAnother: () => setState(() => _showSuccessDialog = false),
              onBackHome: () {
                setState(() => _showSuccessDialog = false);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int? maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.dark)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines ?? 1,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.textGray, size: 20),
            alignLabelWithHint: maxLines != null && maxLines! > 1,
          ),
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String productId;
  final VoidCallback onViewProduct;
  final VoidCallback onAddAnother;
  final VoidCallback onBackHome;

  const _SuccessDialog({
    required this.productId,
    required this.onViewProduct,
    required this.onAddAnother,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.green, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('Product Added!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.dark)),
              const SizedBox(height: 8),
              const Text(
                'Your new item is now live on the store for all customers.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textGray, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewProduct,
                  child: const Text('View Product'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAddAnother,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bgGray,
                    foregroundColor: AppTheme.dark,
                  ),
                  child: const Text('Add Another'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onBackHome,
                child: const Text('Back to Home',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
