// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../data/products.dart';
import '../models/models.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late List<Review>  _reviews;
  final _commentCtrl = TextEditingController();
  int  _selectedSize = 2;
  int? _newReviewId;

  final _sizes = ['64GB', '128GB', '256GB', '512GB', '1TB'];

  @override
  void initState() {
    super.initState();
    _reviews = List.from(kSampleReviews);
  }

  void _addToCart() {
    context.read<CartProvider>().add(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart 🛍️'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitReview() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final ts = DateTime.now().millisecondsSinceEpoch;
    final r = Review(
      id: '$ts',
      username: 'You',
      rating: 5,
      comment: text,
      date: 'Just now',
      isLocal: true,
    );
    setState(() {
      _reviews.insert(0, r);
      _newReviewId = ts;
    });
    _commentCtrl.clear();
    Future.delayed(const Duration(milliseconds: 900),
        () { if (mounted) setState(() => _newReviewId = null); });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inCart = context.watch<CartProvider>().contains(widget.product.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── Hero Image ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.bg,
                surfaceTintColor: Colors.transparent,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surfaceHi,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceHi,
                          child: const Icon(Icons.phone_iphone,
                              color: AppColors.textMuted, size: 80),
                        ),
                      ),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, AppColors.bg],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Body ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGlow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(widget.product.category,
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            )),
                      ),
                      const SizedBox(height: 10),

                      // Name + Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(widget.product.name,
                                style: GoogleFonts.inter(
                                  color: AppColors.text,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                )),
                          ),
                          const SizedBox(width: 12),
                          Text('\$${widget.product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Rating
                      StarRow(
                        rating:    widget.product.rating,
                        size:      17,
                        showCount: true,
                        count:     widget.product.reviewCount,
                      ),
                      const SizedBox(height: 18),

                      // Description
                      Text(widget.product.description,
                          style: GoogleFonts.inter(
                            color: AppColors.textSubtle,
                            fontSize: 14,
                            height: 1.8,
                          )),

                      // Specs
                      if (widget.product.specs.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: widget.product.specs.map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(s,
                                style: GoogleFonts.inter(
                                  color: AppColors.textSubtle,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                )),
                          )).toList(),
                        ),
                      ],

                      // Storage selector
                      const SizedBox(height: 24),
                      Text('STORAGE',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          )),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_sizes.length, (i) {
                            final sel = _selectedSize == i;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel
                                        ? Colors.transparent
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(_sizes[i],
                                    style: GoogleFonts.inter(
                                      color: sel
                                          ? Colors.white
                                          : AppColors.textSubtle,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    )),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Reviews
                      const SizedBox(height: 32),
                      const SectionTitle('Customer Reviews'),
                      const SizedBox(height: 16),
                      ..._reviews.map((r) => _ReviewCard(
                            review: r,
                            isNew:  _newReviewId == int.tryParse(r.id),
                          ).animate(
                            key: ValueKey(r.id),
                          ).fadeIn(duration: 400.ms).slideY(begin: -0.15)),

                      // Write review
                      const SizedBox(height: 20),
                      Text('Share your thoughts',
                          style: GoogleFonts.inter(
                            color: AppColors.textSubtle,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentCtrl,
                              onSubmitted: (_) => _submitReview(),
                              style: GoogleFonts.inter(
                                  color: AppColors.text, fontSize: 14),
                              decoration: InputDecoration(
                                  hintText: 'What did you think?'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _submitReview,
                            child: Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDk
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─── Sticky Bottom Buttons ─────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: AppColors.bg,
                border: const Border(
                    top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GhostButton(
                      label: inCart ? '✓ In Cart' : 'Add to Cart',
                      onPressed: _addToCart,
                      borderColor: inCart ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: EmeraldButton(
                      label: 'Buy Now',
                      onPressed: () {
                        _addToCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Proceeding to checkout…')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Review Card ─────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;
  final bool   isNew;
  const _ReviewCard({required this.review, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? AppColors.primaryGlow : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? AppColors.primary : AppColors.border,
          width: isNew ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryGlow,
                child: Text(review.username[0],
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.username,
                        style: GoogleFonts.inter(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        )),
                    Text(review.date,
                        style: GoogleFonts.inter(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              StarRow(rating: review.rating, size: 13),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment,
              style: GoogleFonts.inter(
                color: AppColors.textSubtle,
                fontSize: 13,
                height: 1.6,
              )),
        ],
      ),
    );
  }
}
