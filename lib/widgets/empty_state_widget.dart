import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../config/app_spacing.dart';

/// Empty state widget component
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? height;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppTheme.textSecondary,
            size: 56,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty cart state
class EmptyCartWidget extends StatelessWidget {
  final VoidCallback onShop;

  const EmptyCartWidget({super.key, required this.onShop});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'Your Cart is Empty',
      message: 'Start shopping to add items to your cart and checkout later.',
      actionLabel: 'Start Shopping',
      onAction: onShop,
    );
  }
}

/// Empty search results state
class EmptySearchWidget extends StatelessWidget {
  final String searchQuery;

  const EmptySearchWidget({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      message:
          'No products found for "$searchQuery". Try different keywords.',
    );
  }
}

/// Empty orders state
class EmptyOrdersWidget extends StatelessWidget {
  final VoidCallback onShop;

  const EmptyOrdersWidget({super.key, required this.onShop});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'No Orders Yet',
      message: 'You haven\'t placed any orders. Start shopping to create your first order.',
      actionLabel: 'Browse Products',
      onAction: onShop,
    );
  }
}

/// Empty notifications state
class EmptyNotificationsWidget extends StatelessWidget {
  const EmptyNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_none_rounded,
      title: 'No Notifications',
      message: 'You\'re all caught up! Check back later for updates.',
    );
  }
}
