import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'short_preview_page.dart';

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

// ── Short Candidate Model ───────────────────────────────────────────
class ShortCandidate {
  const ShortCandidate({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.viralScore,
    required this.hookScore,
    required this.category,
    required this.sourceStart,
    required this.sourceEnd,
    required this.editingStyle,
    required this.retentionEstimate,
    this.isDuplicate = false,
    this.duplicateOf,
    this.isSelected = false,
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final double duration; // seconds
  final double viralScore; // 0-100
  final double hookScore; // 0-100
  final ShortCategory category;
  final String sourceStart; // "02:14"
  final String sourceEnd; // "03:32"
  final String editingStyle; // "Punch-in + Zoom", "Jump Cut", etc.
  final double retentionEstimate; // 0-1
  final bool isDuplicate;
  final String? duplicateOf;
  final bool isSelected;
}

enum ShortCategory {
  funny,
  emotional,
  educational,
  dramatic,
  motivational,
  informational;

  String get label {
    switch (this) {
      case ShortCategory.funny:
        return 'Funny';
      case ShortCategory.emotional:
        return 'Emotional';
      case ShortCategory.educational:
        return 'Educational';
      case ShortCategory.dramatic:
        return 'Dramatic';
      case ShortCategory.motivational:
        return 'Motivational';
      case ShortCategory.informational:
        return 'Informational';
    }
  }

  Color get color {
    switch (this) {
      case ShortCategory.funny:
        return _warningAmber;
      case ShortCategory.emotional:
        return _errorRed;
      case ShortCategory.educational:
        return _accentBlue;
      case ShortCategory.dramatic:
        return _purple;
      case ShortCategory.motivational:
        return _successGreen;
      case ShortCategory.informational:
        return _textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case ShortCategory.funny:
        return PhosphorIconsRegular.smiley;
      case ShortCategory.emotional:
        return PhosphorIconsRegular.heart;
      case ShortCategory.educational:
        return PhosphorIconsRegular.graduationCap;
      case ShortCategory.dramatic:
        return PhosphorIconsRegular.lightning;
      case ShortCategory.motivational:
        return PhosphorIconsRegular.fire;
      case ShortCategory.informational:
        return PhosphorIconsRegular.info;
    }
  }
}

enum ShortFilter {
  all,
  highScore,
  funny,
  emotional,
  educational,
  dramatic;

  String get label {
    switch (this) {
      case ShortFilter.all:
        return 'All';
      case ShortFilter.highScore:
        return 'High Score';
      case ShortFilter.funny:
        return 'Funny';
      case ShortFilter.emotional:
        return 'Emotional';
      case ShortFilter.educational:
        return 'Educational';
      case ShortFilter.dramatic:
        return 'Dramatic';
    }
  }
}

enum SortOption {
  viralScore,
  hookScore,
  recent,
  duration;

  String get label {
    switch (this) {
      case SortOption.viralScore:
        return 'Viral Score';
      case SortOption.hookScore:
        return 'Hook Score';
      case SortOption.recent:
        return 'Most Recent';
      case SortOption.duration:
        return 'Duration';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.viralScore:
        return PhosphorIconsRegular.trendUp;
      case SortOption.hookScore:
        return PhosphorIconsRegular.link;
      case SortOption.recent:
        return PhosphorIconsRegular.clock;
      case SortOption.duration:
        return PhosphorIconsRegular.timer;
    }
  }
}

// ── State ───────────────────────────────────────────────────────────
class ShortsDiscoveryState {
  const ShortsDiscoveryState({
    this.candidates = const [],
    this.filter = ShortFilter.all,
    this.sortOption = SortOption.viralScore,
    this.selectedIds = const {},
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
  });

  final List<ShortCandidate> candidates;
  final ShortFilter filter;
  final SortOption sortOption;
  final Set<String> selectedIds;
  final bool isLoading;
  final bool isGenerating;
  final String? error;

  ShortsDiscoveryState copyWith({
    List<ShortCandidate>? candidates,
    ShortFilter? filter,
    SortOption? sortOption,
    Set<String>? selectedIds,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    bool clearError = false,
  }) {
    return ShortsDiscoveryState(
      candidates: candidates ?? this.candidates,
      filter: filter ?? this.filter,
      sortOption: sortOption ?? this.sortOption,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<ShortCandidate> get filteredCandidates {
    var filtered = List<ShortCandidate>.from(candidates);

    switch (filter) {
      case ShortFilter.all:
        break;
      case ShortFilter.highScore:
        filtered = filtered.where((c) => c.viralScore >= 70).toList();
        break;
      case ShortFilter.funny:
        filtered = filtered
            .where((c) => c.category == ShortCategory.funny)
            .toList();
        break;
      case ShortFilter.emotional:
        filtered = filtered
            .where((c) => c.category == ShortCategory.emotional)
            .toList();
        break;
      case ShortFilter.educational:
        filtered = filtered
            .where((c) => c.category == ShortCategory.educational)
            .toList();
        break;
      case ShortFilter.dramatic:
        filtered = filtered
            .where((c) => c.category == ShortCategory.dramatic)
            .toList();
        break;
    }

    switch (sortOption) {
      case SortOption.viralScore:
        filtered.sort((a, b) => b.viralScore.compareTo(a.viralScore));
        break;
      case SortOption.hookScore:
        filtered.sort((a, b) => b.hookScore.compareTo(a.hookScore));
        break;
      case SortOption.recent:
        break; // Already sorted by default
      case SortOption.duration:
        filtered.sort((a, b) => a.duration.compareTo(b.duration));
        break;
    }

    return filtered;
  }

  int get selectedCount => selectedIds.length;
}

// ── Provider ────────────────────────────────────────────────────────
final shortsDiscoveryProvider = StateNotifierProvider<
    ShortsDiscoveryNotifier, ShortsDiscoveryState>((ref) {
  return ShortsDiscoveryNotifier();
});

class ShortsDiscoveryNotifier extends StateNotifier<ShortsDiscoveryState> {
  ShortsDiscoveryNotifier() : super(const ShortsDiscoveryState()) {
    _loadMockData();
  }

  void _loadMockData() {
    state = state.copyWith(isLoading: true);
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      state = state.copyWith(
        isLoading: false,
        candidates: _mockCandidates,
      );
    });
  }

  void setFilter(ShortFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSortOption(SortOption sort) {
    state = state.copyWith(sortOption: sort);
  }

  void toggleSelection(String id) {
    final selected = Set<String>.from(state.selectedIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    state = state.copyWith(selectedIds: selected);
  }

  void selectAll() {
    state = state.copyWith(
      selectedIds: state.filteredCandidates.map((c) => c.id).toSet(),
    );
  }

  void deselectAll() {
    state = state.copyWith(selectedIds: {});
  }

  void approveSelected() {
    // TODO: Implement actual approval logic
    state = state.copyWith(selectedIds: {});
  }

  void rejectSelected() {
    // TODO: Implement actual rejection logic
    state = state.copyWith(selectedIds: {});
  }

  void generateMore() {
    state = state.copyWith(isGenerating: true);
    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(isGenerating: false);
      // TODO: Add new candidates from API
    });
  }
}

// ── Mock Data ───────────────────────────────────────────────────────
final _mockCandidates = [
  ShortCandidate(
    id: '1',
    title: 'Epic Reaction Moment',
    thumbnailUrl: '',
    duration: 32,
    viralScore: 92,
    hookScore: 88,
    category: ShortCategory.funny,
    sourceStart: '02:14',
    sourceEnd: '02:46',
    editingStyle: 'Punch-in + Zoom',
    retentionEstimate: 0.78,
  ),
  ShortCandidate(
    id: '2',
    title: 'Emotional Breakthrough',
    thumbnailUrl: '',
    duration: 45,
    viralScore: 87,
    hookScore: 91,
    category: ShortCategory.emotional,
    sourceStart: '05:30',
    sourceEnd: '06:15',
    editingStyle: 'Slow-mo + Reverb',
    retentionEstimate: 0.82,
  ),
  ShortCandidate(
    id: '3',
    title: 'Quick Tip #47',
    thumbnailUrl: '',
    duration: 18,
    viralScore: 74,
    hookScore: 70,
    category: ShortCategory.educational,
    sourceStart: '10:02',
    sourceEnd: '10:20',
    editingStyle: 'Jump Cut + Text',
    retentionEstimate: 0.65,
  ),
  ShortCandidate(
    id: '4',
    title: 'The Big Reveal',
    thumbnailUrl: '',
    duration: 28,
    viralScore: 95,
    hookScore: 93,
    category: ShortCategory.dramatic,
    sourceStart: '12:44',
    sourceEnd: '13:12',
    editingStyle: 'Tension Build + Drop',
    retentionEstimate: 0.91,
    isDuplicate: true,
    duplicateOf: 'Moment at 08:15',
  ),
  ShortCandidate(
    id: '5',
    title: 'Motivational Quote Drop',
    thumbnailUrl: '',
    duration: 22,
    viralScore: 68,
    hookScore: 62,
    category: ShortCategory.motivational,
    sourceStart: '15:30',
    sourceEnd: '15:52',
    editingStyle: 'Overlay Text + Music',
    retentionEstimate: 0.55,
  ),
  ShortCandidate(
    id: '6',
    title: 'Behind the Scenes',
    thumbnailUrl: '',
    duration: 38,
    viralScore: 45,
    hookScore: 40,
    category: ShortCategory.informational,
    sourceStart: '20:00',
    sourceEnd: '20:38',
    editingStyle: 'Narrator + B-Roll',
    retentionEstimate: 0.42,
  ),
  ShortCandidate(
    id: '7',
    title: 'Plot Twist Moment',
    thumbnailUrl: '',
    duration: 35,
    viralScore: 89,
    hookScore: 85,
    category: ShortCategory.dramatic,
    sourceStart: '25:10',
    sourceEnd: '25:45',
    editingStyle: 'Reverse Reveal',
    retentionEstimate: 0.84,
  ),
  ShortCandidate(
    id: '8',
    title: 'Hilarious Outtake',
    thumbnailUrl: '',
    duration: 15,
    viralScore: 78,
    hookScore: 72,
    category: ShortCategory.funny,
    sourceStart: '30:22',
    sourceEnd: '30:37',
    editingStyle: 'Zoom + Sound FX',
    retentionEstimate: 0.68,
  ),
];

// ── Score Color Helper ──────────────────────────────────────────────
Color _scoreColor(double score) {
  if (score < 40) return _errorRed;
  if (score <= 70) return _warningAmber;
  return _successGreen;
}

// ── Format Duration ─────────────────────────────────────────────────
String _formatDuration(double seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toInt().toString().padLeft(2, '0');
  return '$m:$s';
}

// ══════════════════════════════════════════════════════════════════════
// SHORTS DISCOVERY PAGE
// ══════════════════════════════════════════════════════════════════════
class ShortsDiscoveryPage extends ConsumerStatefulWidget {
  const ShortsDiscoveryPage({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ShortsDiscoveryPage> createState() =>
      _ShortsDiscoveryPageState();
}

class _ShortsDiscoveryPageState extends ConsumerState<ShortsDiscoveryPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shortsDiscoveryProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1200;
    final columns = isDesktop ? 4 : (isTablet ? 3 : 2);

    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          _buildHeader(state, isDesktop),

          // ── Filter Row ──────────────────────────────────────────
          _buildFilterRow(state),

          // ── Content ─────────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? _buildLoadingState()
                : state.filteredCandidates.isEmpty
                    ? _buildEmptyState()
                    : _buildGrid(state, columns),
          ),

          // ── Bottom Action Bar ───────────────────────────────────
          if (state.selectedCount > 0) _buildBatchActionBar(state),

          // ── Generate More Button ────────────────────────────────
          _buildGenerateButton(state),
        ],
      ),
    );
  }

  Widget _buildHeader(ShortsDiscoveryState state, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          // Title
          PhosphorIconsRegular.filmStrip.icon(size: 24, color: _accentBlue),
          const SizedBox(width: 12),
          Text(
            'Discovered Shorts',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accentBlue.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentBlue.withAlpha(60)),
            ),
            child: Text(
              '${state.filteredCandidates.length}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _accentBlue,
              ),
            ),
          ),
          const Spacer(),

          // Sort Button
          PopupMenuButton<SortOption>(
            onSelected: ref.read(shortsDiscoveryProvider.notifier).setSortOption,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(state.sortOption.icon, size: 18, color: _textSecondary),
                const SizedBox(width: 4),
                Text(
                  state.sortOption.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_drop_down, color: _textSecondary),
              ],
            ),
            color: _cardColor,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _borderColor),
            ),
            itemBuilder: (context) => SortOption.values.map((option) {
              return PopupMenuItem<SortOption>(
                value: option,
                child: Row(
                  children: [
                    Icon(option.icon,
                        size: 16,
                        color: state.sortOption == option
                            ? _accentBlue
                            : _textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      option.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: state.sortOption == option
                            ? _accentBlue
                            : _textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(width: 8),

          // Select All toggle
          if (state.filteredCandidates.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                if (state.selectedCount ==
                    state.filteredCandidates.length) {
                  ref
                      .read(shortsDiscoveryProvider.notifier)
                      .deselectAll();
                } else {
                  ref.read(shortsDiscoveryProvider.notifier).selectAll();
                }
              },
              icon: Icon(
                state.selectedCount == state.filteredCandidates.length
                    ? PhosphorIconsRegular.checkSquare
                    : PhosphorIconsRegular.square,
                size: 18,
                color: _textSecondary,
              ),
              label: Text(
                state.selectedCount == state.filteredCandidates.length
                    ? 'Deselect All'
                    : 'Select All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(ShortsDiscoveryState state) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ShortFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = ShortFilter.values[index];
          final isActive = state.filter == filter;
          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                label: Text(
                  filter.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : _textSecondary,
                  ),
                ),
                selected: isActive,
                onSelected: (_) {
                  ref
                      .read(shortsDiscoveryProvider.notifier)
                      .setFilter(filter);
                },
                backgroundColor: _cardColor,
                selectedColor: _accentBlue,
                showCheckmark: false,
                side: BorderSide(
                  color: isActive
                      ? _accentBlue
                      : _borderColor,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(ShortsDiscoveryState state, int columns) {
    final candidates = state.filteredCandidates;
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 16.0;
        final totalSpacing = spacing * (columns - 1);
        final cardWidth =
            (constraints.maxWidth - 48 - totalSpacing) / columns;
        // Limit the card width on very wide screens
        final effectiveCardWidth = cardWidth > 340 ? 340.0 : cardWidth;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(candidates.length, (index) {
              final candidate = candidates[index];
              final isSelected =
                  state.selectedIds.contains(candidate.id);
              return SizedBox(
                width: effectiveCardWidth,
                child: _ShortCandidateCard(
                  candidate: candidate,
                  isSelected: isSelected,
                  index: index,
                  onTap: () {
                    ref
                        .read(shortsDiscoveryProvider.notifier)
                        .toggleSelection(candidate.id);
                  },
                  onPreview: () {
                    // Navigate to preview - use the shortId from candidate
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShortPreviewPage(
                          shortId: candidate.id,
                        ),
                      ),
                    );
                  },
                  onApprove: () {
                    // TODO: Approve
                  },
                  onReject: () {
                    // TODO: Reject
                  },
                  onEdit: () {
                    // TODO: Open editor
                  },
                  onRegenerate: () {
                    // TODO: Regenerate
                  },
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildBatchActionBar(ShortsDiscoveryState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          // Count
          Icon(PhosphorIconsRegular.checks, size: 20, color: _accentBlue),
          const SizedBox(width: 10),
          Text(
            '${state.selectedCount} selected',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const Spacer(),

          // Approve All
          _BatchActionButton(
            label: 'Approve All',
            icon: PhosphorIconsRegular.checkCircle,
            color: _successGreen,
            onPressed: ref
                .read(shortsDiscoveryProvider.notifier)
                .approveSelected,
          ),
          const SizedBox(width: 10),

          // Reject All
          _BatchActionButton(
            label: 'Reject All',
            icon: PhosphorIconsRegular.xCircle,
            color: _errorRed,
            onPressed: ref
                .read(shortsDiscoveryProvider.notifier)
                .rejectSelected,
          ),
          const SizedBox(width: 10),

          // Export Selected
          _BatchActionButton(
            label: 'Export',
            icon: PhosphorIconsRegular.export,
            color: _purple,
            onPressed: () {
              // TODO: Export selected
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(ShortsDiscoveryState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: _bgColor,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: state.isGenerating
              ? null
              : ref
                  .read(shortsDiscoveryProvider.notifier)
                  .generateMore,
          icon: state.isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(PhosphorIconsRegular.sparkle, size: 20),
          label: Text(
            state.isGenerating ? 'Generating…' : 'Generate More Shorts',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _accentBlue.withAlpha(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _accentBlue),
          const SizedBox(height: 16),
          Text(
            'Discovering shorts…',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration placeholder
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(70),
                border: Border.all(color: _borderColor),
              ),
              child: Icon(
                PhosphorIconsRegular.filmStrip,
                size: 56,
                color: _textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No shorts found yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate your first batch of shorts\nfrom detected viral moments.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// SHORT CANDIDATE CARD
// ══════════════════════════════════════════════════════════════════════
class _ShortCandidateCard extends StatelessWidget {
  const _ShortCandidateCard({
    required this.candidate,
    required this.isSelected,
    required this.index,
    required this.onTap,
    required this.onPreview,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
    required this.onRegenerate,
  });

  final ShortCandidate candidate;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onPreview;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _accentBlue : _borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _accentBlue.withAlpha(40),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ────────────────────────────────────────
            _buildThumbnail(),

            // ── Content ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  _buildTitleRow(),
                  const SizedBox(height: 8),

                  // Scores
                  _buildScores(),
                  const SizedBox(height: 10),

                  // Category + Editing Style
                  _buildTags(),
                  const SizedBox(height: 8),

                  // Source timestamp
                  _buildTimestamp(),
                  const SizedBox(height: 10),

                  // Retention bar
                  _buildRetentionBar(),

                  // Duplicate warning
                  if (candidate.isDuplicate) ...[
                    const SizedBox(height: 8),
                    _buildDuplicateWarning(),
                  ],

                  const SizedBox(height: 12),

                  // Actions
                  _buildActions(context),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: (index * 60).ms,
        )
        .slideY(begin: 0.06, end: 0, duration: 400.ms, delay: (index * 60).ms);
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        // Thumbnail placeholder
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15),
            ),
            gradient: LinearGradient(
              colors: [
                candidate.category.color.withAlpha(30),
                _surfaceColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              candidate.category.icon,
              size: 40,
              color: candidate.category.color.withAlpha(80),
            ),
          ),
        ),

        // Duration badge
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _formatDuration(candidate.duration),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Selection indicator
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected
                  ? _accentBlue
                  : Colors.black.withAlpha(150),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isSelected ? _accentBlue : Colors.white.withAlpha(60),
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),

        // Viral score badge
        Positioned(
          top: 8,
          left: 8,
          child: _ScoreBadge(
            score: candidate.viralScore,
            label: 'Viral',
          ),
        ),
      ],
    );
  }

  Widget _buildTitleRow() {
    return Text(
      candidate.title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildScores() {
    return Row(
      children: [
        // Viral Score
        _buildScoreIndicator('Viral', candidate.viralScore),
        const SizedBox(width: 12),
        // Hook Score
        _buildScoreIndicator('Hook', candidate.hookScore),
      ],
    );
  }

  Widget _buildScoreIndicator(String label, double score) {
    final color = _scoreColor(score);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                score.toInt().toString(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: _borderColor,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        // Category tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: candidate.category.color.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: candidate.category.color.withAlpha(50),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(candidate.category.icon, size: 12, color: candidate.category.color),
              const SizedBox(width: 4),
              Text(
                candidate.category.label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: candidate.category.color,
                ),
              ),
            ],
          ),
        ),

        // Editing style badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _purple.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _purple.withAlpha(50)),
          ),
          child: Text(
            candidate.editingStyle,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _purple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp() {
    return Row(
      children: [
        Icon(PhosphorIconsRegular.clock, size: 13, color: _textTertiary),
        const SizedBox(width: 5),
        Text(
          '${candidate.sourceStart} → ${candidate.sourceEnd}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: _textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildRetentionBar() {
    final color = _scoreColor(candidate.retentionEstimate * 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Est. Retention',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _textTertiary,
              ),
            ),
            const Spacer(),
            Text(
              '${(candidate.retentionEstimate * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: candidate.retentionEstimate,
            backgroundColor: _borderColor,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildDuplicateWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _warningAmber.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _warningAmber.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.warning, size: 14, color: _warningAmber),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Similar to ${candidate.duplicateOf}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _warningAmber,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: PhosphorIconsRegular.play,
          label: 'Preview',
          color: _accentBlue,
          onTap: onPreview,
        ),
        const SizedBox(width: 6),
        _ActionButton(
          icon: PhosphorIconsRegular.check,
          label: 'Approve',
          color: _successGreen,
          onTap: onApprove,
        ),
        const SizedBox(width: 6),
        _ActionButton(
          icon: PhosphorIconsRegular.x,
          label: 'Reject',
          color: _errorRed,
          onTap: onReject,
        ),
        const Spacer(),
        _IconActionButton(
          icon: PhosphorIconsRegular.pencilSimple,
          color: _textSecondary,
          onTap: onEdit,
          tooltip: 'Edit',
        ),
        const SizedBox(width: 4),
        _IconActionButton(
          icon: PhosphorIconsRegular.arrowsClockwise,
          color: _textSecondary,
          onTap: onRegenerate,
          tooltip: 'Regenerate',
        ),
      ],
    );
  }
}

// ── Small reusable widgets ──────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.label});

  final double score;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _scoreColor(score).withAlpha(200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label ${score.toInt()}',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _BatchActionButton extends StatelessWidget {
  const _BatchActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(25),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withAlpha(50)),
        ),
      ),
    );
  }
}

// Extension for icon on IconData
extension _IconDataExt on IconData {
  Widget icon({double size = 24, Color? color}) {
    return Icon(this, size: size, color: color);
  }
}


