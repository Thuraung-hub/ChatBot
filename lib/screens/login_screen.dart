import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

class _ForgotPasswordResult {
  final bool isSuccess;
  final String message;

  const _ForgotPasswordResult._({
    required this.isSuccess,
    required this.message,
  });

  const _ForgotPasswordResult.success(String message)
      : this._(isSuccess: true, message: message);
}

class _ForgotPasswordDialog extends StatefulWidget {
  final AuthService auth;
  final String initialEmail;

  const _ForgotPasswordDialog({
    required this.auth,
    required this.initialEmail,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  static const _successMessage =
      'Reset link sent. Check your email to create a new password. If you do not see it, check your spam folder.';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _sending = false;
  String? _dialogError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _sending = true;
      _dialogError = null;
    });

    try {
      await widget.auth.sendPasswordReset(_emailController.text);

      if (!mounted) return;
      Navigator.of(context).pop(
        const _ForgotPasswordResult.success(_successMessage),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _dialogError = widget.auth.errorMessage ??
            'Unable to send reset email right now.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Reset Password',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppTheme.textDark,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Forgot your password? Enter your email to reset it.',
                style: TextStyle(color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Can\'t log in? We\'ll send you a password reset link.',
                style: TextStyle(color: AppTheme.textGray),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your registered email to receive reset instructions.',
                style: TextStyle(color: AppTheme.textGray),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  final input = value?.trim() ?? '';
                  if (input.isEmpty) {
                    return 'Email is required.';
                  }
                  return AppValidators.email(input);
                },
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: Colors.white70,
                  ),
                  hintText: 'name@example.com',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: AppTheme.textDark,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
                  ),
                ),
              ),
              if (_dialogError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _dialogError!,
                  style: TextStyle(
                    color: Colors.redAccent.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sending ? null : _submit,
          child: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Send Reset Link'),
        ),
      ],
    );
  }
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
      if (!mounted) return;
      final message = auth.errorMessage ??
          'Google sign-in failed. Please try again.';
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.redAccent.shade700,
          ),
        );
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final auth = context.read<AuthService>();
    final parentMessenger = ScaffoldMessenger.of(context);

    final result = await showDialog<_ForgotPasswordResult>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(
        auth: auth,
        initialEmail: _emailController.text.trim(),
      ),
    );

    if (!mounted || result == null) return;

    parentMessenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 4),
          backgroundColor:
              result.isSuccess ? AppTheme.green : Colors.redAccent.shade700,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isCompact = screenWidth < 600;

    final horizontalPadding = isCompact ? 16.0 : 24.0;
    final cardPadding = isCompact ? 20.0 : 32.0;
    final titleSize = isCompact ? 24.0 : 28.0;
    final subtitleSize = isCompact ? 14.0 : 15.0;
    final logoSize = isCompact ? 84.0 : 104.0;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24 + mediaQuery.viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 520 : double.infinity,
                      ),
                      child: Column(
                        mainAxisAlignment: kIsWeb
                            ? MainAxisAlignment.center
                            : (isCompact
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center),
                        children: [
                      const SizedBox(height: 8),
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppTheme.borderGray),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: EdgeInsets.all(isCompact ? 10 : 12),
                            child: Image.asset(
                              'assets/images/pinky_shop_logo.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 20 : 28),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(isCompact ? 20 : 24),
                          border: Border.all(color: AppTheme.borderGray),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.08),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(cardPadding),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome Back',
                                  style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textDark)),
                              const SizedBox(height: 4),
                              Text('Login to access your account',
                                  style: TextStyle(
                                      color: AppTheme.textGray,
                                      fontSize: subtitleSize)),
                              SizedBox(height: isCompact ? 20 : 28),
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
                                style: const TextStyle(color: Colors.white),
                                validator: (value) =>
                                    AppValidators.requiredField(
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
                                style: const TextStyle(color: Colors.white),
                                validator: (value) =>
                                    AppValidators.requiredField(value,
                                        label: 'Password'),
                                onFieldSubmitted: (_) => _handleEmailLogin(),
                                decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded,
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
                                  onPressed: _showForgotPasswordDialog,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.royalBlue,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
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
                                  onPressed: auth.processing || !_canSubmit
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                      child:
                                          Divider(color: AppTheme.borderGray)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'Or continue with',
                                      style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13),
                                    ),
                                  ),
                                  const Expanded(
                                      child:
                                          Divider(color: AppTheme.borderGray)),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    side: const BorderSide(
                                        color: AppTheme.deepButtonBorder),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, Routes.signup.path),
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                          color: AppTheme.textGray,
                                          fontSize: 14),
                                      children: [
                                        TextSpan(
                                            text: "Don't have an account? "),
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
            },
          ),
        ),
      ),
    );
  }
}
