import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _roseGold = Color(0xFFFFC0CB);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.width < 380;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0A10),
              Color(0xFF17111D),
              Color(0xFF0F0C13),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -60,
              child: _SoftGlow(
                size: 220,
                color: _roseGold.withValues(alpha: 0.13),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -70,
              child: _SoftGlow(
                size: 260,
                color: _roseGold.withValues(alpha: 0.10),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 18 : 24,
                      20,
                      isCompact ? 18 : 24,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 150,
                          child: Image.asset(
                            'assets/images/pinky_shop_logo.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Pinky Shop: Your 24/7 AI-Powered Boutique.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: -0.3,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Stop searching. Start style. Let our intelligent chatbot sew your perfect look and suggest curated premium fashion, always available.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: isCompact ? 15 : 16,
                            height: 1.6,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: const [
                            _HighlightCard(
                              icon: Icons.auto_awesome_rounded,
                              title: 'AI Styling Engine',
                              subtitle: 'Personalized looks generated in seconds.',
                            ),
                            _HighlightCard(
                              icon: Icons.verified_user_outlined,
                              title: 'Trusted Premium Picks',
                              subtitle: 'Curated catalog with secure checkout flow.',
                            ),
                            _HighlightCard(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: '24/7 Fashion Chatbot',
                              subtitle: 'Guidance anytime for outfits, gifts, and trends.',
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppConstants.loginRoute);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _roseGold,
                              foregroundColor: const Color(0xFF1A1018),
                              elevation: 0,
                              minimumSize: const Size.fromHeight(60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: GoogleFonts.montserrat(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                              child: const Text('Get Personalized Style'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220, minHeight: 132),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC0CB).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Color(0xFFFFC0CB),
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 12.8,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}