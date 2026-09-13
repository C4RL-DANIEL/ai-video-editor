import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:ai_video_editor/features/projects/presentation/projects_list_page.dart';
import 'package:ai_video_editor/features/upload/presentation/upload_page.dart' as upload;
import 'package:ai_video_editor/features/analysis/presentation/analytics_page.dart' as analytics;
import 'package:ai_video_editor/features/settings/presentation/settings_page.dart' as settings;

// ────────────────────────────────────────────────────────────────
// Color palette
// ────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const background = Color(0xFF0D0D0F);
  static const surface = Color(0xFF141418);
  static const card = Color(0xFF1A1A1F);
  static const border = Color(0xFF222228);
  static const accent = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFA0A0A0);
  static const textMuted = Color(0xFF6B6B6B);
}

// ────────────────────────────────────────────────────────────────
// Dashboard page – main shell with bottom navigation
// ────────────────────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<_TabItem> _tabs = const [
    _TabItem(
      label: 'Projects',
      icon: PhosphorIconsRegular.folder,
      selectedIcon: PhosphorIconsFill.folder,
    ),
    _TabItem(
      label: 'Upload',
      icon: PhosphorIconsRegular.uploadSimple,
      selectedIcon: PhosphorIconsFill.uploadSimple,
    ),
    _TabItem(
      label: 'Analytics',
      icon: PhosphorIconsRegular.chartLineUp,
      selectedIcon: PhosphorIconsFill.chartLineUp,
    ),
    _TabItem(
      label: 'Settings',
      icon: PhosphorIconsRegular.gear,
      selectedIcon: PhosphorIconsFill.gear,
    ),
  ];

  late final List<Widget> _pages = const [
    ProjectsListPage(),
    upload.UploadPage(),
    analytics.AnalyticsPage(),
    settings.SettingsPage(),
  ];

  void _onTabChanged(int index) {
    if (index != _currentIndex) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                PhosphorIconsBold.filmStrip,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI Video Editor',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Notification bell
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'No new notifications',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: AppColors.card,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  PhosphorIconsRegular.bell,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                // Red dot
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isWide
          ? _WideLayout(
              tabs: _tabs,
              currentIndex: _currentIndex,
              onTabChanged: _onTabChanged,
              pages: _pages,
            )
          : _NarrowLayout(
              tabs: _tabs,
              currentIndex: _currentIndex,
              onTabChanged: _onTabChanged,
              pages: _pages,
            ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Tab data holder
// ────────────────────────────────────────────────────────────────
class _TabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

// ────────────────────────────────────────────────────────────────
// Narrow layout (phone) – bottom nav
// ────────────────────────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<Widget> pages;

  const _NarrowLayout({
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Page content
        Expanded(
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
        // Bottom navigation bar
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(tabs.length, (index) {
                  final tab = tabs[index];
                  final isSelected = index == currentIndex;
                  return _NavItem(
                    tab: tab,
                    isSelected: isSelected,
                    onTap: () => onTabChanged(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Wide layout (tablet / desktop) – side rail
// ────────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<Widget> pages;

  const _WideLayout({
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
    required this.pages,
  });

  static const double railWidth = 80;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Side navigation rail
        Container(
          width: railWidth,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              right: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              ...List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final isSelected = index == currentIndex;
                return _RailNavItem(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () => onTabChanged(index),
                );
              }),
            ],
          ),
        ),
        // Page content
        Expanded(
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Bottom nav item
// ────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? tab.selectedIcon : tab.icon,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Side rail nav item
// ────────────────────────────────────────────────────────────────
class _RailNavItem extends StatelessWidget {
  final _TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _RailNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? tab.selectedIcon : tab.icon,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                tab.label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.accent : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
