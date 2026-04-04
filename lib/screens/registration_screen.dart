import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../config/app_constants.dart';
import '../config/app_validators.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _acceptedPolicy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedPolicy) return;

    final auth = context.read<AuthService>();
    try {
      await auth.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

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
                        const Text('Create Account',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.dark)),
                        const SizedBox(height: 4),
                        const Text('Join Pinky Shop today',
                            style: TextStyle(
                                color: AppTheme.textGray, fontSize: 15)),
                        const SizedBox(height: 28),
                        if (auth.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.redLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.red.withValues(alpha: 0.2)),
                            ),
                            child: Text(auth.errorMessage!,
                                style: const TextStyle(
                                    color: AppTheme.red, fontSize: 13)),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _label('Full Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          validator: AppValidators.name,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded,
                                color: AppTheme.textGray),
                            hintText: 'Your name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('Email Address'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: AppValidators.email,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.mail_outline_rounded,
                                color: AppTheme.textGray),
                            hintText: 'name@example.com',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          validator: AppValidators.password,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: AppTheme.textGray),
                            hintText: '••••••••',
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textGray),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormField<bool>(
                          initialValue: _acceptedPolicy,
                          validator: (value) {
                            if (value != true) {
                              return 'You must accept the Privacy Policy and User Agreement.';
                            }
                            return null;
                          },
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  value: _acceptedPolicy,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptedPolicy = value ?? false;
                                    });
                                    state.didChange(_acceptedPolicy);
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'I agree to the Privacy Policy and User Agreement',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                if (state.errorText != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      state.errorText!,
                                      style: const TextStyle(
                                        color: AppTheme.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.processing ? null : _handleRegister,
                            child: auth.processing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : const Text('Create Account'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, Routes.login.path),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                    color: AppTheme.textGray, fontSize: 14),
                                children: [
                                  TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                        color: AppTheme.royalBlue,
                                        fontWeight: FontWeight.w700),
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

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.dark));
}
