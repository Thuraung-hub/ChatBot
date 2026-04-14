import 'package:flutter/material.dart';

/// Enhanced page route builders with various transition styles
class AppPageRoute {
  /// Slide from right
  static PageRoute<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Slide from bottom (bottom sheet style)
  static PageRoute<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Fade transition
  static PageRoute<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Scale with fade (zoom in)
  static PageRoute<T> scaleWithFade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOutCubic;

        var scaleAnimation = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve))
            .animate(animation);
        var fadeAnimation = animation;

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Rotate with fade
  static PageRoute<T> rotateWithFade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = -0.1;
        const end = 0.0;

        var rotateTween = Tween(begin: begin, end: end);
        var fadeAnimation = animation;

        return ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(animation),
          child: RotationTransition(
            turns: rotateTween.animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// Slide from left
  static PageRoute<T> slideFromLeft<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}

/// Navigation helper extension
extension AppPageRouteNavigation on BuildContext {
  /// Navigate with slide from right
  Future<T?> navigateSlideRight<T>(Widget page) =>
      Navigator.of(this).push<T>(AppPageRoute.slideFromRight<T>(page));

  /// Navigate with slide from bottom
  Future<T?> navigateSlideBottom<T>(Widget page) =>
      Navigator.of(this).push<T>(AppPageRoute.slideFromBottom<T>(page));

  /// Navigate with fade
  Future<T?> navigateFade<T>(Widget page) =>
      Navigator.of(this).push<T>(AppPageRoute.fade<T>(page));

  /// Navigate with scale and fade
  Future<T?> navigateScale<T>(Widget page) =>
      Navigator.of(this).push<T>(AppPageRoute.scaleWithFade<T>(page));

  /// Navigate with rotate and fade
  Future<T?> navigateRotate<T>(Widget page) =>
      Navigator.of(this).push<T>(AppPageRoute.rotateWithFade<T>(page));

  /// Navigate with slide from left
  Future<T?> navigateSlideLeft<T>(Widget page) =>
      Navigator.of(this).push<T>(AppPageRoute.slideFromLeft<T>(page));

  /// Replace with slide from right
  Future<T?> replaceSlideRight<T>(Widget page) =>
      Navigator.of(this).pushReplacement<T, T>(AppPageRoute.slideFromRight<T>(page));

  /// Pop with animation
  void popWithAnimation() {
    Navigator.of(this).pop();
  }
}
