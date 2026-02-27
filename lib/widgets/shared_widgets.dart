// lib/widgets/shared_widgets.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

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
  final String   label;
  final VoidCallback onPressed;
  final bool     fullWidth;
  final double   height;
  final IconData? icon;

  const EmeraldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
    this.height    = 52,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
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
  final String   label;
  final VoidCallback onPressed;
  final Color?   borderColor;

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

// ─── Styled Text Input ────────────────────────────────────────────────────────
class AppInput extends StatelessWidget {
  final String             label;
  final String             hint;
  final TextEditingController controller;
  final bool               obscure;
  final TextInputType      keyboardType;
  final TextInputAction    textInputAction;
  final VoidCallback?      onSubmit;
  final Widget?            suffix;

  const AppInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure         = false,
    this.keyboardType    = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmit,
    this.suffix,
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
        TextField(
          controller:      controller,
          obscureText:     obscure,
          keyboardType:    keyboardType,
          textInputAction: textInputAction,
          onSubmitted:     onSubmit != null ? (_) => onSubmit!() : null,
          style: GoogleFonts.inter(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─── Star Rating Row ──────────────────────────────────────────────────────────
class StarRow extends StatelessWidget {
  final double rating;
  final double size;
  final bool   showCount;
  final int    count;

  const StarRow({
    super.key,
    required this.rating,
    this.size      = 14,
    this.showCount = false,
    this.count     = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) => Icon(
          i < rating.round()
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          color: AppColors.star,
          size:  size,
        )),
        if (showCount) ...[
          const SizedBox(width: 6),
          Text('$rating',
              style: GoogleFonts.inter(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: size - 1,
              )),
          const SizedBox(width: 4),
          Text('($count)',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: size - 2,
              )),
        ],
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ));
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────
class NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     selected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textMuted,
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                )),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 4),
              width:  selected ? 20 : 0,
              height: selected ? 3  : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>>   _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        3,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 600))
          ..repeat(reverse: true, period: Duration(milliseconds: 600 + i * 150)));
    _anims = _ctrls
        .map((c) => Tween(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topRight:    Radius.circular(18),
          bottomLeft:  Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => AnimatedBuilder(
            animation: _anims[i],
            builder: (_, __) => Container(
              margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
              width:  8,
              height: 8 + (_anims[i].value * 6),
              decoration: BoxDecoration(
                color:        AppColors.textMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Loader ───────────────────────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -2, end: 2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width:  widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end:   Alignment(_anim.value + 1, 0),
            colors: const [
              AppColors.surface,
              AppColors.surfaceHi,
              AppColors.surface,
            ],
          ),
        ),
      ),
    );
  }
}
