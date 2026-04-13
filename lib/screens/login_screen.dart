import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../config/app_constants.dart';
import '../config/app_validators.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateCanSubmit);
    _passwordController.addListener(_updateCanSubmit);
  }

  void _updateCanSubmit() {
    final next = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
    if (_canSubmit == next) return;
    setState(() => _canSubmit = next);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateCanSubmit);
    _passwordController.removeListener(_updateCanSubmit);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthService>();

    try {
      await auth.signInWithIdentifier(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.home.path);
      }
    } catch (_) {
      auth.clearError();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('incorrect email and password'),
            duration: Duration(seconds: 5),
          ),
        );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final auth = context.read<AuthService>();

    try {
      await auth.signInWithGoogle();

      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.home.path);
      }
    } catch (_) {
      // Error is shown via auth.errorMessage panel.
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                Container(
                  constraints: const BoxConstraints(maxWidth: 420),
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
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome Back',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textDark)),
                        const SizedBox(height: 4),
                        const Text('Login to access your account',
                            style: TextStyle(
                                color: AppTheme.textGray, fontSize: 15)),
                        const SizedBox(height: 28),
                        const Text('Email or Username',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textDark)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) => AppValidators.requiredField(
                            value,
                            label: 'Email or username',
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.mail_outline_rounded,
                                color: AppTheme.textGray),
                            hintText: 'name@example.com or your username',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Password',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textDark)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              AppValidators.requiredField(value,
                                  label: 'Password'),
                          onFieldSubmitted: (_) => _handleEmailLogin(),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.processing ||
                                    _passwordController.text.isEmpty
                                ? null
                                : _handleEmailLogin,
                            child: auth.processing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
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
                        Row(
                          children: [
                            const Expanded(
                                child: Divider(color: AppTheme.borderGray)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13),
                              ),
                            ),
                            const Expanded(
                                child: Divider(color: AppTheme.borderGray)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _handleGoogleLogin,
                            icon: const Icon(Icons.g_mobiledata_rounded,
                                size: 24, color: Colors.white),
                            label: const Text(
                              'Google Account',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppTheme.deepButtonBg,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                  color: AppTheme.deepButtonBorder),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, Routes.signup.path),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                    color: AppTheme.textGray, fontSize: 14),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
