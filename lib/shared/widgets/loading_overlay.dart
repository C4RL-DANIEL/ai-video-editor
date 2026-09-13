import 'package:flutter/material.dart';

/// A full-screen semi-transparent overlay with spinner and optional message.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;
  final Color backgroundColor;
  final Color? spinnerColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    this.message,
    required this.child,
    this.backgroundColor = const Color(0x80000000),
    this.spinnerColor,
  }) : super(key: key);

  /// Convenience: wrap a widget tree and show overlay when `isLoading` is true.
  const LoadingOverlay.simple({
    Key? key,
    required bool isLoading,
    String? message,
    required Widget child,
  })  : isLoading = isLoading,
        message = message,
        child = child,
        backgroundColor = const Color(0x80000000),
        spinnerColor = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF222228),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            spinnerColor ?? const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A simple full-screen loading widget.
class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D0F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF3B82F6),
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: Color(0xFFA0A0A0),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
