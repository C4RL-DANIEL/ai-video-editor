import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_button.dart';

/// An error display widget with error icon, message, and retry button.
class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? details;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.details,
    this.retryLabel = 'Retry',
    this.onRetry,
    this.icon,
  }) : super(key: key);

  /// Network error.
  const ErrorDisplay.network({
    Key? key,
    String? details,
    VoidCallback? onRetry,
  })  : message = 'Network error',
        details = details ?? 'Please check your connection and try again.',
        retryLabel = 'Retry',
        onRetry = onRetry,
        icon = PhosphorIcons.wifiSlash,
        super(key: key);

  /// Generic error.
  const ErrorDisplay.generic({
    Key? key,
    String? message,
    String? details,
    VoidCallback? onRetry,
  })  : message = message ?? 'Something went wrong',
        details = details,
        retryLabel = 'Retry',
        onRetry = onRetry,
        icon = PhosphorIcons.warningCircle,
        super(key: key);

  /// Server error.
  const ErrorDisplay.server({
    Key? key,
    String? details,
    VoidCallback? onRetry,
  })  : message = 'Server error',
        details = details ?? 'The server is unavailable. Please try again later.',
        retryLabel = 'Retry',
        onRetry = onRetry,
        icon = PhosphorIcons.server,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Icon(
                  icon ?? PhosphorIcons.warningCircle,
                  size: 32,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Message
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Details
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: const TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton.outline(
                label: retryLabel!,
                icon: const Icon(
                  PhosphorIcons.arrowClockwise,
                  size: 16,
                  color: Color(0xFFA0A0A0),
                ),
                size: AppButtonSize.compact,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
