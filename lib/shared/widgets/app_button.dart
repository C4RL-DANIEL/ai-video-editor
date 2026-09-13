import 'package:flutter/material.dart';

/// Button variant enumeration.
enum AppButtonVariant { primary, secondary, outline, ghost, danger }

/// Button size enumeration.
enum AppButtonSize { normal, compact }

/// A reusable app button with multiple variants and states.
class AppButton extends StatefulWidget {
  final String? label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final bool isLoading;
  final bool enabled;
  final String? tooltip;
  final double? width;
  final double? height;

  const AppButton({
    Key? key,
    this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
    this.fullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.tooltip,
    this.width,
    this.height,
  }) : super(key: key);

  /// Primary button variant.
  const AppButton.primary({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = AppButtonSize.normal,
    this.fullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.tooltip,
    this.width,
    this.height,
  })  : variant = AppButtonVariant.primary,
        super(key: key);

  /// Secondary button variant.
  const AppButton.secondary({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = AppButtonSize.normal,
    this.fullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.tooltip,
    this.width,
    this.height,
  })  : variant = AppButtonVariant.secondary,
        super(key: key);

  /// Outline button variant.
  const AppButton.outline({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = AppButtonSize.normal,
    this.fullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.tooltip,
    this.width,
    this.height,
  })  : variant = AppButtonVariant.outline,
        super(key: key);

  /// Ghost button variant.
  const AppButton.ghost({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = AppButtonSize.normal,
    this.fullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.tooltip,
    this.width,
    this.height,
  })  : variant = AppButtonVariant.ghost,
        super(key: key);

  /// Danger button variant.
  const AppButton.danger({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = AppButtonSize.normal,
    this.fullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.tooltip,
    this.width,
    this.height,
  })  : variant = AppButtonVariant.danger,
        super(key: key);

  /// Icon-only button.
  const AppButton.iconOnly({
    Key? key,
    required this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.ghost,
    this.size = AppButtonSize.normal,
    this.tooltip,
  })  : label = null,
        fullWidth = false,
        isLoading = false,
        enabled = true,
        width = null,
        height = null,
        super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return 'AppButton($label, variant: $variant)';
  }
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isEnabled => widget.enabled && !widget.isLoading;

  Color _getBackgroundColor() {
    if (!_isEnabled) {
      return const Color(0xFF222228);
    }
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return const Color(0xFF3B82F6);
      case AppButtonVariant.secondary:
        return const Color(0xFF1A1A1F);
      case AppButtonVariant.outline:
        return Colors.transparent;
      case AppButtonVariant.ghost:
        return _isHovered ? const Color(0xFF222228) : Colors.transparent;
      case AppButtonVariant.danger:
        return const Color(0xFFEF4444);
    }
  }

  Color _getTextColor() {
    if (!_isEnabled) {
      return const Color(0xFF6B6B6B);
    }
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
        return Colors.white;
      case AppButtonVariant.outline:
        return const Color(0xFFA0A0A0);
      case AppButtonVariant.ghost:
        return const Color(0xFFA0A0A0);
    }
  }

  Color _getBorderColor() {
    if (!_isEnabled) {
      return const Color(0xFF222228);
    }
    switch (widget.variant) {
      case AppButtonVariant.outline:
        return _isHovered
            ? const Color(0xFF3B82F6)
            : const Color(0xFF222228);
      default:
        return Colors.transparent;
    }
  }

  double _getElevation() {
    if (!_isEnabled) return 0;
    if (_isPressed) return 0;
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return _isHovered ? 6 : 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.size == AppButtonSize.compact;
    final padding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    final fontSize = isCompact ? 13.0 : 14.0;
    final minHeight = widget.height ?? (isCompact ? 32.0 : 40.0);

    Widget child;

    if (widget.isLoading) {
      child = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    } else if (widget.icon != null && widget.label != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Text(widget.label!),
        ],
      );
    } else if (widget.icon != null) {
      child = widget.icon!;
    } else {
      child = Text(widget.label ?? '');
    }

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(
            minHeight: minHeight,
            minWidth: widget.width ?? 0,
          ),
          padding: padding,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_getElevation() * 0.05),
                blurRadius: _getElevation(),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: _getTextColor(),
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (_isEnabled && widget.onPressed != null) {
      button = GestureDetector(
        onTap: widget.onPressed,
        child: button,
      );
    }

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
