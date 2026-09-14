import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';

const _uuid = Uuid();

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Caption segment data model.
class CaptionSegment {
  final String id;
  final String text;
  final double startTime; // seconds
  final double endTime; // seconds
  final CaptionPosition position;
  final bool isBold;
  final bool isItalic;
  final Color color;

  const CaptionSegment({
    required this.id,
    required this.text,
    required this.startTime,
    required this.endTime,
    this.position = CaptionPosition.bottom,
    this.isBold = true,
    this.isItalic = false,
    this.color = Colors.white,
  });

  CaptionSegment copyWith({
    String? text,
    double? startTime,
    double? endTime,
    CaptionPosition? position,
    bool? isBold,
    bool? isItalic,
    Color? color,
  }) {
    return CaptionSegment(
      id: id,
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      position: position ?? this.position,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      color: color ?? this.color,
    );
  }

  String get timeRange => '${_fmt(startTime)} – ${_fmt(endTime)}';

  static String _fmt(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toStringAsFixed(1).padLeft(4, '0');
    return '$m:$s';
  }
}

enum CaptionPosition { top, center, bottom }

/// Visual effect preset.
enum VideoEffect {
  cinematic,
  vintage,
  highContrast,
  coolTone,
  warmTone,
  zoomIn,
  zoomOut,
  speedUp,
  slowMotion,
  fadeIn,
  fadeOut,
}

extension VideoEffectX on VideoEffect {
  String get label {
    switch (this) {
      case VideoEffect.cinematic:
        return 'Cinematic';
      case VideoEffect.vintage:
        return 'Vintage';
      case VideoEffect.highContrast:
        return 'High Contrast';
      case VideoEffect.coolTone:
        return 'Cool Tone';
      case VideoEffect.warmTone:
        return 'Warm Tone';
      case VideoEffect.zoomIn:
        return 'Zoom In';
      case VideoEffect.zoomOut:
        return 'Zoom Out';
      case VideoEffect.speedUp:
        return 'Speed Up';
      case VideoEffect.slowMotion:
        return 'Slow Motion';
      case VideoEffect.fadeIn:
        return 'Fade In';
      case VideoEffect.fadeOut:
        return 'Fade Out';
    }
  }

  String get icon {
    switch (this) {
      case VideoEffect.cinematic:
        return '🎬';
      case VideoEffect.vintage:
        return '🌅';
      case VideoEffect.highContrast:
        return '⚡';
      case VideoEffect.coolTone:
        return '🔵';
      case VideoEffect.warmTone:
        return '🟠';
      case VideoEffect.zoomIn:
        return '📐';
      case VideoEffect.zoomOut:
        return '📐';
      case VideoEffect.speedUp:
        return '⏩';
      case VideoEffect.slowMotion:
        return '🐌';
      case VideoEffect.fadeIn:
        return '✨';
      case VideoEffect.fadeOut:
        return '✨';
    }
  }

  String get description {
    switch (this) {
      case VideoEffect.cinematic:
        return 'Warm color grade + letterbox bars';
      case VideoEffect.vintage:
        return 'Sepia tone + vignette edges';
      case VideoEffect.highContrast:
        return 'Boosted contrast for bold look';
      case VideoEffect.coolTone:
        return 'Blue tint for moody feel';
      case VideoEffect.warmTone:
        return 'Orange tint for cozy feel';
      case VideoEffect.zoomIn:
        return 'Ken Burns zoom-in effect';
      case VideoEffect.zoomOut:
        return 'Ken Burns zoom-out effect';
      case VideoEffect.speedUp:
        return 'Playback at 1.5× speed';
      case VideoEffect.slowMotion:
        return 'Playback at 0.5× slow-mo';
      case VideoEffect.fadeIn:
        return 'Fade from black at start';
      case VideoEffect.fadeOut:
        return 'Fade to black at end';
    }
  }
}

/// Sound effect data.
class SfxItem {
  final String id;
  final String name;
  final String icon;
  final double durationSeconds;
  final List<double> waveform;

  const SfxItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.durationSeconds,
    required this.waveform,
  });
}

/// Placed SFX on the timeline.
class PlacedSfx {
  final String id;
  final SfxItem sfx;
  final double positionSeconds;

  const PlacedSfx({
    required this.id,
    required this.sfx,
    required this.positionSeconds,
  });
}

/// Transition type.
enum TransitionType {
  fadeToBlack,
  crossDissolve,
  slideLeft,
  slideRight,
  zoom,
}

extension TransitionTypeX on TransitionType {
  String get label {
    switch (this) {
      case TransitionType.fadeToBlack:
        return 'Fade to Black';
      case TransitionType.crossDissolve:
        return 'Cross Dissolve';
      case TransitionType.slideLeft:
        return 'Slide Left';
      case TransitionType.slideRight:
        return 'Slide Right';
      case TransitionType.zoom:
        return 'Zoom';
    }
  }

  IconData get phosphorIcon {
    switch (this) {
      case TransitionType.fadeToBlack:
        return PhosphorIconsRegular.moon;
      case TransitionType.crossDissolve:
        return PhosphorIconsRegular.arrowsLeftRight;
      case TransitionType.slideLeft:
        return PhosphorIconsRegular.arrowLeft;
      case TransitionType.slideRight:
        return PhosphorIconsRegular.arrowRight;
      case TransitionType.zoom:
        return PhosphorIconsRegular.magnifyingGlassPlus;
    }
  }
}

/// Export quality.
enum ExportQuality { low, medium, high, original }

extension ExportQualityX on ExportQuality {
  String get label {
    switch (this) {
      case ExportQuality.low:
        return 'Low (480p)';
      case ExportQuality.medium:
        return 'Medium (720p)';
      case ExportQuality.high:
        return 'High (1080p)';
      case ExportQuality.original:
        return 'Original';
    }
  }

  String get estimatedSize {
    switch (this) {
      case ExportQuality.low:
        return '~15 MB';
      case ExportQuality.medium:
        return '~45 MB';
      case ExportQuality.high:
        return '~120 MB';
      case ExportQuality.original:
        return '~250 MB';
    }
  }
}

/// Export format.
enum ExportFormat { mp4, webm }

extension ExportFormatX on ExportFormat {
  String get label {
    switch (this) {
      case ExportFormat.mp4:
        return 'MP4';
      case ExportFormat.webm:
        return 'WebM';
    }
  }

  String get description {
    switch (this) {
      case ExportFormat.mp4:
        return 'H.264 • Best compatibility';
      case ExportFormat.webm:
        return 'VP9 • Smaller file size';
    }
  }
}

/// Resolution option.
enum ExportResolution { r480, r720, r1080, r1440, r2160 }

extension ExportResolutionX on ExportResolution {
  String get label {
    switch (this) {
      case ExportResolution.r480:
        return '480p';
      case ExportResolution.r720:
        return '720p';
      case ExportResolution.r1080:
        return '1080p';
      case ExportResolution.r1440:
        return '1440p (2K)';
      case ExportResolution.r2160:
        return '2160p (4K)';
    }
  }

  String get dimensions {
    switch (this) {
      case ExportResolution.r480:
        return '854×480';
      case ExportResolution.r720:
        return '1280×720';
      case ExportResolution.r1080:
        return '1920×1080';
      case ExportResolution.r1440:
        return '2560×1440';
      case ExportResolution.r2160:
        return '3840×2160';
    }
  }
}

/// The overall state that the panel manages, passed back to the parent.
class VideoEffectsState {
  final List<CaptionSegment> captions;
  final Set<VideoEffect> appliedEffects;
  final List<PlacedSfx> placedSfx;
  final TransitionType transitionType;
  final double transitionDuration;
  final ExportQuality exportQuality;
  final ExportResolution exportResolution;
  final ExportFormat exportFormat;

  const VideoEffectsState({
    this.captions = const [],
    this.appliedEffects = const {},
    this.placedSfx = const [],
    this.transitionType = TransitionType.crossDissolve,
    this.transitionDuration = 0.5,
    this.exportQuality = ExportQuality.high,
    this.exportResolution = ExportResolution.r1080,
    this.exportFormat = ExportFormat.mp4,
  });

  VideoEffectsState copyWith({
    List<CaptionSegment>? captions,
    Set<VideoEffect>? appliedEffects,
    List<PlacedSfx>? placedSfx,
    TransitionType? transitionType,
    double? transitionDuration,
    ExportQuality? exportQuality,
    ExportResolution? exportResolution,
    ExportFormat? exportFormat,
  }) {
    return VideoEffectsState(
      captions: captions ?? this.captions,
      appliedEffects: appliedEffects ?? this.appliedEffects,
      placedSfx: placedSfx ?? this.placedSfx,
      transitionType: transitionType ?? this.transitionType,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      exportQuality: exportQuality ?? this.exportQuality,
      exportResolution: exportResolution ?? this.exportResolution,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }

  int get totalAppliedCount =>
      captions.length +
      appliedEffects.length +
      placedSfx.length +
      1; // +1 for transition
}

// ═══════════════════════════════════════════════════════════════════════════════
// AVAILABLE SFX LIBRARY
// ═══════════════════════════════════════════════════════════════════════════════

final List<SfxItem> sfxLibrary = [
  SfxItem(
    id: 'impact_boom',
    name: 'Impact Boom',
    icon: '💥',
    durationSeconds: 1.2,
    waveform: _generateWaveform(24, 0.8),
  ),
  SfxItem(
    id: 'whoosh',
    name: 'Whoosh',
    icon: '💨',
    durationSeconds: 0.8,
    waveform: _generateWaveform(16, 0.6),
  ),
  SfxItem(
    id: 'ding',
    name: 'Ding',
    icon: '🔔',
    durationSeconds: 0.5,
    waveform: _generateWaveform(10, 0.9),
  ),
  SfxItem(
    id: 'crowd_cheer',
    name: 'Crowd Cheer',
    icon: '👏',
    durationSeconds: 2.5,
    waveform: _generateWaveform(50, 0.7),
  ),
  SfxItem(
    id: 'transition_sound',
    name: 'Transition Sound',
    icon: '🎵',
    durationSeconds: 1.0,
    waveform: _generateWaveform(20, 0.5),
  ),
];

List<double> _generateWaveform(int count, double maxAmp) {
  return List<double>.generate(count, (i) {
    final base = (i / count) * maxAmp;
    final noise = (i % 3 == 0 ? 0.2 : -0.1) * (i / count);
    return (base + noise).clamp(0.05, 1.0);
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN PANEL WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

/// A complete video effects panel that can be shown as a bottom sheet
/// or embedded directly.
///
/// The [onEffectsChanged] callback fires whenever any setting changes.
class VideoEffectsPanel extends StatefulWidget {
  final VideoEffectsState? initialState;
  final ValueChanged<VideoEffectsState>? onEffectsChanged;
  final VoidCallback? onClose;

  const VideoEffectsPanel({
    super.key,
    this.initialState,
    this.onEffectsChanged,
    this.onClose,
  });

  /// Shows the panel as a modal bottom sheet. Returns the final state.
  static Future<VideoEffectsState?> show(
    BuildContext context, {
    VideoEffectsState? initialState,
  }) {
    return showModalBottomSheet<VideoEffectsState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VideoEffectsSheetWrapper(initialState: initialState),
    );
  }

  @override
  State<VideoEffectsPanel> createState() => _VideoEffectsPanelState();
}

// ─── Bottom Sheet Wrapper ──────────────────────────────────────────────────

class _VideoEffectsSheetWrapper extends StatefulWidget {
  final VideoEffectsState? initialState;
  const _VideoEffectsSheetWrapper({this.initialState});

  @override
  State<_VideoEffectsSheetWrapper> createState() =>
      _VideoEffectsSheetWrapperState();
}

class _VideoEffectsSheetWrapperState extends State<_VideoEffectsSheetWrapper> {
  late VideoEffectsState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState ?? const VideoEffectsState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return VideoEffectsPanel(
          initialState: _state,
          onClose: () => Navigator.of(context).pop(_state),
          onEffectsChanged: (s) => setState(() => _state = s),
        );
      },
    );
  }
}

// ─── Panel State ───────────────────────────────────────────────────────────

class _VideoEffectsPanelState extends State<VideoEffectsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoEffectsState _state;

  // Animation controllers for live previews
  late AnimationController _waveformController;
  late AnimationController _transitionPreviewController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _state = widget.initialState ?? const VideoEffectsState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _transitionPreviewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant VideoEffectsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialState != oldWidget.initialState &&
        widget.initialState != null) {
      _state = widget.initialState!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _waveformController.dispose();
    _transitionPreviewController.dispose();
    super.dispose();
  }

  void _update(VideoEffectsState s) {
    setState(() => _state = s);
    widget.onEffectsChanged?.call(s);
  }

  // ── Caption helpers ──

  void _addCaption() {
    final list = List<CaptionSegment>.from(_state.captions);
    final lastEnd = list.isNotEmpty ? list.last.endTime : 0.0;
    list.add(CaptionSegment(
      id: _uuid.v4(),
      text: 'New caption',
      startTime: lastEnd,
      endTime: lastEnd + 3.0,
    ));
    _update(_state.copyWith(captions: list));
  }

  void _removeCaption(String id) {
    _update(_state.copyWith(
      captions: _state.captions.where((c) => c.id != id).toList(),
    ));
  }

  void _editCaption(String id,
      {String? text,
      CaptionPosition? position,
      bool? isBold,
      bool? isItalic,
      Color? color}) {
    _update(_state.copyWith(
      captions: _state.captions.map((c) {
        if (c.id == id) {
          return c.copyWith(
            text: text,
            position: position,
            isBold: isBold,
            isItalic: isItalic,
            color: color,
          );
        }
        return c;
      }).toList(),
    ));
  }

  // ── Effect helpers ──

  void _toggleEffect(VideoEffect e) {
    final effects = Set<VideoEffect>.from(_state.appliedEffects);
    effects.contains(e) ? effects.remove(e) : effects.add(e);
    _update(_state.copyWith(appliedEffects: effects));
  }

  // ── SFX helpers ──

  void _addSfx(SfxItem sfx, double position) {
    final list = List<PlacedSfx>.from(_state.placedSfx);
    list.add(PlacedSfx(id: _uuid.v4(), sfx: sfx, positionSeconds: position));
    _update(_state.copyWith(placedSfx: list));
  }

  void _removeSfx(String id) {
    _update(_state.copyWith(
      placedSfx: _state.placedSfx.where((s) => s.id != id).toList(),
    ));
  }

  // ── Summary ──

  String _buildSummary() {
    final parts = <String>[];
    if (_state.captions.isNotEmpty) parts.add('${_state.captions.length} caption(s)');
    if (_state.appliedEffects.isNotEmpty) parts.add('${_state.appliedEffects.length} effect(s)');
    if (_state.placedSfx.isNotEmpty) parts.add('${_state.placedSfx.length} SFX');
    parts.add('${_state.transitionType.label} transition');
    return parts.join(' • ');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
          _buildSummaryBar(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.borderStrong,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.gradientCreative,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(PhosphorIconsRegular.sparkle, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Video Effects', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Captions, effects, SFX & more', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(PhosphorIconsRegular.x, size: 18, color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: const [
          Tab(text: 'Captions', icon: Icon(PhosphorIconsRegular.subtitles, size: 14)),
          Tab(text: 'Effects',  icon: Icon(PhosphorIconsRegular.filmStrip, size: 14)),
          Tab(text: 'SFX',      icon: Icon(PhosphorIconsRegular.speakerHigh, size: 14)),
          Tab(text: 'Transitions', icon: Icon(PhosphorIconsRegular.arrowsLeftRight, size: 14)),
          Tab(text: 'Export',   icon: Icon(PhosphorIconsRegular.export, size: 14)),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        CaptionsTab(
          captions: _state.captions,
          onAdd: _addCaption,
          onRemove: _removeCaption,
          onEdit: _editCaption,
        ),
        EffectsTab(
          appliedEffects: _state.appliedEffects,
          onToggle: _toggleEffect,
        ),
        SfxTab(
          placedSfx: _state.placedSfx,
          onAdd: _addSfx,
          onRemove: _removeSfx,
          currentTime: 0,
          totalDuration: 30,
          waveformController: _waveformController,
        ),
        TransitionsTab(
          selectedType: _state.transitionType,
          duration: _state.transitionDuration,
          onSelectType: (t) => _update(_state.copyWith(transitionType: t)),
          onChangeDuration: (d) => _update(_state.copyWith(transitionDuration: d)),
          animController: _transitionPreviewController,
        ),
        ExportTab(
          quality: _state.exportQuality,
          resolution: _state.exportResolution,
          format: _state.exportFormat,
          onChangeQuality: (q) => _update(_state.copyWith(exportQuality: q)),
          onChangeResolution: (r) => _update(_state.copyWith(exportResolution: r)),
          onChangeFormat: (f) => _update(_state.copyWith(exportFormat: f)),
        ),
      ],
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.backgroundTertiary,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(PhosphorIconsRegular.info, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _buildSummary(),
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_state.totalAppliedCount} total',
                style: GoogleFonts.inter(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CAPTIONS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class CaptionsTab extends StatelessWidget {
  final List<CaptionSegment> captions;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, {String? text, CaptionPosition? position, bool? isBold, bool? isItalic, Color? color}) onEdit;

  const CaptionsTab({
    super.key,
    required this.captions,
    required this.onAdd,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add button
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: _PanelButton(
              label: 'Add Caption',
              icon: PhosphorIconsRegular.plus,
              onTap: onAdd,
              isPrimary: true,
            ),
          ),
        ),

        // Caption list
        Expanded(
          child: captions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: captions.length,
                  itemBuilder: (context, index) {
                    final caption = captions[index];
                    return _CaptionCard(
                      caption: caption,
                      onRemove: () => onRemove(caption.id),
                      onEdit: (text, position, isBold, isItalic, color) =>
                          onEdit(caption.id,
                              text: text,
                              position: position,
                              isBold: isBold,
                              isItalic: isItalic,
                              color: color),
                    );
                  },
                ),
        ),

        // Live preview area
        _buildPreviewArea(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(PhosphorIconsRegular.subtitles, size: 36, color: AppColors.textTertiary),
          const SizedBox(height: 10),
          Text('No captions yet', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Tap "Add Caption" to create one', style: GoogleFonts.inter(color: AppColors.textDisabled, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    final previewCaption = captions.isNotEmpty ? captions.first : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: previewCaption != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  previewCaption.text,
                  style: GoogleFonts.inter(
                    color: previewCaption.color,
                    fontSize: 14,
                    fontWeight: previewCaption.isBold ? FontWeight.w700 : FontWeight.w400,
                    fontStyle: previewCaption.isItalic ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Text('Preview', style: GoogleFonts.inter(color: AppColors.textDisabled, fontSize: 12)),
      ),
    );
  }
}

class _CaptionCard extends StatefulWidget {
  final CaptionSegment caption;
  final VoidCallback onRemove;
  final void Function(String text, CaptionPosition position, bool isBold, bool isItalic, Color color) onEdit;

  const _CaptionCard({
    required this.caption,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  State<_CaptionCard> createState() => _CaptionCardCardState();
}

class _CaptionCardCardState extends State<_CaptionCard> {
  bool _expanded = false;
  late TextEditingController _textController;
  late CaptionPosition _position;
  late bool _isBold;
  late bool _isItalic;
  late Color _color;

  static const _presetColors = [
    Colors.white, AppColors.accent, AppColors.green400, AppColors.amber400,
    AppColors.purple400, AppColors.red400, Colors.cyan, Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _syncFromCaption();
  }

  @override
  void didUpdateWidget(covariant _CaptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.caption.id != widget.caption.id) _syncFromCaption();
  }

  void _syncFromCaption() {
    _textController = TextEditingController(text: widget.caption.text);
    _position = widget.caption.position;
    _isBold = widget.caption.isBold;
    _isItalic = widget.caption.isItalic;
    _color = widget.caption.color;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _expanded ? AppColors.surfaceActive : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _expanded ? AppColors.accent.withOpacity(0.5) : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.subtitles, size: 12, color: AppColors.green400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(widget.caption.timeRange, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 10)),
                  ),
                  _SmallIconButton(
                    icon: _expanded ? PhosphorIconsRegular.check : PhosphorIconsRegular.pencilSimple,
                    color: _expanded ? AppColors.success : AppColors.textTertiary,
                    onTap: () => setState(() => _expanded = !_expanded),
                  ),
                  const SizedBox(width: 4),
                  _SmallIconButton(
                    icon: PhosphorIconsRegular.trash,
                    color: AppColors.error,
                    onTap: widget.onRemove,
                  ),
                ],
              ),
            ),

            // Collapsed preview
            if (!_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Text(
                  widget.caption.text,
                  style: GoogleFonts.inter(
                    color: _color,
                    fontSize: 12,
                    fontWeight: _isBold ? FontWeight.w700 : FontWeight.w400,
                    fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Expanded editing controls
            if (_expanded) _buildEditingControls(),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildEditingControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text input
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundQuaternary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _textController,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Caption text...',
                hintStyle: GoogleFonts.inter(color: AppColors.textDisabled, fontSize: 12),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              onChanged: (v) => widget.onEdit(v, _position, _isBold, _isItalic, _color),
            ),
          ),
          const SizedBox(height: 8),

          // Font style toggle row
          Row(
            children: [
              _StyleToggle(
                label: 'B',
                isActive: _isBold,
                fontWeight: FontWeight.w700,
                onTap: () {
                  setState(() => _isBold = !_isBold);
                  widget.onEdit(_textController.text, _position, _isBold, _isItalic, _color);
                },
              ),
              const SizedBox(width: 6),
              _StyleToggle(
                label: 'I',
                isActive: _isItalic,
                fontStyle: FontStyle.italic,
                onTap: () {
                  setState(() => _isItalic = !_isItalic);
                  widget.onEdit(_textController.text, _position, _isBold, _isItalic, _color);
                },
              ),
              const SizedBox(width: 12),

              // Color picker
              ..._presetColors.map((c) => GestureDetector(
                    onTap: () {
                      setState(() => _color = c);
                      widget.onEdit(_textController.text, _position, _isBold, _isItalic, _color);
                    },
                    child: Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == c ? Colors.white : AppColors.border,
                          width: _color == c ? 2 : 1,
                        ),
                        boxShadow: _color == c
                            ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 4)]
                            : null,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),

          // Position selector
          Row(
            children: [
              Text('Position', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(width: 8),
              ...CaptionPosition.values.map((pos) {
                final isSelected = _position == pos;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _position = pos);
                      widget.onEdit(_textController.text, _position, _isBold, _isItalic, _color);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent.withOpacity(0.15) : AppColors.backgroundQuaternary,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                      ),
                      child: Text(
                        pos.name[0].toUpperCase() + pos.name.substring(1),
                        style: GoogleFonts.inter(
                          color: isSelected ? AppColors.accent : AppColors.textTertiary,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EFFECTS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class EffectsTab extends StatelessWidget {
  final Set<VideoEffect> appliedEffects;
  final ValueChanged<VideoEffect> onToggle;

  const EffectsTab({
    super.key,
    required this.appliedEffects,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.filmStrip, size: 14, color: AppColors.purple400),
              const SizedBox(width: 6),
              Text('Visual Effects', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (appliedEffects.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.purple500.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${appliedEffects.length} active',
                    style: GoogleFonts.inter(color: AppColors.purple400, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemCount: VideoEffect.values.length,
              itemBuilder: (context, index) {
                final effect = VideoEffect.values[index];
                final isSelected = appliedEffects.contains(effect);
                return _EffectCard(effect: effect, isSelected: isSelected, onTap: () => onToggle(effect));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectCard extends StatelessWidget {
  final VideoEffect effect;
  final bool isSelected;
  final VoidCallback onTap;

  const _EffectCard({required this.effect, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple500.withOpacity(0.12) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.purple500 : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.purple500.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(effect.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    effect.label,
                    style: GoogleFonts.inter(
                      color: isSelected ? AppColors.purple300 : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    effect.description,
                    style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 9),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(color: AppColors.purple500, shape: BoxShape.circle),
                  child: const Icon(PhosphorIconsRegular.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: (VideoEffect.values.indexOf(effect) * 30).ms);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SFX TAB
// ═══════════════════════════════════════════════════════════════════════════════

class SfxTab extends StatelessWidget {
  final List<PlacedSfx> placedSfx;
  final void Function(SfxItem sfx, double position) onAdd;
  final ValueChanged<String> onRemove;
  final double currentTime;
  final double totalDuration;
  final AnimationController waveformController;

  const SfxTab({
    super.key,
    required this.placedSfx,
    required this.onAdd,
    required this.onRemove,
    required this.currentTime,
    required this.totalDuration,
    required this.waveformController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SFX Library header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              const Icon(PhosphorIconsRegular.speakerHigh, size: 14, color: AppColors.timelineSfx),
              const SizedBox(width: 6),
              Text('Sound Effects Library', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        // Horizontal SFX card list
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: sfxLibrary.length,
            itemBuilder: (context, index) {
              final sfx = sfxLibrary[index];
              return _SfxLibraryCard(
                sfx: sfx,
                waveformController: waveformController,
                onAdd: () => onAdd(sfx, currentTime),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Timeline placed SFX
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(PhosphorIconsRegular.clock, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text('Timeline', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${placedSfx.length} placed', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 10)),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: placedSfx.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsRegular.timeline, size: 32, color: AppColors.textDisabled),
                      const SizedBox(height: 8),
                      Text('No SFX placed yet', style: GoogleFonts.inter(color: AppColors.textDisabled, fontSize: 12)),
                    ],
                  ),
                )
              : _buildPlacedSfxTimeline(),
        ),
      ],
    );
  }

  Widget _buildPlacedSfxTimeline() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundQuaternary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Mini timeline header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                const Icon(PhosphorIconsRegular.play, size: 10, color: AppColors.accent),
                const SizedBox(width: 6),
                Text('Playhead: ${currentTime.toStringAsFixed(1)}s', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 10)),
                const Spacer(),
                // Mini timeline bar
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(height: 3, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                          ...placedSfx.map((sfx) {
                            final pos = (sfx.positionSeconds / totalDuration).clamp(0.0, 1.0);
                            return Positioned(
                              left: (pos * constraints.maxWidth).clamp(0, constraints.maxWidth - 4),
                              top: -2,
                              child: Container(width: 4, height: 7, decoration: BoxDecoration(color: AppColors.timelineSfx, borderRadius: BorderRadius.circular(2))),
                            );
                          }),
                          Positioned(
                            left: ((currentTime / totalDuration).clamp(0.0, 1.0) * constraints.maxWidth).clamp(0, constraints.maxWidth - 2),
                            top: -3,
                            child: Container(width: 2, height: 9, color: AppColors.accent),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Placed SFX list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: placedSfx.length,
              itemBuilder: (context, index) {
                final placed = placedSfx[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text(placed.sfx.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(placed.sfx.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w500)),
                            Text(
                              '@ ${placed.positionSeconds.toStringAsFixed(1)}s • ${placed.sfx.durationSeconds}s',
                              style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                      _SmallIconButton(
                        icon: PhosphorIconsRegular.x,
                        color: AppColors.error,
                        onTap: () => onRemove(placed.id),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SfxLibraryCard extends StatelessWidget {
  final SfxItem sfx;
  final AnimationController waveformController;
  final VoidCallback onAdd;

  const _SfxLibraryCard({required this.sfx, required this.waveformController, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(sfx.icon, style: const TextStyle(fontSize: 18)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.backgroundQuaternary, borderRadius: BorderRadius.circular(8)),
                  child: Text('${sfx.durationSeconds}s', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 8)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(sfx.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),

            // Waveform visualization
            Expanded(
              child: AnimatedBuilder(
                animation: waveformController,
                builder: (context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: sfx.waveform.map((amp) {
                      final animatedAmp = amp * (0.7 + 0.3 * waveformController.value);
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          height: 24 * animatedAmp,
                          decoration: BoxDecoration(
                            color: AppColors.timelineSfx.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),
            Center(
              child: Icon(PhosphorIconsRegular.plusCircle, size: 14, color: AppColors.timelineSfx),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TRANSITIONS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class TransitionsTab extends StatelessWidget {
  final TransitionType selectedType;
  final double duration;
  final ValueChanged<TransitionType> onSelectType;
  final ValueChanged<double> onChangeDuration;
  final AnimationController animController;

  const TransitionsTab({
    super.key,
    required this.selectedType,
    required this.duration,
    required this.onSelectType,
    required this.onChangeDuration,
    required this.animController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(PhosphorIconsRegular.arrowsLeftRight, size: 14, color: AppColors.amber400),
              const SizedBox(width: 6),
              Text('Transition Type', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),

          // Transition type cards
          ...TransitionType.values.map((type) {
            final isSelected = selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onSelectType(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.amber500.withOpacity(0.08) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.amber500 : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.amber500.withOpacity(0.15) : AppColors.backgroundQuaternary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(type.phosphorIcon, size: 16, color: isSelected ? AppColors.amber400 : AppColors.textTertiary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type.label, style: GoogleFonts.inter(
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                            Text(_transitionDescription(type), style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 10)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: AppColors.amber500, shape: BoxShape.circle),
                          child: const Icon(PhosphorIconsRegular.check, size: 12, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Duration slider
          Row(
            children: [
              const Icon(PhosphorIconsRegular.timer, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text('Duration', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.backgroundQuaternary, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  '${duration.toStringAsFixed(1)}s',
                  style: GoogleFonts.inter(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppColors.amber500,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.amber500,
              overlayColor: AppColors.amber500.withOpacity(0.1),
            ),
            child: Slider(value: duration, min: 0.3, max: 2.0, divisions: 17, onChanged: onChangeDuration),
          ),

          const SizedBox(height: 16),

          // Preview animation area
          Text('Preview', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(child: _TransitionPreview(type: selectedType, animController: animController)),
        ],
      ),
    );
  }

  String _transitionDescription(TransitionType type) {
    switch (type) {
      case TransitionType.fadeToBlack:
        return 'Fade scene to black, then reveal next';
      case TransitionType.crossDissolve:
        return 'Smooth blend between two clips';
      case TransitionType.slideLeft:
        return 'Slide next clip in from the right';
      case TransitionType.slideRight:
        return 'Slide next clip in from the left';
      case TransitionType.zoom:
        return 'Zoom through to the next clip';
    }
  }
}

class _TransitionPreview extends StatelessWidget {
  final TransitionType type;
  final AnimationController animController;

  const _TransitionPreview({required this.type, required this.animController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: animController,
        builder: (context, _) {
          final t = animController.value;
          return Stack(
            children: [
              _buildClipA(t),
              _buildClipB(t),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                    child: Text(type.label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 9)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClipA(double t) {
    final label = Text('A', style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700));
    switch (type) {
      case TransitionType.fadeToBlack:
        return Opacity(opacity: (t < 0.5 ? 1.0 : (1.0 - (t - 0.5) * 2)).clamp(0.0, 1.0), child: Container(color: AppColors.accent.withOpacity(0.3), child: Center(child: label)));
      case TransitionType.crossDissolve:
        return Opacity(opacity: (1.0 - t).clamp(0.0, 1.0), child: Container(color: AppColors.accent.withOpacity(0.3), child: Center(child: label)));
      case TransitionType.slideLeft:
        return Transform.translate(offset: Offset(-t * 200, 0), child: Container(color: AppColors.accent.withOpacity(0.3), child: Center(child: label)));
      case TransitionType.slideRight:
        return Transform.translate(offset: Offset(t * 200, 0), child: Container(color: AppColors.accent.withOpacity(0.3), child: Center(child: label)));
      case TransitionType.zoom:
        return Transform.scale(scale: 1.0 + t * 2, child: Opacity(opacity: (1.0 - t).clamp(0.0, 1.0), child: Container(color: AppColors.accent.withOpacity(0.3), child: Center(child: label))));
    }
  }

  Widget _buildClipB(double t) {
    final label = Text('B', style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700));
    switch (type) {
      case TransitionType.fadeToBlack:
        return Opacity(opacity: (t < 0.5 ? 0.0 : (t - 0.5) * 2).clamp(0.0, 1.0), child: Container(color: AppColors.purple500.withOpacity(0.3), child: Center(child: label)));
      case TransitionType.crossDissolve:
        return Opacity(opacity: t.clamp(0.0, 1.0), child: Container(color: AppColors.purple500.withOpacity(0.3), child: Center(child: label)));
      case TransitionType.slideLeft:
        return Transform.translate(offset: Offset((1.0 - t) * 200, 0), child: Container(color: AppColors.purple500.withOpacity(0.3), child: Center(child: label)));
      case TransitionType.slideRight:
        return Transform.translate(offset: Offset(-(1.0 - t) * 200, 0), child: Container(color: AppColors.purple500.withOpacity(0.3), child: Center(child: label)));
      case TransitionType.zoom:
        return Transform.scale(scale: 0.1 + (1.0 - t) * 0.9, child: Opacity(opacity: t.clamp(0.0, 1.0), child: Container(color: AppColors.purple500.withOpacity(0.3), child: Center(child: label))));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXPORT TAB
// ═══════════════════════════════════════════════════════════════════════════════

class ExportTab extends StatelessWidget {
  final ExportQuality quality;
  final ExportResolution resolution;
  final ExportFormat format;
  final ValueChanged<ExportQuality> onChangeQuality;
  final ValueChanged<ExportResolution> onChangeResolution;
  final ValueChanged<ExportFormat> onChangeFormat;

  const ExportTab({
    super.key,
    required this.quality,
    required this.resolution,
    required this.format,
    required this.onChangeQuality,
    required this.onChangeResolution,
    required this.onChangeFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quality selector
            _sectionHeader('Quality', PhosphorIconsRegular.gauge, AppColors.accent),
            const SizedBox(height: 10),
            ...ExportQuality.values.map((q) {
              final isSelected = quality == q;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => onChangeQuality(q),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent.withOpacity(0.08) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(isSelected ? PhosphorIconsRegular.radioButton : PhosphorIconsRegular.circle, size: 16, color: isSelected ? AppColors.accent : AppColors.textTertiary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.label, style: GoogleFonts.inter(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                              Text('Est. ${q.estimatedSize}', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Resolution picker
            _sectionHeader('Resolution', PhosphorIconsRegular.monitorPlay, AppColors.purple400),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ExportResolution.values.map((r) {
                final isSelected = resolution == r;
                return GestureDetector(
                  onTap: () => onChangeResolution(r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.purple500.withOpacity(0.12) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? AppColors.purple500 : AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(r.label, style: GoogleFonts.inter(color: isSelected ? AppColors.purple300 : AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                        Text(r.dimensions, style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 9)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Format selector
            _sectionHeader('Format', PhosphorIconsRegular.fileVideo, AppColors.green400),
            const SizedBox(height: 10),
            ...ExportFormat.values.map((f) {
              final isSelected = format == f;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => onChangeFormat(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.green500.withOpacity(0.08) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.green500 : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(isSelected ? PhosphorIconsRegular.radioButton : PhosphorIconsRegular.circle, size: 16, color: isSelected ? AppColors.green500 : AppColors.textTertiary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.label, style: GoogleFonts.inter(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                              Text(f.description, style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Estimated file size
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundQuaternary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.hardDrive, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Text('Estimated file size: ', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 11)),
                  Text(quality.estimatedSize, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${resolution.label} • ${format.label}', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 10)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Export button
            SizedBox(
              width: double.infinity,
              child: _PanelButton(
                label: 'Export Final Video',
                icon: PhosphorIconsRegular.export,
                onTap: () {},
                isPrimary: true,
                gradient: AppColors.gradientPurple,
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _PanelButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final Gradient? gradient;

  const _PanelButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isPrimary ? (gradient ?? AppColors.gradientPrimary) : null,
          color: isPrimary ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: isPrimary ? null : Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallIconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 12, color: color),
      ),
    );
  }
}

class _StyleToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final VoidCallback onTap;

  const _StyleToggle({
    required this.label,
    required this.isActive,
    this.fontWeight,
    this.fontStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.15) : AppColors.backgroundQuaternary,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? AppColors.accent : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? AppColors.accent : AppColors.textTertiary,
              fontSize: 12,
              fontWeight: fontWeight ?? FontWeight.w400,
              fontStyle: fontStyle ?? FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONVENIENCE FUNCTION
// ═══════════════════════════════════════════════════════════════════════════════

/// Convenience method to show the effects panel as a modal bottom sheet.
Future<VideoEffectsState?> showVideoEffectsPanel(
  BuildContext context, {
  VideoEffectsState? initialState,
}) {
  return VideoEffectsPanel.show(context, initialState: initialState);
}
