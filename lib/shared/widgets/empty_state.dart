import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_button.dart';

/// An empty state widget with illustration placeholder, title, description, and optional action button.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? iconSize;
  final Color? iconColor;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconSize,
    this.iconColor,
  }) : super(key: key);

  /// No projects state.
  const EmptyState.noProjects({
    Key? key,
    VoidCallback? onAction,
  })  : icon = PhosphorIcons.folderOpen,
        title = 'No projects yet',
        description = 'Create your first project to get started with AI-powered video editing.',
        actionLabel = 'Create Project',
        onAction = onAction,
        iconSize = null,
        iconColor = null,
        super(key: key);

  /// No results state.
  const EmptyState.noResults({
    Key? key,
    String? customTitle,
    String? customDescription,
  })  : icon = PhosphorIcons.magnifyingGlass,
        title = customTitle ?? 'No results found',
        description = customDescription ?? 'Try adjusting your search or filters.',
        actionLabel = null,
        onAction = null,
        iconSize = null,
        iconColor = null,
        super(key: key);

  /// No media state.
  const EmptyState.noMedia({
    Key? key,
    VoidCallback? onAction,
  })  : icon = PhosphorIcons.filmStrip,
        title = 'No media uploaded',
        description = 'Upload videos to start editing with AI assistance.',
        actionLabel = 'Upload Video',
        onAction = onAction,
        iconSize = null,
        iconColor = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF222228),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize ?? 36,
                  color: iconColor ?? const Color(0xFF3B82F6),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  color: Color(0xFFA0A0A0),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton.primary(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
