import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stat_card.dart';

/// Analytics overview page with stat cards, a weekly activity chart,
/// and a recent projects list.
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  // ── Mock data ──────────────────────────────────────────────────────

  static const _weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekValues = [3, 5, 2, 8, 6, 4, 1]; // processed videos
  static const _weekViews = [120, 340, 90, 560, 410, 210, 45];

  static const _recentProjects = [
    _ProjectRow(
      title: 'Flutter UI Deep-Dive',
      status: 'Completed',
      date: 'Jan 12',
      shorts: 4,
    ),
    _ProjectRow(
      title: 'React vs Flutter Comparison',
      status: 'Completed',
      date: 'Jan 10',
      shorts: 6,
    ),
    _ProjectRow(
      title: 'Building a SaaS from Scratch',
      status: 'Processing',
      date: 'Jan 9',
      shorts: 0,
    ),
    _ProjectRow(
      title: 'Web Dev Weekly #42',
      status: 'Completed',
      date: 'Jan 7',
      shorts: 3,
    ),
    _ProjectRow(
      title: 'AI Tools Round-Up',
      status: 'Completed',
      date: 'Jan 5',
      shorts: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          'Analytics',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stat cards ─────────────────────────────────────────
            _buildStatCards(context),
            const SizedBox(height: 28),

            // ── Section title ──────────────────────────────────────
            _sectionHeader('Weekly Activity'),
            const SizedBox(height: 14),
            _buildWeeklyChart(),
            const SizedBox(height: 28),

            // ── Section title ──────────────────────────────────────
            _sectionHeader('Views This Week'),
            const SizedBox(height: 14),
            _buildViewsChart(),
            const SizedBox(height: 28),

            // ── Section title ──────────────────────────────────────
            _sectionHeader('Recent Projects'),
            const SizedBox(height: 12),
            _buildRecentProjects(),

            const SizedBox(height: 20),

            // ── Insights card ──────────────────────────────────────
            _buildInsightsCard(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // STAT CARDS
  // ══════════════════════════════════════════════════════════════════

  Widget _buildStatCards(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 40;
    final cardW = (width - 12) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: cardW,
          child: const StatCard(
            icon: PhosphorIconsLight.folder,
            label: 'Total Projects',
            value: '12',
            iconColor: AppColors.accent,
          ),
        ),
        SizedBox(
          width: cardW,
          child: const StatCard(
            icon: PhosphorIconsLight.play,
            label: 'Total Views',
            value: '1,775',
            iconColor: AppColors.success,
          ),
        ),
        SizedBox(
          width: cardW,
          child: const StatCard(
            icon: PhosphorIconsLight.scissors,
            label: 'Shorts Created',
            value: '34',
            iconColor: AppColors.accentSecondary,
          ),
        ),
        SizedBox(
          width: cardW,
          child: const StatCard(
            icon: PhosphorIconsLight.checkCircle,
            label: 'Completion Rate',
            value: '83%',
            iconColor: AppColors.warning,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04);
  }

  // ══════════════════════════════════════════════════════════════════
  // WEEKLY ACTIVITY BAR CHART
  // ══════════════════════════════════════════════════════════════════

  Widget _buildWeeklyChart() {
    final maxVal =
        _weekValues.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Chart bars
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final fraction = maxVal > 0 ? _weekValues[i] / maxVal : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          '${_weekValues[i]}',
                          style: GoogleFonts.inter(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Bar
                        AnimatedContainer(
                          duration: Duration(milliseconds: 600 + i * 80),
                          curve: Curves.easeOutCubic,
                          height: 160 * fraction,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.blue400],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Labels
          Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    _weekLabels[i],
                    style: GoogleFonts.inter(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.06);
  }

  // ══════════════════════════════════════════════════════════════════
  // VIEWS BAR CHART
  // ══════════════════════════════════════════════════════════════════

  Widget _buildViewsChart() {
    final maxVal =
        _weekViews.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Chart bars
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final fraction = maxVal > 0 ? _weekViews[i] / maxVal : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          _weekViews[i] >= 100
                              ? '${(_weekViews[i] / 1000).toStringAsFixed(1)}k'
                              : '${_weekViews[i]}',
                          style: GoogleFonts.inter(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Bar
                        AnimatedContainer(
                          duration: Duration(milliseconds: 700 + i * 80),
                          curve: Curves.easeOutCubic,
                          height: 140 * fraction,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.success,
                                AppColors.green400,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Labels
          Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    _weekLabels[i],
                    style: GoogleFonts.inter(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.06);
  }

  // ══════════════════════════════════════════════════════════════════
  // RECENT PROJECTS
  // ══════════════════════════════════════════════════════════════════

  Widget _buildRecentProjects() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _recentProjects.length; i++) ...[
            _buildProjectRow(_recentProjects[i]),
            if (i < _recentProjects.length - 1)
              const Divider(height: 1, indent: 52, color: AppColors.border),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.06);
  }

  Widget _buildProjectRow(_ProjectRow project) {
    final isProcessing = project.status == 'Processing';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Thumbnail placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIconsLight.filmStrip,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  project.date,
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Shorts badge
          if (project.shorts > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentSecondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    PhosphorIconsLight.scissors,
                    color: AppColors.accentSecondary,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${project.shorts}',
                    style: GoogleFonts.inter(
                      color: AppColors.accentSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isProcessing
                  ? AppColors.warningSurface
                  : AppColors.successSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              project.status,
              style: GoogleFonts.inter(
                color: isProcessing ? AppColors.warning : AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // INSIGHTS CARD
  // ══════════════════════════════════════════════════════════════════

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsBold.lightbulb,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Videos with 3+ shorts get 2.4× more views on average. Keep repurposing!',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const PhosphorIcon(
            PhosphorIconsLight.arrowRight,
            color: Colors.white70,
            size: 18,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.06);
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Private model ──────────────────────────────────────────────────

class _ProjectRow {
  final String title;
  final String status;
  final String date;
  final int shorts;

  const _ProjectRow({
    required this.title,
    required this.status,
    required this.date,
    required this.shorts,
  });
}
