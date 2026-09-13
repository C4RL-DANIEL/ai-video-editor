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

// ─── Settings State ──────────────────────────────────────────────────────────
class SettingsState {
  // Profile
  final String userName;
  final String userEmail;

  // AI Preferences
  final String defaultEditingStyle;
  final String defaultIntensity;
  final String commentaryPersonality;
  final String captionStyle;

  // Export Settings
  final String defaultResolution;
  final String defaultFormat;
  final bool watermarkEnabled; // OFF by default

  SettingsState({
    this.userName = 'Alex Johnson',
    this.userEmail = 'alex@example.com',
    this.defaultEditingStyle = 'Dynamic',
    this.defaultIntensity = 'Medium',
    this.commentaryPersonality = 'Enthusiastic',
    this.captionStyle = 'Bold Pop',
    this.defaultResolution = '1920×1080',
    this.defaultFormat = 'MP4 (H.264)',
    this.watermarkEnabled = false,
  });

  SettingsState copyWith({
    String? userName,
    String? userEmail,
    String? defaultEditingStyle,
    String? defaultIntensity,
    String? commentaryPersonality,
    String? captionStyle,
    String? defaultResolution,
    String? defaultFormat,
    bool? watermarkEnabled,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      defaultEditingStyle: defaultEditingStyle ?? this.defaultEditingStyle,
      defaultIntensity: defaultIntensity ?? this.defaultIntensity,
      commentaryPersonality: commentaryPersonality ?? this.commentaryPersonality,
      captionStyle: captionStyle ?? this.captionStyle,
      defaultResolution: defaultResolution ?? this.defaultResolution,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      watermarkEnabled: watermarkEnabled ?? this.watermarkEnabled,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void setUserName(String name) => state = state.copyWith(userName: name);
  void setUserEmail(String email) => state = state.copyWith(userEmail: email);
  void setEditingStyle(String style) => state = state.copyWith(defaultEditingStyle: style);
  void setIntensity(String intensity) => state = state.copyWith(defaultIntensity: intensity);
  void setCommentaryPersonality(String personality) => state = state.copyWith(commentaryPersonality: personality);
  void setCaptionStyle(String style) => state = state.copyWith(captionStyle: style);
  void setResolution(String resolution) => state = state.copyWith(defaultResolution: resolution);
  void setFormat(String format) => state = state.copyWith(defaultFormat: format);
  void toggleWatermark() => state = state.copyWith(watermarkEnabled: !state.watermarkEnabled);
}

// ─── Settings Page ───────────────────────────────────────────────────────────
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 700;

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
            Icon(PhosphorIcons.gearSix, size: 18, color: _accentColor),
            const SizedBox(width: 8),
            Text('Settings', style: GoogleFonts.inter(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: isCompact
          ? _buildMobileLayout(context, ref, state)
          : _buildDesktopLayout(context, ref, state),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, SettingsState state) {
    return Row(
      children: [
        // Left: Profile
        SizedBox(
          width: 300,
          child: _ProfileSection(state: state, ref: ref),
        ),

        // Right: Settings
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AIPreferencesSection(state: state, ref: ref),
                const SizedBox(height: 24),
                _ExportSettingsSection(state: state, ref: ref),
                const SizedBox(height: 24),
                _AccountSection(state: state),
                const SizedBox(height: 24),
                _AboutSection(),
                const SizedBox(height: 24),
                _SignOutButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, SettingsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileSection(state: state, ref: ref),
          const SizedBox(height: 24),
          _AIPreferencesSection(state: state, ref: ref),
          const SizedBox(height: 24),
          _ExportSettingsSection(state: state, ref: ref),
          const SizedBox(height: 24),
          _AccountSection(state: state),
          const SizedBox(height: 24),
          _AboutSection(),
          const SizedBox(height: 24),
          _SignOutButton(),
        ],
      ),
    );
  }
}

// ─── Profile Section ─────────────────────────────────────────────────────────
class _ProfileSection extends StatelessWidget {
  final SettingsState state;
  final WidgetRef ref;

  const _ProfileSection({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(right: BorderSide(color: _borderColor)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Avatar
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_accentColor, _purpleColor]),
                  boxShadow: [
                    BoxShadow(color: _accentColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    state.userName.split(' ').map((n) => n[0]).join(),
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: _surfaceColor, width: 2),
                  ),
                  child: const Icon(PhosphorIcons.camera, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(state.userName, style: GoogleFonts.inter(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(state.userEmail, style: GoogleFonts.inter(color: _textMuted, fontSize: 12)),
          const SizedBox(height: 20),

          // Edit profile button
          Container(
            width: double.infinity,
            height: 36,
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Center(
              child: Text('Edit Profile', style: GoogleFonts.inter(color: _textSecondary, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 32),

          // Stats
          Row(
            children: [
              _StatItem(label: 'Projects', value: '24'),
              _StatItem(label: 'Exports', value: '156'),
              _StatItem(label: 'Hours', value: '89'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.inter(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── AI Preferences Section ──────────────────────────────────────────────────
class _AIPreferencesSection extends StatelessWidget {
  final SettingsState state;
  final WidgetRef ref;

  const _AIPreferencesSection({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'AI Preferences',
      icon: PhosphorIcons.brain,
      iconColor: _purpleColor,
      children: [
        _SettingsDropdown(
          label: 'Default Editing Style',
          value: state.defaultEditingStyle,
          options: ['Dynamic', 'Cinematic', 'Fast-Paced', 'Minimal', 'Dramatic'],
          onChanged: (v) => ref.read(settingsProvider.notifier).setEditingStyle(v),
        ),
        _SettingsDropdown(
          label: 'Default Intensity',
          value: state.defaultIntensity,
          options: ['Low', 'Medium', 'High', 'Extreme'],
          onChanged: (v) => ref.read(settingsProvider.notifier).setIntensity(v),
        ),
        _SettingsDropdown(
          label: 'Commentary Personality',
          value: state.commentaryPersonality,
          options: ['Enthusiastic', 'Professional', 'Casual', 'Dramatic', 'Humorous'],
          onChanged: (v) => ref.read(settingsProvider.notifier).setCommentaryPersonality(v),
        ),
        _SettingsDropdown(
          label: 'Caption Style',
          value: state.captionStyle,
          options: ['Bold Pop', 'Minimal', 'Gradient Glow', 'Outlined', 'Shadow Drop'],
          onChanged: (v) => ref.read(settingsProvider.notifier).setCaptionStyle(v),
        ),
      ],
    );
  }
}

// ─── Export Settings Section ─────────────────────────────────────────────────
class _ExportSettingsSection extends StatelessWidget {
  final SettingsState state;
  final WidgetRef ref;

  const _ExportSettingsSection({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Export Settings',
      icon: PhosphorIcons.export,
      iconColor: _accentColor,
      children: [
        _SettingsDropdown(
          label: 'Default Resolution',
          value: state.defaultResolution,
          options: ['1280×720', '1920×1080', '2560×1440', '3840×2160'],
          onChanged: (v) => ref.read(settingsProvider.notifier).setResolution(v),
        ),
        _SettingsDropdown(
          label: 'Default Format',
          value: state.defaultFormat,
          options: ['MP4 (H.264)', 'MP4 (H.265)', 'WebM', 'MOV'],
          onChanged: (v) => ref.read(settingsProvider.notifier).setFormat(v),
        ),
        const SizedBox(height: 8),
        // Watermark toggle - with clear note
        _WatermarkToggle(
          enabled: state.watermarkEnabled,
          onTap: () => ref.read(settingsProvider.notifier).toggleWatermark(),
        ),
      ],
    );
  }
}

class _WatermarkToggle extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _WatermarkToggle({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _successColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _successColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.appWindow, size: 16, color: _successColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('App Watermark', style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(
                        'NEVER adds app watermark',
                        style: GoogleFonts.inter(color: _successColor, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // Toggle
                Container(
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: enabled ? _errorColor : _successColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.shieldCheck, size: 12, color: _successColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      enabled ? '⚠ Watermark will be added to exports' : '✓ Your exports will NEVER have a watermark',
                      style: GoogleFonts.inter(
                        color: enabled ? _warningColor : _successColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Account Section ─────────────────────────────────────────────────────────
class _AccountSection extends StatelessWidget {
  final SettingsState state;

  const _AccountSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Account',
      icon: PhosphorIcons.userCircle,
      iconColor: _accentColor,
      children: [
        // Subscription
        _AccountCard(
          icon: PhosphorIcons.crown,
          iconColor: _warningColor,
          title: 'Subscription',
          subtitle: 'Pro Plan • Renews Dec 15',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _warningColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('Active', style: GoogleFonts.inter(color: _warningColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ),

        // Usage
        _AccountCard(
          icon: PhosphorIcons.chartBar,
          iconColor: _accentColor,
          title: 'Usage This Month',
          subtitle: '42/50 exports • 18/25 AI edits',
          trailing: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('84%', style: GoogleFonts.inter(color: _accentColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ),

        // API Keys
        _AccountCard(
          icon: PhosphorIcons.key,
          iconColor: _purpleColor,
          title: 'API Keys',
          subtitle: 'Manage external integrations',
          trailing: Icon(PhosphorIcons.caretRight, size: 14, color: _textMuted),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _AccountCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                Text(subtitle, style: GoogleFonts.inter(color: _textMuted, fontSize: 10)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ─── About Section ───────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'About',
      icon: PhosphorIcons.info,
      iconColor: _textMuted,
      children: [
        _AboutItem(label: 'Version', value: '2.1.0 (Build 247)'),
        _AboutItem(label: 'License', value: 'MIT'),
        _AboutItem(label: 'Privacy Policy', value: '', isLink: true),
        _AboutItem(label: 'Terms of Service', value: '', isLink: true),
        _AboutItem(label: 'Open Source Licenses', value: '', isLink: true),
      ],
    );
  }
}

class _AboutItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;

  const _AboutItem({required this.label, required this.value, this.isLink = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(color: _textSecondary, fontSize: 12)),
          const Spacer(),
          if (value.isNotEmpty)
            Text(value, style: GoogleFonts.inter(color: _textMuted, fontSize: 12)),
          if (isLink) ...[
            Text('View', style: GoogleFonts.inter(color: _accentColor, fontSize: 12)),
            const SizedBox(width: 4),
            Icon(PhosphorIcons.arrowUpRight, size: 12, color: _accentColor),
          ],
        ],
      ),
    );
  }
}

// ─── Sign Out Button ─────────────────────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _surfaceColor,
            title: Text('Sign Out', style: GoogleFonts.inter(color: _textPrimary, fontSize: 16)),
            content: Text('Are you sure you want to sign out?', style: GoogleFonts.inter(color: _textSecondary, fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: GoogleFonts.inter(color: _textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Sign Out', style: GoogleFonts.inter(color: _errorColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: _errorColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _errorColor.withOpacity(0.2)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.signOut, size: 16, color: _errorColor),
              const SizedBox(width: 8),
              Text('Sign Out', style: GoogleFonts.inter(color: _errorColor, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Section Widget ─────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.inter(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ─── Reusable Dropdown Widget ────────────────────────────────────────────────
class _SettingsDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SettingsDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: GoogleFonts.inter(color: _textSecondary, fontSize: 12)),
            ),
            DropdownButton<String>(
              value: value,
              dropdownColor: _surfaceColor,
              underline: const SizedBox(),
              isDense: true,
              style: GoogleFonts.inter(color: _textPrimary, fontSize: 12),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ],
        ),
      ),
    );
  }
}
