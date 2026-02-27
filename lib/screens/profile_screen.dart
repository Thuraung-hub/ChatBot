// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final name  = user.name  ?? 'Guest User';
    final email = user.email ?? 'guest@example.com';
    final initials = name.split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 32,
        bottom: 32 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // ── Avatar ────────────────────────────────────────────────────────
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDk],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:      AppColors.primary.withOpacity(0.35),
                      blurRadius: 24,
                      offset:     const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(initials,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    )),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color:  AppColors.surface,
                  shape:  BoxShape.circle,
                  border: Border.all(color: AppColors.bg, width: 2),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: AppColors.text, size: 15),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.85, 0.85)),

          const SizedBox(height: 16),
          Text(name,
              style: GoogleFonts.inter(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              )).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 4),
          Text(email,
              style: GoogleFonts.inter(
                  color: AppColors.textMuted, fontSize: 14))
              .animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 20),
          // Stats
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _Stat(value: '12', label: 'Orders'),
                _vDivider(),
                _Stat(value: '4',  label: 'Reviews'),
                _vDivider(),
                _Stat(value: '8',  label: 'Saved'),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 28),
          // Action items
          ..._actions(context).asMap().entries.map((e) {
            final a = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActionTile(
                icon:    a['icon'] as IconData,
                label:   a['label'] as String,
                sub:     a['sub'] as String,
                onTap:   a['onTap'] as VoidCallback,
                isDanger: a['danger'] == true,
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 300 + e.key * 60),
                  ).slideX(begin: 0.05),
            );
          }),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1, height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.border,
      );

  List<Map<String, dynamic>> _actions(BuildContext context) => [
        {
          'icon':  Icons.local_shipping_outlined,
          'label': 'My Orders',
          'sub':   'Track your purchases',
          'onTap': () {},
        },
        {
          'icon':  Icons.favorite_border_rounded,
          'label': 'Saved Items',
          'sub':   'Your wishlist',
          'onTap': () {},
        },
        {
          'icon':  Icons.credit_card_rounded,
          'label': 'Payment Methods',
          'sub':   'Cards & wallets',
          'onTap': () {},
        },
        {
          'icon':  Icons.security_rounded,
          'label': 'Privacy & Security',
          'sub':   '2FA, data & alerts',
          'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PrivacySecurityScreen())),
        },
        {
          'icon':  Icons.notifications_none_rounded,
          'label': 'Notifications',
          'sub':   'Manage alerts',
          'onTap': () {},
        },
        {
          'icon':  Icons.logout_rounded,
          'label': 'Sign Out',
          'sub':   'Log out of your account',
          'danger': true,
          'onTap': () => context.read<UserProvider>().logout(),
        },
      ];
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String   label, sub;
  final VoidCallback onTap;
  final bool     isDanger;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDanger
                  ? AppColors.danger.withOpacity(0.3)
                  : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isDanger
                    ? AppColors.danger.withOpacity(0.1)
                    : AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isDanger ? AppColors.danger : AppColors.textSubtle,
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                        color: isDanger ? AppColors.danger : AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                  Text(sub,
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: isDanger ? AppColors.danger : AppColors.textMuted,
                size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Privacy & Security Screen ────────────────────────────────────────────────
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Security
          _SectionHeader('Security'),
          const SizedBox(height: 12),
          _ToggleTile(
            icon:    Icons.verified_user_rounded,
            label:   'Two-Factor Authentication',
            sub:     'Add an extra layer of protection',
            value:   user.twoFactorEnabled,
            onChange: user.setTwoFactor,
          ),
          const SizedBox(height: 10),
          _ToggleTile(
            icon:    Icons.notifications_active_rounded,
            label:   'Security Alerts',
            sub:     'Get notified of unusual activity',
            value:   user.securityAlerts,
            onChange: user.setSecurityAlerts,
          ),

          const SizedBox(height: 28),
          // Data
          _SectionHeader('Data & Privacy'),
          const SizedBox(height: 12),
          _ToggleTile(
            icon:    Icons.share_outlined,
            label:   'Data Sharing',
            sub:     'Share usage data to improve the app',
            value:   user.dataSharing,
            onChange: user.setDataSharing,
          ),
          const SizedBox(height: 10),
          _InfoTile(
            icon:  Icons.download_outlined,
            label: 'Download My Data',
            sub:   'Get a copy of your account data',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data export will be emailed to you.')),
            ),
          ),

          // Danger zone
          const SizedBox(height: 36),
          _SectionHeader('Danger Zone', color: AppColors.danger),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.danger.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delete Account',
                    style: GoogleFonts.inter(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    )),
                const SizedBox(height: 6),
                Text(
                  'This action permanently deletes your account and all data. '
                  'This cannot be undone.',
                  style: GoogleFonts.inter(
                      color: AppColors.textMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _confirmDelete(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Delete My Account',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Account?',
            style: GoogleFonts.inter(
                color: AppColors.text, fontWeight: FontWeight.w800)),
        content: Text(
          'This will permanently remove your account. You cannot undo this action.',
          style: GoogleFonts.inter(
              color: AppColors.textMuted, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textSubtle)),
          ),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().deleteAccount();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final Color  color;
  const _SectionHeader(this.text, {this.color = AppColors.textSubtle});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String   label, sub;
  final bool     value;
  final void Function(bool) onChange;
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.textSubtle, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
                Text(sub,
                    style: GoogleFonts.inter(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChange,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String   label, sub;
  final VoidCallback onTap;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.textSubtle, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                  Text(sub,
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
