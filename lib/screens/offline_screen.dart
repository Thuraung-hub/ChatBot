import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../utils/responsive.dart';

class OfflineScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final bodyPadding = context.responsivePadding;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(bodyPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wifi icon with slash
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: isMobile ? 82 : 100,
                      color: AppTheme.primary.withValues(alpha: 0.3),
                    ),
                    Container(
                      width: isMobile ? 96 : 120,
                      height: isMobile ? 96 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Title
                Text(
                  'You are offline',
                  style: TextStyle(
                    fontSize: isMobile ? 26 : 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 32),
                  child: Text(
                    'Check your connection to continue your shopping support session.',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),

                // Retry Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Check Connection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
