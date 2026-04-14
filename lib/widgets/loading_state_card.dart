import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../app_theme.dart';
import '../config/app_spacing.dart';

/// Loading state card component
class LoadingStateCard extends StatelessWidget {
  final String? message;
  final double? height;
  final bool isFullScreen;

  const LoadingStateCard({
    super.key,
    this.message = 'Loading...',
    this.height = 200,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SpinKitRing(
          color: AppTheme.primary,
          size: 50,
          lineWidth: 2,
          duration: Duration(milliseconds: 1200),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (message != null)
          Text(
            message!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );

    if (isFullScreen) {
      return Center(child: content);
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: content,
    );
  }
}

/// Shimmer loading skeleton
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.border,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const ShimmerEffect(),
    );
  }
}

/// Shimmer effect animation
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            gradient: LinearGradient(
              begin: Alignment(_controller.value * 2 - 1, -1),
              end: Alignment(_controller.value * 2 - 1, 1),
              colors: [
                Colors.grey.shade900,
                Colors.grey.shade800,
                Colors.grey.shade900,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// List of skeleton loaders for product grid
class SkeletonProductGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const SkeletonProductGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SkeletonProductCard();
      },
    );
  }
}

/// Skeleton product card
class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppTheme.border),
      ),
          child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SkeletonLoader(
            width: double.infinity,
            height: 150,
              borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 12,
                ),
                SizedBox(height: AppSpacing.sm),
                SkeletonLoader(
                  width: 100,
                  height: 12,
                ),
                SizedBox(height: AppSpacing.md),
                SkeletonLoader(
                  width: double.infinity,
                  height: 36,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
