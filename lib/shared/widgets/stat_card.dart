import 'package:flutter/material.dart';

/// A stat card that displays an icon, label, and value.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.onTap,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  /// Compact stat card variant.
  const StatCard.compact({
    Key? key,
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? valueColor,
    VoidCallback? onTap,
  })  : icon = icon,
        label = label,
        value = value,
        iconColor = iconColor,
        valueColor = valueColor,
        onTap = onTap,
        padding = const EdgeInsets.all(12),
        width = null,
        height = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF141418);
    final borderColor = onTap != null
        ? const Color(0xFF222228)
        : const Color(0xFF222228);
    final effectiveIconColor = iconColor ?? const Color(0xFF3B82F6);

    Widget card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: effectiveIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: effectiveIconColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Value and label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// A mini stat card for inline use.
class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const MiniStatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statColor = color ?? const Color(0xFF3B82F6);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: statColor,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: statColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
