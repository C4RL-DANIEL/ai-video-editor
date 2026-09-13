import 'package:flutter/material.dart';

/// Custom page transitions: fade, slide-up, slide-right.
class PageTransitions {
  PageTransitions._();

  /// Fade transition.
  static Route<T> fade<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  /// Slide up transition.
  static Route<T> slideUp<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide right transition.
  static Route<T> slideRight<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Scale transition.
  static Route<T> scale<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide from bottom (full height, like modal).
  static Route<T> modalSlideUp<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

/// Named route generator with custom transitions.
class AppRoutes {
  AppRoutes._();

  /// Generate route with fade transition.
  static Route<T> fadeRoute<T>(Widget page, String routeName) {
    return PageTransitions.fade<T>(
      page,
      settings: RouteSettings(name: routeName),
    );
  }

  /// Generate route with slide right transition.
  static Route<T> slideRightRoute<T>(Widget page, String routeName) {
    return PageTransitions.slideRight<T>(
      page,
      settings: RouteSettings(name: routeName),
    );
  }

  /// Generate route with slide up transition.
  static Route<T> slideUpRoute<T>(Widget page, String routeName) {
    return PageTransitions.slideUp<T>(
      page,
      settings: RouteSettings(name: routeName),
    );
  }
}

/// Navigation extension on BuildContext.
extension NavigationExtensions on BuildContext {
  /// Push with fade transition.
  Future<T?> pushFade<T>(Widget page) {
    return Navigator.of(this).push(PageTransitions.fade<T>(page));
  }

  /// Push with slide right transition.
  Future<T?> pushSlideRight<T>(Widget page) {
    return Navigator.of(this).push(PageTransitions.slideRight<T>(page));
  }

  /// Push with slide up transition.
  Future<T?> pushSlideUp<T>(Widget page) {
    return Navigator.of(this).push(PageTransitions.slideUp<T>(page));
  }

  /// Push with scale transition.
  Future<T?> pushScale<T>(Widget page) {
    return Navigator.of(this).push(PageTransitions.scale<T>(page));
  }

  /// Push and replace with fade transition.
  Future<T?> pushReplacementFade<T>(Widget page) {
    return Navigator.of(this).pushReplacement(PageTransitions.fade<T>(page));
  }

  /// Push and remove all with fade transition.
  Future<T?> pushAndRemoveAllFade<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil(
      PageTransitions.fade<T>(page),
      (_) => false,
    );
  }
}
