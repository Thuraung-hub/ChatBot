import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../config/app_constants.dart';
import '../services/auth_service.dart';
import '../utils/animations.dart';
import '../utils/page_routes.dart';
import '../utils/responsive.dart';
import '../widgets/app_action_button.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/loading_state_card.dart';
import 'admin_notifications_screen.dart';
import 'buy_item_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _handleLogout(BuildContext context, AuthService auth) async {
    await auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.login.path);
    }
  }

  void _openBuyItemScreen(BuildContext context) {
    context.navigateSlideRight(const BuyItemScreen());
  }

  Future<void> _confirmDeleteAccount(BuildContext context, AuthService auth) async {
    final shouldDelete = await AppDialog.showConfirmationDialog(
      context,
      title: 'Delete Account',
      message:
          'This will permanently erase your account, email, and chat history. This cannot be undone.',
      confirmLabel: 'Delete Account',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      AppDialog.showLoadingDialog(context, message: 'Deleting account...');
      await auth.deleteAccount();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, Routes.login.path);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      await AppDialog.showErrorDialog(
        context,
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> _confirmDeleteMyData(BuildContext context, AuthService auth) async {
    final shouldDelete = await AppDialog.showConfirmationDialog(
      context,
      title: 'Delete My Data',
      message:
          'This will permanently remove your purchased items and order history. Your account will stay active. This cannot be undone.',
      confirmLabel: 'Delete Data',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      AppDialog.showLoadingDialog(context, message: 'Deleting data...');
      await auth.deleteMyData();
      if (!context.mounted) return;
      Navigator.pop(context);
      await AppDialog.showSuccessDialog(
        context,
        title: 'Success',
        message: 'Purchase history deleted successfully.',
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      await AppDialog.showErrorDialog(
        context,
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void _openSettingsScreen(BuildContext context, AuthService auth) {
    context.navigateFade(
      _ProfileSettingsScreen(
        auth: auth,
        onDeleteAccount: () => _confirmDeleteAccount(context, auth),
        onDeleteMyData: () => _confirmDeleteMyData(context, auth),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = auth.profile;
    final isStrictAdmin = profile?.role == AppConstants.adminRole;
    final canBuyItem = profile?.role == AppConstants.customerRole;
    final roleLabel = profile?.role == AppConstants.subAdminRole
        ? 'Sub-Admin'
        : (profile?.role == AppConstants.adminRole ? 'Admin' : 'Customer');

    if (profile == null) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: LoadingStateCard(
              isFullScreen: true,
              message: 'Loading profile...',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = context.responsivePadding;
          final maxContentWidth = context.isDesktop
              ? 760.0
              : (context.isTablet ? 640.0 : constraints.maxWidth);

          final infoTiles = [
            _InfoTile(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: profile.email,
            ),
            _InfoTile(
              icon: Icons.shield_outlined,
              label: 'Role',
              value: roleLabel,
            ),
          ];

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    AnimationHelpers.fadeInUp(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            height: 130,
                            width: double.infinity,
                            color: AppTheme.primary,
                          ),
                          Positioned(
                            bottom: -44,
                            left: horizontalPadding + 4,
                            child: AnimationHelpers.fadeInUp(
                              delay: 120,
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppTheme.primary,
                                    size: 44,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 56),
                    Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: AnimationHelpers.fadeInUp(
                        delay: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: TextStyle(
                                fontSize: context.isMobile ? 26 : 30,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.email,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'ACCOUNT INFORMATION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade400,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (context.isMobile) ...[
                              infoTiles[0],
                              const SizedBox(height: 10),
                              infoTiles[1],
                            ] else ...[
                              Row(
                                children: [
                                  Expanded(child: infoTiles[0]),
                                  const SizedBox(width: 10),
                                  Expanded(child: infoTiles[1]),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            AppActionButton(
                              label: 'Settings',
                              icon: Icons.settings_outlined,
                              onPressed: () => _openSettingsScreen(context, auth),
                              backgroundColor: AppTheme.primaryLight,
                              foregroundColor: AppTheme.primary,
                            ),
                            if (isStrictAdmin) ...[
                              const SizedBox(height: 12),
                              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection(AppConstants.adminNotificationsCollection)
                                    .where('read', isEqualTo: false)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final unreadCount = snapshot.data?.docs.length ?? 0;
                                  return AppActionButton(
                                    label: unreadCount > 0
                                        ? 'Notifications ($unreadCount)'
                                        : 'Notifications',
                                    icon: Icons.notifications_none_rounded,
                                    onPressed: () {
                                      context.navigateSlideRight(
                                        const AdminNotificationsScreen(),
                                      );
                                    },
                                    backgroundColor: AppTheme.primaryLight,
                                    foregroundColor: AppTheme.primary,
                                  );
                                },
                              ),
                            ],
                            if (canBuyItem) ...[
                              const SizedBox(height: 18),
                              AppActionButton(
                                label: 'Buy Item',
                                icon: Icons.inventory_2_outlined,
                                onPressed: () => _openBuyItemScreen(context),
                                backgroundColor: AppTheme.primaryLight,
                                foregroundColor: AppTheme.primary,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (!canBuyItem) const SizedBox(height: 12),
                            AppActionButton(
                              label: 'Logout',
                              icon: Icons.logout_rounded,
                              onPressed: () => _handleLogout(context, auth),
                              backgroundColor: AppTheme.redLight,
                              foregroundColor: AppTheme.red,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileSettingsScreen extends StatelessWidget {
  final AuthService auth;
  final VoidCallback onDeleteAccount;
  final VoidCallback onDeleteMyData;

  const _ProfileSettingsScreen({
    required this.auth,
    required this.onDeleteAccount,
    required this.onDeleteMyData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            AppActionButton(
              label: 'Delete Account',
              icon: Icons.delete_forever_rounded,
              onPressed: auth.processing ? null : onDeleteAccount,
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            AppActionButton(
              label: 'Delete My Data',
              icon: Icons.delete_sweep_outlined,
              onPressed: auth.processing ? null : onDeleteMyData,
              backgroundColor: AppTheme.redLight,
              foregroundColor: AppTheme.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  State<_InfoTile> createState() => _InfoTileState();
}

class _InfoTileState extends State<_InfoTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _pressed
                ? AppTheme.primary.withValues(alpha: 0.92)
                : AppTheme.textDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: AppTheme.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
