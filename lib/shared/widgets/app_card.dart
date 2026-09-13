import 'package:flutter/material.dart';

/// Card variant enumeration.
enum AppCardVariant { elevated, outlined, filled }

/// A reusable card widget with optional hover effect and tap handler.
class AppCard extends StatefulWidget {
  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final bool enableHover;
  final BorderRadiusGeometry? borderRadius;

  const AppCard({
    Key? key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.enableHover = true,
    this.borderRadius,
  }) : super(key: key);

  /// Elevated card with shadow.
  const AppCard.elevated({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.enableHover = true,
    this.borderRadius,
  })  : variant = AppCardVariant.elevated,
        super(key: key);

  /// Outlined card with border.
  const AppCard.outlined({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.enableHover = true,
    this.borderRadius,
  })  : variant = AppCardVariant.outlined,
        super(key: key);

  /// Filled card with background color.
  const AppCard.filled({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.enableHover = true,
    this.borderRadius,
  })  : variant = AppCardVariant.filled,
        super(key: key);

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  Color _getBackgroundColor() {
    if (_isHovered && widget.onTap != null) {
      return const Color(0xFF1A1A1F);
    }
    switch (widget.variant) {
      case AppCardVariant.elevated:
        return const Color(0xFF141418);
      case AppCardVariant.outlined:
        return const Color(0xFF0D0D0F);
      case AppCardVariant.filled:
        return const Color(0xFF1A1A1F);
    }
  }

  Color _getBorderColor() {
    if (widget.borderColor != null) return widget.borderColor!;
    if (_isHovered && widget.onTap != null) {
      return const Color(0xFF3B82F6).withOpacity(0.3);
    }
    switch (widget.variant) {
      case AppCardVariant.elevated:
        return const Color(0xFF222228);
      case AppCardVariant.outlined:
        return const Color(0xFF222228);
      case AppCardVariant.filled:
        return Colors.transparent;
    }
  }

  List<BoxShadow> _getBoxShadow() {
    if (_isHovered && widget.onTap != null) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    switch (widget.variant) {
      case AppCardVariant.elevated:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case AppCardVariant.outlined:
      case AppCardVariant.filled:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: radius,
        border: Border.all(color: _getBorderColor()),
        boxShadow: _getBoxShadow(),
      ),
      child: widget.child,
    );

    if (widget.enableHover && widget.onTap != null) {
      card = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: card,
        ),
      );
    } else if (widget.onTap != null) {
      card = GestureDetector(
        onTap: widget.onTap,
        child: card,
      );
    }

    return card;
  }
}
