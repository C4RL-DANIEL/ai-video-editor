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
const Color _textPrimary = Color(0xFFF5F5F7);
const Color _textSecondary = Color(0xFF9CA3AF);
const Color _textMuted = Color(0xFF6B7280);

// ─── Short Editor State ──────────────────────────────────────────────────────
class ShortEditorState {
  final String projectName;
  final bool showBeforeAfter;
  final bool isGenerating;
  final Duration currentTime;
  final Duration totalDuration;

  // Hook
  final String hookText;
  final double hookFontSize;

  // Captions
  final String captionStyle;
  final double captionSize;
  final String captionPosition;
  final String captionAnimation;
  final Color captionColor;
  final String captionFont;

  // Effects
  final double zoomIntensity;
  final double speedRamp;
  final bool freezeFrame;
  final bool enableShake;

  // Audio
  final double musicVolume;
  final double commentaryVolume;
  final double sfxVolume;
  final bool musicDucking;

  // Overrides
  final bool overrideHook;
  final bool overrideCaptions;
  final bool overridePacing;
  final bool overrideMusic;

  ShortEditorState({
    this.projectName = 'Short #1',
    this.showBeforeAfter = false,
    this.isGenerating = false,
    this.currentTime = Duration.zero,
    this.totalDuration = const Duration(seconds: 45),
    this.hookText = 'WAIT FOR IT... 😱',
    this.hookFontSize = 28,
    this.captionStyle = 'Bold Pop',
    this.captionSize = 22,
    this.captionPosition = 'Center',
    this.captionAnimation = 'Word-by-Word',
    this.captionColor = Colors.white,
    this.captionFont = 'Montserrat',
    this.zoomIntensity = 1.2,
    this.speedRamp = 1.5,
    this.freezeFrame = false,
    this.enableShake = true,
    this.musicVolume = 0.7,
    this.commentaryVolume = 1.0,
    this.sfxVolume = 0.8,
    this.musicDucking = true,
    this.overrideHook = false,
    this.overrideCaptions = false,
    this.overridePacing = false,
    this.overrideMusic = false,
  });

  ShortEditorState copyWith({
    String? projectName,
    bool? showBeforeAfter,
    bool? isGenerating,
    Duration? currentTime,
    Duration? totalDuration,
    String? hookText,
    double? hookFontSize,
    String? captionStyle,
    double? captionSize,
    String? captionPosition,
    String? captionAnimation,
    Color? captionColor,
    String? captionFont,
    double? zoomIntensity,
    double? speedRamp,
    bool? freezeFrame,
    bool? enableShake,
    double? musicVolume,
    double? commentaryVolume,
    double? sfxVolume,
    bool? musicDucking,
    bool? overrideHook,
    bool? overrideCaptions,
    bool? overridePacing,
    bool? overrideMusic,
  }) {
    return ShortEditorState(
      projectName: projectName ?? this.projectName,
      showBeforeAfter: showBeforeAfter ?? this.showBeforeAfter,
      isGenerating: isGenerating ?? this.isGenerating,
      currentTime: currentTime ?? this.currentTime,
      totalDuration: totalDuration ?? this.totalDuration,
      hookText: hookText ?? this.hookText,
      hookFontSize: hookFontSize ?? this.hookFontSize,
      captionStyle: captionStyle ?? this.captionStyle,
      captionSize: captionSize ?? this.captionSize,
      captionPosition: captionPosition ?? this.captionPosition,
      captionAnimation: captionAnimation ?? this.captionAnimation,
      captionColor: captionColor ?? this.captionColor,
      captionFont: captionFont ?? this.captionFont,
      zoomIntensity: zoomIntensity ?? this.zoomIntensity,
      speedRamp: speedRamp ?? this.speedRamp,
      freezeFrame: freezeFrame ?? this.freezeFrame,
      enableShake: enableShake ?? this.enableShake,
      musicVolume: musicVolume ?? this.musicVolume,
      commentaryVolume: commentaryVolume ?? this.commentaryVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicDucking: musicDucking ?? this.musicDucking,
      overrideHook: overrideHook ?? this.overrideHook,
      overrideCaptions: overrideCaptions ?? this.overrideCaptions,
      overridePacing: overridePacing ?? this.overridePacing,
      overrideMusic: overrideMusic ?? this.overrideMusic,
    );
  }
}

final shortEditorProvider = StateNotifierProvider<ShortEditorNotifier, ShortEditorState>(
  (ref) => ShortEditorNotifier(),
);

class ShortEditorNotifier extends StateNotifier<ShortEditorState> {
  ShortEditorNotifier() : super(ShortEditorState());

  void setHookText(String text) => state = state.copyWith(hookText: text);
  void setHookFontSize(double size) => state = state.copyWith(hookFontSize: size);
  void setCaptionStyle(String style) => state = state.copyWith(captionStyle: style);
  void setCaptionSize(double size) => state = state.copyWith(captionSize: size);
  void setCaptionPosition(String pos) => state = state.copyWith(captionPosition: pos);
  void setCaptionAnimation(String anim) => state = state.copyWith(captionAnimation: anim);
  void setCaptionFont(String font) => state = state.copyWith(captionFont: font);
  void setZoomIntensity(double v) => state = state.copyWith(zoomIntensity: v);
  void setSpeedRamp(double v) => state = state.copyWith(speedRamp: v);
  void toggleFreezeFrame() => state = state.copyWith(freezeFrame: !state.freezeFrame);
  void toggleShake() => state = state.copyWith(enableShake: !state.enableShake);
  void setMusicVolume(double v) => state = state.copyWith(musicVolume: v);
  void setCommentaryVolume(double v) => state = state.copyWith(commentaryVolume: v);
  void setSfxVolume(double v) => state = state.copyWith(sfxVolume: v);
  void toggleMusicDucking() => state = state.copyWith(musicDucking: !state.musicDucking);
  void toggleBeforeAfter() => state = state.copyWith(showBeforeAfter: !state.showBeforeAfter);
  void toggleOverrideHook() => state = state.copyWith(overrideHook: !state.overrideHook);
  void toggleOverrideCaptions() => state = state.copyWith(overrideCaptions: !state.overrideCaptions);
  void toggleOverridePacing() => state = state.copyWith(overridePacing: !state.overridePacing);
  void toggleOverrideMusic() => state = state.copyWith(overrideMusic: !state.overrideMusic);

  void regenerate() {
    state = state.copyWith(isGenerating: true);
    Future.delayed(const Duration(seconds: 3), () {
      state = state.copyWith(isGenerating: false);
    });
  }
}

// ─── Short Editor Page ───────────────────────────────────────────────────────
class ShortEditorPage extends ConsumerWidget {
  const ShortEditorPage({super.key, this.projectId, this.shortId});
  final String? projectId;
  final String? shortId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shortEditorProvider);
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 900;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 18),
          color: _textSecondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_accentColor, _purpleColor]),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('SHORT', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            Text(state.projectName, style: GoogleFonts.inter(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          // Before/After Toggle
          _AppBarButton(
            icon: PhosphorIconsRegular.arrowBendDoubleUpLeft,
            label: 'A/B',
            isActive: state.showBeforeAfter,
            onTap: () => ref.read(shortEditorProvider.notifier).toggleBeforeAfter(),
          ),
          const SizedBox(width: 8),

          // Regenerate
          _AppBarButton(
            icon: PhosphorIconsRegular.arrowsClockwise,
            label: 'Regenerate',
            isActive: false,
            onTap: () => ref.read(shortEditorProvider.notifier).regenerate(),
            isLoading: state.isGenerating,
          ),
          const SizedBox(width: 8),

          // Export Short
          Container(
            height: 32,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_accentColor, _purpleColor]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(PhosphorIconsRegular.export, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text('Export Short', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: isCompact ? _buildMobileLayout(context, ref, state) : _buildDesktopLayout(context, ref, state),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, ShortEditorState state) {
    return Row(
      children: [
        // Left: Preview
        Expanded(
          flex: 3,
          child: _PreviewArea(state: state),
        ),

        // Right: Controls
        Expanded(
          flex: 4,
          child: Container(
            decoration: const BoxDecoration(
              color: _surfaceColor,
              border: Border(left: BorderSide(color: _borderColor)),
            ),
            child: _ControlPanels(state: state, ref: ref),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, ShortEditorState state) {
    return Column(
      children: [
        // Preview (smaller on mobile)
        SizedBox(
          height: 300,
          child: _PreviewArea(state: state),
        ),

        // Controls
        Expanded(
          child: _ControlPanels(state: state, ref: ref),
        ),
      ],
    );
  }
}

// ─── Preview Area ────────────────────────────────────────────────────────────
class _PreviewArea extends StatelessWidget {
  final ShortEditorState state;

  const _PreviewArea({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          width: 270,
          height: 480,
          decoration: BoxDecoration(
            color: const Color(0xFF111115),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Before/After mode
              if (state.showBeforeAfter)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0A0A0C),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIconsRegular.playCircle, size: 32, color: _textMuted),
                            const SizedBox(height: 8),
                            Text('BEFORE', style: GoogleFonts.inter(color: _textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 2, color: _accentColor),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D1117),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIconsRegular.playCircle, size: 32, color: _accentColor),
                            const SizedBox(height: 8),
                            Text('AFTER', style: GoogleFonts.inter(color: _accentColor, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                // Single preview
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIconsRegular.filmSlate, size: 40, color: _textMuted),
                    const SizedBox(height: 8),
                    Text('9:16 Preview', style: GoogleFonts.inter(color: _textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${state.totalDuration.inSeconds}s',
                      style: GoogleFonts.inter(color: _textMuted, fontSize: 10),
                    ),
                  ],
                ),

                // Hook text overlay
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      state.hookText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: state.hookFontSize,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                // Caption overlay
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Auto-generated captions appear here...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: state.captionSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Control Panels ──────────────────────────────────────────────────────────
class _ControlPanels extends StatelessWidget {
  final ShortEditorState state;
  final WidgetRef ref;

  const _ControlPanels({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: const BoxDecoration(
              color: _surfaceColor,
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
                Tab(text: 'Hook'),
                Tab(text: 'Captions'),
                Tab(text: 'Effects'),
                Tab(text: 'Audio'),
                Tab(text: 'SFX'),
                Tab(text: 'Overrides'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              children: [
                _HookTab(state: state, ref: ref),
                _CaptionsTab(state: state, ref: ref),
                _EffectsTab(state: state, ref: ref),
                _AudioTab(state: state, ref: ref),
                _SfxTab(state: state),
                _OverridesTab(state: state, ref: ref),
              ],
            ),
          ),

          // Mini Timeline
          _MiniTimeline(state: state),
        ],
      ),
    );
  }
}

class _HookTab extends StatelessWidget {
  final ShortEditorState state;
  final WidgetRef ref;

  const _HookTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'Hook Text', icon: PhosphorIconsRegular.link),
        const SizedBox(height: 12),

        // Hook text input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: TextField(
            maxLines: 3,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: state.hookFontSize, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: 'Enter hook text...',
              hintStyle: GoogleFonts.inter(color: _textMuted, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => ref.read(shortEditorProvider.notifier).setHookText(v),
          ),
        ),
        const SizedBox(height: 16),

        // Font Size
        _SliderControl(
          label: 'Font Size',
          value: state.hookFontSize,
          min: 16,
          max: 48,
          suffix: '${state.hookFontSize.toInt()}px',
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setHookFontSize(v),
        ),
        const SizedBox(height: 16),

        // Quick presets
        _SectionHeader(title: 'Quick Presets', icon: PhosphorIconsRegular.lightning),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PresetChip(label: '😱 WAIT FOR IT', onTap: () => ref.read(shortEditorProvider.notifier).setHookText('😱 WAIT FOR IT')),
            _PresetChip(label: '🔥 THIS CHANGES EVERYTHING', onTap: () => ref.read(shortEditorProvider.notifier).setHookText('🔥 THIS CHANGES EVERYTHING')),
            _PresetChip(label: 'POV: You discovered...', onTap: () => ref.read(shortEditorProvider.notifier).setHookText('POV: You discovered...')),
            _PresetChip(label: 'Nobody expected this', onTap: () => ref.read(shortEditorProvider.notifier).setHookText('Nobody expected this')),
            _PresetChip(label: 'Watch till the end', onTap: () => ref.read(shortEditorProvider.notifier).setHookText('Watch till the end')),
          ],
        ),
      ],
    );
  }
}

class _CaptionsTab extends StatelessWidget {
  final ShortEditorState state;
  final WidgetRef ref;

  const _CaptionsTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'Caption Style', icon: PhosphorIconsRegular.subtitles),
        const SizedBox(height: 12),

        _DropdownControl(
          label: 'Style',
          value: state.captionStyle,
          options: ['Bold Pop', 'Minimal', 'Gradient Glow', 'Outlined', 'Shadow Drop'],
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setCaptionStyle(v),
        ),
        const SizedBox(height: 12),

        _DropdownControl(
          label: 'Font',
          value: state.captionFont,
          options: ['Montserrat', 'Inter', 'Poppins', 'Bebas Neue', 'Impact'],
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setCaptionFont(v),
        ),
        const SizedBox(height: 12),

        _SliderControl(
          label: 'Size',
          value: state.captionSize,
          min: 14,
          max: 36,
          suffix: '${state.captionSize.toInt()}px',
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setCaptionSize(v),
        ),
        const SizedBox(height: 12),

        _DropdownControl(
          label: 'Position',
          value: state.captionPosition,
          options: ['Top', 'Center', 'Bottom', 'Dynamic'],
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setCaptionPosition(v),
        ),
        const SizedBox(height: 12),

        _DropdownControl(
          label: 'Animation',
          value: state.captionAnimation,
          options: ['Word-by-Word', 'Line-by-Line', 'Typewriter', 'Pop-in', 'Fade-in'],
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setCaptionAnimation(v),
        ),
        const SizedBox(height: 16),

        // Color picker row
        _SectionHeader(title: 'Color', icon: PhosphorIconsRegular.paintBucket),
        const SizedBox(height: 8),
        Row(
          children: [
            _ColorDot(color: Colors.white, isSelected: state.captionColor == Colors.white, onTap: () {}),
            _ColorDot(color: _warningColor, isSelected: false, onTap: () {}),
            _ColorDot(color: _accentColor, isSelected: false, onTap: () {}),
            _ColorDot(color: _successColor, isSelected: false, onTap: () {}),
            _ColorDot(color: _errorColor, isSelected: false, onTap: () {}),
            _ColorDot(color: _purpleColor, isSelected: false, onTap: () {}),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _borderColor),
                gradient: const LinearGradient(colors: [_accentColor, _purpleColor, _warningColor]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EffectsTab extends StatelessWidget {
  final ShortEditorState state;
  final WidgetRef ref;

  const _EffectsTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'Visual Effects', icon: PhosphorIconsRegular.sparkle),
        const SizedBox(height: 12),

        _SliderControl(
          label: 'Zoom Intensity',
          value: state.zoomIntensity,
          min: 1.0,
          max: 2.0,
          suffix: '${state.zoomIntensity.toStringAsFixed(1)}x',
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setZoomIntensity(v),
        ),
        const SizedBox(height: 12),

        _SliderControl(
          label: 'Speed Ramp',
          value: state.speedRamp,
          min: 0.5,
          max: 3.0,
          suffix: '${state.speedRamp.toStringAsFixed(1)}x',
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setSpeedRamp(v),
        ),
        const SizedBox(height: 16),

        // Toggle effects
        _SectionHeader(title: 'Toggles', icon: PhosphorIconsRegular.toggleRight),
        const SizedBox(height: 8),
        _ToggleRow(
          label: 'Freeze Frame',
          subtitle: 'Pause on key moments',
          value: state.freezeFrame,
          color: _warningColor,
          onTap: () => ref.read(shortEditorProvider.notifier).toggleFreezeFrame(),
        ),
        _ToggleRow(
          label: 'Camera Shake',
          subtitle: 'Add emphasis to impacts',
          value: state.enableShake,
          color: _errorColor,
          onTap: () => ref.read(shortEditorProvider.notifier).toggleShake(),
        ),
      ],
    );
  }
}

class _AudioTab extends StatelessWidget {
  final ShortEditorState state;
  final WidgetRef ref;

  const _AudioTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'Audio Levels', icon: PhosphorIconsRegular.speakerHigh),
        const SizedBox(height: 12),

        _SliderControl(
          label: '🎵 Music Volume',
          value: state.musicVolume,
          min: 0,
          max: 1,
          suffix: '${(state.musicVolume * 100).toInt()}%',
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setMusicVolume(v),
        ),
        const SizedBox(height: 12),

        _SliderControl(
          label: '🎤 Commentary',
          value: state.commentaryVolume,
          min: 0,
          max: 1,
          suffix: '${(state.commentaryVolume * 100).toInt()}%',
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setCommentaryVolume(v),
        ),
        const SizedBox(height: 12),

        _SliderControl(
          label: '🔊 SFX',
          value: state.sfxVolume,
          min: 0,
          max: 1,
          suffix: '${(state.sfxVolume * 100).toInt()}%',
          onChanged: (v) => ref.read(shortEditorProvider.notifier).setSfxVolume(v),
        ),
        const SizedBox(height: 16),

        _ToggleRow(
          label: 'Auto Ducking',
          subtitle: 'Lower music during speech',
          value: state.musicDucking,
          color: _successColor,
          onTap: () => ref.read(shortEditorProvider.notifier).toggleMusicDucking(),
        ),
      ],
    );
  }
}

class _SfxTab extends StatelessWidget {
  final ShortEditorState state;

  const _SfxTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'Sound Effects', icon: PhosphorIconsRegular.speakerHigh),
        const SizedBox(height: 12),

        // SFX items
        _SfxItem(name: 'Whoosh', time: '00:02', icon: PhosphorIconsRegular.wind),
        _SfxItem(name: 'Impact Boom', time: '00:08', icon: PhosphorIconsRegular.warning),
        _SfxItem(name: 'Ding', time: '00:15', icon: PhosphorIconsRegular.bell),
        _SfxItem(name: 'Crowd Ooh', time: '00:22', icon: PhosphorIconsRegular.users),
        _SfxItem(name: 'Record Scratch', time: '00:30', icon: PhosphorIconsRegular.record),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor, style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIconsRegular.plus, size: 16, color: _accentColor),
              const SizedBox(width: 8),
              Text('Add SFX', style: GoogleFonts.inter(color: _accentColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverridesTab extends StatelessWidget {
  final ShortEditorState state;
  final WidgetRef ref;

  const _OverridesTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'AI Decision Overrides', icon: PhosphorIconsRegular.brain),
        const SizedBox(height: 4),
        Text(
          'Override AI-generated decisions for specific aspects.',
          style: GoogleFonts.inter(color: _textMuted, fontSize: 11),
        ),
        const SizedBox(height: 16),

        _OverrideRow(
          label: 'Hook Selection',
          description: 'AI chose: "00:03 surprise reaction"',
          enabled: state.overrideHook,
          onTap: () => ref.read(shortEditorProvider.notifier).toggleOverrideHook(),
        ),
        _OverrideRow(
          label: 'Caption Timing',
          description: 'AI synced to speech at natural pauses',
          enabled: state.overrideCaptions,
          onTap: () => ref.read(shortEditorProvider.notifier).toggleOverrideCaptions(),
        ),
        _OverrideRow(
          label: 'Pacing',
          description: 'AI used fast pace for engagement',
          enabled: state.overridePacing,
          onTap: () => ref.read(shortEditorProvider.notifier).toggleOverridePacing(),
        ),
        _OverrideRow(
          label: 'Music Selection',
          description: 'AI chose: "Energetic Pop" track',
          enabled: state.overrideMusic,
          onTap: () => ref.read(shortEditorProvider.notifier).toggleOverrideMusic(),
        ),
      ],
    );
  }
}

// ─── Mini Timeline ───────────────────────────────────────────────────────────
class _MiniTimeline extends StatelessWidget {
  final ShortEditorState state;

  const _MiniTimeline({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.filmStrip, size: 10, color: _textMuted),
              const SizedBox(width: 4),
              Text('Timeline', style: GoogleFonts.inter(color: _textMuted, fontSize: 9)),
              const Spacer(),
              // Playback controls
              Icon(PhosphorIconsRegular.skipBack, size: 10, color: _textSecondary),
              const SizedBox(width: 4),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsRegular.play, size: 8, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Icon(PhosphorIconsRegular.skipForward, size: 10, color: _textSecondary),
            ],
          ),
          const SizedBox(height: 4),

          // Mini track
          Expanded(
            child: Row(
              children: [
                // Video blocks
                _MiniClip(color: _accentColor.withOpacity(0.4), flex: 3),
                _MiniClip(color: _accentColor.withOpacity(0.6), flex: 5),
                _MiniClip(color: _accentColor.withOpacity(0.3), flex: 2),
                const SizedBox(width: 4),
                // SFX markers
                ...List.generate(3, (i) => Container(
                  width: 4,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: _warningColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────
class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isLoading;

  const _AppBarButton({required this.icon, required this.label, required this.isActive, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _accentColor.withOpacity(0.15) : _cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? _accentColor : _borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: _accentColor))
            else
              Icon(icon, size: 12, color: isActive ? _accentColor : _textSecondary),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.inter(color: isActive ? _accentColor : _textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

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

class _SliderControl extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: GoogleFonts.inter(color: _textSecondary, fontSize: 11)),
            const Spacer(),
            Text(suffix, style: GoogleFonts.inter(color: _accentColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: _accentColor,
            inactiveTrackColor: _borderColor,
            thumbColor: _accentColor,
            overlayColor: _accentColor.withOpacity(0.1),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _DropdownControl extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _DropdownControl({required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(color: _textMuted, fontSize: 11)),
          const Spacer(),
          DropdownButton<String>(
            value: value,
            dropdownColor: _surfaceColor,
            underline: const SizedBox(),
            isDense: true,
            style: GoogleFonts.inter(color: _textPrimary, fontSize: 11),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final Color color;
  final VoidCallback onTap;

  const _ToggleRow({required this.label, required this.subtitle, required this.value, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.08) : _cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: value ? color.withOpacity(0.3) : _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: value ? color : _textMuted, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
                ],
              ),
            ),
            Icon(value ? PhosphorIconsRegular.toggleRight : PhosphorIconsRegular.toggleLeft, size: 24, color: value ? color : _textMuted),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Text(label, style: GoogleFonts.inter(color: _textSecondary, fontSize: 11)),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)] : null,
        ),
      ),
    );
  }
}

class _SfxItem extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;

  const _SfxItem({required this.name, required this.time, required this.icon});

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
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _warningColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: _warningColor),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(time, style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Icon(PhosphorIconsRegular.gear, size: 12, color: _textMuted),
        ],
      ),
    );
  }
}

class _OverrideRow extends StatelessWidget {
  final String label;
  final String description;
  final bool enabled;
  final VoidCallback onTap;

  const _OverrideRow({required this.label, required this.description, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled ? _purpleColor.withOpacity(0.08) : _cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: enabled ? _purpleColor.withOpacity(0.3) : _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsRegular.brain, size: 12, color: enabled ? _purpleColor : _textMuted),
                const SizedBox(width: 6),
                Text(label, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                const Spacer(),
                Container(
                  width: 36,
                  height: 20,
                  decoration: BoxDecoration(
                    color: enabled ? _purpleColor : _borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!enabled) ...[
              const SizedBox(height: 4),
              Text(description, style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
            ],
            if (enabled) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Override active — custom selection will be used', style: GoogleFonts.inter(color: _purpleColor, fontSize: 10)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniClip extends StatelessWidget {
  final Color color;
  final int flex;

  const _MiniClip({required this.color, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
