import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart' as app;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String _error = '';
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() { _loading = true; _error = ''; });
    try {
      await context.read<app.AuthProvider>().signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() { _error = ''; });
    try {
      await context.read<app.AuthProvider>().signInWithGoogle();
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded,
                      color: AppTheme.primary, size: 36),
                ),
                const SizedBox(height: 32),

                // Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderGray),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome Back',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.dark)),
                      const SizedBox(height: 4),
                      const Text('Login to access your account',
                          style: TextStyle(color: AppTheme.textGray, fontSize: 15)),
                      const SizedBox(height: 28),

                      // Error
                      if (_error.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.redLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.red.withValues(alpha: 0.2)),
                          ),
                          child: Text(_error,
                              style: const TextStyle(
                                  color: AppTheme.red, fontSize: 13)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email field
                      const Text('Email Address',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.dark)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline_rounded,
                              color: AppTheme.textGray),
                          hintText: 'name@example.com',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      const Text('Password',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.dark)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppTheme.textGray),
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.textGray,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onSubmitted: (_) => _handleEmailLogin(),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.royalBlue,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppTheme.royalBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleEmailLogin,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text('Login'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(children: [
                        const Expanded(child: Divider(color: AppTheme.borderGray)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Or continue with',
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 13)),
                        ),
                        const Expanded(child: Divider(color: AppTheme.borderGray)),
                      ]),
                      const SizedBox(height: 24),

                      // Google Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _handleGoogleLogin,
                          icon: const Icon(Icons.g_mobiledata_rounded,
                              size: 24, color: Colors.white),
                          label: const Text('Google Account',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.deepButtonBg,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppTheme.deepButtonBorder),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign up link
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/signup'),
                          child: RichText(
                            text: const TextSpan(
                              style:
                                  TextStyle(color: AppTheme.textGray, fontSize: 14),
                              children: [
                                TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Create Account',
                                  style: TextStyle(
                                    color: AppTheme.royalBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
