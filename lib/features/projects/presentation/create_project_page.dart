import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';

import 'package:ai_video_editor/core/theme/app_colors.dart';
import 'package:ai_video_editor/features/projects/presentation/project_providers.dart';
import 'package:ai_video_editor/features/projects/presentation/project_detail_page.dart';

// ────────────────────────────────────────────────────────────────
// Source selection enum
// ────────────────────────────────────────────────────────────────
enum SourceType { none, file, link }

// ────────────────────────────────────────────────────────────────
// Style presets
// ────────────────────────────────────────────────────────────────
enum StylePreset {
  highEnergy(label: 'High-Energy Commentary'),
  professional(label: 'Clean Professional'),
  cinematic(label: 'Cinematic'),
  storytelling(label: 'Storytelling');

  final String label;
  const StylePreset({required this.label});
}

// ────────────────────────────────────────────────────────────────
// Create project page
// ────────────────────────────────────────────────────────────────
class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _urlFocusNode = FocusNode();

  SourceType _selectedSource = SourceType.none;
  String? _selectedFileName;
  String? _selectedLinkUrl;
  StylePreset _selectedStyle = StylePreset.highEnergy;
  bool _useReferenceStyle = false;
  String? _referenceFileName;
  String? _referenceLinkUrl;
  SourceType _referenceSource = SourceType.none;

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _selectedSource != SourceType.none &&
      (_selectedSource == SourceType.file
          ? _selectedFileName != null
          : _selectedLinkUrl != null && _urlController.text.trim().isNotEmpty);

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  // ── Actions ──

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowedExtensions: ['mp4', 'mov', 'mkv', 'webm', 'avi', 'm4v'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedSource = SourceType.file;
          _selectedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File picker not available on this platform',
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
      }
    }
  }

  void _selectLink() {
    setState(() {
      _selectedSource = SourceType.link;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlFocusNode.requestFocus();
    });
  }

  void _clearSource() {
    setState(() {
      _selectedSource = SourceType.none;
      _selectedFileName = null;
      _selectedLinkUrl = null;
      _urlController.clear();
    });
  }

  Future<void> _pickReferenceFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _referenceSource = SourceType.file;
          _referenceFileName = result.files.first.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File picker not available',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: AppColors.card,
          ),
        );
      }
    }
  }

  void _selectReferenceLink() {
    setState(() {
      _referenceSource = SourceType.link;
      _referenceLinkUrl = 'https://';
    });
  }

  void _startProcessing() {
    if (!_canSubmit) return;

    // Create a new project
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      status: ProjectStatus.processing,
      shortsCount: 0,
      longFormCount: 0,
      createdAt: DateTime.now(),
    );

    // Show processing feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting analysis pipeline…',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to project detail after brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      // Pop back to the project list, then push detail
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProjectDetailPage(project: project),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.x, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create New Project',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Project name ──
            _buildNameField(),
            const SizedBox(height: 28),

            // ── Source selection ──
            _buildSectionTitle('Video Source'),
            const SizedBox(height: 12),
            isWide ? _buildSourceCardsRow() : _buildSourceCardsColumn(),
            const SizedBox(height: 20),

            // ── Link input (shown when link selected) ──
            if (_selectedSource == SourceType.link) ...[
              _buildLinkInput(),
              const SizedBox(height: 20),
            ],

            // ── Selected source preview ──
            if (_selectedSource != SourceType.none) ...[
              _buildSelectedSourcePreview(),
              const SizedBox(height: 24),
            ],

            // ── Reference style section ──
            _buildReferenceSection(),
            const SizedBox(height: 24),

            // ── Style selection ──
            _buildSectionTitle('Content Style'),
            const SizedBox(height: 12),
            _buildStyleGrid(),
            const SizedBox(height: 32),

            // ── Start button ──
            _buildStartButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Name field ──
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Project Name'),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Enter project name…',
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 15),
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 50.ms).slideY(begin: 0.03);
  }

  // ── Section title ──
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ── Source cards row ──
  Widget _buildSourceCardsRow() {
    return Row(
      children: [
        Expanded(child: _buildUploadFileCard()),
        const SizedBox(width: 14),
        Expanded(child: _buildPasteLinkCard()),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.04);
  }

  // ── Source cards column ──
  Widget _buildSourceCardsColumn() {
    return Column(
      children: [
        _buildUploadFileCard(),
        const SizedBox(height: 14),
        _buildPasteLinkCard(),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.04);
  }

  // ── Upload file card ──
  Widget _buildUploadFileCard() {
    final isSelected = _selectedSource == SourceType.file;
    return GestureDetector(
      onTap: _pickFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent.withOpacity(0.4)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                PhosphorIconsBold.uploadSimple,
                size: 24,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Upload File',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'MP4, MOV, MKV,\nWebM, AVI, M4V',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Paste link card ──
  Widget _buildPasteLinkCard() {
    final isSelected = _selectedSource == SourceType.link;
    return GestureDetector(
      onTap: _selectLink,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple.withOpacity(0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.purple : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.purple.withOpacity(0.15)
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.purple.withOpacity(0.4)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                PhosphorIconsBold.link,
                size: 24,
                color: isSelected ? AppColors.purple : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Paste Link',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.purple : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'YouTube, TikTok,\nInstagram, etc.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Link input ──
  Widget _buildLinkInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _urlController,
          focusNode: _urlFocusNode,
          onChanged: (v) {
            setState(() {
              _selectedLinkUrl = v.isNotEmpty ? v : null;
            });
          },
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'Paste Video URL',
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: const Icon(
              PhosphorIconsRegular.link,
              size: 18,
              color: AppColors.textMuted,
            ),
            suffixIcon: _urlController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(PhosphorIconsRegular.xCircle, size: 18, color: AppColors.textMuted),
                    onPressed: () {
                      _urlController.clear();
                      setState(() => _selectedLinkUrl = null);
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05);
  }

  // ── Selected source preview ──
  Widget _buildSelectedSourcePreview() {
    final isFile = _selectedSource == SourceType.file;
    final label = isFile ? _selectedFileName ?? '' : _selectedLinkUrl ?? '';
    final icon = isFile ? PhosphorIconsBold.fileVideo : PhosphorIconsBold.globe;
    final color = isFile ? AppColors.accent : AppColors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(PhosphorIconsRegular.x, size: 16, color: color),
            onPressed: _clearSource,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  // ── Reference style section ──
  Widget _buildReferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use Reference Style',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Provide a reference video to match editing style',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _useReferenceStyle,
              onChanged: (v) => setState(() => _useReferenceStyle = v),
              activeColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withOpacity(0.3),
              inactiveThumbColor: AppColors.textMuted,
              inactiveTrackColor: AppColors.surface,
            ),
          ],
        ),

        // Reference upload options
        if (_useReferenceStyle) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              // Upload reference
              Expanded(
                child: GestureDetector(
                  onTap: _pickReferenceFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _referenceSource == SourceType.file
                          ? AppColors.accent.withOpacity(0.08)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _referenceSource == SourceType.file
                            ? AppColors.accent.withOpacity(0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          PhosphorIconsRegular.uploadSimple,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Upload',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Paste reference link
              Expanded(
                child: GestureDetector(
                  onTap: _selectReferenceLink,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _referenceSource == SourceType.link
                          ? AppColors.purple.withOpacity(0.08)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _referenceSource == SourceType.link
                            ? AppColors.purple.withOpacity(0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          PhosphorIconsRegular.link,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Paste Link',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Show selected reference
          if (_referenceSource != SourceType.none) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    _referenceSource == SourceType.file
                        ? PhosphorIconsRegular.fileVideo
                        : PhosphorIconsRegular.globe,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _referenceSource == SourceType.file
                          ? (_referenceFileName ?? 'Selected')
                          : (_referenceLinkUrl ?? 'Pasted link'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _referenceSource = SourceType.none;
                      _referenceFileName = null;
                      _referenceLinkUrl = null;
                    }),
                    child: const Icon(PhosphorIconsRegular.xCircle, size: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),
          ],
        ],
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  // ── Style grid ──
  Widget _buildStyleGrid() {
    return Column(
      children: StylePreset.values.map((style) {
        final isSelected = _selectedStyle == style;
        return GestureDetector(
          onTap: () => setState(() => _selectedStyle = style),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withOpacity(0.08)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Radio-like indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.textMuted,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    style.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    PhosphorIconsBold.checkCircle,
                    size: 18,
                    color: AppColors.accent,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Start button ──
  Widget _buildStartButton() {
    final enabled = _canSubmit;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled ? AppColors.accent : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? _startProcessing : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: enabled ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsBold.play,
                  size: 18,
                  color: enabled ? Colors.white : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  'Start Processing',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.05);
  }
}
