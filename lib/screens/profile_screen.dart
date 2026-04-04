import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_action_button.dart';
import 'buy_item_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context, AuthService auth) async {
    await auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.login.path);
    }
  }

  void _openBuyItemScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BuyItemScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = auth.profile;
    final isAdmin = auth.isAdmin;

    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner + Avatar
            Stack(
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
                  left: 28,
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
                            offset: const Offset(0, 8))
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppTheme.primary, size: 44),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 56),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name,
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textGray)),
                            const SizedBox(height: 2),
                            Text(profile.email,
                                style: const TextStyle(
                                    color: AppTheme.textGray, fontSize: 14)),
                          ],
                        ),
                      ),
                      ],
                    ),
                    const SizedBox(height: 32),

                  // Account info section
                  Text('ACCOUNT INFORMATION',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade400,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 12),

                  _InfoTile(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: profile.email,
                  ),
                  const SizedBox(height: 10),
                  _InfoTile(
                    icon: Icons.shield_outlined,
                    label: 'Role',
                    value: isAdmin ? 'Admin' : 'Customer',
                  ),
                  const SizedBox(height: 18),
                  AppActionButton(
                    label: 'Buy Item',
                    icon: Icons.inventory_2_outlined,
                    onPressed: () => _openBuyItemScreen(context),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Logout',
                    icon: Icons.logout_rounded,
                    onPressed: () => _handleLogout(context, auth),
                    backgroundColor: AppTheme.redLight,
                    foregroundColor: AppTheme.red,
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Delete Account',
                    icon: Icons.delete_forever_rounded,
                    onPressed: auth.processing
                        ? null
                        : () => _confirmDeleteAccount(context, auth),
                    backgroundColor: AppTheme.red,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  AppActionButton(
                    label: 'Delete My Data',
                    icon: Icons.delete_forever_rounded,
                    onPressed: auth.processing
                        ? null
                        : () => _confirmDeleteMyData(context, auth),
                    backgroundColor: AppTheme.red,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, AuthService auth) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently erase your account, email, and chat history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await auth.deleteAccount();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, Routes.login.path);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _confirmDeleteMyData(
      BuildContext context, AuthService auth) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete My Data'),
        content: const Text(
          'This will permanently remove your purchased items and order history. Your account will stay active. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await auth.deleteMyData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase history deleted successfully.'),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textGray,
                      letterSpacing: 0.8)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.dark)),
            ],
          ),
        ],
      ),
    );
  }
}
