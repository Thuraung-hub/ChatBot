// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../data/products.dart';
import '../models/models.dart';
import '../providers/user_provider.dart';

import '../theme/app_theme.dart';
import '../widgets/star_row.dart';
import '../widgets/floating_chat_bubble.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<Product> get _filtered => _query.isEmpty
      ? kProducts
      : kProducts.where((p) =>
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.description.toLowerCase().contains(_query.toLowerCase()) ||
          p.category.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // ================= MAIN CONTENT =================
          CustomScrollView(
            slivers: [
              // ─── SliverAppBar ─────────────────────────────
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                expandedHeight: 140,
                backgroundColor: AppColors.bg,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 0, 60),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STITCH SHOP',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          )),
                      Text('iPhone Collection',
                          style: GoogleFonts.inter(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          )),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.surface, AppColors.bg],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Search Bar ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search iPhones...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),

              // ─── Product Grid ─────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _ProductCard(
                      product: _filtered[i],
                      index: i,
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: i * 60),
                          duration: 400.ms,
                        ),
                    childCount: _filtered.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                ),
              ),
            ],
          ),

          // ================= FLOATING AI CHAT =================
         
        ],
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final Product product;
  final int index;

  const _ProductCard({
    required this.product,
    required this.index,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.contains(widget.product.id);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(product: widget.product),
        ),
      ),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: inCart
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 6),
                    Text('\$${widget.product.price}',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 4),
                    StarRow(
                      rating: widget.product.rating,
                      size: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}