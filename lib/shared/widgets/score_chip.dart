import 'package:flutter/material.dart';

/// A score chip that displays a score (0-100) with color coding.
class ScoreChip extends StatelessWidget {
  final int score;
  final String? label;
  final double? size;
  final bool showLabel;
  final bool compact;

  const ScoreChip({
    Key? key,
    required this.score,
    this.label,
    this.size,
    this.showLabel = true,
    this.compact = false,
  }) : super(key: key);

  /// Get color based on score value.
  static Color getColor(int score) {
    if (score < 40) {
      return const Color(0xFFEF4444); // Red
    } else if (score < 70) {
      return const Color(0xFFF59E0B); // Amber
    } else {
      return const Color(0xFF22C55E); // Green
    }
  }

  /// Get background color based on score value.
  static Color getBackgroundColor(int score) {
    if (score < 40) {
      return const Color(0xFFEF4444).withOpacity(0.1);
    } else if (score < 70) {
      return const Color(0xFFF59E0B).withOpacity(0.1);
    } else {
      return const Color(0xFF22C55E).withOpacity(0.1);
    }
  }

  /// Get label based on score value.
  static String getScoreLabel(int score) {
    if (score < 40) {
      return 'Poor';
    } else if (score < 70) {
      return 'Good';
    } else {
      return 'Excellent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor(score);
    final bgColor = getBackgroundColor(score);
    final displayLabel = label ?? (showLabel ? getScoreLabel(score) : null);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Text(
          '$score',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size ?? 12,
        vertical: (size ?? 12) * 0.35,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score value
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: size != null ? size! * 0.9 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (displayLabel != null) ...[
            const SizedBox(width: 4),
            Text(
              displayLabel,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: size != null ? size! * 0.65 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A circular score display widget.
class ScoreCircle extends StatelessWidget {
  final int score;
  final double size;
  final String? label;
  final bool showLabel;

  const ScoreCircle({
    Key? key,
    required this.score,
    this.size = 48,
    this.label,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = ScoreChip.getColor(score);
    final bgColor = ScoreChip.getBackgroundColor(score);
    final displayLabel = label ?? (showLabel ? ScoreChip.getScoreLabel(score) : null);

    return SizedBox(
      width: size,
      height: size + (displayLabel != null ? 16 : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background circle
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color.withOpacity(0.1),
                  ),
                ),
                // Score arc
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: Colors.transparent,
                ),
                // Center text
                Center(
                  child: Text(
                    '$score',
                    style: TextStyle(
                      color: color,
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Label
          if (displayLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              displayLabel,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: size * 0.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
