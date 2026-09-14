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

  bool get hasData => moment != null && hooks.isNotEmpty;

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

// ── Hook Generation Templates ──────────────────────────────────────
const _hookTemplates = {
  HookType.curiosity: [
    "Wait until you see what happens next…",
    "You won't believe what's about to unfold",
    "This moment changes everything",
    "Something incredible is about to happen",
    "Watch closely — you'll miss it if you blink",
    "The answer will surprise you",
    "What happens next will blow your mind",
    "I never expected this to happen",
  ],
  HookType.shock: [
    "I can't believe what just happened 😳",
    "Nobody saw this coming",
    "This is absolutely insane",
    "My jaw literally dropped watching this",
    "Warning: you won't be ready for this",
    "This is the most shocking thing I've seen",
  ],
  HookType.question: [
    "Would you dare try this? 😱",
    "What would you do in this situation?",
    "Have you ever seen anything like this?",
    "Why would anyone do this?",
    "Can you guess what happens?",
  ],
  HookType.humor: [
    "His face says it all 💀",
    "I'm dying laughing at this reaction",
    "When you realize what just happened 😂",
    "This is comedy gold right here",
  ],
  HookType.emotional: [
    "The most satisfying reaction I've ever captured",
    "When life gives you the perfect moment 🎬",
    "This gave me chills watching it back",
    "You can see the pure joy in that moment",
  ],
  HookType.challenge: [
    "Try not to laugh at this reaction challenge",
    "Bet you can't watch this without smiling",
    "I dare you to keep a straight face",
  ],
  HookType.promise: [
    "Watch until the end — you won't be disappointed",
    "This is worth every second of your time",
    "The payoff at the end is absolutely worth it",
    "Stick around for the best part",
  ],
  HookType.controversy: [
    "This reaction broke the internet for a reason",
    "Some people are saying this is fake… they're wrong",
    "The internet is divided on this one",
    "You won't see eye to eye with everyone on this",
  ],
};

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
  int _nextHookId = 1;

  void _loadData() {
    state = state.copyWith(isLoading: true);
    Future.delayed(const Duration(milliseconds: 600), () {
      // No mock data — start with empty state
      state = state.copyWith(
        isLoading: false,
      );
    });
  }

  void loadMoment(MomentInfo moment) {
    state = state.copyWith(moment: moment);
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

  void updateHookText(String hookId, String newText) {
    final updatedHooks = state.hooks.map((h) {
      if (h.id == hookId) {
        return GeneratedHook(
          id: h.id,
          text: newText,
          type: h.type,
          score: h.score,
          isUsing: h.isUsing,
        );
      }
      return h;
    }).toList();
    final isSelected = state.selectedHookId == hookId;
    state = state.copyWith(
      hooks: updatedHooks,
      previewText: isSelected ? newText : state.previewText,
    );
  }

  void generateMore() {
    if (state.moment == null) return;
    state = state.copyWith(isGenerating: true);
    Future.delayed(const Duration(milliseconds: 800), () {
      final random = math.Random();
      final types = HookType.values.where((t) => t != HookType.all).toList();
      final newHooks = <GeneratedHook>[];

      // Generate 3-5 new hook variations
      final count = 3 + random.nextInt(3);
      for (var i = 0; i < count; i++) {
        final type = types[random.nextInt(types.length)];
        final templates = _hookTemplates[type] ?? [];
        if (templates.isEmpty) continue;
        final text = templates[random.nextInt(templates.length)];
        final score = 55.0 + random.nextDouble() * 40;
        newHooks.add(GeneratedHook(
          id: 'gen_${_nextHookId++}',
          text: text,
          type: type,
          score: double.parse(score.toStringAsFixed(1)),
        ));
      }

      final allHooks = [...state.hooks, ...newHooks];
      state = state.copyWith(
        isGenerating: false,
        hooks: allHooks,
      );
    });
  }
}

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
          : !state.hasData
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
          Icon(PhosphorIconsRegular.sparkle,
              size: 48, color: _textTertiary),
          const SizedBox(height: 16),
          Text(
            'No hooks generated yet',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate hooks to get started',
            style: GoogleFonts.inter(
                fontSize: 14, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Desktop Layout ──────────────────────────────────────────────
  Widget _buildDesktopLayout(
      BuildContext context, WidgetRef ref, HooksPageState state) {
    final notifier = ref.read(hooksPageProvider(momentId).notifier);
    void showSnack(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.inter()),
          duration: const Duration(seconds: 2),
          backgroundColor: _surfaceColor,
        ),
      );
    }

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
                onFilterChanged: notifier.setFilter,
              ),

              // Hooks list
              Expanded(
                child: _HooksList(
                  hooks: state.filteredHooks,
                  selectedHookId: state.selectedHookId,
                  onSelect: notifier.useHook,
                  onEdit: notifier.updateHookText,
                  onNotify: showSnack,
                ),
              ),

              // Generate more button
              _GenerateMoreButton(
                isGenerating: state.isGenerating,
                onGenerate: notifier.generateMore,
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
            onNotify: showSnack,
          ),
        ),
      ],
    );
  }

  // ── Mobile Layout ───────────────────────────────────────────────
  Widget _buildMobileLayout(
      BuildContext context, WidgetRef ref, HooksPageState state) {
    final notifier = ref.read(hooksPageProvider(momentId).notifier);
    void showSnack(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.inter()),
          duration: const Duration(seconds: 2),
          backgroundColor: _surfaceColor,
        ),
      );
    }

    return Column(
      children: [
        // Moment info
        _MomentInfoCard(moment: state.moment!),

        // Filter tabs
        _HookFilterTabs(
          activeFilter: state.activeFilter,
          hooks: state.hooks,
          onFilterChanged: notifier.setFilter,
        ),

        // Hooks list
        Expanded(
          child: _HooksList(
            hooks: state.filteredHooks,
            selectedHookId: state.selectedHookId,
            onSelect: notifier.useHook,
            onEdit: notifier.updateHookText,
            onNotify: showSnack,
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
          onGenerate: notifier.generateMore,
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
    required this.onEdit,
    required this.onNotify,
  });

  final List<GeneratedHook> hooks;
  final String? selectedHookId;
  final ValueChanged<String> onSelect;
  final void Function(String hookId, String newText) onEdit;
  final void Function(String message) onNotify;

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
          onEdit: () {
            _showEditDialog(context, hook, onEdit);
          },
          onNotify: onNotify,
        );
      },
    );
  }
}

void _showEditDialog(
    BuildContext context, GeneratedHook hook, void Function(String hookId, String newText) onEdit) {
  final controller = TextEditingController(text: hook.text);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: _cardColor,
      title: Text(
        'Edit Hook',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      ),
      content: TextField(
        controller: controller,
        maxLines: 3,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: _textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Enter hook text...',
          hintStyle: GoogleFonts.inter(color: _textTertiary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _accentBlue),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: _textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final newText = controller.text.trim();
            if (newText.isNotEmpty) {
              onEdit(hook.id, newText);
            }
            Navigator.of(ctx).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentBlue,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Save',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════
class _HookCard extends StatelessWidget {
  const _HookCard({
    required this.hook,
    required this.isSelected,
    required this.index,
    required this.onSelect,
    this.onEdit,
    this.onNotify,
  });

  final GeneratedHook hook;
  final bool isSelected;
  final int index;
  final VoidCallback onSelect;
  final VoidCallback? onEdit;
  final void Function(String message)? onNotify;

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
                  onPressed: onEdit ?? () {},
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
    this.onNotify,
  });

  final String hookText;
  final MomentInfo moment;
  final void Function(String message)? onNotify;

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
                onNotify: onNotify,
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
  const _PhoneMockup({required this.hookText, this.onNotify});

  final String hookText;
  final void Function(String message)? onNotify;

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
                  GestureDetector(
                    onTap: () => onNotify?.call('❤️ Liked!'),
                    child: Icon(PhosphorIconsRegular.heart,
                        size: 20, color: Colors.white.withAlpha(150)),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => onNotify?.call('💬 Comments coming soon'),
                    child: Icon(PhosphorIconsRegular.chatCircle,
                        size: 20, color: Colors.white.withAlpha(150)),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => onNotify?.call('📤 Share coming soon'),
                    child: Icon(PhosphorIconsRegular.shareFat,
                        size: 20, color: Colors.white.withAlpha(150)),
                  ),
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
