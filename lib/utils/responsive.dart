import 'package:flutter/material.dart';

/// Helper class for responsive design breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
}

/// Extension methods for responsive design
extension ResponsiveContext on BuildContext {
  /// Screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Screen width
  double get screenWidth => screenSize.width;
  
  /// Screen height
  double get screenHeight => screenSize.height;

  /// Device padding (safe area)
  EdgeInsets get devicePadding => MediaQuery.of(this).padding;

  /// Is mobile device
  bool get isMobile => screenWidth < ResponsiveBreakpoints.tablet;

  /// Is tablet device
  bool get isTablet => screenWidth >= ResponsiveBreakpoints.tablet &&
      screenWidth < ResponsiveBreakpoints.desktop;

  /// Is desktop device
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.desktop;

  /// Device orientation
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Is portrait
  bool get isPortrait => orientation == Orientation.portrait;

  /// Is landscape
  bool get isLandscape => orientation == Orientation.landscape;

  /// Responsive padding based on screen width
  double get responsivePadding {
    if (isDesktop) return 32;
    if (isTablet) return 24;
    return 16;
  }

  /// Number of columns for grid based on device
  int get gridColumns {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }
}

/// Utility class for responsive design helpers
class ResponsiveHelper {
  static double scaleFont(BuildContext context, double baseSize) {
    if (context.isDesktop) return baseSize * 1.2;
    if (context.isTablet) return baseSize * 1.1;
    return baseSize;
  }

  static EdgeInsets responsiveMargin(BuildContext context) {
    final padding = context.responsivePadding;
    return EdgeInsets.all(padding);
  }

  static int getGridColumns(BuildContext context) {
    return context.gridColumns;
  }
}
