import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:ai_video_editor/core/theme/app_colors.dart';
import 'package:ai_video_editor/features/projects/presentation/create_project_page.dart';
import 'package:ai_video_editor/features/projects/presentation/project_detail_page.dart';
import 'package:ai_video_editor/features/projects/presentation/project_providers.dart';

// Re-export for backward compatibility
export 'package:ai_video_editor/features/projects/presentation/project_providers.dart'
    show Project, ProjectStatus;

// ────────────────────────────────────────────────────────────────
// Projects list page
// ────────────────────────────────────────────────────────────────
class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  // --- Demo data -------------------------------------------------
  List<Project> _projects = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0=All 1=Processing 2=Ready 3=Archived

  final List<String> _filterLabels = ['All', 'Processing', 'Ready', 'Archived'];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _isLoading = false;
      _projects = [
        Project(
          id: '1',
          name: 'React Tutorial Series',
          status: ProjectStatus.ready,
          shortsCount: 12,
          longFormCount: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Project(
          id: '2',
          name: 'Flutter Workshop 2024',
          status: ProjectStatus.processing,
          shortsCount: 5,
          longFormCount: 1,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Project(
          id: '3',
          name: 'AI Conference Talk',
          status: ProjectStatus.ready,
          shortsCount: 20,
          longFormCount: 5,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        Project(
          id: '4',
          name: 'Product Launch Video',
          status: ProjectStatus.archived,
          shortsCount: 8,
          longFormCount: 2,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Project(
          id: '5',
          name: 'Cooking with Docker',
          status: ProjectStatus.error,
          shortsCount: 0,
          longFormCount: 0,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        Project(
          id: '6',
          name: 'Travel Vlog Compilation',
          status: ProjectStatus.ready,
          shortsCount: 15,
          longFormCount: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];
    });
  }

  List<Project> get _filteredProjects {
    var list = _projects;

    // Search
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter
    switch (_selectedFilter) {
      case 1:
        list = list.where((p) => p.status == ProjectStatus.processing).toList();
        break;
      case 2:
        list = list.where((p) => p.status == ProjectStatus.ready).toList();
        break;
      case 3:
        list = list.where((p) => p.status == ProjectStatus.archived).toList();
        break;
    }

    return list;
  }

  // ── Navigation ──
  void _openCreateProject() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CreateProjectPage(),
      ),
    );
  }

  void _openProjectDetail(Project project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectDetailPage(project: project),
      ),
    );
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final projects = _filteredProjects;
    final isEmpty = projects.isEmpty && !_isLoading;

    return SafeArea(
      child: Column(
        children: [
          // ── Header ──
          _buildHeader(),
          // ── Search bar ──
          _buildSearchBar(),
          // ── Filter chips ──
          _buildFilterChips(),
          const SizedBox(height: 4),
          // ── Content ──
          Expanded(
            child: isEmpty
                ? _buildEmptyState()
                : _buildProjectGrid(screenWidth, projects),
          ),
        ],
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            'My Projects',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // New project button
          Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: _openCreateProject,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsBold.plus, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'New Project',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 50.ms).slideY(begin: -0.05);
  }

  // ── Search bar ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search projects…',
          hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.textMuted, size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(PhosphorIconsRegular.xCircle, color: AppColors.textMuted, size: 18),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  // ── Filter chips ──
  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filterLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent.withOpacity(0.15) : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.accent.withOpacity(0.4) : AppColors.border,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _filterLabels[index],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 150.ms);
  }

  // ── Project grid ──
  Widget _buildProjectGrid(double screenWidth, List<Project> projects) {
    // Responsive columns: 2 on phone, 3 on tablet, 4 on desktop
    int crossAxisCount = 2;
    if (screenWidth >= 1400) {
      crossAxisCount = 4;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
    }

    if (_isLoading) {
      return _buildLoadingGrid(crossAxisCount);
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: _loadProjects,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return _ProjectCard(
            project: projects[index],
            onTap: () => _openProjectDetail(projects[index]),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: Duration(milliseconds: 60 * index))
              .slideY(begin: 0.06);
        },
      ),
    );
  }

  // ── Loading grid ──
  Widget _buildLoadingGrid(int columns) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(
        onPlay: (c) => c.repeat(reverse: true),
      ).shimmer(
        duration: 1200.ms,
        color: AppColors.border.withOpacity(0.3),
      ),
    );
  }

  // ── Empty state ──
  Widget _buildEmptyState() {
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
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsBold.folderOpen,
                color: AppColors.accent,
                size: 36,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'No projects yet',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to start\nrepurposing your videos with AI',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Material(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _openCreateProject,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsBold.plus, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Create your first project',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Project card widget
// ────────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _statusColor.withOpacity(0.3),
                          AppColors.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Center(
                      child: Icon(
                        PhosphorIconsBold.filmStrip,
                        size: 36,
                        color: _statusColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _StatusBadge(status: project.status),
                  ),
                ],
              ),
            ),
            // ── Info ──
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    // Counts row
                    Row(
                      children: [
                        _CountBadge(
                          icon: PhosphorIconsFill.videoCamera,
                          count: project.shortsCount,
                          color: AppColors.purple,
                          label: 'Shorts',
                        ),
                        const SizedBox(width: 10),
                        _CountBadge(
                          icon: PhosphorIconsFill.filmStrip,
                          count: project.longFormCount,
                          color: AppColors.accent,
                          label: 'Long',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(project.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (project.status) {
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
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

// ────────────────────────────────────────────────────────────────
// Status badge
// ────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: GoogleFonts.inter(
              fontSize: 10,
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
    }
  }
}

// ────────────────────────────────────────────────────────────────
// Count badge
// ────────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final String label;

  const _CountBadge({
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          '$count $label',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
