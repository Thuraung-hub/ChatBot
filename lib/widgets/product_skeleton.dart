import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../app_theme.dart';

class ProductSkeleton extends StatelessWidget {
  const ProductSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF3A3A3A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(color: const Color(0xFF2A2A2A)),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2F2F),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2F2F),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2F2F),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 72,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F2F2F),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F2F2F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

class ProductSkeletonGrid extends StatelessWidget {
  final int itemCount;

  const ProductSkeletonGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Container(
              height: 180,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 160,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F2F2F),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F2F2F),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F2F2F),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 92,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F2F2F),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, __) => const ProductSkeleton(),
              childCount: itemCount,
            ),
          ),
        ),
      ],
    );
  }
}