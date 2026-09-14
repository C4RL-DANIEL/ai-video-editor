import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_video_editor/core/theme/app_colors.dart';
import 'package:ai_video_editor/features/projects/presentation/project_providers.dart';
import 'package:ai_video_editor/core/navigation/app_router.dart';

// ────────────────────────────────────────────────────────────────
// Project detail page
// ────────────────────────────────────────────────────────────────
class ProjectDetailPage extends ConsumerStatefulWidget {
  final Project? project;
  final String? projectId;

  const ProjectDetailPage({super.key, this.project, this.projectId});

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Project? _loadedProject;
  bool _isLoading = false;
  String? _error;

  static const _tabLabels = ['Overview', 'Shorts', 'Long-Form', 'Analysis', 'Editor'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _initProject();
  }

  void _initProject() {
    if (widget.project != null) {
      _loadedProject = widget.project;
      // Also set it in the current project provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentProjectProvider.notifier).set(widget.project!);
      });
    } else if (widget.projectId != null) {
      _loadProject(widget.projectId!);
    }
  }

  Future<void> _loadProject(String id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(currentProjectProvider.notifier).load(id);
      final project = ref.read(currentProjectProvider);
      if (mounted) {
        setState(() {
          _loadedProject = project;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load project: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If navigated with just a projectId, create a demo project
    final project = _loadedProject ?? Project(
      id: widget.projectId ?? 'unknown',
      name: 'Project ${widget.projectId ?? ""}',
      status: ProjectStatus.ready,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(PhosphorIconsRegular.warningCircle, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_error!, style: GoogleFonts.inter(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (widget.projectId != null) _loadProject(widget.projectId!);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──
          SliverAppBar(
            backgroundColor: AppColors.surface,
            pinned: true,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.caretLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              project.name,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showOverflowMenu(context, project),
                icon: const Icon(PhosphorIconsRegular.dotsThreeVertical, color: Colors.white),
              ),
            ],
          ),
          // ── Header with status ──
          SliverToBoxAdapter(child: _buildHeader(project)),
          // ── Tab bar ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              labels: _tabLabels,
            ),
          ),
          // ── Tab content ──
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(project: project),
                _ShortsTab(project: project),
                _LongFormTab(project: project),
                _AnalysisTab(project: project),
                _EditorTab(project: project),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOverflowMenu(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(PhosphorIconsBold.pencilSimple, color: AppColors.textSecondary),
              title: Text('Rename Project', style: GoogleFonts.inter(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, project);
              },
            ),
            ListTile(
              leading: const Icon(PhosphorIconsBold.trash, color: AppColors.error),
              title: Text('Delete Project', style: GoogleFonts.inter(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, project);
              },
            ),
            ListTile(
              leading: const Icon(PhosphorIconsBold.archive, color: AppColors.textSecondary),
              title: Text('Archive Project', style: GoogleFonts.inter(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _archiveProject(project);
              },
            ),
            ListTile(
              leading: const Icon(PhosphorIconsBold.share, color: AppColors.textSecondary),
              title: Text('Share Project', style: GoogleFonts.inter(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  _snackBar('Share functionality coming soon'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Project project) {
    final controller = TextEditingController(text: project.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Rename Project', style: GoogleFonts.inter(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Project name',
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await ref.read(projectListProvider.notifier).updateProject(
                  project.id,
                  name: newName,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text('Save', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete Project', style: GoogleFonts.inter(color: AppColors.error)),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This action cannot be undone.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(projectListProvider.notifier).delete(project.id);
              if (context.mounted) {
                Navigator.pop(context);
                context.go(RoutePaths.projects);
              }
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _archiveProject(Project project) async {
    await ref.read(projectListProvider.notifier).updateProject(
      project.id,
      status: ProjectStatus.archived,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Project archived'),
      );
    }
  }

  // ── Header with gradient + status ──
  Widget _buildHeader(Project project) {
    // Compute analysis progress from project metadata
    final analysisProgress = _computeAnalysisProgress(project);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & Source row
          Row(
            children: [
              _DetailStatusChip(status: project.status),
              const SizedBox(width: 10),
              if (project.metadata.containsKey('sourcePlatform'))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsRegular.globe, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${project.metadata['sourcePlatform']} Source',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Text(
                _formatDate(project.createdAt),
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Quick action buttons ──
          Row(
            children: [
              _ActionButton(
                label: 'Generate Shorts',
                icon: PhosphorIconsBold.videoCamera,
                color: AppColors.purple,
                onTap: () => context.go(
                  RoutePaths.shortsForProject(project.id),
                ),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                label: 'Build Long-Form',
                icon: PhosphorIconsBold.filmStrip,
                color: AppColors.accent,
                onTap: () => context.go(
                  RoutePaths.longFormForProject(project.id),
                ),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                label: 'Open Editor',
                icon: PhosphorIconsBold.pencilSimple,
                color: AppColors.success,
                onTap: () => context.go(
                  RoutePaths.editorForProject(project.id),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  double _computeAnalysisProgress(Project project) {
    if (project.status == ProjectStatus.completed) return 1.0;
    if (project.status == ProjectStatus.ready) return 1.0;
    if (project.status == ProjectStatus.error || project.status == ProjectStatus.failed) return 0.0;
    if (project.status == ProjectStatus.draft) return 0.0;
    if (project.status == ProjectStatus.uploaded) return 0.1;
    if (project.status == ProjectStatus.analyzing) {
      // Check metadata for progress percentage
      final progress = project.metadata['analysisProgress'];
      if (progress is num) return progress.toDouble().clamp(0.0, 1.0);
      return 0.5;
    }
    if (project.status == ProjectStatus.processing) {
      final progress = project.metadata['processingProgress'];
      if (progress is num) return progress.toDouble().clamp(0.0, 1.0);
      return 0.7;
    }
    return 0.0;
  }

  SnackBar _snackBar(String text) {
    return SnackBar(
      content: Text(text, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: AppColors.card,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

// ────────────────────────────────────────────────────────────────
// Tab bar delegate
// ────────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> labels;

  _TabBarDelegate({required this.tabController, required this.labels});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        indicatorColor: AppColors.accent,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        dividerColor: Colors.transparent,
        tabs: labels.map((l) => Tab(text: l)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => true;
}

// ────────────────────────────────────────────────────────────────
// Detail status chip
// ────────────────────────────────────────────────────────────────
class _DetailStatusChip extends StatelessWidget {
  final ProjectStatus status;
  const _DetailStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == ProjectStatus.processing)
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: _color,
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (status) {
      case ProjectStatus.processing:
        return AppColors.warning;
      case ProjectStatus.ready:
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.archived:
        return AppColors.textMuted;
      case ProjectStatus.error:
      case ProjectStatus.failed:
        return AppColors.error;
      case ProjectStatus.draft:
      case ProjectStatus.uploaded:
      case ProjectStatus.analyzing:
        return AppColors.textSecondary;
      default:
        return AppColors.textMuted;
    }
  }

  String get _label {
    switch (status) {
      case ProjectStatus.processing:
        return 'Processing';
      case ProjectStatus.ready:
        return 'Ready';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.archived:
        return 'Archived';
      case ProjectStatus.error:
        return 'Error';
      case ProjectStatus.failed:
        return 'Failed';
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.uploaded:
        return 'Uploaded';
      case ProjectStatus.analyzing:
        return 'Analyzing';
      default:
        return 'Unknown';
    }
  }
}

// ────────────────────────────────────────────────────────────────
// Action button
// ────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ════════════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final Project project;
  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Stats grid ──
        _buildStatsRow(),
        const SizedBox(height: 20),

        // ── Processing timeline ──
        _buildProcessingTimeline(),
        const SizedBox(height: 20),

        // ── Analysis progress ──
        _buildAnalysisProgress(),
        const SizedBox(height: 20),

        // ── Recent Shorts preview ──
        _buildRecentShorts(context),
        const SizedBox(height: 20),

        // ── Source video info ──
        _buildSourceInfo(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStatsRow() {
    // Compute duration from metadata
    final durationSeconds = project.metadata['durationSeconds'];
    final String durationText;
    if (durationSeconds is num) {
      final totalSeconds = durationSeconds.toInt();
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      durationText = '${minutes}:${seconds.toString().padLeft(2, '0')}';
    } else {
      durationText = '--:--';
    }

    // Compute virality score from metadata
    final viralityScore = project.metadata['viralityScore'];
    final String scoreText;
    if (viralityScore is num) {
      scoreText = '${(viralityScore * 100).toInt()}%';
    } else {
      scoreText = '--';
    }

    final stats = [
      _StatItem(
        icon: PhosphorIconsFill.videoCamera,
        value: '${project.shortsCount}',
        label: 'Shorts',
        color: AppColors.purple,
      ),
      _StatItem(
        icon: PhosphorIconsFill.filmStrip,
        value: '${project.longFormCount}',
        label: 'Long-Form',
        color: AppColors.accent,
      ),
      _StatItem(
        icon: PhosphorIconsFill.clock,
        value: durationText,
        label: 'Duration',
        color: AppColors.success,
      ),
      _StatItem(
        icon: PhosphorIconsFill.chartBar,
        value: scoreText,
        label: 'Score',
        color: AppColors.warning,
      ),
    ];

    return Row(
      children: stats.map((s) => Expanded(child: _StatCard(stat: s))).toList(),
    );
  }

  Widget _buildProcessingTimeline() {
    // Determine completed stages based on project status
    final stages = [
      _TimelineStep(
        label: 'Upload',
        icon: PhosphorIconsBold.uploadSimple,
        isCompleted: _isStageCompleted(0),
      ),
      _TimelineStep(
        label: 'Analysis',
        icon: PhosphorIconsBold.magnifyingGlass,
        isCompleted: _isStageCompleted(1),
      ),
      _TimelineStep(
        label: 'AI Processing',
        icon: PhosphorIconsBold.brain,
        isCompleted: _isStageCompleted(2),
      ),
      _TimelineStep(
        label: 'Generation',
        icon: PhosphorIconsBold.magicWand,
        isCompleted: _isStageCompleted(3),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processing Timeline',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(stages.length, (i) {
            final stage = stages[i];
            final isLast = i == stages.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: stage.isCompleted
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: stage.isCompleted ? AppColors.success : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        stage.isCompleted ? PhosphorIconsBold.check : stage.icon,
                        size: 14,
                        color: stage.isCompleted ? AppColors.success : AppColors.textMuted,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 24,
                        color: stage.isCompleted
                            ? AppColors.success.withOpacity(0.5)
                            : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      stage.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: stage.isCompleted ? FontWeight.w600 : FontWeight.w500,
                        color: stage.isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  bool _isStageCompleted(int stageIndex) {
    switch (project.status) {
      case ProjectStatus.draft:
        return false;
      case ProjectStatus.uploaded:
        return stageIndex == 0;
      case ProjectStatus.analyzing:
        return stageIndex == 0;
      case ProjectStatus.processing:
        return stageIndex <= 1;
      case ProjectStatus.ready:
        return stageIndex <= 2;
      case ProjectStatus.completed:
        return true;
      case ProjectStatus.error:
      case ProjectStatus.failed:
        return stageIndex <= 1;
      case ProjectStatus.archived:
        return true;
      default:
        return false;
    }
  }

  Widget _buildAnalysisProgress() {
    // Compute analysis progress from project status and metadata
    final double progress;
    final String statusText;
    
    switch (project.status) {
      case ProjectStatus.completed:
      case ProjectStatus.ready:
        progress = 1.0;
        statusText = 'Analysis complete';
      case ProjectStatus.analyzing:
        final p = project.metadata['analysisProgress'];
        progress = (p is num) ? p.toDouble().clamp(0.0, 1.0) : 0.5;
        statusText = 'Processing highlights & scenes…';
      case ProjectStatus.processing:
        final p = project.metadata['processingProgress'];
        progress = (p is num) ? p.toDouble().clamp(0.0, 1.0) : 0.7;
        statusText = 'AI processing in progress…';
      case ProjectStatus.error:
      case ProjectStatus.failed:
        progress = 0.0;
        statusText = 'Analysis failed';
      case ProjectStatus.uploaded:
        progress = 0.1;
        statusText = 'Awaiting analysis…';
      default:
        progress = 0.0;
        statusText = 'No analysis data yet';
    }

    final percentText = progress >= 1.0 ? '100%' : '${(progress * 100).toInt()}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 30,
            lineWidth: 5,
            percent: progress,
            center: Text(
              percentText,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
            progressColor: AppColors.accent,
            backgroundColor: AppColors.border,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Pipeline',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildRecentShorts(BuildContext context) {
    final shortsCount = project.shortsCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Shorts',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (shortsCount > 0)
              TextButton(
                onPressed: () => context.go(
                  RoutePaths.shortsForProject(project.id),
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.accent),
                ),
              ),
          ],
        ),
        if (shortsCount == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  PhosphorIconsBold.videoCamera,
                  color: AppColors.textMuted.withOpacity(0.5),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No shorts generated yet',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shortsCount,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final shortId = 'short_$index';
                return GestureDetector(
                  onTap: () => context.go(
                    RoutePaths.shortDetailPath(project.id, shortId),
                  ),
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIconsFill.videoCamera,
                          color: AppColors.purple.withOpacity(0.6),
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Short ${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 250.ms, delay: Duration(milliseconds: 50 * index)),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSourceInfo() {
    // Pull real data from metadata, with empty state fallback
    final platform = project.metadata['sourcePlatform'] as String?;
    final resolution = project.metadata['resolution'] as String?;
    final fps = project.metadata['fps'] as num?;
    final durationSeconds = project.metadata['durationSeconds'] as num?;
    final fileSize = project.metadata['fileSizeMB'] as num?;
    final format = project.metadata['format'] as String?;

    final hasSourceData = platform != null || resolution != null || fps != null;

    if (!hasSourceData) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(PhosphorIconsBold.globe, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Source Video',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    PhosphorIconsRegular.info,
                    color: AppColors.textMuted.withOpacity(0.5),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No source video data available',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload a video to see source details',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
    }

    // Build duration string from seconds
    String durationText = '--';
    if (durationSeconds != null) {
      final totalSeconds = durationSeconds.toInt();
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      durationText = '$minutes min $seconds sec';
    }

    // Build file size string
    String fileSizeText = '--';
    if (fileSize != null) {
      fileSizeText = '${fileSize.toStringAsFixed(0)} MB';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsBold.globe, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Source Video',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (platform != null) _InfoRow(label: 'Platform', value: platform),
          if (resolution != null) _InfoRow(label: 'Resolution', value: resolution),
          if (fps != null) _InfoRow(label: 'FPS', value: '${fps.toInt()}'),
          if (durationSeconds != null) _InfoRow(label: 'Duration', value: durationText),
          if (fileSize != null) _InfoRow(label: 'Size', value: fileSizeText),
          if (format != null) _InfoRow(label: 'Format', value: format),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  BoxDecoration _cardDeco() => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      );
}

// ────────────────────────────────────────────────────────────────
// Timeline step
// ────────────────────────────────────────────────────────────────
class _TimelineStep {
  final String label;
  final IconData icon;
  final bool isCompleted;

  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.isCompleted,
  });
}

// ────────────────────────────────────────────────────────────────
// Stat item
// ────────────────────────────────────────────────────────────────
class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

// ────────────────────────────────────────────────────────────────
// Stat card
// ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _StatItem stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(stat.icon, size: 18, color: stat.color),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ────────────────────────────────────────────────────────────────
// Info row
// ────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SHORTS TAB
// ════════════════════════════════════════════════════════════════
class _ShortsTab extends StatelessWidget {
  final Project project;
  const _ShortsTab({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.shortsCount == 0) {
      return _EmptyTabContent(
        icon: PhosphorIconsBold.videoCamera,
        title: 'No shorts yet',
        subtitle: 'Generate shorts from your source video',
        actionLabel: 'Generate Shorts',
        onAction: () => context.go(
          RoutePaths.shortsForProject(project.id),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: project.shortsCount,
      itemBuilder: (context, index) {
        final shortId = 'short_$index';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  PhosphorIconsFill.videoCamera,
                  color: AppColors.purple.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Short #${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generated',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Ready',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.go(
                  RoutePaths.shortDetailPath(project.id, shortId),
                ),
                icon: const Icon(PhosphorIconsBold.play, size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index));
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// LONG-FORM TAB
// ════════════════════════════════════════════════════════════════
class _LongFormTab extends StatelessWidget {
  final Project project;
  const _LongFormTab({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.longFormCount == 0) {
      return _EmptyTabContent(
        icon: PhosphorIconsBold.filmStrip,
        title: 'No long-form videos yet',
        subtitle: 'Build a long-form video from your source',
        actionLabel: 'Build Long-Form',
        onAction: () => context.go(
          RoutePaths.longFormForProject(project.id),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: project.longFormCount,
      itemBuilder: (context, index) {
        final longFormId = 'longform_$index';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  PhosphorIconsFill.filmStrip,
                  color: AppColors.accent.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Long-Form #${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edited',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.go(
                  RoutePaths.longFormDetailPath(project.id, longFormId),
                ),
                icon: const Icon(PhosphorIconsBold.play, size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 60 * index));
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ANALYSIS TAB
// ════════════════════════════════════════════════════════════════
class _AnalysisTab extends StatelessWidget {
  final Project project;
  const _AnalysisTab({required this.project});

  @override
  Widget build(BuildContext context) {
    // Pull analysis data from project metadata
    final scenesCount = project.metadata['scenesCount'] as num?;
    final wordsCount = project.metadata['wordsCount'] as num?;
    final momentsCount = project.metadata['momentsCount'] as num?;
    final highlightsCount = project.metadata['highlightsCount'] as num?;

    // Check if there's any analysis data
    final hasAnalysisData = scenesCount != null || wordsCount != null || momentsCount != null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Pipeline status
        _buildPipelineCard(),
        const SizedBox(height: 16),
        // Scene detection
        _buildMetricCard(
          title: 'Scene Detection',
          value: scenesCount != null
              ? '${scenesCount.toInt()} scenes identified'
              : 'No data yet',
          progress: scenesCount != null ? 0.9 : 0.0,
          color: AppColors.purple,
        ),
        const SizedBox(height: 12),
        // Transcription
        _buildMetricCard(
          title: 'Transcription',
          value: wordsCount != null
              ? '${wordsCount.toInt()} words transcribed'
              : 'No data yet',
          progress: wordsCount != null ? 1.0 : 0.0,
          color: AppColors.success,
        ),
        const SizedBox(height: 12),
        // Sentiment
        _buildMetricCard(
          title: 'Sentiment Analysis',
          value: momentsCount != null
              ? 'High-energy moments detected'
              : 'No data yet',
          progress: momentsCount != null ? 0.6 : 0.0,
          color: AppColors.warning,
        ),
        const SizedBox(height: 12),
        // Highlights
        _buildMetricCard(
          title: 'Highlight Extraction',
          value: highlightsCount != null
              ? '${highlightsCount.toInt()} key moments found'
              : 'No data yet',
          progress: highlightsCount != null ? 0.8 : 0.0,
          color: AppColors.accent,
        ),
        if (!hasAnalysisData) ...[
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(
                  PhosphorIconsRegular.magnifyingGlass,
                  color: AppColors.textMuted.withOpacity(0.5),
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  'No analysis data available',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Run analysis on your project to see insights here',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPipelineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Pipeline',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The AI analyzes your video for optimal content repurposing.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                progress > 0 ? '${(progress * 100).toInt()}%' : '--',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(progress > 0 ? color : AppColors.border),
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ════════════════════════════════════════════════════════════════
// EDITOR TAB
// ════════════════════════════════════════════════════════════════
class _EditorTab extends StatelessWidget {
  final Project project;
  const _EditorTab({required this.project});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsBold.pencilSimple,
                color: AppColors.success,
                size: 36,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'Video Editor',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Edit your video with AI-powered tools',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Material(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => context.go(
                  RoutePaths.editorForProject(project.id),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: Text(
                    'Open Editor',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Empty tab content
// ────────────────────────────────────────────────────────────────
class _EmptyTabContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyTabContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Material(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
