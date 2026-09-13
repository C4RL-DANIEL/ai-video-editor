import 'package:flutter/material.dart';

/// Extensions on [BuildContext] for convenient access to common utilities.
extension ContextExtensions on BuildContext {
  // ─── Theme ──────────────────────────────────────────────────────────────

  /// Returns the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Returns the current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns the current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ─── Screen Dimensions ──────────────────────────────────────────────────

  /// Returns the screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the screen height.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns true if the screen width is less than 600 (mobile).
  bool get isMobile => screenWidth < 600;

  /// Returns true if the screen width is between 600 and 1024 (tablet).
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  /// Returns true if the screen width is 1024 or more (desktop).
  bool get isDesktop => screenWidth >= 1024;

  /// Returns the current keyboard height (0 if hidden).
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  /// Returns true if the keyboard is currently visible.
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Returns the top padding (e.g., status bar height).
  double get topPadding => MediaQuery.of(this).padding.top;

  /// Returns the bottom padding (e.g., home indicator height).
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  // ─── Navigation ─────────────────────────────────────────────────────────

  /// Pushes a named route onto the navigator.
  ///
  /// Example:
  /// ```dart
  /// context.pushNamed('/editor', arguments: {'projectId': '123'});
  /// ```
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Pushes a material page route onto the navigator.
  ///
  /// Example:
  /// ```dart
  /// context.push(MaterialPageRoute(builder: (_) => EditorPage()));
  /// ```
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Pushes and removes all routes until the predicate returns true.
  ///
  /// Example:
  /// ```dart
  /// context.pushAndRemoveUntil('/');
  /// ```
  void pushAndRemoveUntil(String routeName, {bool Function(Route<dynamic>)? predicate}) {
    Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      predicate ?? (_) => false,
    );
  }

  /// Replaces the current route with a new named route.
  ///
  /// Example:
  /// ```dart
  /// context.pushReplacementNamed('/home');
  /// ```
  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed<T, void>(routeName, arguments: arguments);
  }

  /// Pops the current route.
  ///
  /// Example:
  /// ```dart
  /// context.pop();
  /// ```
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// Pops until the predicate returns true.
  ///
  /// Example:
  /// ```dart
  /// context.popUntil('/');
  /// ```
  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }

  /// Returns true if the navigator can pop.
  bool get canPop => Navigator.of(this).canPop();

  // ─── SnackBar ───────────────────────────────────────────────────────────

  /// Shows a [SnackBar] with the given message.
  ///
  /// [type] can be:
  /// - "success" (green)
  /// - "error" (red)
  /// - "warning" (amber)
  /// - "info" (blue, default)
  ///
  /// Example:
  /// ```dart
  /// context.showSnackBar('Video exported successfully!', type: 'success');
  /// ```
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    String type = 'info',
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'success':
        backgroundColor = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        break;
      case 'error':
        backgroundColor = Colors.red.shade700;
        icon = Icons.error_outline;
        break;
      case 'warning':
        backgroundColor = Colors.amber.shade700;
        icon = Icons.warning_amber_outlined;
        break;
      default:
        backgroundColor = Colors.blue.shade700;
        icon = Icons.info_outline;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
    );

    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// Hides the current [SnackBar] if any.
  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  // ─── Dialog ─────────────────────────────────────────────────────────────

  /// Shows a material dialog.
  ///
  /// Example:
  /// ```dart
  /// context.showDialog(
  ///   title: Text('Delete Project'),
  ///   content: Text('Are you sure you want to delete this project?'),
  ///   actions: [
  ///     TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
  ///     TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
  ///   ],
  /// );
  /// ```
  Future<T?> showDialog<T>({
    required Widget title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: title,
          content: content,
          actions: actions,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );
      },
    );
  }

  /// Shows a confirmation dialog and returns true if confirmed.
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await context.showConfirmDialog(
  ///   title: 'Delete?',
  ///   message: 'This action cannot be undone.',
  ///   confirmText: 'Delete',
  /// );
  /// ```
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => pop(true),
          style: confirmColor != null
              ? TextButton.styleFrom(foregroundColor: confirmColor)
              : null,
          child: Text(confirmText),
        ),
      ],
    );
    return result ?? false;
  }

  // ─── Focus ──────────────────────────────────────────────────────────────

  /// Unfocuses the current focus node (hides keyboard).
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  /// Requests focus on a specific [FocusNode].
  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }
}
