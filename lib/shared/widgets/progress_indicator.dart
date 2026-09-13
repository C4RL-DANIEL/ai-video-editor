import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Progress indicator variant enumeration.
enum AppProgressIndicatorVariant { linear, circular, stepped }

/// A progress indicator with multiple variants.
class AppProgressIndicator extends StatelessWidget {
  final AppProgressIndicatorVariant variant;
  final double? value;
  final String? label;
  final Color? color;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  const AppProgressIndicator({
    Key? key,
    this.variant = AppProgressIndicatorVariant.linear,
    this.value,
    this.label,
    this.color,
    this.backgroundColor,
    this.height,
    this.width,
  }) : super(key: key);

  /// Linear progress indicator.
  const AppProgressIndicator.linear({
    Key? key,
    double? value,
    String? label,
    Color? color,
    double? height,
  })  : variant = AppProgressIndicatorVariant.linear,
        value = value,
        label = label,
        color = color,
        backgroundColor = null,
        height = height,
        width = null,
        super(key: key);

  /// Circular progress indicator.
  const AppProgressIndicator.circular({
    Key? key,
    double? value,
    String? label,
    Color? color,
    double? width,
    double? height,
  })  : variant = AppProgressIndicatorVariant.circular,
        value = value,
        label = label,
        color = color,
        backgroundColor = null,
        height = height,
        width = width,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppProgressIndicatorVariant.linear:
        return _buildLinear(context);
      case AppProgressIndicatorVariant.circular:
        return _buildCircular(context);
      case AppProgressIndicatorVariant.stepped:
        return const SizedBox.shrink(); // Use SteppedProgressIndicator
    }
  }

  Widget _buildLinear(BuildContext context) {
    final indicatorColor = color ?? const Color(0xFF3B82F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: height ?? 4,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: backgroundColor ?? const Color(0xFF222228),
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),
        ),
        if (value != null) ...[
          const SizedBox(height: 4),
          Text(
            '${(value! * 100).toInt()}%',
            style: TextStyle(
              color: indicatorColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCircular(BuildContext context) {
    final indicatorColor = color ?? const Color(0xFF3B82F6);
    final size = width ?? 36;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 3,
            backgroundColor: backgroundColor ?? const Color(0xFF222228),
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: const TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (value != null) ...[
          const SizedBox(height: 4),
          Text(
            '${(value! * 100).toInt()}%',
            style: TextStyle(
              color: indicatorColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Pipeline stage enumeration.
enum PipelineStage { upload, analyze, discover, edit, render, done }

/// A stepped progress indicator for pipeline stages.
class SteppedProgressIndicator extends StatelessWidget {
  final int currentStage;
  final bool isProcessing;
  final String? statusMessage;

  const SteppedProgressIndicator({
    Key? key,
    required this.currentStage,
    this.isProcessing = false,
    this.statusMessage,
  }) : super(key: key);

  /// All pipeline stages.
  static const List<String> _stageLabels = [
    'Upload',
    'Analyze',
    'Discover',
    'Edit',
    'Render',
    'Done',
  ];

  static const List<PhosphorIconData> _stageIcons = [
    PhosphorIconsRegular.uploadSimple,
    PhosphorIconsRegular.brain,
    PhosphorIconsRegular.magnifyingGlass,
    PhosphorIconsRegular.pencilSimple,
    PhosphorIconsRegular.filmStrip,
    PhosphorIconsRegular.checkCircle,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status message
        if (statusMessage != null) ...[
          Text(
            statusMessage!,
            style: const TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Steps
        Row(
          children: List.generate(_stageLabels.length, (index) {
            return Expanded(
              child: _buildStep(index),
            );
          }),
        ),

        // Connector line
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: currentStage / (_stageLabels.length - 1),
              backgroundColor: const Color(0xFF222228),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF3B82F6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int index) {
    final isCompleted = index < currentStage;
    final isCurrent = index == currentStage;
    final isPending = index > currentStage;

    Color circleColor;
    Color textColor;
    Color iconColor;

    if (isCompleted) {
      circleColor = const Color(0xFF22C55E).withOpacity(0.15);
      textColor = const Color(0xFF22C55E);
      iconColor = const Color(0xFF22C55E);
    } else if (isCurrent && isProcessing) {
      circleColor = const Color(0xFF3B82F6).withOpacity(0.15);
      textColor = const Color(0xFF3B82F6);
      iconColor = const Color(0xFF3B82F6);
    } else if (isCurrent) {
      circleColor = const Color(0xFF3B82F6).withOpacity(0.1);
      textColor = const Color(0xFF3B82F6);
      iconColor = const Color(0xFF3B82F6);
    } else {
      circleColor = const Color(0xFF1A1A1F);
      textColor = const Color(0xFF6B6B6B);
      iconColor = const Color(0xFF6B6B6B);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF22C55E).withOpacity(0.3)
                  : isCurrent
                      ? const Color(0xFF3B82F6).withOpacity(0.3)
                      : const Color(0xFF222228),
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    PhosphorIconsRegular.check,
                    size: 16,
                    color: iconColor,
                  )
                : (isCurrent && isProcessing)
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                        ),
                      )
                    : Icon(
                        _stageIcons[index],
                        size: 16,
                        color: iconColor,
                      ),
          ),
        ),
        const SizedBox(height: 6),

        // Label
        Text(
          _stageLabels[index],
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
