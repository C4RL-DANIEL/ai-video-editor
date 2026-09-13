import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// ── Theme Colors ────────────────────────────────────────────────────
const _bgColor = Color(0xFF0D0D0F);
const _surfaceColor = Color(0xFF141418);
const _cardColor = Color(0xFF1A1A1F);
const _borderColor = Color(0xFF222228);
const _accentBlue = Color(0xFF3B82F6);
const _purple = Color(0xFF8B5CF6);
const _successGreen = Color(0xFF22C55E);
const _warningAmber = Color(0xFFF59E0B);
const _errorRed = Color(0xFFEF4444);
const _textPrimary = Color(0xFFF5F5F7);
const _textSecondary = Color(0xFF9CA3AF);
const _textTertiary = Color(0xFF6B7280);

// ── Score Color Helper ──────────────────────────────────────────────
Color _scoreColor(double score) {
  if (score < 40) return _errorRed;
  if (score <= 70) return _warningAmber;
  return _successGreen;
}

String _formatDuration(double seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toInt().toString().padLeft(2, '0');
  return '$m:$s';
}

// ── Models ──────────────────────────────────────────────────────────
class EditingDecision {
  const EditingDecision({
    required this.label,
    required this.timestamp,
    required this.description,
    this.confidence,
  });

  final String label;
  final String timestamp;
  final String description;
  final double? confidence;
}

class ViralScoreBreakdown {
  const ViralScoreBreakdown({
    required this.overall,
    required this.hook,
    required this.emotion,
    required this.humor,
    required this.pacing,
    required this.visualImpact,
    required this.shareability,
  });

  final double overall;
  final double hook;
  final double emotion;
  final double humor;
  final double pacing;
  final double visualImpact;
  final double shareability;

  List<MapEntry<String, double>> get entries => [
        MapEntry('Hook', hook),
        MapEntry('Emotion', emotion),
        MapEntry('Humor', humor),
        MapEntry('Pacing', pacing),
        MapEntry('Visual', visualImpact),
        MapEntry('Shareability', shareability),
      ];
}

class ShortVersion {
  const ShortVersion({
    required this.version,
    required this.label,
    required this.createdAt,
    required this.viralScore,
    this.isActive = false,
  });

  final int version;
  final String label;
  final String createdAt;
  final double viralScore;
  final bool isActive;
}

class HookVariation {
  const HookVariation({
    required this.id,
    required this.text,
    required this.type,
    required this.score,
  });

  final String id;
  final String text;
  final String type;
  final double score;
}

class ShortPreviewData {
  const ShortPreviewData({
    required this.id,
    required this.title,
    required this.shortNumber,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.viralScore,
    required this.scoreBreakdown,
    required this.hookText,
    required this.commentary,
    required this.editingDecisions,
    required this.captionText,
    this.versions = const [],
    this.hookVariations = const [],
  });

  final String id;
  final String title;
  final int shortNumber;
  final String videoUrl;
  final String thumbnailUrl;
  final double duration;
  final double viralScore;
  final ViralScoreBreakdown scoreBreakdown;
  final String hookText;
  final String commentary;
  final List<EditingDecision> editingDecisions;
  final String captionText;
  final List<ShortVersion> versions;
  final List<HookVariation> hookVariations;
}

// ── State ───────────────────────────────────────────────────────────
class ShortPreviewState {
  const ShortPreviewState({
    this.data,
    this.isPlaying = false,
    this.currentPosition = 0.0,
    this.selectedVersion,
    this.showCaptions = true,
    this.isLoading = false,
  });

  final ShortPreviewData? data;
  final bool isPlaying;
  final double currentPosition;
  final int? selectedVersion;
  final bool showCaptions;
  final bool isLoading;

  ShortPreviewState copyWith({
    ShortPreviewData? data,
    bool? isPlaying,
    double? currentPosition,
    int? selectedVersion,
    bool? showCaptions,
    bool? isLoading,
  }) {
    return ShortPreviewState(
      data: data ?? this.data,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      selectedVersion: selectedVersion ?? this.selectedVersion,
      showCaptions: showCaptions ?? this.showCaptions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Provider ────────────────────────────────────────────────────────
final shortPreviewProvider =
    StateNotifierProvider.family<ShortPreviewNotifier, ShortPreviewState, String>(
  (ref, shortId) => ShortPreviewNotifier(shortId),
);

class ShortPreviewNotifier extends StateNotifier<ShortPreviewState> {
  ShortPreviewNotifier(this._shortId) : super(const ShortPreviewState()) {
    _loadData();
  }

  final String _shortId;

  void _loadData() {
    state = state.copyWith(isLoading: true);
    Future.delayed(const Duration(milliseconds: 600), () {
      state = state.copyWith(
        isLoading: false,
        data: _mockPreviewData,
        selectedVersion: _mockPreviewData.versions.length,
      );
    });
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void updatePosition(double position) {
    state = state.copyWith(currentPosition: position);
  }

  void selectVersion(int version) {
    state = state.copyWith(selectedVersion: version);
  }

  void toggleCaptions() {
    state = state.copyWith(showCaptions: !state.showCaptions);
  }
}

// ── Mock Data ───────────────────────────────────────────────────────
final _mockPreviewData = ShortPreviewData(
  id: 'short_1',
  title: 'Epic Reaction Moment',
  shortNumber: 1,
  videoUrl: '',
  thumbnailUrl: '',
  duration: 32,
  viralScore: 92,
  scoreBreakdown: const ViralScoreBreakdown(
    overall: 92,
    hook: 88,
    emotion: 95,
    humor: 72,
    pacing: 90,
    visualImpact: 85,
    shareability: 91,
  ),
  hookText: "Wait until you see his reaction when the door opens…",
  commentary:
      "This clip captures a genuine, high-emotion moment with perfect comedic timing. The subject's reaction is immediately relatable and shareable, making it ideal for short-form platforms.",
  captionText: "When you finally see what's behind the door 😱",
  editingDecisions: [
    const EditingDecision(
      label: 'Punch-in Zoom',
      timestamp: '02:14',
      description: 'Detected high-emotion reaction at 02:14. Added 1.25x punch-in to emphasize facial expression.',
      confidence: 0.92,
    ),
    const EditingDecision(
      label: 'Keyword Highlight',
      timestamp: '02:18',
      description: 'Highlighted keyword "no way" with animated text overlay.',
      confidence: 0.88,
    ),
    const EditingDecision(
      label: 'Impact SFX',
      timestamp: '02:20',
      description: 'Added impact SFX at the peak reaction moment for comedic emphasis.',
      confidence: 0.95,
    ),
    const EditingDecision(
      label: 'Background Music Duck',
      timestamp: '02:12',
      description: 'Ducked background music to foreground the dialogue and reaction.',
      confidence: 0.90,
    ),
    const EditingDecision(
      label: 'Speed Ramp',
      timestamp: '02:22',
      description: 'Applied 1.5x speed ramp on aftermath for energetic pacing.',
      confidence: 0.85,
    ),
  ],
  versions: [
    const ShortVersion(
      version: 1,
      label: 'Initial draft',
      createdAt: '2 hours ago',
      viralScore: 78,
    ),
    const ShortVersion(
      version: 2,
      label: 'With punch-ins',
      createdAt: '1 hour ago',
      viralScore: 85,
      isActive: false,
    ),
    const ShortVersion(
      version: 3,
      label: 'Final v3',
      createdAt: '30 min ago',
      viralScore: 92,
      isActive: true,
    ),
  ],
  hookVariations: [
    const HookVariation(
      id: 'h1',
      text: "Wait until you see his reaction when the door opens…",
      type: 'Curiosity',
      score: 92,
    ),
    const HookVariation(
      id: 'h2',
      text: "This reaction broke the internet for a reason",
      type: 'Social Proof',
      score: 87,
    ),
    const HookVariation(
      id: 'h3',
      text: "I can't believe what just happened 😳",
      type: 'Shock',
      score: 84,
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════
// SHORT PREVIEW PAGE
// ══════════════════════════════════════════════════════════════════════
class ShortPreviewPage extends ConsumerWidget {
  const ShortPreviewPage({
    super.key,
    required this.shortId,
    this.projectId,
  });

  final String shortId;
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shortPreviewProvider(shortId));
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft, color: _textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: state.data != null
            ? Text(
                'Short #${state.data!.shortNumber}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              )
            : null,
        actions: [
          // Caption toggle
          IconButton(
            icon: Icon(
              state.showCaptions
                  ? PhosphorIconsRegular.captions
                  : PhosphorIconsRegular.captionsSlash,
              color: state.showCaptions ? _accentBlue : _textTertiary,
            ),
            onPressed: ref.read(shortPreviewProvider(shortId).notifier).toggleCaptions,
            tooltip: 'Toggle Captions',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? _buildLoading()
          : state.data == null
              ? _buildError()
              : isDesktop
                  ? _buildDesktopLayout(context, ref, state)
                  : _buildMobileLayout(context, ref, state),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: _accentBlue),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsRegular.warningCircle, size: 48, color: _errorRed),
          const SizedBox(height: 16),
          Text(
            'Could not load short preview',
            style: GoogleFonts.inter(fontSize: 16, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Desktop: side-by-side layout ────────────────────────────────
  Widget _buildDesktopLayout(
      BuildContext context, WidgetRef ref, ShortPreviewState state) {
    final data = state.data!;
    return Row(
      children: [
        // Left: Phone preview
        Expanded(
          flex: 5,
          child: Center(
            child: _PhonePreviewFrame(
              data: data,
              isPlaying: state.isPlaying,
              showCaptions: state.showCaptions,
              currentPosition: state.currentPosition,
              duration: data.duration,
              onPlayPause: ref.read(shortPreviewProvider(shortId).notifier).togglePlayPause,
              onSeek: ref.read(shortPreviewProvider(shortId).notifier).updatePosition,
            ),
          ),
        ),

        // Right: Details panel
        Expanded(
          flex: 6,
          child: _DetailsPanel(data: data, shortId: shortId),
        ),
      ],
    );
  }

  // ── Mobile: stacked layout ──────────────────────────────────────
  Widget _buildMobileLayout(
      BuildContext context, WidgetRef ref, ShortPreviewState state) {
    final data = state.data!;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _PhonePreviewFrame(
            data: data,
            isPlaying: state.isPlaying,
            showCaptions: state.showCaptions,
            currentPosition: state.currentPosition,
            duration: data.duration,
            onPlayPause: ref.read(shortPreviewProvider(shortId).notifier).togglePlayPause,
            onSeek: ref.read(shortPreviewProvider(shortId).notifier).updatePosition,
          ),
          const SizedBox(height: 24),
          _DetailsPanel(data: data, shortId: shortId),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// PHONE PREVIEW FRAME (9:16 mockup)
// ══════════════════════════════════════════════════════════════════════
class _PhonePreviewFrame extends StatelessWidget {
  const _PhonePreviewFrame({
    required this.data,
    required this.isPlaying,
    required this.showCaptions,
    required this.currentPosition,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
  });

  final ShortPreviewData data;
  final bool isPlaying;
  final bool showCaptions;
  final double currentPosition;
  final double duration;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Phone frame ───────────────────────────────────────
          Container(
            width: 280,
            height: 500, // ~9:16 ratio
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: _borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: Stack(
                children: [
                  // ── Video area ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _surfaceColor,
                          _cardColor,
                          _surfaceColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Play state icon
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying
                                  ? PhosphorIconsRegular.pause
                                  : PhosphorIconsRegular.play,
                              size: 32,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _formatDuration(currentPosition),
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withAlpha(150),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Tap to play/pause ──────────────────────────
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: onPlayPause,
                    ),
                  ),

                  // ── Caption overlay ────────────────────────────
                  if (showCaptions)
                    Positioned(
                      bottom: 80,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(170),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data.captionText,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // ── Duration badge ─────────────────────────────
                  Positioned(
                    top: 16,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatDuration(duration),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // ── Notch ──────────────────────────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Timeline Scrubber ──────────────────────────────────
          _TimelineScrubber(
            position: currentPosition,
            duration: duration,
            onSeek: onSeek,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }
}

// ══════════════════════════════════════════════════════════════════════
// TIMELINE SCRUBBER
// ══════════════════════════════════════════════════════════════════════
class _TimelineScrubber extends StatelessWidget {
  const _TimelineScrubber({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final double position;
  final double duration;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final progress = duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: _accentBlue,
            inactiveTrackColor: _borderColor,
            thumbColor: _accentBlue,
            overlayColor: _accentBlue.withAlpha(30),
          ),
          child: Slider(
            value: progress,
            onChanged: (v) => onSeek(v * duration),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _textTertiary,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                _formatDuration(duration),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _textTertiary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// DETAILS PANEL
// ══════════════════════════════════════════════════════════════════════
class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.data, required this.shortId});

  final ShortPreviewData data;
  final String shortId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──────────────────────────────────────────────
          Text(
            'Short #${data.shortNumber}',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // ── Viral Score ────────────────────────────────────────
          _ViralScoreSection(data: data),
          const SizedBox(height: 28),

          // ── Hook Text ──────────────────────────────────────────
          _buildSectionTitle('Hook'),
          const SizedBox(height: 8),
          _buildInfoCard(
            child: Text(
              '"${data.hookText}"',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: _textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Commentary ─────────────────────────────────────────
          _buildSectionTitle('AI Commentary'),
          const SizedBox(height: 8),
          _buildInfoCard(
            child: Text(
              data.commentary,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _textSecondary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Editing Decisions ──────────────────────────────────
          _buildSectionTitle('AI Editing Decisions'),
          const SizedBox(height: 10),
          ...data.editingDecisions.map(
            (decision) => _EditingDecisionCard(decision: decision),
          ),
          const SizedBox(height: 24),

          // ── Action Buttons ─────────────────────────────────────
          _buildSectionTitle('Actions'),
          const SizedBox(height: 12),
          _buildActionButtons(context),
          const SizedBox(height: 28),

          // ── Version History ────────────────────────────────────
          if (data.versions.length > 1) ...[
            _buildSectionTitle('Version History'),
            const SizedBox(height: 10),
            ...data.versions.map(
              (v) => _VersionCard(
                version: v,
                onSelect: () {
                  // TODO: Select version
                },
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── Hook A/B Testing ───────────────────────────────────
          if (data.hookVariations.isNotEmpty) ...[
            _buildSectionTitle('Hook A/B Testing'),
            const SizedBox(height: 4),
            Text(
              'Compare hook variations side by side',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            _HookABSection(hooks: data.hookVariations),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: child,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionChip(
          label: 'Regenerate',
          icon: PhosphorIconsRegular.pencilSimple,
          color: _accentBlue,
          onTap: () {},
        ),
        _ActionChip(
          label: 'Edit',
          icon: PhosphorIconsRegular.faders,
          color: _purple,
          onTap: () {},
        ),
        _ActionChip(
          label: 'Export',
          icon: PhosphorIconsRegular.export,
          color: _warningAmber,
          onTap: () {},
        ),
        _ActionChip(
          label: 'Approve',
          icon: PhosphorIconsRegular.checkCircle,
          color: _successGreen,
          onTap: () {},
        ),
        _ActionChip(
          label: 'Reject',
          icon: PhosphorIconsRegular.xCircle,
          color: _errorRed,
          onTap: () {},
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// VIRAL SCORE SECTION (radar-style breakdown)
// ══════════════════════════════════════════════════════════════════════
class _ViralScoreSection extends StatelessWidget {
  const _ViralScoreSection({required this.data});

  final ShortPreviewData data;

  @override
  Widget build(BuildContext context) {
    final breakdown = data.scoreBreakdown;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall score
          Row(
            children: [
              // Big score circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _scoreColor(breakdown.overall),
                      _scoreColor(breakdown.overall).withAlpha(150),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    breakdown.overall.toInt().toString(),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viral Score',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      breakdown.overall >= 70
                          ? 'High viral potential'
                          : breakdown.overall >= 40
                              ? 'Moderate potential'
                              : 'Low potential',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _scoreColor(breakdown.overall),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Breakdown bars
          ...breakdown.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ScoreBreakdownBar(
                label: entry.key,
                score: entry.value,
              ),
            ),
          ),

          // Mini radar chart
          const SizedBox(height: 8),
          Center(
            child: CustomPaint(
              size: const Size(180, 180),
              painter: _RadarChartPainter(
                values: breakdown.entries.map((e) => e.value).toList(),
                labels: breakdown.entries.map((e) => e.key).toList(),
                color: _accentBlue,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms);
  }
}

// ══════════════════════════════════════════════════════════════════════
// SCORE BREAKDOWN BAR
// ══════════════════════════════════════════════════════════════════════
class _ScoreBreakdownBar extends StatelessWidget {
  const _ScoreBreakdownBar({required this.label, required this.score});

  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: _borderColor,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 32,
          child: Text(
            score.toInt().toString(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// RADAR CHART PAINTER
// ══════════════════════════════════════════════════════════════════════
class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.values,
    required this.labels,
    required this.color,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final sides = values.length;

    if (sides < 3) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid
    for (int level = 1; level <= 4; level++) {
      final r = radius * level / 4;
      final path = Path();
      for (int i = 0; i <= sides; i++) {
        final angle = (2 * math.pi * i / sides) - math.pi / 2;
        final point = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      paint.color = _borderColor;
      canvas.drawPath(path, paint);
    }

    // Draw axes
    for (int i = 0; i < sides; i++) {
      final angle = (2 * math.pi * i / sides) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      paint.color = _borderColor;
      canvas.drawLine(center, point, paint);
    }

    // Draw data polygon
    final dataPath = Path();
    for (int i = 0; i <= sides; i++) {
      final idx = i % sides;
      final angle = (2 * math.pi * idx / sides) - math.pi / 2;
      final r = radius * (values[idx] / 100);
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    // Fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withAlpha(40);
    canvas.drawPath(dataPath, fillPaint);

    // Stroke
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
    canvas.drawPath(dataPath, paint);

    // Draw dots
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    for (int i = 0; i < sides; i++) {
      final angle = (2 * math.pi * i / sides) - math.pi / 2;
      final r = radius * (values[i] / 100);
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      canvas.drawCircle(point, 4, dotPaint);
    }

    // Draw labels
    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    for (int i = 0; i < sides; i++) {
      final angle = (2 * math.pi * i / sides) - math.pi / 2;
      final labelRadius = radius + 14;
      final point = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );
      labelPainter.text = TextSpan(
        text: labels[i],
        style: GoogleFonts.inter(
          fontSize: 10,
          color: _textTertiary,
        ),
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          point.dx - labelPainter.width / 2,
          point.dy - labelPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

// ══════════════════════════════════════════════════════════════════════
// EDITING DECISION CARD
// ══════════════════════════════════════════════════════════════════════
class _EditingDecisionCard extends StatelessWidget {
  const _EditingDecisionCard({required this.decision});

  final EditingDecision decision;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Timestamp badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _purple.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  decision.timestamp,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _purple,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                decision.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              // Confidence
              if (decision.confidence != null) ...[
                Icon(
                  PhosphorIconsRegular.brain,
                  size: 14,
                  color: _textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${(decision.confidence! * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _scoreColor(decision.confidence! * 100),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // AI Decision explanation
          Text(
            decision.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03, end: 0, duration: 300.ms);
  }
}

// ══════════════════════════════════════════════════════════════════════
// VERSION CARD
// ══════════════════════════════════════════════════════════════════════
class _VersionCard extends StatelessWidget {
  const _VersionCard({required this.version, required this.onSelect});

  final ShortVersion version;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: version.isActive
            ? _accentBlue.withAlpha(15)
            : _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: version.isActive ? _accentBlue.withAlpha(50) : _borderColor,
        ),
      ),
      child: Row(
        children: [
          // Version number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: version.isActive
                  ? _accentBlue.withAlpha(30)
                  : _surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'v${version.version}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: version.isActive ? _accentBlue : _textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  version.createdAt,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Score
          _MiniScoreBadge(score: version.viralScore),

          const SizedBox(width: 10),

          // Active / Select
          if (version.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _accentBlue.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Active',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _accentBlue,
                ),
              ),
            )
          else
            TextButton(
              onPressed: onSelect,
              child: Text(
                'Select',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniScoreBadge extends StatelessWidget {
  const _MiniScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _scoreColor(score).withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        score.toInt().toString(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _scoreColor(score),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// HOOK A/B TESTING SECTION
// ══════════════════════════════════════════════════════════════════════
class _HookABSection extends StatelessWidget {
  const _HookABSection({required this.hooks});

  final List<HookVariation> hooks;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hooks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final hook = hooks[index];
          return _HookVariationCard(hook: hook, index: index);
        },
      ),
    );
  }
}

class _HookVariationCard extends StatelessWidget {
  const _HookVariationCard({required this.hook, required this.index});

  final HookVariation hook;
  final int index;

  @override
  Widget build(BuildContext context) {
    final letters = ['A', 'B', 'C', 'D', 'E'];
    final label = index < letters.length ? letters[index] : '${index + 1}';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: index == 0 ? _accentBlue.withAlpha(60) : _borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: index == 0
                      ? _accentBlue.withAlpha(30)
                      : _surfaceColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: index == 0 ? _accentBlue : _textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hook.type,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _textTertiary,
                  ),
                ),
              ),
              _MiniScoreBadge(score: hook.score),
            ],
          ),
          const SizedBox(height: 10),

          // Hook text
          Expanded(
            child: Text(
              hook.text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _textPrimary,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Score bar
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: hook.score / 100,
              backgroundColor: _borderColor,
              valueColor: AlwaysStoppedAnimation(_scoreColor(hook.score)),
              minHeight: 3,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
        .slideX(begin: 0.05, end: 0, duration: 400.ms, delay: (index * 100).ms);
  }
}

// ══════════════════════════════════════════════════════════════════════
// ACTION CHIP
// ══════════════════════════════════════════════════════════════════════
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
