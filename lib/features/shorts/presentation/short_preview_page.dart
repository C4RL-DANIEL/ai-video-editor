import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Preview page for a single short video.
class ShortPreviewPage extends StatelessWidget {
  const ShortPreviewPage({
    super.key,
    required this.projectId,
    required this.shortId,
  });

  final String projectId;
  final String shortId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Short Preview', style: GoogleFonts.inter()),
        leading: IconButton(
          icon: const PhosphorIcon(PhosphorIconsLight.caretLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PhosphorIcon(
              PhosphorIconsLight.video,
              size: 64,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            Text(
              'Short $shortId',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Project: $projectId',
              style: GoogleFonts.inter(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
