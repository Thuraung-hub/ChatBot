// lib/screens/auth_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  void _toggle() => setState(() { _isLogin = !_isLogin; });

  void _submit() {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    if (_isLogin) {
      if (email.isEmpty || pass.isEmpty) {
        _snack('Please fill in all fields.');
        return;
      }
      context.read<UserProvider>().login(
          email.split('@').first.replaceAll('.', ' ').split(' ')
              .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
              .join(' '),
          email);
    } else {
      if (name.isEmpty || email.isEmpty || pass.isEmpty) {
        _snack('Please fill in all fields.');
        return;
      }
      context.read<UserProvider>().login(name, email);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Ambient Gradient Background ──────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.3, -0.6),
                  radius: 1.2,
                  colors: [Color(0xFF0D3D2B), AppColors.bg],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Logo
                  Container(
                    width: 76, height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDk],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shopping_bag_rounded,
                        color: Colors.white, size: 38),
                  ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 20),
                  Text('STITCH SHOP',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      )).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _isLogin ? 'Welcome back' : 'Create account',
                      key: ValueKey(_isLogin),
                      style: GoogleFonts.inter(
                        color: AppColors.text,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin ? 'Sign in to your account' : 'Join the community',
                    style: GoogleFonts.inter(
                        color: AppColors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // Glass form card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.glass,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: !_isLogin
                                  ? AppInput(
                                      label: 'Full Name',
                                      hint: 'Alex Chen',
                                      controller: _nameCtrl,
                                      textInputAction: TextInputAction.next,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            AppInput(
                              label: 'Email',
                              hint: 'you@example.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            AppInput(
                              label: 'Password',
                              hint: '••••••••',
                              controller: _passCtrl,
                              obscure: true,
                              textInputAction: TextInputAction.done,
                              onSubmit: _submit,
                            ),
                            EmeraldButton(
                              label: _isLogin ? 'Sign In' : 'Create Account',
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                        style: GoogleFonts.inter(
                            color: AppColors.textMuted, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: _toggle,
                        child: Text(
                          _isLogin ? 'Create account' : 'Sign in',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }
}
