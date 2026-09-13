import 'package:flutter/material.dart';

/// Responsive breakpoint values.
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  static const double mobileMax = 599;
  static const double tabletMax = 1023;
  static const double desktopMax = 1439;
}

/// Responsive layout information.
class ResponsiveLayout {
  final double screenWidth;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const ResponsiveLayout({
    required this.screenWidth,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  /// Create responsive layout from screen width.
  factory ResponsiveLayout.fromWidth(double width) {
    return ResponsiveLayout(
      screenWidth: width,
      isMobile: width < Breakpoints.mobile,
      isTablet: width >= Breakpoints.mobile && width < Breakpoints.tablet,
      isDesktop: width >= Breakpoints.tablet,
    );
  }

  /// Get the current breakpoint name.
  String get breakpointName {
    if (isMobile) return 'mobile';
    if (isTablet) return 'tablet';
    return 'desktop';
  }

  /// Get max content width based on breakpoint.
  double get maxContentWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return 720;
    return 1080;
  }
}

/// A builder that provides responsive layout information.
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveLayout layout) builder;
  final Widget Function(BuildContext context, ResponsiveLayout layout)? mobileBuilder;
  final Widget Function(BuildContext context, ResponsiveLayout layout)? tabletBuilder;
  final Widget Function(BuildContext context, ResponsiveLayout layout)? desktopBuilder;

  const ResponsiveLayoutBuilder({
    Key? key,
    required this.builder,
    this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromWidth(constraints.maxWidth);

        // Use specific builders if provided
        if (layout.isMobile && mobileBuilder != null) {
          return mobileBuilder!(context, layout);
        }
        if (layout.isTablet && tabletBuilder != null) {
          return tabletBuilder!(context, layout);
        }
        if (layout.isDesktop && desktopBuilder != null) {
          return desktopBuilder!(context, layout);
        }

        // Fall back to general builder
        return builder(context, layout);
      },
    );
  }
}

/// Extension on BuildContext for responsive utilities.
extension ResponsiveExtensions on BuildContext {
  /// Get responsive layout from current context.
  ResponsiveLayout get responsive {
    return ResponsiveLayout.fromWidth(MediaQuery.of(this).size.width);
  }

  /// Check if current screen is mobile.
  bool get isMobile => responsive.isMobile;

  /// Check if current screen is tablet.
  bool get isTablet => responsive.isTablet;

  /// Check if current screen is desktop.
  bool get isDesktop => responsive.isDesktop;
}
