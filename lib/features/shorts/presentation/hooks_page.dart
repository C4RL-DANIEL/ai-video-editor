import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

// ── Hook Type ───────────────────────────────────────────────────────
enum HookType {
  all,
  curiosity,
  shock,
  question,
  humor,
  emotional,
  challenge,
  promise,
  controversy;

  String get label {
    switch (this) {
      case HookType.all:
        return 'All';
      case HookType.curiosity:
        return 'Curiosity';
      case HookType.shock:
        return 'Shock';
      case HookType.question:
        return 'Question';
      case HookType.humor:
        return 'Humor';
      case HookType.emotional:
        return 'Emotional';
      case HookType.challenge:
        return 'Challenge';
      case HookType.promise:
        return 'Promise';
      case HookType.controversy:
        return 'Controversy';
    }
  }

  Color get color {
    switch (this) {
      case HookType.all:
        return _textSecondary;
      case HookType.curiosity:
        return _accentBlue;
      case HookType.shock:
        return _errorRed;
      case HookType.question:
        return _warningAmber;
      case HookType.humor:
        return _successGreen;
      case HookType.emotional:
        return _purple;
      case HookType.challenge:
        return const Color(0xFFFF6B6B);
      case HookType.promise:
        return const Color(0xFF06B6D4);
      case HookType.controversy:
        return const Color(0xFFF97316);
    }
  }

  IconData get icon {
    switch (this) {
      case HookType.all:
        return PhosphorIconsRegular.funnel;
      case HookType.curiosity:
        return PhosphorIconsRegular.magnifyingGlass;
      case HookType.shock:
        return PhosphorIconsRegular.lightning;
      case HookType.question:
        return PhosphorIconsRegular.question;
      case HookType.humor:
        return PhosphorIconsRegular.smiley;
      case HookType.emotional:
        return PhosphorIconsRegular.heart;
      case HookType.challenge:
        return PhosphorIconsRegular.sword;
      case HookType.promise:
        return PhosphorIconsRegular.star;
      case HookType.controversy:
        return PhosphorIconsRegular.warning;
    }
  }
}

// ── Models ──────────────────────────────────────────────────────────
class MomentInfo {
  const MomentInfo({
    required this.id,
    required this.timestamp,
    required this.description,
    required this.score,
    this.startOffset,
    this.endOffset,
  });

  final String id;
  final String timestamp;
  final String description;
  final double score;
  final double? startOffset;
  final double? endOffset;
}

class GeneratedHook {
  const GeneratedHook({
    required this.id,
    required this.text,
    required this.type,
    required this.score,
    this.isUsing = false,
  });

  final String id;
  final String text;
  final HookType type;
  final double score;
  final bool isUsing;
}

// ── State ───────────────────────────────────────────────────────────
class HooksPageState {
  const HooksPageState({
    this.moment,
    this.hooks = const [],
    this.activeFilter = HookType.all,
    this.isLoading = false,
    this.isGenerating = false,
    this.selectedHookId,
    this.previewText = '',
  });

  final MomentInfo? moment;
  final List<GeneratedHook> hooks;
  final HookType activeFilter;
  final bool isLoading;
  final bool isGenerating;
  final String? selectedHookId;
  final String previewText;

  HooksPageState copyWith({
    MomentInfo? moment,
    List<GeneratedHook>? hooks,
    HookType? activeFilter,
    bool? isLoading,
    bool? isGenerating,
    String? selectedHookId,
    String? previewText,
  }) {
    return HooksPageState(
      moment: moment ?? this.moment,
      hooks: hooks ?? this.hooks,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      selectedHookId: selectedHookId ?? this.selectedHookId,
      previewText: previewText ?? this.previewText,
    );
  }

  List<GeneratedHook> get filteredHooks {
    if (activeFilter == HookType.all) return hooks;
    return hooks.where((h) => h.type == activeFilter).toList();
  }
}

// ── Provider ────────────────────────────────────────────────────────
final hooksPageProvider =
    StateNotifierProvider.family<HooksPageNotifier, HooksPageState, String>(
  (ref, momentId) => HooksPageNotifier(momentId),
);

class HooksPageNotifier extends StateNotifier<HooksPageState> {
  HooksPageNotifier(this._momentId) : super(const HooksPageState()) {
    _loadData();
  }

  final String _momentId;

  void _loadData() {
    state = state.copyWith(isLoading: true);
    Future.delayed(const Duration(milliseconds: 600), () {
      state = state.copyWith(
        isLoading: false,
        moment: _mockMoment,
        hooks: _mockHooks,
        previewText: _mockHooks.first.text,
        selectedHookId: _mockHooks.first.id,
      );
    });
  }

  void setFilter(HookType filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void useHook(String hookId) {
    final hook = state.hooks.firstWhere((h) => h.id == hookId);
    state = state.copyWith(
      selectedHookId: hookId,
      previewText: hook.text,
    );
  }

  void generateMore() {
    state = state.copyWith(isGenerating: true);
    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(isGenerating: false);
      // TODO: Add more hooks from API
    });
  }
}

// ── Mock Data ───────────────────────────────────────────────────────
final _mockMoment = const MomentInfo(
  id: 'moment_1',
  timestamp: '02:14',
  description:
      'Subject displays genuine surprise reaction when shown unexpected reveal. High emotional peak with strong facial expression.',
  score: 92,
  startOffset: 134,
  endOffset: 192,
);

final _mockHooks = [
  const GeneratedHook(
    id: 'h1',
    text: "Wait until you see his reaction when the door opens…",
    type: HookType.curiosity,
    score: 92,
    isUsing: true,
  ),
  const GeneratedHook(
    id: 'h2',
    text: "This reaction broke the internet for a reason",
    type: HookType.controversy,
    score: 87,
  ),
  const GeneratedHook(
    id: 'h3',
    text: "I can't believe what just happened 😳",
    type: HookType.shock,
    score: 84,
  ),
  const GeneratedHook(
    id: 'h4',
    text: "POV: You finally see what's behind the door",
    type: HookType.curiosity,
    score: 81,
  ),
  const GeneratedHook(
    id: 'h5',
    text: "Nobody expected what happened next",
    type: HookType.shock,
    score: 79,
  ),
  const GeneratedHook(
    id: 'h6',
    text: "Would YOU open the door? 😱",
    type: HookType.question,
    score: 76,
  ),
  const GeneratedHook(
    id: 'h7',
    text: "His face says it all 💀",
    type: HookType.humor,
    score: 74,
  ),
  const GeneratedHook(
    id: 'h8',
    text: "The most satisfying reaction I've ever captured",
    type: HookType.emotional,
    score: 72,
  ),
  const GeneratedHook(
    id: 'h9',
    text: "Watch until the end - you won't be disappointed",
    type: HookType.promise,
    score: 68,
  ),
  const GeneratedHook(
    id: 'h10',
    text: "Some people are saying this is fake… they're wrong",
    type: HookType.controversy,
    score: 65,
  ),
  const GeneratedHook(
    id: 'h11',
    text: "When life gives you the perfect moment 🎬",
    type: HookType.emotional,
    score: 63,
  ),
  const GeneratedHook(
    id: 'h12',
    text: "Try not to laugh at this reaction challenge",
    type: HookType.humor,
    score: 60,
  ),
  const GeneratedHook(
    id: 'h13',
    text: "The door was closed for a reason…",
    type: HookType.curiosity,
    score: 88,
  ),
  const GeneratedHook(
    id: 'h14',
    text: "You're about to witness something incredible",
    type: HookType.promise,
    score: 77,
  ),
  const GeneratedHook(
    id: 'h15',
    text: "This changes everything we thought we knew",
    type: HookType.shock,
    score: 71,
  ),
];

// ══════════════════════════════════════════════════════════════════════
// HOOKS PAGE
// ══════════════════════════════════════════════════════════════════════
class HooksPage extends ConsumerWidget {
  const HooksPage({super.key, required this.momentId, this.projectId});

  final String momentId;
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hooksPageProvider(momentId));
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
        title: Text(
          'Hook Lab',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        actions: [
          // Hook count
          if (state.hooks.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _accentBlue.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${state.hooks.length} hooks',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _accentBlue,
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? _buildLoading()
          : state.moment == null
              ? _buildEmpty()
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsRegular.magnifyingGlass,
              size: 48, color: _textTertiary),
          const SizedBox(height: 16),
          Text(
            'No moment found',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
          ),
        ],
      ),
    );
  }

  // ── Desktop Layout ──────────────────────────────────────────────
  Widget _buildDesktopLayout(
      BuildContext context, WidgetRef ref, HooksPageState state) {
    return Row(
      children: [
        // Left: Moment info + hooks list
        Expanded(
          flex: 5,
          child: Column(
            children: [
              // Moment info
              _MomentInfoCard(moment: state.moment!),

              // Filter tabs
              _HookFilterTabs(
                activeFilter: state.activeFilter,
                hooks: state.hooks,
                onFilterChanged:
                    ref.read(hooksPageProvider(momentId).notifier).setFilter,
              ),

              // Hooks list
              Expanded(
                child: _HooksList(
                  hooks: state.filteredHooks,
                  selectedHookId: state.selectedHookId,
                  onSelect: ref.read(hooksPageProvider(momentId).notifier).useHook,
                ),
              ),

              // Generate more button
              _GenerateMoreButton(
                isGenerating: state.isGenerating,
                onGenerate:
                    ref.read(hooksPageProvider(momentId).notifier).generateMore,
              ),
            ],
          ),
        ),

        // Right: Preview area
        Expanded(
          flex: 5,
          child: _PreviewArea(
            hookText: state.previewText,
            moment: state.moment!,
          ),
        ),
      ],
    );
  }

  // ── Mobile Layout ───────────────────────────────────────────────
  Widget _buildMobileLayout(
      BuildContext context, WidgetRef ref, HooksPageState state) {
    return Column(
      children: [
        // Moment info
        _MomentInfoCard(moment: state.moment!),

        // Filter tabs
        _HookFilterTabs(
          activeFilter: state.activeFilter,
          hooks: state.hooks,
          onFilterChanged:
              ref.read(hooksPageProvider(momentId).notifier).setFilter,
        ),

        // Hooks list
        Expanded(
          child: _HooksList(
            hooks: state.filteredHooks,
            selectedHookId: state.selectedHookId,
            onSelect: ref.read(hooksPageProvider(momentId).notifier).useHook,
          ),
        ),

        // Preview area (collapsed on mobile)
        _PreviewAreaCompact(
          hookText: state.previewText,
          moment: state.moment!,
        ),

        // Generate more button
        _GenerateMoreButton(
          isGenerating: state.isGenerating,
          onGenerate:
              ref.read(hooksPageProvider(momentId).notifier).generateMore,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// MOMENT INFO CARD
// ══════════════════════════════════════════════════════════════════════
class _MomentInfoCard extends StatelessWidget {
  const _MomentInfoCard({required this.moment});

  final MomentInfo moment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(PhosphorIconsRegular.clock, size: 18, color: _accentBlue),
              const SizedBox(width: 8),
              Text(
                'Moment at ${moment.timestamp}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              // Score badge
              _MomentScoreBadge(score: moment.score),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            moment.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0);
  }
}

class _MomentScoreBadge extends StatelessWidget {
  const _MomentScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsRegular.trendUp, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            'Score: ${score.toInt()}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// HOOK FILTER TABS
// ══════════════════════════════════════════════════════════════════════
class _HookFilterTabs extends StatelessWidget {
  const _HookFilterTabs({
    required this.activeFilter,
    required this.hooks,
    required this.onFilterChanged,
  });

  final HookType activeFilter;
  final List<GeneratedHook> hooks;
  final ValueChanged<HookType> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: HookType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = HookType.values[index];
          final isActive = activeFilter == type;
          final count = type == HookType.all
              ? hooks.length
              : hooks.where((h) => h.type == type).length;

          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                avatar: Icon(
                  type.icon,
                  size: 14,
                  color: isActive ? Colors.white : type.color,
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? Colors.white : _textSecondary,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withAlpha(30)
                              : type.color.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : type.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: isActive,
                onSelected: (_) => onFilterChanged(type),
                backgroundColor: _cardColor,
                selectedColor: type == HookType.all ? _accentBlue : type.color,
                showCheckmark: false,
                side: BorderSide(
                  color: isActive
                      ? (type == HookType.all ? _accentBlue : type.color)
                      : _borderColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// HOOKS LIST
// ══════════════════════════════════════════════════════════════════════
class _HooksList extends StatelessWidget {
  const _HooksList({
    required this.hooks,
    required this.selectedHookId,
    required this.onSelect,
  });

  final List<GeneratedHook> hooks;
  final String? selectedHookId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (hooks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.magnifyingGlass,
                  size: 40, color: _textTertiary),
              const SizedBox(height: 12),
              Text(
                'No hooks match this filter',
                style: GoogleFonts.inter(
                    fontSize: 14, color: _textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: hooks.length,
      itemBuilder: (context, index) {
        final hook = hooks[index];
        final isSelected = selectedHookId == hook.id;
        return _HookCard(
          hook: hook,
          isSelected: isSelected,
          index: index,
          onSelect: () => onSelect(hook.id),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// HOOK CARD
// ══════════════════════════════════════════════════════════════════════
class _HookCard extends StatelessWidget {
  const _HookCard({
    required this.hook,
    required this.isSelected,
    required this.index,
    required this.onSelect,
  });

  final GeneratedHook hook;
  final bool isSelected;
  final int index;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(hook.score);

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _accentBlue.withAlpha(12) : _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _accentBlue : _borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _accentBlue.withAlpha(25),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ───────────────────────────────────
            Row(
              children: [
                // Number
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _accentBlue.withAlpha(30)
                        : _surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? _accentBlue : _textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hook.type.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hook.type.color.withAlpha(40),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(hook.type.icon, size: 12, color: hook.type.color),
                      const SizedBox(width: 4),
                      Text(
                        hook.type.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: hook.type.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Score
                Text(
                  hook.score.toInt().toString(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(PhosphorIconsRegular.star, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 12),

            // ── Hook Text ────────────────────────────────────
            Text(
              '"${hook.text}"',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: _textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // ── Score Bar ────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: hook.score / 100,
                backgroundColor: _borderColor,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),

            // ── Actions ──────────────────────────────────────
            Row(
              children: [
                // Use This Hook
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSelect,
                    icon: Icon(
                      isSelected
                          ? PhosphorIconsRegular.checkCircle
                          : PhosphorIconsRegular.cursor,
                      size: 16,
                    ),
                    label: Text(
                      isSelected ? 'Using This Hook' : 'Use This Hook',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? _successGreen : _accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Edit button
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open hook editor
                  },
                  icon:
                      Icon(PhosphorIconsRegular.pencilSimple, size: 16),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: (index * 40).ms)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 350.ms,
          delay: (index * 40).ms,
        );
  }
}

// ══════════════════════════════════════════════════════════════════════
// PREVIEW AREA (desktop - full)
// ══════════════════════════════════════════════════════════════════════
class _PreviewArea extends StatelessWidget {
  const _PreviewArea({
    required this.hookText,
    required this.moment,
  });

  final String hookText;
  final MomentInfo moment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(left: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _borderColor)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.eye, size: 18, color: _accentBlue),
                const SizedBox(width: 8),
                Text(
                  'Preview',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Phone mockup with hook
          Expanded(
            child: Center(
              child: _PhoneMockup(
                hookText: hookText,
              ),
            ),
          ),

          // Hook text detail
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Hook',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hookText.isNotEmpty ? '"$hookText"' : 'Select a hook to preview',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: _textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PreviewStat(
                      label: 'Characters',
                      value: '${hookText.length}',
                    ),
                    const SizedBox(width: 20),
                    _PreviewStat(
                      label: 'Words',
                      value: '${hookText.split(' ').length}',
                    ),
                    const SizedBox(width: 20),
                    _PreviewStat(
                      label: 'Read Time',
                      value: '${(hookText.split(' ').length * 0.4).toStringAsFixed(1)}s',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// PREVIEW AREA COMPACT (mobile)
// ══════════════════════════════════════════════════════════════════════
class _PreviewAreaCompact extends StatelessWidget {
  const _PreviewAreaCompact({
    required this.hookText,
    required this.moment,
  });

  final String hookText;
  final MomentInfo moment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.eye, size: 16, color: _accentBlue),
              const SizedBox(width: 6),
              Text(
                'Preview',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${hookText.length} chars',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
            ),
            child: Text(
              hookText.isNotEmpty ? '"$hookText"' : 'Select a hook',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: _textPrimary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// PHONE MOCKUP (hook as opening text)
// ══════════════════════════════════════════════════════════════════════
class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup({required this.hookText});

  final String hookText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 426, // ~9:16
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_surfaceColor, _cardColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Notch
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 100,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            // Play icon
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsRegular.play,
                  size: 28,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ),

            // Hook text overlay at bottom
            if (hookText.isNotEmpty)
              Positioned(
                bottom: 60,
                left: 12,
                right: 12,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(hookText),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hookText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

            // Bottom bar indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIconsRegular.heart,
                      size: 20, color: Colors.white.withAlpha(150)),
                  const SizedBox(width: 24),
                  Icon(PhosphorIconsRegular.chatCircle,
                      size: 20, color: Colors.white.withAlpha(150)),
                  const SizedBox(width: 24),
                  Icon(PhosphorIconsRegular.shareFat,
                      size: 20, color: Colors.white.withAlpha(150)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ══════════════════════════════════════════════════════════════════════
// PREVIEW STAT
// ══════════════════════════════════════════════════════════════════════
class _PreviewStat extends StatelessWidget {
  const _PreviewStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _textTertiary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// GENERATE MORE BUTTON
// ══════════════════════════════════════════════════════════════════════
class _GenerateMoreButton extends StatelessWidget {
  const _GenerateMoreButton({
    required this.isGenerating,
    required this.onGenerate,
  });

  final bool isGenerating;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: isGenerating ? null : onGenerate,
          icon: isGenerating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(PhosphorIconsRegular.sparkle, size: 18),
          label: Text(
            isGenerating ? 'Generating…' : 'Generate More Hooks',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _accentBlue.withAlpha(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
