import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────
const Color _bgColor = Color(0xFF0D0D0F);
const Color _surfaceColor = Color(0xFF141418);
const Color _cardColor = Color(0xFF1A1A1F);
const Color _borderColor = Color(0xFF222228);
const Color _accentColor = Color(0xFF3B82F6);
const Color _purpleColor = Color(0xFF8B5CF6);
const Color _successColor = Color(0xFF22C55E);
const Color _warningColor = Color(0xFFF59E0B);
const Color _errorColor = Color(0xFFEF4444);
const Color _playheadColor = Color(0xFFEF4444);
const Color _textPrimary = Color(0xFFF5F5F7);
const Color _textSecondary = Color(0xFF9CA3AF);
const Color _textMuted = Color(0xFF6B7280);

// ─── Chapter Data ────────────────────────────────────────────────────────────
class ChapterData {
  final int number;
  final String title;
  final double startTime;
  final double endTime;
  final String description;
  final int footageCount;
  final String commentary;
  final Color color;

  ChapterData({
    required this.number,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.footageCount,
    this.commentary = '',
    required this.color,
  });

  ChapterData copyWith({String? commentary, String? title, String? description}) {
    return ChapterData(
      number: number,
      title: title ?? this.title,
      startTime: startTime,
      endTime: endTime,
      description: description ?? this.description,
      footageCount: footageCount,
      commentary: commentary ?? this.commentary,
      color: color,
    );
  }
}

class TransitionData {
  final int fromChapter;
  final int toChapter;
  final String type;
  final double duration;

  TransitionData({required this.fromChapter, required this.toChapter, required this.type, required this.duration});
}

// ─── Editor State ────────────────────────────────────────────────────────────
class LongFormEditorState {
  final String projectName;
  final String? projectId;
  final String? longFormId;
  final bool leftPanelOpen;
  final bool rightPanelOpen;
  final double zoom;
  final Duration currentTime;
  final Duration totalDuration;
  final bool isPlaying;
  final int selectedChapter;
  final List<ChapterData> chapters;
  final List<TransitionData> transitions;
  final String selectedCaptionStyle;
  final bool isSaving;
  final bool isExporting;
  final bool showSubtitles;
  final bool isFullscreen;
  final DateTime? lastSaved;
  final String? exportDestination;
  final String? undoStack;
  final String? redoStack;

  LongFormEditorState({
    this.projectName = 'Long-Form Video',
    this.projectId,
    this.longFormId,
    this.leftPanelOpen = true,
    this.rightPanelOpen = true,
    this.zoom = 1.0,
    this.currentTime = Duration.zero,
    this.totalDuration = const Duration(minutes: 8),
    this.isPlaying = false,
    this.selectedChapter = 0,
    List<ChapterData>? chapters,
    List<TransitionData>? transitions,
    this.selectedCaptionStyle = 'Bold',
    this.isSaving = false,
    this.isExporting = false,
    this.showSubtitles = false,
    this.isFullscreen = false,
    this.lastSaved,
    this.exportDestination,
    this.undoStack,
    this.redoStack,
  })  : chapters = chapters ?? [],
        transitions = transitions ?? [];

  LongFormEditorState copyWith({
    String? projectName,
    String? projectId,
    String? longFormId,
    bool? leftPanelOpen,
    bool? rightPanelOpen,
    double? zoom,
    Duration? currentTime,
    Duration? totalDuration,
    bool? isPlaying,
    int? selectedChapter,
    List<ChapterData>? chapters,
    List<TransitionData>? transitions,
    String? selectedCaptionStyle,
    bool? isSaving,
    bool? isExporting,
    bool? showSubtitles,
    bool? isFullscreen,
    DateTime? lastSaved,
    String? exportDestination,
    String? undoStack,
    String? redoStack,
  }) {
    return LongFormEditorState(
      projectName: projectName ?? this.projectName,
      projectId: projectId ?? this.projectId,
      longFormId: longFormId ?? this.longFormId,
      leftPanelOpen: leftPanelOpen ?? this.leftPanelOpen,
      rightPanelOpen: rightPanelOpen ?? this.rightPanelOpen,
      zoom: zoom ?? this.zoom,
      currentTime: currentTime ?? this.currentTime,
      totalDuration: totalDuration ?? this.totalDuration,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedChapter: selectedChapter ?? this.selectedChapter,
      chapters: chapters ?? this.chapters,
      transitions: transitions ?? this.transitions,
      selectedCaptionStyle: selectedCaptionStyle ?? this.selectedCaptionStyle,
      isSaving: isSaving ?? this.isSaving,
      isExporting: isExporting ?? this.isExporting,
      showSubtitles: showSubtitles ?? this.showSubtitles,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      lastSaved: lastSaved ?? this.lastSaved,
      exportDestination: exportDestination,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

final longFormEditorProvider = StateNotifierProvider<LongFormEditorNotifier, LongFormEditorState>(
  (ref) => LongFormEditorNotifier(),
);

class LongFormEditorNotifier extends StateNotifier<LongFormEditorState> {
  Timer? _playbackTimer;

  LongFormEditorNotifier() : super(LongFormEditorState());

  void init({String? projectId, String? longFormId, String? projectName, List<ChapterData>? chapters}) {
    state = state.copyWith(
      projectId: projectId,
      longFormId: longFormId,
      projectName: projectName ?? state.projectName,
      chapters: chapters,
    );
  }

  void toggleLeftPanel() => state = state.copyWith(leftPanelOpen: !state.leftPanelOpen);
  void toggleRightPanel() => state = state.copyWith(rightPanelOpen: !state.rightPanelOpen);
  void setZoom(double zoom) => state = state.copyWith(zoom: zoom.clamp(0.25, 4.0));
  void setCurrentTime(Duration time) {
    final clamped = Duration(milliseconds: time.inMilliseconds.clamp(0, state.totalDuration.inMilliseconds));
    state = state.copyWith(currentTime: clamped);
  }

  void togglePlay() {
    final newPlaying = !state.isPlaying;
    state = state.copyWith(isPlaying: newPlaying);
    _playbackTimer?.cancel();
    if (newPlaying) {
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!mounted) {
          _playbackTimer?.cancel();
          return;
        }
        final next = state.currentTime + const Duration(milliseconds: 100);
        if (next >= state.totalDuration) {
          state = state.copyWith(currentTime: Duration.zero, isPlaying: false);
          _playbackTimer?.cancel();
        } else {
          state = state.copyWith(currentTime: next);
          // Auto-select chapter based on current time
          _updateSelectedChapter();
        }
      });
    }
  }

  void _updateSelectedChapter() {
    final seconds = state.currentTime.inSeconds.toDouble();
    for (int i = 0; i < state.chapters.length; i++) {
      final ch = state.chapters[i];
      if (seconds >= ch.startTime && seconds < ch.endTime) {
        if (state.selectedChapter != i) {
          state = state.copyWith(selectedChapter: i);
        }
        return;
      }
    }
  }

  void skipBack() {
    final newTime = state.currentTime - const Duration(seconds: 10);
    setCurrentTime(newTime);
  }

  void skipForward() {
    final newTime = state.currentTime + const Duration(seconds: 10);
    setCurrentTime(newTime);
  }

  void toggleSubtitles() => state = state.copyWith(showSubtitles: !state.showSubtitles);
  void toggleFullscreen() => state = state.copyWith(isFullscreen: !state.isFullscreen);

  void selectChapter(int index) {
    if (index >= 0 && index < state.chapters.length) {
      state = state.copyWith(selectedChapter: index);
      final ch = state.chapters[index];
      setCurrentTime(Duration(seconds: ch.startTime.toInt()));
    }
  }

  void updateCommentary(int chapterIndex, String text) {
    final chapters = List<ChapterData>.from(state.chapters);
    chapters[chapterIndex] = chapters[chapterIndex].copyWith(commentary: text);
    state = state.copyWith(chapters: chapters);
  }

  /// Save the current editor state
  void save() {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      state = state.copyWith(isSaving: false, lastSaved: DateTime.now());
    });
  }

  /// Start export to a destination
  void exportTo(String destination) {
    if (state.isExporting) return;
    state = state.copyWith(isExporting: true, exportDestination: destination);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      state = state.copyWith(isExporting: false, exportDestination: null);
    });
  }

  /// Undo (simulated)
  void undo() {
    // In a real app, this would pop from an undo stack
    // For now, show the save state changed
  }

  /// Redo (simulated)
  void redo() {
    // In a real app, this would pop from a redo stack
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}

// ─── Long Form Editor Page ───────────────────────────────────────────────────
class LongFormEditorPage extends ConsumerStatefulWidget {
  const LongFormEditorPage({super.key, this.projectId, this.longFormId});
  final String? projectId;
  final String? longFormId;

  @override
  ConsumerState<LongFormEditorPage> createState() => _LongFormEditorPageState();
}

class _LongFormEditorPageState extends ConsumerState<LongFormEditorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(longFormEditorProvider.notifier).init(
        projectId: widget.projectId,
        longFormId: widget.longFormId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(longFormEditorProvider);
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 900;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          // ─── Top Bar ─────────────────────────────────────────────────
          _EditorTopBar(state: state, ref: ref),

          // ─── Main Content ────────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                // Chapter Sidebar (Left Panel)
                if (state.leftPanelOpen && !isCompact)
                  _ChapterSidebar(state: state, ref: ref),

                // Center Area
                Expanded(
                  child: Column(
                    children: [
                      // Video Preview
                      Expanded(
                        child: _VideoPreviewArea(state: state, ref: ref),
                      ),

                      // Timeline
                      _TimelineArea(state: state, ref: ref),
                    ],
                  ),
                ),

                // Right Panel (Pacing, Commentary, Transitions, Export)
                if (state.rightPanelOpen && !isCompact)
                  _RightPanel(state: state, ref: ref),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────
class _EditorTopBar extends StatelessWidget {
  final LongFormEditorState state;
  final WidgetRef ref;

  const _EditorTopBar({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.list, size: 18),
            color: _textSecondary,
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          // Project name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsRegular.bookOpenText, size: 12, color: _purpleColor),
                const SizedBox(width: 6),
                Text(state.projectName, style: GoogleFonts.inter(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Undo/Redo
          _ToolBarButton(icon: PhosphorIconsRegular.arrowUUpLeft, tooltip: 'Undo', onTap: () {
            ref.read(longFormEditorProvider.notifier).undo();
          }),
          _ToolBarButton(icon: PhosphorIconsRegular.arrowUUpRight, tooltip: 'Redo', onTap: () {
            ref.read(longFormEditorProvider.notifier).redo();
          }),
          const SizedBox(width: 8),
          _ToolBarDivider(),
          // Zoom
          _ToolBarButton(icon: PhosphorIconsRegular.magnifyingGlassMinus, tooltip: 'Zoom Out', onTap: () {
            ref.read(longFormEditorProvider.notifier).setZoom(state.zoom - 0.25);
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('${(state.zoom * 100).toInt()}%', style: GoogleFonts.inter(color: _textSecondary, fontSize: 11)),
          ),
          _ToolBarButton(icon: PhosphorIconsRegular.magnifyingGlassPlus, tooltip: 'Zoom In', onTap: () {
            ref.read(longFormEditorProvider.notifier).setZoom(state.zoom + 0.25);
          }),
          const Spacer(),
          // Chapters toggle
          _ToolBarButton(
            icon: PhosphorIconsRegular.listNumbers,
            tooltip: 'Chapters',
            onTap: () => ref.read(longFormEditorProvider.notifier).toggleLeftPanel(),
            isActive: state.leftPanelOpen,
          ),
          _ToolBarButton(
            icon: PhosphorIconsRegular.gearSix,
            tooltip: 'Properties',
            onTap: () => ref.read(longFormEditorProvider.notifier).toggleRightPanel(),
            isActive: state.rightPanelOpen,
          ),
          const SizedBox(width: 8),
          // Save button
          _ToolBarButton(
            icon: state.isSaving ? PhosphorIconsRegular.spinner : PhosphorIconsRegular.floppyDisk,
            tooltip: state.lastSaved != null
                ? 'Saved at ${_formatTime(state.lastSaved!)}'
                : 'Save',
            onTap: () => ref.read(longFormEditorProvider.notifier).save(),
            isActive: state.isSaving,
          ),
          const SizedBox(width: 4),
          // Export button
          GestureDetector(
            onTap: () => _showExportDialog(context, ref),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_accentColor, _purpleColor]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(PhosphorIconsRegular.youtubeLogo, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Export for YouTube', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _borderColor),
        ),
        title: Text('Export Video', style: GoogleFonts.inter(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ExportDialogOption(
              label: 'YouTube',
              icon: PhosphorIconsRegular.youtubeLogo,
              color: _errorColor,
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(longFormEditorProvider.notifier).exportTo('YouTube');
              },
            ),
            const SizedBox(height: 8),
            _ExportDialogOption(
              label: 'Download File',
              icon: PhosphorIconsRegular.downloadSimple,
              color: _accentColor,
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(longFormEditorProvider.notifier).exportTo('Download');
              },
            ),
            const SizedBox(height: 8),
            _ExportDialogOption(
              label: 'Share Link',
              icon: PhosphorIconsRegular.link,
              color: _successColor,
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(longFormEditorProvider.notifier).exportTo('Share');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: _textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ExportDialogOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ExportDialogOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(PhosphorIconsRegular.caretRight, size: 12, color: _textMuted),
          ],
        ),
      ),
    );
  }
}

class _ToolBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _ToolBarButton({required this.icon, required this.tooltip, required this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? _accentColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: isActive ? _accentColor : _textSecondary),
        ),
      ),
    );
  }
}

class _ToolBarDivider extends StatelessWidget {
  const _ToolBarDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 20, color: _borderColor);
}

// ─── Chapter Sidebar ─────────────────────────────────────────────────────────
class _ChapterSidebar extends StatelessWidget {
  final LongFormEditorState state;
  final WidgetRef ref;

  const _ChapterSidebar({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(right: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _borderColor)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.listNumbers, size: 14, color: _accentColor),
                const SizedBox(width: 8),
                Text('Chapters', style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${state.chapters.length}', style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
              ],
            ),
          ),

          // Pacing Map
          if (state.chapters.isNotEmpty) _PacingMap(chapters: state.chapters),

          // Chapter List
          Expanded(
            child: state.chapters.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No chapters loaded', style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = state.chapters[index];
                      final isSelected = state.selectedChapter == index;
                      return _ChapterItem(
                        chapter: chapter,
                        isSelected: isSelected,
                        onTap: () => ref.read(longFormEditorProvider.notifier).selectChapter(index),
                      );
                    },
                  ),
          ),

          // Total duration
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _borderColor)),
            ),
            child: Row(
              children: [
                Text('Total Duration', style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
                const Spacer(),
                Text(_formatDuration(state.totalDuration), style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PacingMap extends StatelessWidget {
  final List<ChapterData> chapters;

  const _PacingMap({required this.chapters});

  @override
  Widget build(BuildContext context) {
    final totalDuration = chapters.isNotEmpty ? chapters.last.endTime : 480.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.chartBar, size: 12, color: _accentColor),
              const SizedBox(width: 6),
              Text('Pacing Map', style: GoogleFonts.inter(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          // Pacing bar
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: chapters.map((ch) {
                final width = totalDuration > 0 ? (ch.endTime - ch.startTime) / totalDuration : 0.0;
                return Expanded(
                  flex: (width * 1000).round().clamp(1, 1000),
                  child: Tooltip(
                    message: '${ch.title}\n${_formatDuration(Duration(milliseconds: (ch.startTime * 1000).round()))} → ${_formatDuration(Duration(milliseconds: (ch.endTime * 1000).round()))}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: ch.color.withOpacity(0.5),
                        border: const Border(
                          right: BorderSide(color: _borderColor, width: 0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${ch.number}',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          // Legend
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: chapters.take(4).map((ch) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: ch.color, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text(ch.title, style: GoogleFonts.inter(color: _textMuted, fontSize: 8)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChapterItem extends StatelessWidget {
  final ChapterData chapter;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChapterItem({required this.chapter, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? chapter.color.withOpacity(0.08) : _cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? chapter.color.withOpacity(0.3) : _borderColor),
        ),
        child: Row(
          children: [
            // Chapter number
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: chapter.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '${chapter.number}',
                  style: GoogleFonts.inter(color: chapter.color, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter.title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11, fontWeight: FontWeight.w500)),
                  Text(
                    '${_formatDuration(Duration(milliseconds: (chapter.startTime * 1000).round()))} → ${_formatDuration(Duration(milliseconds: (chapter.endTime * 1000).round()))}',
                    style: GoogleFonts.inter(color: _textMuted, fontSize: 9),
                  ),
                ],
              ),
            ),
            // Footage count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${chapter.footageCount}', style: GoogleFonts.inter(color: _textMuted, fontSize: 9)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Video Preview ───────────────────────────────────────────────────────────
class _VideoPreviewArea extends StatelessWidget {
  final LongFormEditorState state;
  final WidgetRef ref;

  const _VideoPreviewArea({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final currentChapter = state.chapters.isNotEmpty && state.selectedChapter < state.chapters.length
        ? state.chapters[state.selectedChapter]
        : null;

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video placeholder / preview
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF111115),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isPlaying ? PhosphorIconsRegular.filmStrip : PhosphorIconsRegular.filmSlate,
                        size: 48,
                        color: state.isPlaying ? _accentColor : _textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.isPlaying ? 'Playing...' : 'Long-Form Preview',
                        style: GoogleFonts.inter(
                          color: state.isPlaying ? _accentColor : _textMuted,
                          fontSize: 14,
                        ),
                      ),
                      if (currentChapter != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Chapter ${state.selectedChapter + 1}: ${currentChapter.title}',
                          style: GoogleFonts.inter(color: _textSecondary, fontSize: 11),
                        ),
                      ],
                      if (state.isExporting) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            backgroundColor: _borderColor,
                            color: _accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Exporting to ${state.exportDestination ?? "YouTube"}...',
                          style: GoogleFonts.inter(color: _accentColor, fontSize: 10),
                        ),
                      ],
                    ],
                  ),

                  // Subtitles overlay
                  if (state.showSubtitles && currentChapter != null)
                    Positioned(
                      bottom: 60,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          currentChapter.description,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Playback controls
          Positioned(
            bottom: 12,
            left: 24,
            right: 24,
            child: _PlaybackControls(state: state, ref: ref),
          ),
        ],
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  final LongFormEditorState state;
  final WidgetRef ref;

  const _PlaybackControls({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.skipBack, size: 16),
          color: _textSecondary,
          onPressed: () => ref.read(longFormEditorProvider.notifier).skipBack(),
          tooltip: 'Skip Back 10s',
        ),
        IconButton(
          icon: Icon(state.isPlaying ? PhosphorIconsRegular.pause : PhosphorIconsRegular.play, size: 20),
          color: Colors.white,
          onPressed: () => ref.read(longFormEditorProvider.notifier).togglePlay(),
          tooltip: state.isPlaying ? 'Pause' : 'Play',
        ),
        IconButton(
          icon: const Icon(PhosphorIconsRegular.skipForward, size: 16),
          color: _textSecondary,
          onPressed: () => ref.read(longFormEditorProvider.notifier).skipForward(),
          tooltip: 'Skip Forward 10s',
        ),
        const SizedBox(width: 8),
        Text(_formatDuration(state.currentTime), style: GoogleFonts.inter(color: _textPrimary, fontSize: 11)),
        Text(' / ${_formatDuration(state.totalDuration)}', style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
        const Spacer(),
        IconButton(
          icon: Icon(
            PhosphorIconsRegular.subtitles,
            size: 16,
            color: state.showSubtitles ? _accentColor : _textSecondary,
          ),
          onPressed: () => ref.read(longFormEditorProvider.notifier).toggleSubtitles(),
          tooltip: 'Toggle Subtitles',
        ),
        IconButton(
          icon: Icon(
            PhosphorIconsRegular.arrowsOutSimple,
            size: 16,
            color: state.isFullscreen ? _accentColor : _textSecondary,
          ),
          onPressed: () => ref.read(longFormEditorProvider.notifier).toggleFullscreen(),
          tooltip: 'Toggle Fullscreen',
        ),
      ],
    );
  }
}

// ─── Timeline ────────────────────────────────────────────────────────────────
class _TimelineArea extends StatelessWidget {
  final LongFormEditorState state;
  final WidgetRef ref;

  const _TimelineArea({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          // Timeline header
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: _surfaceColor,
              border: Border(bottom: BorderSide(color: _borderColor)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.filmStrip, size: 14, color: _textSecondary),
                const SizedBox(width: 6),
                Text('Timeline', style: GoogleFonts.inter(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(PhosphorIconsRegular.magnifyingGlassMinus, size: 12, color: _textMuted),
                SizedBox(
                  width: 80,
                  child: Slider(
                    value: state.zoom,
                    min: 0.25,
                    max: 4.0,
                    onChanged: (v) => ref.read(longFormEditorProvider.notifier).setZoom(v),
                    activeColor: _accentColor,
                    inactiveColor: _borderColor,
                  ),
                ),
                Icon(PhosphorIconsRegular.magnifyingGlassPlus, size: 12, color: _textMuted),
              ],
            ),
          ),

          // Timeline tracks
          Expanded(
            child: state.chapters.isEmpty
                ? Center(
                    child: Text('No timeline data', style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
                  )
                : Row(
                    children: [
                      // Track headers
                      SizedBox(
                        width: 120,
                        child: Column(
                          children: [
                            _TrackLabel(label: 'Video', icon: PhosphorIconsRegular.videoCamera, color: _accentColor),
                            _TrackLabel(label: 'Commentary', icon: PhosphorIconsRegular.microphone, color: _purpleColor),
                            _TrackLabel(label: 'Music', icon: PhosphorIconsRegular.musicNote, color: _successColor),
                            _TrackLabel(label: 'Chapters', icon: PhosphorIconsRegular.bookmarkSimple, color: _warningColor),
                          ],
                        ),
                      ),

                      // Track content
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 800 * state.zoom,
                            child: Column(
                              children: [
                                // Ruler
                                _TimelineRuler(totalSeconds: state.totalDuration.inSeconds.toDouble(), zoom: state.zoom),
                                // Video track
                                _TimelineTrack(
                                  clips: state.chapters.map((ch) => _TimelineClip(
                                    name: ch.title,
                                    start: ch.startTime,
                                    duration: ch.endTime - ch.startTime,
                                    color: ch.color,
                                  )).toList(),
                                  totalSeconds: state.totalDuration.inSeconds.toDouble(),
                                  zoom: state.zoom,
                                  height: 32,
                                ),
                                // Commentary track
                                _TimelineTrack(
                                  clips: state.chapters.where((ch) => ch.commentary.isNotEmpty).map((ch) => _TimelineClip(
                                    name: ch.title,
                                    start: ch.startTime,
                                    duration: ch.endTime - ch.startTime,
                                    color: _purpleColor.withOpacity(0.6),
                                  )).toList(),
                                  totalSeconds: state.totalDuration.inSeconds.toDouble(),
                                  zoom: state.zoom,
                                  height: 28,
                                ),
                                // Music track
                                _TimelineTrack(
                                  clips: [_TimelineClip(name: 'Background Music', start: 0, duration: state.totalDuration.inSeconds.toDouble(), color: _successColor.withOpacity(0.3))],
                                  totalSeconds: state.totalDuration.inSeconds.toDouble(),
                                  zoom: state.zoom,
                                  height: 24,
                                ),
                                // Chapters track
                                _TimelineTrack(
                                  clips: state.chapters.map((ch) => _TimelineClip(
                                    name: '${ch.number}',
                                    start: ch.startTime,
                                    duration: ch.endTime - ch.startTime,
                                    color: ch.color.withOpacity(0.4),
                                  )).toList(),
                                  totalSeconds: state.totalDuration.inSeconds.toDouble(),
                                  zoom: state.zoom,
                                  height: 24,
                                ),

                                // Playhead
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 2,
                                    height: double.infinity,
                                    child: Container(color: _playheadColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TrackLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TrackLabel({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: GoogleFonts.inter(color: _textSecondary, fontSize: 9, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _TimelineRuler extends StatelessWidget {
  final double totalSeconds;
  final double zoom;

  const _TimelineRuler({required this.totalSeconds, required this.zoom});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      color: _surfaceColor,
      child: CustomPaint(
        painter: _RulerPainter(totalSeconds: totalSeconds, zoom: zoom),
        size: Size(double.infinity, 24),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double totalSeconds;
  final double zoom;

  _RulerPainter({required this.totalSeconds, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final pixelsPerSecond = (800 * zoom) / totalSeconds;

    for (double t = 0; t <= totalSeconds; t += 10) {
      final x = t * pixelsPerSecond;
      if (x > size.width) break;
      paint.color = _borderColor;
      canvas.drawLine(Offset(x, size.height * 0.5), Offset(x, size.height), paint);

      if (t % 60 == 0) {
        final mins = (t / 60).floor();
        textPainter.text = TextSpan(text: '${mins}m', style: const TextStyle(color: _textMuted, fontSize: 8));
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 2, 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) => oldDelegate.zoom != zoom;
}

class _TimelineTrack extends StatelessWidget {
  final List<_TimelineClip> clips;
  final double totalSeconds;
  final double zoom;
  final double height;

  const _TimelineTrack({required this.clips, required this.totalSeconds, required this.zoom, required this.height});

  @override
  Widget build(BuildContext context) {
    final pixelsPerSecond = (800 * zoom) / totalSeconds;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: Stack(
        children: clips.map((clip) {
          final left = clip.start * pixelsPerSecond;
          final width = (clip.duration * pixelsPerSecond).clamp(4.0, double.infinity);
          return Positioned(
            left: left,
            top: 3,
            bottom: 3,
            width: width,
            child: Container(
              decoration: BoxDecoration(
                color: clip.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: clip.color.withOpacity(0.5), width: 0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Text(
                  clip.name,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 8),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineClip {
  final String name;
  final double start;
  final double duration;
  final Color color;

  _TimelineClip({required this.name, required this.start, required this.duration, required this.color});
}

// ─── Right Panel ─────────────────────────────────────────────────────────────
class _RightPanel extends StatelessWidget {
  final LongFormEditorState state;
  final WidgetRef ref;

  const _RightPanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(left: BorderSide(color: _borderColor)),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _borderColor)),
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: _accentColor,
                unselectedLabelColor: _textMuted,
                labelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
                indicatorColor: _accentColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Pacing'),
                  Tab(text: 'Transitions'),
                  Tab(text: 'Commentary'),
                  Tab(text: 'Export'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PacingPanel(state: state),
                  _TransitionsPanel(state: state),
                  _CommentaryPanel(state: state, ref: ref),
                  _ExportPanel(ref: ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PacingPanel extends StatelessWidget {
  final LongFormEditorState state;

  const _PacingPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.chapters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No pacing data available', style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
        ),
      );
    }

    final totalDuration = state.totalDuration.inSeconds.toDouble();

    // Compute pacing score dynamically based on chapter balance
    double avgDuration = totalDuration / state.chapters.length;
    double variance = state.chapters.fold(0.0, (sum, ch) {
      final d = ch.endTime - ch.startTime;
      return sum + (d - avgDuration) * (d - avgDuration);
    }) / state.chapters.length;
    double stdDev = variance > 0 ? _sqrt(variance) : 0;
    double balanceScore = (1.0 - (stdDev / (avgDuration + 1))).clamp(0.0, 1.0);
    double pacingScore = 5.0 + balanceScore * 4.5; // Range: 5.0 - 9.5

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Pacing Analysis', icon: PhosphorIconsRegular.chartBar),
        const SizedBox(height: 12),

        // Pacing visualization
        ...state.chapters.map((ch) {
          final normalizedDuration = totalDuration > 0 ? (ch.endTime - ch.startTime) / totalDuration : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: ch.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Text('${ch.number}', style: GoogleFonts.inter(color: ch.color, fontSize: 8, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(ch.title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 10)),
                    ),
                    Text(
                      _formatDuration(Duration(milliseconds: ((ch.endTime - ch.startTime) * 1000).round())),
                      style: GoogleFonts.inter(color: _textMuted, fontSize: 9),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: normalizedDuration.clamp(0.0, 1.0).toDouble(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ch.color.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),
        _SectionHeader(title: 'Pacing Score', icon: PhosphorIconsRegular.star),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(pacingScore.toStringAsFixed(1), style: GoogleFonts.inter(color: _successColor, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pacingScore >= 7 ? 'Good pacing' : 'Needs improvement',
                      style: GoogleFonts.inter(color: _textPrimary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Based on ${state.chapters.length} chapters',
                      style: GoogleFonts.inter(color: _textMuted, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}

class _TransitionsPanel extends StatelessWidget {
  final LongFormEditorState state;

  const _TransitionsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.transitions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No transitions configured', style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Chapter Transitions', icon: PhosphorIconsRegular.arrowsLeftRight),
        const SizedBox(height: 12),
        ...state.transitions.map((t) {
          final from = state.chapters.firstWhere((c) => c.number == t.fromChapter, orElse: () => state.chapters.first);
          final to = state.chapters.firstWhere((c) => c.number == t.toChapter, orElse: () => state.chapters.first);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: from.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Ch.${t.fromChapter}', style: GoogleFonts.inter(color: from.color, fontSize: 9, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 4),
                    Icon(PhosphorIconsRegular.arrowRight, size: 10, color: _textMuted),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: to.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Ch.${t.toChapter}', style: GoogleFonts.inter(color: to.color, fontSize: 9, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text('${t.duration}s', style: GoogleFonts.inter(color: _textMuted, fontSize: 9)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(PhosphorIconsRegular.arrowsClockwise, size: 12, color: _accentColor),
                    const SizedBox(width: 6),
                    Text(t.type, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11)),
                    const Spacer(),
                    Icon(PhosphorIconsRegular.gearSix, size: 12, color: _textMuted),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _CommentaryPanel extends StatelessWidget {
  final LongFormEditorState state;
  final WidgetRef ref;

  const _CommentaryPanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (state.chapters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No chapters loaded', style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Chapter Commentary', icon: PhosphorIconsRegular.microphone),
        const SizedBox(height: 12),
        ...state.chapters.asMap().entries.map((e) {
          final ch = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ch.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text('${ch.number}', style: GoogleFonts.inter(color: ch.color, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(ch.title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    maxLines: 2,
                    controller: TextEditingController(text: ch.commentary),
                    style: GoogleFonts.inter(color: _textPrimary, fontSize: 10),
                    decoration: InputDecoration(
                      hintText: 'Add commentary for this chapter...',
                      hintStyle: GoogleFonts.inter(color: _textMuted, fontSize: 10),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => ref.read(longFormEditorProvider.notifier).updateCommentary(e.key, v),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ExportPanel extends StatelessWidget {
  final WidgetRef ref;

  const _ExportPanel({required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Export Settings', icon: PhosphorIconsRegular.export),
        const SizedBox(height: 12),

        _ExportOption(label: 'Format', value: 'MP4 (H.264)'),
        _ExportOption(label: 'Resolution', value: '1920×1080'),
        _ExportOption(label: 'Frame Rate', value: '30 fps'),
        _ExportOption(label: 'Bitrate', value: '12 Mbps'),

        const SizedBox(height: 16),
        _SectionHeader(title: 'Destination', icon: PhosphorIconsRegular.shareNetwork),
        const SizedBox(height: 12),

        _ExportDestination(
          label: 'YouTube',
          icon: PhosphorIconsRegular.youtubeLogo,
          color: _errorColor,
          onTap: () => ref.read(longFormEditorProvider.notifier).exportTo('YouTube'),
        ),
        _ExportDestination(
          label: 'Download File',
          icon: PhosphorIconsRegular.downloadSimple,
          color: _accentColor,
          onTap: () => ref.read(longFormEditorProvider.notifier).exportTo('Download'),
        ),
        _ExportDestination(
          label: 'Share Link',
          icon: PhosphorIconsRegular.link,
          color: _successColor,
          onTap: () => ref.read(longFormEditorProvider.notifier).exportTo('Share'),
        ),

        const SizedBox(height: 16),
        // Export button
        GestureDetector(
          onTap: () => ref.read(longFormEditorProvider.notifier).exportTo('YouTube'),
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_accentColor, _purpleColor]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(PhosphorIconsRegular.youtubeLogo, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Export as YouTube Video', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _accentColor),
        const SizedBox(width: 6),
        Text(title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ExportOption extends StatelessWidget {
  final String label;
  final String value;

  const _ExportOption({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Text(label, style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
            const Spacer(),
            Text(value, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11)),
            const SizedBox(width: 4),
            Icon(PhosphorIconsRegular.caretDown, size: 10, color: _textMuted),
          ],
        ),
      ),
    );
  }
}

class _ExportDestination extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ExportDestination({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12)),
            const Spacer(),
            Icon(PhosphorIconsRegular.caretRight, size: 12, color: _textMuted),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String _formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _formatDurationDouble(double seconds) {
  final mins = (seconds / 60).floor();
  final secs = (seconds % 60).floor();
  return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
