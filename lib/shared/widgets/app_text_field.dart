import 'package:flutter/material.dart';

/// A dark-themed text field with subtle border and focus glow.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? error;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final String? initialValue;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    Key? key,
    this.label,
    this.hint,
    this.error,
    this.prefixIcon,
    this.suffixWidget,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.initialValue,
    this.contentPadding,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return 'AppTextField($label)';
  }
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (_isFocused && !hasError)
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              if (hasError)
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onEditingComplete: widget.onEditingComplete,
            onSubmitted: widget.onSubmitted,
            initialValue: widget.initialValue,
            maxLength: widget.maxLength,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            obscureText: _obscureText,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            enabled: widget.enabled,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            cursorColor: const Color(0xFF3B82F6),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 14,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF6B6B6B),
                        size: 18,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 0,
              ),
              suffixIcon: _buildSuffixIcon(),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 0,
              ),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: widget.enabled
                  ? const Color(0xFF141418)
                  : const Color(0xFF0D0D0F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF222228),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF222228),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF3B82F6),
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF222228),
                ),
              ),
              counterText: '',
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.error!,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // Custom suffix widget takes priority
    if (widget.suffixWidget != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: widget.suffixWidget,
      );
    }

    // Obscure text toggle
    if (widget.obscureText) {
      return GestureDetector(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF6B6B6B),
            size: 18,
          ),
        ),
      );
    }

    // Suffix icon with optional tap
    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            widget.suffixIcon,
            color: const Color(0xFF6B6B6B),
            size: 18,
          ),
        ),
      );
    }

    return null;
  }
}
