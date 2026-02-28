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
import '../widgets/shared_widgets.dart';
import 'product_detail_screen.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/star_row.dart';
import '../widgets/section_title.dart';
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
    return CustomScrollView(
      slivers: [
        // ─── SliverAppBar ──────────────────────────────────────────────────
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
          actions: [
            // Cart badge
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: AppColors.textSubtle),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 6, top: 6,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Consumer<CartProvider>(
                        builder: (_, cart, __) => Text(
                          '${cart.count}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Avatar
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryGlow,
                child: Text(
                  user.name?.isNotEmpty == true ? user.name![0].toUpperCase() : 'U',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
          // ── Search Bar ────────────────────────────────────────────────────
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              height: 56,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search iPhones…',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textMuted, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(Icons.close_rounded,
                              color: AppColors.textMuted, size: 18),
                        )
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ),
        ),

        // ─── Grid or Empty State ──────────────────────────────────────────
        _filtered.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          color: AppColors.textMuted, size: 56),
                      const SizedBox(height: 16),
                      Text('No results for "$_query"',
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted, fontSize: 15)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Text('Clear search',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _ProductCard(
                      product: _filtered[i],
                      index: i,
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: i * 60),
                          duration: 400.ms,
                        ).slideY(begin: 0.1),
                    childCount: _filtered.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:   2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing:  14,
                    childAspectRatio: 0.68,
                  ),
                ),
              ),
      ],
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final Product product;
  final int     index;
  const _ProductCard({required this.product, required this.index});

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
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: widget.product),
        ),
      ),
      child: AnimatedScale(
        scale:    _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:        AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: inCart
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.border,
              width: inCart ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset:     const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft:  Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl:   widget.product.imageUrl,
                    fit:        BoxFit.cover,
                    width:      double.infinity,
                    placeholder: (_, __) => Container(
                      color: AppColors.surfaceHi,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceHi,
                      child: const Icon(Icons.phone_iphone,
                          color: AppColors.textMuted, size: 40),
                    ),
                  ),
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGlow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(widget.product.category,
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          )),
                    ),
                    const SizedBox(height: 6),
                    Text(widget.product.name,
                        style: GoogleFonts.inter(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        StarRow(rating: widget.product.rating, size: 11),
                      ],
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
