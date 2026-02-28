// lib/widgets/shared_widgets.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
// ─── Glass Card ───────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.padding,
    this.onTap,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Emerald Button ───────────────────────────────────────────────────────────
class EmeraldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // ✅ made nullable (fix)
  final bool fullWidth;
  final double height;
  final IconData? icon;

  const EmeraldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
    this.height = 52,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8)
            ],
            Text(label,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ─── Ghost Button ─────────────────────────────────────────────────────────────
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? borderColor;

  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: BorderSide(color: borderColor ?? AppColors.border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

// ─── Styled Text Input (UPDATED) ─────────────────────────────────────────────
class AppInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmit;
  final Widget? suffix;

  // ✅ NEW
  final String? Function(String?)? validator;

  const AppInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmit,
    this.suffix,
    this.validator, // ✅ added
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
              color: AppColors.textSubtle,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            )),
        const SizedBox(height: 8),
        TextFormField( // ✅ changed from TextField
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator, // ✅ connected
          onFieldSubmitted:
              onSubmit != null ? (_) => onSubmit!() : null,
          style:
              GoogleFonts.inter(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}