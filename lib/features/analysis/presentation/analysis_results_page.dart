import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../services/real_video_analyzer.dart';

/// Displays the results of video analysis — viral moments, clips, metadata.
class AnalysisResultsPage extends StatelessWidget {
  final VideoAnalysisResult? analysisResult;
  final String videoName;
  final String? videoPath;

  const AnalysisResultsPage({
    super.key,
    this.analysisResult,
    required this.videoName,
    this.videoPath,
  });

  @override
  Widget build(BuildContext context) {
    final result = analysisResult;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          'Analysis Results',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.caretLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: result == null
          ? _buildNoResults()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video info
                  _buildVideoInfo(result),
                  const SizedBox(height: 20),

                  // Overall score
                  _buildScoreCard(result),
                  const SizedBox(height: 20),

                  // Clips section
                  if (result.clips.isNotEmpty) ...[
                    _buildSectionTitle('Generated Short Clips'),
                    const SizedBox(height: 8),
                    ...result.clips.map((clip) => _buildClipCard(clip, result.metadata)),
                    const SizedBox(height: 20),
                  ],

                  // Viral moments section
                  if (result.viralMoments.isNotEmpty) ...[
                    _buildSectionTitle('Viral Moments'),
                    const SizedBox(height: 8),
                    ...result.viralMoments.map((moment) => _buildMomentCard(moment)),
                    const SizedBox(height: 20),
                  ],

                  // Scenes section
                  if (result.scenes.isNotEmpty) ...[
                    _buildSectionTitle('Scene Changes (${result.scenes.length})'),
                    const SizedBox(height: 8),
                    _buildScenesTimeline(result.scenes, result.metadata),
                    const SizedBox(height: 20),
                  ],

                  // Metadata
                  _buildMetadataSection(result),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsLight.warningCircle, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('No analysis results available', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Upload and analyze a video first', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildVideoInfo(VideoAnalysisResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(PhosphorIconsRegular.filmStrip, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(videoName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${_formatDuration(result.metadata.duration)} • ${result.metadata.width}x${result.metadata.height} • ${result.scenes.length} scenes',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildScoreCard(VideoAnalysisResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent.withOpacity(0.2), AppColors.accent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('Overall', result.overallScore, AppColors.accent),
          _buildScoreItem('Clips', result.clips.length, AppColors.success),
          _buildScoreItem('Scenes', result.scenes.length, AppColors.warning),
          _buildScoreItem('Moments', result.viralMoments.length, AppColors.error),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildScoreItem(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white));
  }

  Widget _buildClipCard(ShortClip clip, VideoMetadata metadata) {
    final startMin = (clip.startTime / 60).floor();
    final startSec = (clip.startTime % 60).floor();
    final endMin = (clip.endTime / 60).floor();
    final endSec = (clip.endTime % 60).floor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(PhosphorIconsRegular.scissors, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clip.label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  '${_formatDuration(clip.duration)} • ${_formatDuration(metadata.duration > 0 ? clip.startTime : 0)} → ${_formatDuration(clip.endTime)}',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${clip.score}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildMomentCard(ViralMoment moment) {
    Color scoreColor;
    if (moment.score >= 75) {
      scoreColor = AppColors.error;
    } else if (moment.score >= 55) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.accent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              moment.type == 'high_energy' ? PhosphorIconsRegular.fire : PhosphorIconsRegular.lightning,
              color: scoreColor, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(moment.label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  '${moment.type.replaceAll('_', ' ').toUpperCase()} • Score: ${moment.score}%',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildScenesTimeline(List<SceneChange> scenes, VideoMetadata metadata) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: scenes.take(8).map((scene) {
          final width = metadata.duration > 0 ? (scene.time / metadata.duration) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    _formatDuration(scene.time),
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: width.toDouble().clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scene.score > 0.7 ? AppColors.error : AppColors.accent,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text(
                    '${(scene.score * 100).round()}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildMetadataSection(VideoAnalysisResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Video Metadata'),
          const SizedBox(height: 12),
          _buildMetaRow('Duration', _formatDuration(result.metadata.duration)),
          _buildMetaRow('Resolution', '${result.metadata.width}x${result.metadata.height}'),
          _buildMetaRow('File Size', _formatFileSize(result.metadata.fileSize)),
          _buildMetaRow('Has Audio', result.hasAudio ? 'Yes' : 'No'),
          _buildMetaRow('Total Scenes', '${result.scenes.length}'),
          _buildMetaRow('Viral Moments', '${result.viralMoments.length}'),
          _buildMetaRow('Short Clips', '${result.clips.length}'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
