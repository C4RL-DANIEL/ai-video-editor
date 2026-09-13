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

// ─── Story Structure ─────────────────────────────────────────────────────────
enum StorySectionType {
  hook('HOOK', PhosphorIcons.fishHook, _errorColor),
  setup('SETUP', PhosphorIcons.treeStructure, _accentColor),
  context('CONTEXT', PhosphorIcons.bookmarkSimple, _accentColor),
  story('STORY', PhosphorIcons.bookOpenText, _purpleColor),
  escalation('ESCALATION', PhosphorIcons.chartLineUp, _warningColor),
  majorEvents('MAJOR EVENTS', PhosphorIcons.star, _warningColor),
  reactions('REACTIONS', PhosphorIcons.smiley, _successColor),
  payoff('PAYOFF', PhosphorIcons.trophy, _purpleColor),
  conclusion('CONCLUSION', PhosphorIcons.flag, _textSecondary);

  final String label;
  final IconData icon;
  final Color color;

  const StorySectionType(this.label, this.icon, this.color);
}

class StorySection {
  final StorySectionType type;
  final List<String> selectedFootage;
  final double estimatedDuration; // in seconds
  final bool expanded;

  StorySection({
    required this.type,
    this.selectedFootage = const [],
    this.estimatedDuration = 0,
    this.expanded = false,
  });

  StorySection copyWith({List<String>? selectedFootage, double? estimatedDuration, bool? expanded}) {
    return StorySection(
      type: type,
      selectedFootage: selectedFootage ?? this.selectedFootage,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      expanded: expanded ?? this.expanded,
    );
  }
}

class Chapter {
  final int number;
  final String title;
  final double startTime;
  final double endTime;
  final String description;
  final int sourceFootageCount;

  Chapter({
    required this.number,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.sourceFootageCount,
  });
}

// ─── Builder State ───────────────────────────────────────────────────────────
class LongFormBuilderState {
  final int targetDurationMinutes;
  final bool isCustomDuration;
  final double customDurationMinutes;
  final List<StorySection> sections;
  final List<Chapter> chapters;
  final bool isBuilding;
  final String narrationText;
  final String selectedFootageFilter;

  LongFormBuilderState({
    this.targetDurationMinutes = 10,
    this.isCustomDuration = false,
    this.customDurationMinutes = 10,
    List<StorySection>? sections,
    List<Chapter>? chapters,
    this.isBuilding = false,
    this.narrationText = '',
    this.selectedFootageFilter = 'All',
  })  : sections = sections ?? _defaultSections,
        chapters = chapters ?? _defaultChapters;

  static List<StorySection> get _defaultSections => [
    StorySection(type: StorySectionType.hook, selectedFootage: ['Opening Reaction', 'Key Surprise'], estimatedDuration: 15),
    StorySection(type: StorySectionType.setup, selectedFootage: ['Introduction', 'Background'], estimatedDuration: 45),
    StorySection(type: StorySectionType.context, selectedFootage: ['Setting Scene', 'Interview Setup'], estimatedDuration: 60),
    StorySection(type: StorySectionType.story, selectedFootage: ['Main Event 1', 'Main Event 2', 'Main Event 3'], estimatedDuration: 120),
    StorySection(type: StorySectionType.escalation, selectedFootage: ['Tension Build', 'Rising Action'], estimatedDuration: 90),
    StorySection(type: StorySectionType.majorEvents, selectedFootage: ['Climax Moment', 'Key Reveal'], estimatedDuration: 75),
    StorySection(type: StorySectionType.reactions, selectedFootage: ['Crowd Reaction', 'Interview Response'], estimatedDuration: 60),
    StorySection(type: StorySectionType.payoff, selectedFootage: ['Resolution', 'Resolution 2'], estimatedDuration: 45),
    StorySection(type: StorySectionType.conclusion, selectedFootage: ['Outro', 'Closing Thoughts'], estimatedDuration: 30),
  ];

  static List<Chapter> get _defaultChapters => [
    Chapter(number: 1, title: 'The Hook', startTime: 0, endTime: 15, description: 'Attention-grabbing opening with surprise element', sourceFootageCount: 2),
    Chapter(number: 2, title: 'Setting the Scene', startTime: 15, endTime: 60, description: 'Introduction and background context', sourceFootageCount: 3),
    Chapter(number: 3, title: 'The Story Unfolds', startTime: 60, endTime: 180, description: 'Main narrative with key events', sourceFootageCount: 5),
    Chapter(number: 4, title: 'Rising Tension', startTime: 180, endTime: 270, description: 'Escalation and building drama', sourceFootageCount: 3),
    Chapter(number: 5, title: 'The Climax', startTime: 270, endTime: 345, description: 'Peak moments and major reveals', sourceFootageCount: 4),
    Chapter(number: 6, title: 'Aftermath', startTime: 345, endTime: 405, description: 'Reactions and emotional responses', sourceFootageCount: 3),
    Chapter(number: 7, title: 'Resolution', startTime: 405, endTime: 450, description: 'Payoff and satisfying conclusion', sourceFootageCount: 2),
    Chapter(number: 8, title: 'Wrap-Up', startTime: 450, endTime: 480, description: 'Closing thoughts and outro', sourceFootageCount: 2),
  ];

  double get totalEstimatedDuration => sections.fold(0, (sum, s) => sum + s.estimatedDuration);
  double get targetDurationSeconds => (isCustomDuration ? customDurationMinutes : targetDurationMinutes) * 60.0;
  double get durationDifference => totalEstimatedDuration - targetDurationSeconds;

  LongFormBuilderState copyWith({
    int? targetDurationMinutes,
    bool? isCustomDuration,
    double? customDurationMinutes,
    List<StorySection>? sections,
    List<Chapter>? chapters,
    bool? isBuilding,
    String? narrationText,
    String? selectedFootageFilter,
  }) {
    return LongFormBuilderState(
      targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
      isCustomDuration: isCustomDuration ?? this.isCustomDuration,
      customDurationMinutes: customDurationMinutes ?? this.customDurationMinutes,
      sections: sections ?? this.sections,
      chapters: chapters ?? this.chapters,
      isBuilding: isBuilding ?? this.isBuilding,
      narrationText: narrationText ?? this.narrationText,
      selectedFootageFilter: selectedFootageFilter ?? this.selectedFootageFilter,
    );
  }
}

final longFormBuilderProvider = StateNotifierProvider<LongFormBuilderNotifier, LongFormBuilderState>(
  (ref) => LongFormBuilderNotifier(),
);

class LongFormBuilderNotifier extends StateNotifier<LongFormBuilderState> {
  LongFormBuilderNotifier() : super(LongFormBuilderState());

  void setTargetDuration(int minutes) => state = state.copyWith(targetDurationMinutes: minutes);
  void setCustomDuration(double minutes) => state = state.copyWith(customDurationMinutes: minutes, isCustomDuration: true);
  void toggleCustomDuration() => state = state.copyWith(isCustomDuration: !state.isCustomDuration);

  void toggleSectionExpanded(int index) {
    final sections = List<StorySection>.from(state.sections);
    sections[index] = sections[index].copyWith(expanded: !sections[index].expanded);
    state = state.copyWith(sections: sections);
  }

  void addFootageToSection(int sectionIndex, String footage) {
    final sections = List<StorySection>.from(state.sections);
    final section = sections[sectionIndex];
    final footageList = List<String>.from(section.selectedFootage);
    if (!footageList.contains(footage)) {
      footageList.add(footage);
      sections[sectionIndex] = section.copyWith(
        selectedFootage: footageList,
        estimatedDuration: section.estimatedDuration + 15,
      );
      state = state.copyWith(sections: sections);
    }
  }

  void removeFootageFromSection(int sectionIndex, int footageIndex) {
    final sections = List<StorySection>.from(state.sections);
    final section = sections[sectionIndex];
    final footageList = List<String>.from(section.selectedFootage);
    if (footageIndex < footageList.length) {
      footageList.removeAt(footageIndex);
      sections[sectionIndex] = section.copyWith(
        selectedFootage: footageList,
        estimatedDuration: max(section.estimatedDuration - 15, 0),
      );
      state = state.copyWith(sections: sections);
    }
  }

  void setNarration(String text) => state = state.copyWith(narrationText: text);
  void setFootageFilter(String filter) => state = state.copyWith(selectedFootageFilter: filter);

  void buildStory() {
    state = state.copyWith(isBuilding: true);
    Future.delayed(const Duration(seconds: 4), () {
      state = state.copyWith(isBuilding: false);
    });
  }

  void reorderChapter(int oldIndex, int newIndex) {
    final chapters = List<Chapter>.from(state.chapters);
    if (oldIndex < newIndex) newIndex--;
    final item = chapters.removeAt(oldIndex);
    chapters.insert(newIndex, item);
    // Renumber
    final renumbered = chapters.asMap().entries.map((e) => Chapter(
      number: e.key + 1,
      title: e.value.title,
      startTime: e.value.startTime,
      endTime: e.value.endTime,
      description: e.value.description,
      sourceFootageCount: e.value.sourceFootageCount,
    )).toList();
    state = state.copyWith(chapters: renumbered);
  }
}

// ─── Long Form Builder Page ──────────────────────────────────────────────────
class LongFormBuilderPage extends ConsumerWidget {
  const LongFormBuilderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(longFormBuilderProvider);
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 1000;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrowLeft, size: 18),
          color: _textSecondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Icon(PhosphorIcons.bookOpenText, size: 18, color: _purpleColor),
            const SizedBox(width: 8),
            Text('Long-Form Builder', style: GoogleFonts.inter(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          // Build Story button
          _BuildButton(state: state, ref: ref),
          const SizedBox(width: 8),
          // Render button
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
                const Icon(PhosphorIcons.export, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text('Render Long-Form', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: isCompact
          ? _buildMobileLayout(context, ref, state)
          : _buildDesktopLayout(context, ref, state),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, LongFormBuilderState state) {
    return Row(
      children: [
        // Left: Story Structure
        Expanded(
          flex: 5,
          child: _StoryStructurePanel(state: state, ref: ref),
        ),

        // Center: Chapters + Pacing
        Expanded(
          flex: 4,
          child: _ChaptersPanel(state: state, ref: ref),
        ),

        // Right: Footage + Narration
        Expanded(
          flex: 3,
          child: _FootageNarrationPanel(state: state, ref: ref),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, LongFormBuilderState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _StoryStructurePanel(state: state, ref: ref),
          _ChaptersPanel(state: state, ref: ref),
          _FootageNarrationPanel(state: state, ref: ref),
        ],
      ),
    );
  }
}

// ─── Story Structure Panel ───────────────────────────────────────────────────
class _StoryStructurePanel extends StatelessWidget {
  final LongFormBuilderState state;
  final WidgetRef ref;

  const _StoryStructurePanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(right: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          // Target Duration Selector
          _DurationSelector(state: state, ref: ref),

          // Duration indicator
          _DurationIndicator(state: state),

          // Story Flow Visualization
          _StoryFlowVisualization(state: state),

          // Sections List
          Expanded(
            child: _SectionsList(state: state, ref: ref),
          ),
        ],
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final LongFormBuilderState state;
  final WidgetRef ref;

  const _DurationSelector({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.clock, size: 14, color: _accentColor),
              const SizedBox(width: 6),
              Text('Target Duration', style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5, 8, 10, 15, 20].map((min) {
              final isSelected = !state.isCustomDuration && state.targetDurationMinutes == min;
              return GestureDetector(
                onTap: () {
                  ref.read(longFormBuilderProvider.notifier).setTargetDuration(min);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _accentColor.withOpacity(0.15) : _cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? _accentColor : _borderColor),
                  ),
                  child: Text(
                    '${min}min',
                    style: GoogleFonts.inter(
                      color: isSelected ? _accentColor : _textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList()..add(
              GestureDetector(
                onTap: () => ref.read(longFormBuilderProvider.notifier).toggleCustomDuration(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: state.isCustomDuration ? _purpleColor.withOpacity(0.15) : _cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: state.isCustomDuration ? _purpleColor : _borderColor),
                  ),
                  child: Text(
                    'Custom',
                    style: GoogleFonts.inter(
                      color: state.isCustomDuration ? _purpleColor : _textSecondary,
                      fontSize: 12,
                      fontWeight: state.isCustomDuration ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (state.isCustomDuration) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Duration: ${state.customDurationMinutes.toInt()} min', style: GoogleFonts.inter(color: _textSecondary, fontSize: 11)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: _purpleColor,
                      inactiveTrackColor: _borderColor,
                      thumbColor: _purpleColor,
                    ),
                    child: Slider(
                      value: state.customDurationMinutes,
                      min: 1,
                      max: 60,
                      onChanged: (v) => ref.read(longFormBuilderProvider.notifier).setCustomDuration(v),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DurationIndicator extends StatelessWidget {
  final LongFormBuilderState state;

  const _DurationIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final estimated = state.totalEstimatedDuration;
    final target = state.targetDurationSeconds;
    final diff = state.durationDifference;
    final isOver = diff > 30;
    final isUnder = diff < -30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          // Estimated
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated', style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
              Text(
                _formatDuration(estimated),
                style: GoogleFonts.inter(
                  color: isOver ? _errorColor : (isUnder ? _warningColor : _successColor),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Icon(PhosphorIcons.arrowRight, size: 14, color: _textMuted),
          const SizedBox(width: 16),
          // Target
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target', style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
              Text(_formatDuration(target), style: GoogleFonts.inter(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const Spacer(),
          // Difference badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOver ? _errorColor.withOpacity(0.15) : (isUnder ? _warningColor.withOpacity(0.15) : _successColor.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${diff > 0 ? '+' : ''}${_formatDuration(diff.abs())}',
              style: GoogleFonts.inter(
                color: isOver ? _errorColor : (isUnder ? _warningColor : _successColor),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryFlowVisualization extends StatelessWidget {
  final LongFormBuilderState state;

  const _StoryFlowVisualization({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: state.sections.map((section) {
          final totalDur = state.totalEstimatedDuration;
          final flex = totalDur > 0 ? (section.estimatedDuration / totalDur * 100).round().clamp(1, 100) : 1;
          return Expanded(
            flex: flex,
            child: Tooltip(
              message: '${section.type.label}: ${_formatDuration(section.estimatedDuration)}',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: section.type.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    section.type.label.substring(0, min(section.type.label.length, 4)),
                    style: GoogleFonts.inter(color: section.type.color, fontSize: 7, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionsList extends StatelessWidget {
  final LongFormBuilderState state;
  final WidgetRef ref;

  const _SectionsList({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.sections.length,
      itemBuilder: (context, index) {
        final section = state.sections[index];
        return _SectionCard(
          section: section,
          index: index,
          onToggle: () => ref.read(longFormBuilderProvider.notifier).toggleSectionExpanded(index),
          onRemoveFootage: (fi) => ref.read(longFormBuilderProvider.notifier).removeFootageFromSection(index, fi),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final StorySection section;
  final int index;
  final VoidCallback onToggle;
  final Function(int) onRemoveFootage;

  const _SectionCard({required this.section, required this.index, required this.onToggle, required this.onRemoveFootage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: section.expanded ? section.type.color.withOpacity(0.05) : _cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: section.expanded ? section.type.color.withOpacity(0.3) : _borderColor),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: section.type.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(section.type.icon, size: 14, color: section.type.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.type.label,
                          style: GoogleFonts.inter(color: _textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${section.selectedFootage.length} clips • ${_formatDuration(section.estimatedDuration)}',
                          style: GoogleFonts.inter(color: _textMuted, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    section.expanded ? PhosphorIcons.caretUp : PhosphorIcons.caretDown,
                    size: 12,
                    color: _textMuted,
                  ),
                ],
              ),
            ),

            // Expanded content
            if (section.expanded) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected footage
                    ...section.selectedFootage.asMap().entries.map((e) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.filmStrip, size: 10, color: section.type.color),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(e.value, style: GoogleFonts.inter(color: _textSecondary, fontSize: 10)),
                            ),
                            GestureDetector(
                              onTap: () => onRemoveFootage(e.key),
                              child: Icon(PhosphorIcons.x, size: 10, color: _errorColor),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (section.selectedFootage.isEmpty)
                      Text('No footage selected', style: GoogleFonts.inter(color: _textMuted, fontSize: 10, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Chapters Panel ──────────────────────────────────────────────────────────
class _ChaptersPanel extends StatelessWidget {
  final LongFormBuilderState state;
  final WidgetRef ref;

  const _ChaptersPanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(right: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _borderColor)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.listNumbers, size: 14, color: _accentColor),
                const SizedBox(width: 8),
                Text('Chapter Preview', style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${state.chapters.length} chapters', style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
              ],
            ),
          ),

          // Pacing Visualization
          _PacingVisualization(state: state),

          // Chapters List (reorderable)
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.chapters.length,
              onReorder: (oldIndex, newIndex) => ref.read(longFormBuilderProvider.notifier).reorderChapter(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final chapter = state.chapters[index];
                return _ChapterCard(key: ValueKey(chapter.number), chapter: chapter, index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PacingVisualization extends StatelessWidget {
  final LongFormBuilderState state;

  const _PacingVisualization({required this.state});

  @override
  Widget build(BuildContext context) {
    final totalDuration = state.chapters.isNotEmpty ? state.chapters.last.endTime : 480.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.chartBar, size: 12, color: _accentColor),
              const SizedBox(width: 6),
              Text('Pacing Map', style: GoogleFonts.inter(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          // Pacing bars per section
          ...state.sections.map((section) {
            final normalizedDuration = totalDuration > 0 ? section.estimatedDuration / totalDuration : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      section.type.label.substring(0, min(section.type.label.length, 5)),
                      style: GoogleFonts.inter(color: _textMuted, fontSize: 8),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: normalizedDuration.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: section.type.color.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(section.estimatedDuration),
                    style: GoogleFonts.inter(color: _textMuted, fontSize: 8),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final int index;

  const _ChapterCard({required Key key, required this.chapter, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          // Drag handle
          Icon(PhosphorIcons.dotsSixVertical, size: 14, color: _textMuted),
          const SizedBox(width: 10),

          // Chapter number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${chapter.number}',
                style: GoogleFonts.inter(color: _accentColor, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chapter.title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(chapter.description, style: GoogleFonts.inter(color: _textMuted, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),

          // Metadata
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatDuration(chapter.startTime)} → ${_formatDuration(chapter.endTime)}',
                style: GoogleFonts.inter(color: _textSecondary, fontSize: 9),
              ),
              Text(
                '${chapter.sourceFootageCount} sources',
                style: GoogleFonts.inter(color: _textMuted, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Footage + Narration Panel ───────────────────────────────────────────────
class _FootageNarrationPanel extends StatelessWidget {
  final LongFormBuilderState state;
  final WidgetRef ref;

  const _FootageNarrationPanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surfaceColor,
      child: Column(
        children: [
          // Available Footage
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.folderOpen, size: 14, color: _successColor),
                    const SizedBox(width: 8),
                    Text('Available Footage', style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                // Filter chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['All', 'Interview', 'B-Roll', 'Reactions', 'Establishing'].map((f) {
                    final isSelected = state.selectedFootageFilter == f;
                    return GestureDetector(
                      onTap: () => ref.read(longFormBuilderProvider.notifier).setFootageFilter(f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? _accentColor.withOpacity(0.15) : _cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? _accentColor : _borderColor),
                        ),
                        child: Text(f, style: GoogleFonts.inter(color: isSelected ? _accentColor : _textMuted, fontSize: 10)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Footage list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _FootageItem(name: 'Interview - Opening', duration: '01:30', type: 'Interview', color: _accentColor),
                _FootageItem(name: 'City Skyline B-Roll', duration: '00:45', type: 'B-Roll', color: _successColor),
                _FootageItem(name: 'Crowd Reaction', duration: '00:15', type: 'Reaction', color: _warningColor),
                _FootageItem(name: 'Interview - Key Moment', duration: '02:15', type: 'Interview', color: _accentColor),
                _FootageItem(name: 'Close-up Details', duration: '00:30', type: 'B-Roll', color: _successColor),
                _FootageItem(name: 'Audience Response', duration: '00:20', type: 'Reaction', color: _warningColor),
                _FootageItem(name: 'Establishing Shot', duration: '00:10', type: 'Establishing', color: _purpleColor),
                _FootageItem(name: 'Interview - Conclusion', duration: '01:00', type: 'Interview', color: _accentColor),
              ],
            ),
          ),

          // Narration Editor
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.microphone, size: 14, color: _purpleColor),
                    const SizedBox(width: 8),
                    Text('Narration', style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('AI Generate', style: GoogleFonts.inter(color: _accentColor, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderColor),
                  ),
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    style: GoogleFonts.inter(color: _textPrimary, fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Write or generate narration script...',
                      hintStyle: GoogleFonts.inter(color: _textMuted, fontSize: 11),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => ref.read(longFormBuilderProvider.notifier).setNarration(v),
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

// ─── Build Button ────────────────────────────────────────────────────────────
class _BuildButton extends StatelessWidget {
  final LongFormBuilderState state;
  final WidgetRef ref;

  const _BuildButton({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state.isBuilding ? null : () => ref.read(longFormBuilderProvider.notifier).buildStory(),
      child: Container(
        height: 32,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: state.isBuilding ? _textMuted : _successColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.isBuilding)
              SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
            else
              const Icon(PhosphorIcons.magicWand, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              state.isBuilding ? 'Building...' : 'Build Story',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Footage Item ────────────────────────────────────────────────────────────
class _FootageItem extends StatelessWidget {
  final String name;
  final String duration;
  final String type;
  final Color color;

  const _FootageItem({required this.name, required this.duration, required this.type, required this.color});

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
            child: Icon(PhosphorIcons.filmStrip, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(color: _textPrimary, fontSize: 11)),
                Text('$type • $duration', style: GoogleFonts.inter(color: _textMuted, fontSize: 9)),
              ],
            ),
          ),
          Icon(PhosphorIcons.plusCircle, size: 16, color: _textMuted),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
String _formatDuration(double seconds) {
  final mins = (seconds / 60).floor();
  final secs = (seconds % 60).floor();
  return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

int min(int a, int b) => a < b ? a : b;
int max(int a, int b) => a > b ? a : b;
