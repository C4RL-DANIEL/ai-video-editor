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

// ─── Editor State ────────────────────────────────────────────────────────────
class EditorState {
  final String projectName;
  final bool leftPanelOpen;
  final bool rightPanelOpen;
  final bool aiChatOpen;
  final double zoom;
  final Duration currentTime;
  final Duration totalDuration;
  final bool isPlaying;
  final int selectedTrack;
  final List<TimelineTrack> tracks;

  EditorState({
    this.projectName = 'Untitled Project',
    this.leftPanelOpen = true,
    this.rightPanelOpen = true,
    this.aiChatOpen = false,
    this.zoom = 1.0,
    this.currentTime = Duration.zero,
    this.totalDuration = const Duration(minutes: 5, seconds: 30),
    this.isPlaying = false,
    this.selectedTrack = 0,
    List<TimelineTrack>? tracks,
  }) : tracks = tracks ?? _defaultTracks;

  static List<TimelineTrack> get _defaultTracks => [
    TimelineTrack(
      name: 'Video',
      icon: PhosphorIcons.videoCamera,
      color: _accentColor,
      clips: [
        TimelineClip(id: 'v1', name: 'Intro', start: 0, duration: 120, color: _accentColor),
        TimelineClip(id: 'v2', name: 'Main', start: 120, duration: 180, color: _accentColor.withOpacity(0.8)),
        TimelineClip(id: 'v3', name: 'Outro', start: 300, duration: 30, color: _accentColor.withOpacity(0.6)),
      ],
    ),
    TimelineTrack(
      name: 'Commentary',
      icon: PhosphorIcons.microphone,
      color: _purpleColor,
      clips: [
        TimelineClip(id: 'c1', name: 'Intro VO', start: 10, duration: 100, color: _purpleColor),
        TimelineClip(id: 'c2', name: 'Main VO', start: 130, duration: 160, color: _purpleColor.withOpacity(0.8)),
      ],
    ),
    TimelineTrack(
      name: 'Music',
      icon: PhosphorIcons.musicNote,
      color: _successColor,
      clips: [
        TimelineClip(id: 'm1', name: 'Background', start: 0, duration: 300, color: _successColor.withOpacity(0.6)),
      ],
    ),
    TimelineTrack(
      name: 'SFX',
      icon: PhosphorIcons.speakerHigh,
      color: _warningColor,
      clips: [
        TimelineClip(id: 's1', name: 'Whoosh', start: 55, duration: 5, color: _warningColor),
        TimelineClip(id: 's2', name: 'Impact', start: 120, duration: 3, color: _warningColor.withOpacity(0.8)),
      ],
    ),
    TimelineTrack(
      name: 'Captions',
      icon: PhosphorIcons.subtitles,
      color: const Color(0xFF06B6D4),
      clips: [
        TimelineClip(id: 'cp1', name: 'Caption 1', start: 10, duration: 90, color: const Color(0xFF06B6D4)),
        TimelineClip(id: 'cp2', name: 'Caption 2', start: 130, duration: 150, color: const Color(0xFF06B6D4).withOpacity(0.8)),
      ],
    ),
    TimelineTrack(
      name: 'Effects',
      icon: PhosphorIcons.sparkle,
      color: const Color(0xFFF472B6),
      clips: [
        TimelineClip(id: 'e1', name: 'Zoom In', start: 50, duration: 10, color: const Color(0xFFF472B6)),
      ],
    ),
  ];

  EditorState copyWith({
    String? projectName,
    bool? leftPanelOpen,
    bool? rightPanelOpen,
    bool? aiChatOpen,
    double? zoom,
    Duration? currentTime,
    Duration? totalDuration,
    bool? isPlaying,
    int? selectedTrack,
    List<TimelineTrack>? tracks,
  }) {
    return EditorState(
      projectName: projectName ?? this.projectName,
      leftPanelOpen: leftPanelOpen ?? this.leftPanelOpen,
      rightPanelOpen: rightPanelOpen ?? this.rightPanelOpen,
      aiChatOpen: aiChatOpen ?? this.aiChatOpen,
      zoom: zoom ?? this.zoom,
      currentTime: currentTime ?? this.currentTime,
      totalDuration: totalDuration ?? this.totalDuration,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      tracks: tracks ?? this.tracks,
    );
  }
}

class TimelineTrack {
  final String name;
  final IconData icon;
  final Color color;
  final List<TimelineClip> clips;
  final bool visible;
  final bool locked;
  final bool muted;

  TimelineTrack({
    required this.name,
    required this.icon,
    required this.color,
    required this.clips,
    this.visible = true,
    this.locked = false,
    this.muted = false,
  });

  TimelineTrack copyWith({bool? visible, bool? locked, bool? muted, List<TimelineClip>? clips}) {
    return TimelineTrack(
      name: name,
      icon: icon,
      color: color,
      clips: clips ?? this.clips,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      muted: muted ?? this.muted,
    );
  }
}

class TimelineClip {
  final String id;
  final String name;
  final double start; // in seconds
  final double duration; // in seconds
  final Color color;

  TimelineClip({
    required this.id,
    required this.name,
    required this.start,
    required this.duration,
    required this.color,
  });
}

// ─── Editor State Provider ───────────────────────────────────────────────────
final editorStateProvider = StateNotifierProvider<EditorNotifier, EditorState>((ref) => EditorNotifier());

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier() : super(EditorState());

  void toggleLeftPanel() => state = state.copyWith(leftPanelOpen: !state.leftPanelOpen);
  void toggleRightPanel() => state = state.copyWith(rightPanelOpen: !state.rightPanelOpen);
  void toggleAiChat() => state = state.copyWith(aiChatOpen: !state.aiChatOpen);
  void setZoom(double zoom) => state = state.copyWith(zoom: zoom.clamp(0.25, 4.0));
  void setCurrentTime(Duration time) => state = state.copyWith(currentTime: time);
  void togglePlay() => state = state.copyWith(isPlaying: !state.isPlaying);
  void selectTrack(int index) => state = state.copyWith(selectedTrack: index);

  void toggleTrackVisibility(int index) {
    final tracks = List<TimelineTrack>.from(state.tracks);
    tracks[index] = tracks[index].copyWith(visible: !tracks[index].visible);
    state = state.copyWith(tracks: tracks);
  }

  void toggleTrackLock(int index) {
    final tracks = List<TimelineTrack>.from(state.tracks);
    tracks[index] = tracks[index].copyWith(locked: !tracks[index].locked);
    state = state.copyWith(tracks: tracks);
  }

  void toggleTrackMute(int index) {
    final tracks = List<TimelineTrack>.from(state.tracks);
    tracks[index] = tracks[index].copyWith(muted: !tracks[index].muted);
    state = state.copyWith(tracks: tracks);
  }
}

// ─── AI Chat Provider ────────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

final aiChatProvider = StateNotifierProvider<AIChatNotifier, List<ChatMessage>>((ref) => AIChatNotifier());

class AIChatNotifier extends StateNotifier<List<ChatMessage>> {
  AIChatNotifier() : super([
    ChatMessage(
      text: "Hey! I'm your AI editing assistant. Try commands like \"Make it funnier\", \"Add dramatic music\", or \"Speed up the intro\".",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ]);

  void sendMessage(String text) {
    state = [
      ...state,
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    ];
    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      state = [
        ...state,
        ChatMessage(
          text: _generateResponse(text),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    });
  }

  String _generateResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('funnier') || lower.contains('funny')) {
      return "I'll analyze the comedic timing and suggest punch-up edits. I've identified 3 moments where quick cuts and sound effects could boost humor. Want me to apply them?";
    } else if (lower.contains('music') || lower.contains('dramatic')) {
      return "I've found 5 dramatic music tracks that match the mood. The \"Epic Reveal\" track fits perfectly at 02:15. Shall I add it?";
    } else if (lower.contains('speed') || lower.contains('fast')) {
      return "I can speed up the intro by 1.5x without losing key context. This would save about 8 seconds. Apply changes?";
    } else if (lower.contains('caption') || lower.contains('text')) {
      return "I'll update the caption style across all segments. Current: Bold white with shadow. Suggested: Animated gradient with motion tracking. Preview it?";
    }
    return "I understand you want to: \"$input\". Let me analyze the timeline and suggest the best approach. This may involve adjusting 2-3 clips. Shall I proceed?";
  }
}

// ─── Editor Page ─────────────────────────────────────────────────────────────
class EditorPage extends ConsumerWidget {
  const EditorPage({super.key, this.projectId});
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorStateProvider);
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
                // Left Panel
                if (state.leftPanelOpen && !isCompact)
                  _LeftPanel(state: state, ref: ref),

                // Center Area
                Expanded(
                  child: Column(
                    children: [
                      // Video Preview
                      Expanded(
                        child: _VideoPreviewArea(state: state),
                      ),

                      // AI Chat Sidebar (overlay)
                      if (state.aiChatOpen)
                        _AiChatPanel(ref: ref),

                      // Timeline
                      _TimelineArea(state: state, ref: ref),
                    ],
                  ),
                ),

                // Right Panel
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
  final EditorState state;
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
          // Menu
          IconButton(
            icon: const Icon(PhosphorIcons.list, size: 18),
            color: _textSecondary,
            onPressed: () {},
            tooltip: 'Menu',
          ),
          const SizedBox(width: 4),

          // Project Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderColor),
            ),
            child: Text(
              state.projectName,
              style: GoogleFonts.inter(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),

          // Undo / Redo
          _ToolBarButton(icon: PhosphorIcons.arrowUUpLeft, tooltip: 'Undo', onTap: () {}),
          _ToolBarButton(icon: PhosphorIcons.arrowUUpRight, tooltip: 'Redo', onTap: () {}),
          const SizedBox(width: 8),
          const _ToolBarDivider(),

          // Zoom Controls
          _ToolBarButton(icon: PhosphorIcons.magnifyingGlassMinus, tooltip: 'Zoom Out', onTap: () {
            ref.read(editorStateProvider.notifier).setZoom(state.zoom - 0.25);
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '${(state.zoom * 100).toInt()}%',
              style: GoogleFonts.inter(color: _textSecondary, fontSize: 11),
            ),
          ),
          _ToolBarButton(icon: PhosphorIcons.magnifyingGlassPlus, tooltip: 'Zoom In', onTap: () {
            ref.read(editorStateProvider.notifier).setZoom(state.zoom + 0.25);
          }),
          const SizedBox(width: 8),
          const _ToolBarDivider(),

          Spacer(),

          // AI Chat Toggle
          _ToolBarButton(
            icon: PhosphorIcons.chatsCircle,
            tooltip: 'AI Assistant',
            onTap: () => ref.read(editorStateProvider.notifier).toggleAiChat(),
            isActive: state.aiChatOpen,
          ),
          const SizedBox(width: 8),

          // Save
          _ToolBarButton(icon: PhosphorIcons.floppyDisk, tooltip: 'Save', onTap: () {}),
          const SizedBox(width: 4),

          // Export
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_accentColor, _purpleColor]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(PhosphorIcons.export, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text('Export', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _ToolBarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

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
          child: Icon(
            icon,
            size: 16,
            color: isActive ? _accentColor : _textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ToolBarDivider extends StatelessWidget {
  const _ToolBarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 20, color: _borderColor);
  }
}

// ─── Left Panel ──────────────────────────────────────────────────────────────
class _LeftPanel extends StatelessWidget {
  final EditorState state;
  final WidgetRef ref;

  const _LeftPanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(right: BorderSide(color: _borderColor)),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // Tab Bar
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _borderColor)),
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: _accentColor,
                unselectedLabelColor: _textMuted,
                labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
                indicatorColor: _accentColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'AI'),
                  Tab(text: 'Content'),
                  Tab(text: 'Moments'),
                  Tab(text: 'Assets'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _AiAnalysisPanel(),
                  _ContentMapTree(),
                  _ViralMomentsList(),
                  _AssetBrowser(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiAnalysisPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'AI Analysis', icon: PhosphorIcons.brain),
        const SizedBox(height: 12),
        _AnalysisCard(
          title: 'Overall Score',
          value: '87/100',
          color: _successColor,
          icon: PhosphorIcons.star,
        ),
        const SizedBox(height: 8),
        _AnalysisCard(
          title: 'Engagement',
          value: 'High',
          color: _accentColor,
          icon: PhosphorIcons.chartLineUp,
        ),
        const SizedBox(height: 8),
        _AnalysisCard(
          title: 'Pacing',
          value: 'Good',
          color: _warningColor,
          icon: PhosphorIcons.gauge,
        ),
        const SizedBox(height: 8),
        _AnalysisCard(
          title: 'Hook Strength',
          value: 'Strong',
          color: _purpleColor,
          icon: PhosphorIcons.fishHook,
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Suggestions', icon: PhosphorIcons.lightbulb),
        const SizedBox(height: 8),
        _SuggestionItem(text: 'Add hook text in first 2 seconds'),
        _SuggestionItem(text: 'Tighten pacing at 01:23 - 01:45'),
        _SuggestionItem(text: 'Add dramatic music at climax'),
        _SuggestionItem(text: 'Caption font could be larger'),
      ],
    );
  }
}

class _ContentMapTree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Content Map', icon: PhosphorIcons.mapTrifold),
        const SizedBox(height: 12),
        _TreeNode(label: 'Scene 1: Opening', depth: 0, clipCount: 3, duration: '00:45'),
        _TreeNode(label: 'Interview Clip', depth: 1, clipCount: 1, duration: '00:30'),
        _TreeNode(label: 'B-Roll: City', depth: 1, clipCount: 2, duration: '00:15'),
        _TreeNode(label: 'Scene 2: Main Story', depth: 0, clipCount: 5, duration: '02:15'),
        _TreeNode(label: 'Key Moment', depth: 1, clipCount: 1, duration: '00:45'),
        _TreeNode(label: 'Reaction Shots', depth: 1, clipCount: 3, duration: '00:30'),
        _TreeNode(label: 'Scene 3: Conclusion', depth: 0, clipCount: 2, duration: '01:00'),
        _TreeNode(label: 'Outro', depth: 0, clipCount: 1, duration: '00:30'),
      ],
    );
  }
}

class _ViralMomentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Viral Moments', icon: PhosphorIcons.fire),
        const SizedBox(height: 12),
        _ViralMomentCard(time: '00:15', title: 'Unexpected reaction', score: 95, type: 'Comedy'),
        _ViralMomentCard(time: '01:23', title: 'Key reveal moment', score: 92, type: 'Dramatic'),
        _ViralMomentCard(time: '02:45', title: 'Funny dialogue', score: 88, type: 'Comedy'),
        _ViralMomentCard(time: '03:10', title: 'Emotional peak', score: 85, type: 'Emotional'),
        _ViralMomentCard(time: '04:20', title: 'Surprise ending', score: 90, type: 'Surprise'),
      ],
    );
  }
}

class _AssetBrowser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Assets', icon: PhosphorIcons.folderOpen),
        const SizedBox(height: 12),
        _AssetCategory(
          icon: PhosphorIcons.microphone,
          label: 'Commentary',
          count: 12,
          color: _purpleColor,
        ),
        _AssetCategory(
          icon: PhosphorIcons.speakerHigh,
          label: 'Sound Effects',
          count: 48,
          color: _warningColor,
        ),
        _AssetCategory(
          icon: PhosphorIcons.musicNote,
          label: 'Music',
          count: 24,
          color: _successColor,
        ),
        _AssetCategory(
          icon: PhosphorIcons.subtitles,
          label: 'Caption Styles',
          count: 8,
          color: const Color(0xFF06B6D4),
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Recent', icon: PhosphorIcons.clock),
        const SizedBox(height: 8),
        _AssetItem(name: 'dramatic_sting.mp3', type: 'SFX'),
        _AssetItem(name: 'bgm_epic.mp3', type: 'Music'),
        _AssetItem(name: 'narration_v2.wav', type: 'Voice'),
      ],
    );
  }
}

// ─── Video Preview Area ──────────────────────────────────────────────────────
class _VideoPreviewArea extends StatelessWidget {
  final EditorState state;

  const _VideoPreviewArea({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Placeholder (16:9)
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
                  // Placeholder
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIcons.filmSlate, size: 48, color: _textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Video Preview',
                        style: GoogleFonts.inter(color: _textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '16:9 • ${_formatDuration(state.currentTime)}',
                        style: GoogleFonts.inter(color: _textMuted, fontSize: 11),
                      ),
                    ],
                  ),

                  // Caption Overlay
                  Positioned(
                    bottom: 60,
                    left: 40,
                    right: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Caption overlay appears here',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playback Controls Overlay (bottom)
          Positioned(
            bottom: 12,
            left: 24,
            right: 24,
            child: _PlaybackControls(state: state),
          ),
        ],
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  final EditorState state;

  const _PlaybackControls({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(PhosphorIcons.skipBack, size: 16),
          color: _textSecondary,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            state.isPlaying ? PhosphorIcons.pause : PhosphorIcons.play,
            size: 20,
          ),
          color: Colors.white,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(PhosphorIcons.skipForward, size: 16),
          color: _textSecondary,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Text(
          _formatDuration(state.currentTime),
          style: GoogleFonts.inter(color: _textPrimary, fontSize: 11, fontFeatures: [const FontFeature.tabularFigures()]),
        ),
        Text(
          ' / ${_formatDuration(state.totalDuration)}',
          style: GoogleFonts.inter(color: _textMuted, fontSize: 11, fontFeatures: [const FontFeature.tabularFigures()]),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(PhosphorIcons.captions, size: 16),
          color: _textSecondary,
          onPressed: () {},
          tooltip: 'Captions',
        ),
        IconButton(
          icon: const Icon(PhosphorIcons.speakerHigh, size: 16),
          color: _textSecondary,
          onPressed: () {},
          tooltip: 'Audio',
        ),
        IconButton(
          icon: const Icon(PhosphorIcons.arrowsOutSimple, size: 16),
          color: _textSecondary,
          onPressed: () {},
          tooltip: 'Fullscreen',
        ),
      ],
    );
  }
}

// ─── AI Chat Panel ───────────────────────────────────────────────────────────
class _AiChatPanel extends ConsumerWidget {
  final WidgetRef ref;

  const _AiChatPanel({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(aiChatProvider);

    return Container(
      height: 250,
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _borderColor)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.brain, size: 14, color: _purpleColor),
                const SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                _QuickCommandButton(label: 'Make funnier', onTap: () {
                  ref.read(aiChatProvider.notifier).sendMessage('Make it funnier');
                }),
                const SizedBox(width: 6),
                _QuickCommandButton(label: 'Add music', onTap: () {
                  ref.read(aiChatProvider.notifier).sendMessage('Add dramatic music');
                }),
                const SizedBox(width: 6),
                _QuickCommandButton(label: 'Speed up', onTap: () {
                  ref.read(aiChatProvider.notifier).sendMessage('Speed up the intro');
                }),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: _purpleColor.withOpacity(0.2),
                          child: Icon(PhosphorIcons.robot, size: 12, color: _purpleColor),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: msg.isUser ? _accentColor : _cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: msg.isUser ? Colors.transparent : _borderColor),
                          ),
                          child: Text(
                            msg.text,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _borderColor),
                    ),
                    child: TextField(
                      style: GoogleFonts.inter(color: _textPrimary, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Ask AI to edit... (e.g., "Make it funnier")',
                        hintStyle: GoogleFonts.inter(color: _textMuted, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          ref.read(aiChatProvider.notifier).sendMessage(value.trim());
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_accentColor, _purpleColor]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(PhosphorIcons.paperPlaneRight, size: 14, color: Colors.white),
                    onPressed: () {},
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

class _QuickCommandButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickCommandButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(color: _textSecondary, fontSize: 10),
        ),
      ),
    );
  }
}

// ─── Right Panel ─────────────────────────────────────────────────────────────
class _RightPanel extends StatelessWidget {
  final EditorState state;
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
                labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
                indicatorColor: _accentColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Properties'),
                  Tab(text: 'Edit Info'),
                  Tab(text: 'AI Decisions'),
                  Tab(text: 'Style'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PropertiesPanel(),
                  _EditDecisionPanel(),
                  _AiDecisionsPanel(),
                  _StyleSettingsPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertiesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Clip Properties', icon: PhosphorIcons.slidersHorizontal),
        const SizedBox(height: 12),
        _PropertyRow(label: 'Duration', value: '00:04:30'),
        _PropertyRow(label: 'Resolution', value: '1920×1080'),
        _PropertyRow(label: 'Frame Rate', value: '30 fps'),
        _PropertyRow(label: 'Codec', value: 'H.264'),
        _PropertyRow(label: 'Bitrate', value: '12 Mbps'),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Transform', icon: PhosphorIcons.crop),
        const SizedBox(height: 12),
        _SliderRow(label: 'Scale', value: 1.0, min: 0.1, max: 3.0),
        _SliderRow(label: 'Rotation', value: 0, min: -180, max: 180),
        _SliderRow(label: 'Opacity', value: 1.0, min: 0, max: 1),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Speed', icon: PhosphorIcons.gauge),
        const SizedBox(height: 12),
        _SliderRow(label: 'Playback Speed', value: 1.0, min: 0.25, max: 4.0),
      ],
    );
  }
}

class _EditDecisionPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Edit Decisions', icon: PhosphorIcons.scissors),
        const SizedBox(height: 12),
        _DecisionCard(
          time: '00:15',
          decision: 'Hard cut to reaction',
          reason: 'Peak emotional moment detected',
          confidence: 0.92,
        ),
        _DecisionCard(
          time: '01:23',
          decision: 'J-cut transition',
          reason: 'Audio leads video for smoother flow',
          confidence: 0.87,
        ),
        _DecisionCard(
          time: '02:45',
          decision: 'Speed ramp 2x → 1x',
          reason: 'Emphasis on key reveal',
          confidence: 0.95,
        ),
      ],
    );
  }
}

class _AiDecisionsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'AI Decisions', icon: PhosphorIcons.brain),
        const SizedBox(height: 12),
        _AiDecisionCard(
          title: 'Hook Placement',
          decision: 'Selected: 00:03 opening reaction',
          explanation: 'This clip shows a genuine surprise reaction that creates curiosity. High retention potential based on similar content patterns.',
          confidence: 0.94,
        ),
        _AiDecisionCard(
          title: 'Pacing Adjustment',
          decision: 'Removed: 01:45-02:10',
          explanation: 'This segment had low engagement indicators. Removing it tightens the narrative without losing key context.',
          confidence: 0.88,
        ),
        _AiDecisionCard(
          title: 'Music Selection',
          decision: 'Applied: "Tension Build" track',
          explanation: 'Matches the emotional arc of the story. Rising intensity aligns with narrative escalation at 02:30.',
          confidence: 0.91,
        ),
      ],
    );
  }
}

class _StyleSettingsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Caption Style', icon: PhosphorIcons.subtitles),
        const SizedBox(height: 12),
        _StyleOption(label: 'Font', value: 'Montserrat Bold'),
        _StyleOption(label: 'Size', value: 'Large'),
        _StyleOption(label: 'Color', value: 'White'),
        _StyleOption(label: 'Background', value: 'Shadow'),
        _StyleOption(label: 'Animation', value: 'Word-by-word'),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Color Grade', icon: PhosphorIcons.palette),
        const SizedBox(height: 12),
        _StyleOption(label: 'Preset', value: 'Cinematic Warm'),
        _SliderRow(label: 'Saturation', value: 1.1, min: 0, max: 2),
        _SliderRow(label: 'Contrast', value: 1.05, min: 0, max: 2),
        _SliderRow(label: 'Brightness', value: 0, min: -1, max: 1),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Transitions', icon: PhosphorIcons.arrowsLeftRight),
        const SizedBox(height: 12),
        _StyleOption(label: 'Default', value: 'Cross Dissolve'),
        _StyleOption(label: 'Duration', value: '0.5s'),
      ],
    );
  }
}

// ─── Timeline Area ───────────────────────────────────────────────────────────
class _TimelineArea extends StatefulWidget {
  final EditorState state;
  final WidgetRef ref;

  const _TimelineArea({required this.state, required this.ref});

  @override
  State<_TimelineArea> createState() => _TimelineAreaState();
}

class _TimelineAreaState extends State<_TimelineArea> {
  final ScrollController _scrollController = ScrollController();
  double _trackHeight = 48.0;
  static const double _rulerHeight = 28.0;
  static const double _trackHeaderWidth = 120.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          // Timeline Header
          _TimelineHeader(state: widget.state, ref: widget.ref),

          // Timeline Content
          Expanded(
            child: Row(
              children: [
                // Track Headers
                SizedBox(
                  width: _trackHeaderWidth,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: _rulerHeight),
                    itemCount: widget.state.tracks.length,
                    itemBuilder: (context, index) => _TrackHeader(
                      track: widget.state.tracks[index],
                      index: index,
                      height: _trackHeight,
                      isSelected: widget.state.selectedTrack == index,
                      onToggleVisibility: () => widget.ref.read(editorStateProvider.notifier).toggleTrackVisibility(index),
                      onToggleLock: () => widget.ref.read(editorStateProvider.notifier).toggleTrackLock(index),
                      onToggleMute: () => widget.ref.read(editorStateProvider.notifier).toggleTrackMute(index),
                      onSelect: () => widget.ref.read(editorStateProvider.notifier).selectTrack(index),
                    ),
                  ),
                ),

                // Timeline Ruler + Tracks
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 800 * widget.state.zoom,
                      child: Column(
                        children: [
                          // Ruler
                          _TimelineRuler(
                            height: _rulerHeight,
                            totalSeconds: widget.state.totalDuration.inSeconds.toDouble(),
                            zoom: widget.state.zoom,
                          ),

                          // Tracks
                          Expanded(
                            child: Stack(
                              children: [
                                // Track backgrounds
                                ...List.generate(widget.state.tracks.length, (index) {
                                  return Positioned(
                                    top: index * _trackHeight,
                                    left: 0,
                                    right: 0,
                                    height: _trackHeight,
                                    child: _TimelineTrackRow(
                                      track: widget.state.tracks[index],
                                      index: index,
                                      totalSeconds: widget.state.totalDuration.inSeconds.toDouble(),
                                      zoom: widget.state.zoom,
                                      trackHeight: _trackHeight,
                                    ),
                                  );
                                }),

                                // Playhead
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: _getPlayheadPosition(
                                    widget.state.currentTime.inSeconds.toDouble(),
                                    widget.state.zoom,
                                  ),
                                  child: Container(
                                    width: 2,
                                    color: _playheadColor,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          top: -4,
                                          left: -5,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: _playheadColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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

  double _getPlayheadPosition(double currentSeconds, double zoom) {
    return (currentSeconds / (800 * zoom / 800)) * 100 * zoom;
  }
}

class _TimelineHeader extends StatelessWidget {
  final EditorState state;
  final WidgetRef ref;

  const _TimelineHeader({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.filmStrip, size: 14, color: _textSecondary),
          const SizedBox(width: 6),
          Text('Timeline', style: GoogleFonts.inter(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          const Spacer(),
          // Zoom slider
          Icon(PhosphorIcons.magnifyingGlassMinus, size: 12, color: _textMuted),
          SizedBox(
            width: 80,
            child: Slider(
              value: state.zoom,
              min: 0.25,
              max: 4.0,
              onChanged: (v) => ref.read(editorStateProvider.notifier).setZoom(v),
              activeColor: _accentColor,
              inactiveColor: _borderColor,
            ),
          ),
          Icon(PhosphorIcons.magnifyingGlassPlus, size: 12, color: _textMuted),
          const SizedBox(width: 12),
          _ToolBarButton(icon: PhosphorIcons.plus, tooltip: 'Add Track', onTap: () {}),
          _ToolBarButton(icon: PhosphorIcons.trash, tooltip: 'Delete Selected', onTap: () {}),
        ],
      ),
    );
  }
}

class _TimelineRuler extends StatelessWidget {
  final double height;
  final double totalSeconds;
  final double zoom;

  const _TimelineRuler({required this.height, required this.totalSeconds, required this.zoom});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: _surfaceColor,
      child: CustomPaint(
        painter: _RulerPainter(totalSeconds: totalSeconds, zoom: zoom),
        size: Size(double.infinity, height),
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
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final pixelsPerSecond = (800 * zoom) / totalSeconds;
    final majorInterval = _getMajorInterval(zoom);
    final minorInterval = majorInterval / 4;

    for (double t = 0; t <= totalSeconds; t += minorInterval) {
      final x = t * pixelsPerSecond;
      if (x > size.width) break;

      final isMajor = (t % majorInterval).abs() < 0.01;
      paint.color = isMajor ? _textMuted : _borderColor;

      final top = isMajor ? 0.0 : size.height * 0.5;
      canvas.drawLine(Offset(x, top), Offset(x, size.height), paint);

      if (isMajor) {
        final minutes = (t / 60).floor();
        final seconds = (t % 60).floor();
        final label = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        textPainter.text = TextSpan(
          text: label,
          style: const TextStyle(color: _textMuted, fontSize: 9),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 3, 2));
      }
    }
  }

  double _getMajorInterval(double zoom) {
    if (zoom >= 2.0) return 5;
    if (zoom >= 1.0) return 10;
    if (zoom >= 0.5) return 30;
    return 60;
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) => oldDelegate.zoom != zoom;
}

class _TrackHeader extends StatelessWidget {
  final TimelineTrack track;
  final int index;
  final double height;
  final bool isSelected;
  final VoidCallback onToggleVisibility;
  final VoidCallback onToggleLock;
  final VoidCallback onToggleMute;
  final VoidCallback onSelect;

  const _TrackHeader({
    required this.track,
    required this.index,
    required this.height,
    required this.isSelected,
    required this.onToggleVisibility,
    required this.onToggleLock,
    required this.onToggleMute,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? track.color.withOpacity(0.08) : Colors.transparent,
          border: Border(
            bottom: const BorderSide(color: _borderColor),
            left: isSelected ? BorderSide(color: track.color, width: 2) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(track.icon, size: 12, color: track.color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                track.name,
                style: GoogleFonts.inter(
                  color: _textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _TrackControlButton(
              icon: track.visible ? PhosphorIcons.eye : PhosphorIcons.eyeSlash,
              onTap: onToggleVisibility,
              color: track.visible ? _textMuted : _errorColor,
              size: 10,
            ),
            _TrackControlButton(
              icon: track.locked ? PhosphorIcons.lockSimple : PhosphorIcons.lockSimpleOpen,
              onTap: onToggleLock,
              color: track.locked ? _warningColor : _textMuted,
              size: 10,
            ),
            if (track.name == 'Music' || track.name == 'SFX' || track.name == 'Commentary')
              _TrackControlButton(
                icon: track.muted ? PhosphorIcons.speakerSlash : PhosphorIcons.speakerHigh,
                onTap: onToggleMute,
                color: track.muted ? _errorColor : _textMuted,
                size: 10,
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _TrackControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}

class _TimelineTrackRow extends StatelessWidget {
  final TimelineTrack track;
  final int index;
  final double totalSeconds;
  final double zoom;
  final double trackHeight;

  const _TimelineTrackRow({
    required this.track,
    required this.index,
    required this.totalSeconds,
    required this.zoom,
    required this.trackHeight,
  });

  @override
  Widget build(BuildContext context) {
    final pixelsPerSecond = (800 * zoom) / totalSeconds;

    return Container(
      height: trackHeight,
      decoration: BoxDecoration(
        color: index % 2 == 0 ? _cardColor.withOpacity(0.3) : _cardColor.withOpacity(0.15),
        border: const Border(bottom: BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: track.visible
          ? Stack(
              children: track.clips.map((clip) {
                final left = clip.start * pixelsPerSecond;
                final width = clip.duration * pixelsPerSecond;
                return Positioned(
                  left: left,
                  top: 6,
                  bottom: 6,
                  width: width.clamp(4, double.infinity),
                  child: _TimelineClipWidget(clip: clip),
                );
              }).toList(),
            )
          : Center(
              child: Text(
                'Hidden',
                style: GoogleFonts.inter(color: _textMuted, fontSize: 9),
              ),
            ),
    );
  }
}

class _TimelineClipWidget extends StatelessWidget {
  final TimelineClip clip;

  const _TimelineClipWidget({required this.clip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: clip.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: clip.color.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Center(
        child: Text(
          clip.name,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ─── Right Panel ─────────────────────────────────────────────────────────────
class _RightPanelOld extends StatelessWidget {
  final EditorState state;
  final WidgetRef ref;

  const _RightPanelOld({required this.state, required this.ref});

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
                labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
                indicatorColor: _accentColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Properties'),
                  Tab(text: 'Edit Info'),
                  Tab(text: 'AI Decisions'),
                  Tab(text: 'Style'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PropertiesPanel(),
                  _EditDecisionPanel(),
                  _AiDecisionsPanel(),
                  _StyleSettingsPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
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
        Text(
          title,
          style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _AnalysisCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
              Text(value, style: GoogleFonts.inter(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final String text;

  const _SuggestionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.lightbulb, size: 12, color: _warningColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(color: _textSecondary, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _TreeNode extends StatelessWidget {
  final String label;
  final int depth;
  final int clipCount;
  final String duration;

  const _TreeNode({required this.label, required this.depth, required this.clipCount, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0 + depth * 16, top: 6, bottom: 6),
      child: Row(
        children: [
          if (depth > 0) ...[
            Icon(PhosphorIcons.caretRight, size: 10, color: _textMuted),
            const SizedBox(width: 4),
          ],
          Icon(depth > 0 ? PhosphorIcons.filmStrip : PhosphorIcons.scene, size: 12, color: _accentColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11)),
          ),
          Text('$clipCount clips', style: GoogleFonts.inter(color: _textMuted, fontSize: 9)),
          const SizedBox(width: 8),
          Text(duration, style: GoogleFonts.inter(color: _textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _ViralMomentCard extends StatelessWidget {
  final String time;
  final String title;
  final int score;
  final String type;

  const _ViralMomentCard({required this.time, required this.title, required this.score, required this.type});

  Color get _typeColor {
    switch (type) {
      case 'Comedy': return _warningColor;
      case 'Dramatic': return _errorColor;
      case 'Emotional': return _purpleColor;
      case 'Surprise': return _accentColor;
      default: return _textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: _errorColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(time, style: GoogleFonts.inter(color: _errorColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(type, style: GoogleFonts.inter(color: _typeColor, fontSize: 10)),
              ),
              const Spacer(),
              Icon(PhosphorIcons.fire, size: 12, color: _warningColor),
              const SizedBox(width: 4),
              Text('$score', style: GoogleFonts.inter(color: _warningColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AssetCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _AssetCategory({required this.icon, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
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
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _AssetItem extends StatelessWidget {
  final String name;
  final String type;

  const _AssetItem({required this.name, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.fileAudio, size: 12, color: _textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: GoogleFonts.inter(color: _textSecondary, fontSize: 10), overflow: TextOverflow.ellipsis)),
          Text(type, style: GoogleFonts.inter(color: _textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final String value;

  const _PropertyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
          const Spacer(),
          Text(value, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;

  const _SliderRow({required this.label, required this.value, required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
              const Spacer(),
              Text(value.toStringAsFixed(2), style: GoogleFonts.inter(color: _textSecondary, fontSize: 11)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: _accentColor,
              inactiveTrackColor: _borderColor,
              thumbColor: _accentColor,
              overlayColor: _accentColor.withOpacity(0.1),
            ),
            child: Slider(value: value, min: min, max: max, onChanged: null),
          ),
        ],
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  final String time;
  final String decision;
  final String reason;
  final double confidence;

  const _DecisionCard({required this.time, required this.decision, required this.reason, required this.confidence});

  @override
  Widget build(BuildContext context) {
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
                  color: _accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(time, style: GoogleFonts.inter(color: _accentColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text('${(confidence * 100).toInt()}%', style: GoogleFonts.inter(color: _successColor, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          Text(decision, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(reason, style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _AiDecisionCard extends StatelessWidget {
  final String title;
  final String decision;
  final String explanation;
  final double confidence;

  const _AiDecisionCard({required this.title, required this.decision, required this.explanation, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _purpleColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.brain, size: 12, color: _purpleColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${(confidence * 100).toInt()}%', style: GoogleFonts.inter(color: _successColor, fontSize: 9)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(decision, style: GoogleFonts.inter(color: _accentColor, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(explanation, style: GoogleFonts.inter(color: _textMuted, fontSize: 10, height: 1.4)),
        ],
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final String label;
  final String value;

  const _StyleOption({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            Icon(PhosphorIcons.caretDown, size: 10, color: _textMuted),
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
