import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A small colored tag chip with optional remove button.
class TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final bool removable;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final double? fontSize;

  const TagChip({
    Key? key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.removable = false,
    this.onRemove,
    this.onTap,
    this.fontSize,
  }) : super(key: key);

  /// Blue tag variant.
  const TagChip.blue({
    Key? key,
    required String label,
    bool removable = false,
    VoidCallback? onRemove,
    VoidCallback? onTap,
  })  : label = label,
        color = const Color(0xFF3B82F6),
        backgroundColor = null,
        removable = removable,
        onRemove = onRemove,
        onTap = onTap,
        fontSize = null,
        super(key: key);

  /// Purple tag variant.
  const TagChip.purple({
    Key? key,
    required String label,
    bool removable = false,
    VoidCallback? onRemove,
    VoidCallback? onTap,
  })  : label = label,
        color = const Color(0xFF8B5CF6),
        backgroundColor = null,
        removable = removable,
        onRemove = onRemove,
        onTap = onTap,
        fontSize = null,
        super(key: key);

  /// Green tag variant.
  const TagChip.green({
    Key? key,
    required String label,
    bool removable = false,
    VoidCallback? onRemove,
    VoidCallback? onTap,
  })  : label = label,
        color = const Color(0xFF22C55E),
        backgroundColor = null,
        removable = removable,
        onRemove = onRemove,
        onTap = onTap,
        fontSize = null,
        super(key: key);

  /// Amber tag variant.
  const TagChip.amber({
    Key? key,
    required String label,
    bool removable = false,
    VoidCallback? onRemove,
    VoidCallback? onTap,
  })  : label = label,
        color = const Color(0xFFF59E0B),
        backgroundColor = null,
        removable = removable,
        onRemove = onRemove,
        onTap = onTap,
        fontSize = null,
        super(key: key);

  /// Red tag variant.
  const TagChip.red({
    Key? key,
    required String label,
    bool removable = false,
    VoidCallback? onRemove,
    VoidCallback? onTap,
  })  : label = label,
        color = const Color(0xFFEF4444),
        backgroundColor = null,
        removable = removable,
        onRemove = onRemove,
        onTap = onTap,
        fontSize = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagColor = color ?? const Color(0xFF3B82F6);
    final bgColor = backgroundColor ?? tagColor.withOpacity(0.12);

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: tagColor.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              color: tagColor,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Remove button
          if (removable && onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                PhosphorIcons.x,
                size: 12,
                color: tagColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      chip = GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }

    return chip;
  }
}
