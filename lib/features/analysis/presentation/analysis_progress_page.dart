import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class AnalysisProgressPage extends StatefulWidget {
  final String sourceType;
  final String sourceName;
  final String? projectId;

  /// Optional external pipeline stages. When null, a sensible default is used.
  final List<PipelineStage>? stages;

  /// Base duration per stage (ms).  The timer-based countdown scales from this.
  final int stageDurationMs;

  const AnalysisProgressPage({
    super.key,
    required this.sourceType,
    required this.sourceName,
    this.projectId,
    this.stages,
    this.stageDurationMs = 2000,
  });

  @override
  State<AnalysisProgressPage> createState() => _AnalysisProgressPageState();
}

class _AnalysisProgressPageState extends State<AnalysisProgressPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late List<PipelineStage> _stages;
  int _currentStageIndex = 1; // 0 is "Upload Complete" → already done
  double _overallProgress = 0;
  bool _isComplete = false;
  bool _isCancelled = false;
  Duration _estimatedTimeRemaining = Duration.zero;

  Timer? _progressTimer;
  double _stageProgress = 0; // 0.0 → 1.0 within current stage

  // ── Default pipeline stages ──────────────────────────────────────

  static List<PipelineStage> _defaultStages() => [
        PipelineStage(
          name: 'Upload Complete',
          icon: PhosphorIconsLight.cloudArrowUp,
          status: StageStatus.completed,
        ),
        PipelineStage(
          name: 'Transcribing Audio',
          icon: PhosphorIconsLight.microphone,
          status: StageStatus.inProgress,
        ),
        PipelineStage(
          name: 'Analyzing Video',
          icon: PhosphorIconsLight.filmStrip,
          status: StageStatus.pending,
        ),
        PipelineStage(
          name: 'Understanding Content',
          icon: PhosphorIconsLight.brain,
          status: StageStatus.pending,
        ),
        PipelineStage(
          name: 'Finding Viral Moments',
          icon: PhosphorIconsLight.fire,
          status: StageStatus.pending,
        ),
        PipelineStage(
          name: 'Generating Shorts',
          icon: PhosphorIconsLight.scissors,
          status: StageStatus.pending,
        ),
        PipelineStage(
          name: 'Building Long-Form',
          icon: PhosphorIconsLight.filmSlate,
          status: StageStatus.pending,
        ),
        PipelineStage(
          name: 'Quality Check',
          icon: PhosphorIconsLight.checkCircle,
          status: StageStatus.pending,
        ),
      ];

  // ── Lifecycle ────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _stages = widget.stages ?? _defaultStages();
    // Ensure first stage is marked completed
    if (_stages.isNotEmpty) _stages[0].status = StageStatus.completed;
    _currentStageIndex = 1;
    _computeEstimate();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnalysis();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Pipeline – real timer-based progress ──────────────────────────

  void _startAnalysis() {
    _stageProgress = 0;
    _progressTimer?.cancel();

    final durationMs = widget.stageDurationMs;
    const tickMs = 50; // update every 50 ms
    final totalTicks = durationMs ~/ tickMs;
    int tick = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
      if (!mounted || _isCancelled) {
        timer.cancel();
        return;
      }

      tick++;
      _stageProgress = (tick / totalTicks).clamp(0.0, 1.0);

      // Compute overall progress: done stages + current fraction
      final completedWeight = _currentStageIndex;
      final totalStages = _stages.length - 1; // first stage always done
      final newProgress =
          (completedWeight + _stageProgress) / totalStages;

      setState(() {
        _overallProgress = newProgress.clamp(0.0, 1.0);
      });

      // Stage finished
      if (_stageProgress >= 1.0) {
        timer.cancel();
        _advanceStage();
      }
    });
  }

  void _advanceStage() {
    if (!mounted || _isCancelled) return;

    // Mark current stage completed
    setState(() {
      _stages[_currentStageIndex].status = StageStatus.completed;
    });

    // Move to next
    _currentStageIndex++;
    if (_currentStageIndex >= _stages.length) {
      // All done
      setState(() {
        _isComplete = true;
        _overallProgress = 1.0;
        _estimatedTimeRemaining = Duration.zero;
      });
      return;
    }

    // Start next stage
    setState(() {
      _stages[_currentStageIndex].status = StageStatus.inProgress;
      _computeEstimate();
    });
    _stageProgress = 0;
    _startAnalysis();
  }

  void _computeEstimate() {
    final remaining = _stages.length - _currentStageIndex - 1;
    final msPerStage = widget.stageDurationMs;
    final totalMs = remaining * msPerStage;
    _estimatedTimeRemaining = Duration(milliseconds: totalMs);
  }

  // ── Navigation ───────────────────────────────────────────────────

  void _viewResults() {
    final pid = widget.projectId;
    if (pid != null && pid.isNotEmpty) {
      context.push('/dashboard/projects/$pid/editor');
    } else {
      // Navigate back to projects list if no projectId
      context.go('/dashboard/projects');
    }
  }

  void _viewInBackground() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const PhosphorIcon(
              PhosphorIconsLight.clock,
              color: AppColors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Analysis running in background. We\'ll notify you when ready.',
                style: GoogleFonts.inter(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: AppColors.white,
          onPressed: () {
            final pid = widget.projectId;
            if (pid != null) {
              context.push('/dashboard/projects/$pid/editor');
            }
          },
        ),
      ),
    );
  }

  void _cancelAnalysis() {
    _progressTimer?.cancel();
    setState(() => _isCancelled = true);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Analysis cancelled.',
            style: GoogleFonts.inter(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(child: _buildPipeline()),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Source badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhosphorIcon(
                  widget.sourceType == 'file'
                      ? PhosphorIconsLight.fileVideo
                      : PhosphorIconsLight.link,
                  color: AppColors.accent,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.sourceType == 'file' ? 'File Upload' : 'URL Import',
                  style: GoogleFonts.inter(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _isCancelled
                ? 'Analysis Cancelled'
                : _isComplete
                    ? 'Analysis Complete'
                    : 'Processing Video',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Video name
          Text(
            widget.sourceName,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // PROGRESS BAR
  // ══════════════════════════════════════════════════════════════════

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                '${(_overallProgress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _overallProgress,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isCancelled
                    ? AppColors.error
                    : _isComplete
                        ? AppColors.success
                        : AppColors.accent,
              ),
              minHeight: 8,
            ),
          ),
          if (!_isComplete && !_isCancelled) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsLight.clock,
                  color: AppColors.textTertiary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Estimated time: ${_formatDuration(_estimatedTimeRemaining)}',
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // PIPELINE STAGES
  // ══════════════════════════════════════════════════════════════════

  Widget _buildPipeline() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: List.generate(_stages.length, (index) {
          final stage = _stages[index];
          final isCurrent = index == _currentStageIndex;
          final isCompleted = stage.status == StageStatus.completed;
          final isPending = stage.status == StageStatus.pending;

          return _buildStageItem(
            stage: stage,
            index: index,
            isCurrent: isCurrent,
            isCompleted: isCompleted,
            isPending: isPending,
            isLast: index == _stages.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildStageItem({
    required PipelineStage stage,
    required int index,
    required bool isCurrent,
    required bool isCompleted,
    required bool isPending,
    required bool isLast,
  }) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, _) {
            final pulseOpacity = isCurrent ? _pulseAnimation.value : 0.0;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.accent.withOpacity(0.08 * pulseOpacity)
                    : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.accent
                      : isCompleted
                          ? AppColors.success.withOpacity(0.35)
                          : AppColors.border,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // ── Stage Icon ─────────────────────────────────
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.successSurface
                          : isCurrent
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.backgroundSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const PhosphorIcon(
                              PhosphorIconsBold.check,
                              color: AppColors.success,
                              size: 20,
                            )
                          : isCurrent
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: _stageProgress,
                                    color: AppColors.accent,
                                    backgroundColor:
                                        AppColors.progressTrack,
                                  ),
                                )
                              : PhosphorIcon(
                                  stage.icon,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ── Stage Info ─────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.name,
                          style: GoogleFonts.inter(
                            color: isCompleted
                                ? AppColors.success
                                : isCurrent
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                            fontWeight: isCurrent || isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${(_stageProgress * 100).toInt()}% — Processing…',
                            style: GoogleFonts.inter(
                              color: AppColors.accent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Status Indicator ───────────────────────────
                  if (isCompleted)
                    const PhosphorIcon(
                      PhosphorIconsBold.checkCircle,
                      color: AppColors.success,
                      size: 20,
                    )
                  else if (isCurrent)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, _) {
                        return Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.accent
                                .withOpacity(_pulseAnimation.value),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    )
                  else
                    const PhosphorIcon(
                      PhosphorIconsLight.clock,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                ],
              ),
            );
          },
        ),

        // ── Connector ──────────────────────────────────────────────
        if (!isLast)
          Container(
            height: 24,
            width: 2,
            color: isCompleted
                ? AppColors.success.withOpacity(0.4)
                : AppColors.border,
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BOTTOM ACTIONS
  // ══════════════════════════════════════════════════════════════════

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Cancel / View in Background
          Expanded(
            child: _isComplete
                ? const SizedBox.shrink()
                : OutlinedButton(
                    onPressed: _isCancelled ? null : _cancelAnalysis,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const PhosphorIcon(
                          PhosphorIconsLight.x,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cancel',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
          ),

          if (_isComplete) ...[
            // View in Background (only before completion, but we keep
            // the layout space filled for consistency)
            Expanded(
              child: OutlinedButton(
                onPressed: null, // disabled when complete
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PhosphorIcon(PhosphorIconsLight.arrowsIn, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Background',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // View Results (visible when complete)
          if (_isComplete) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _viewResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PhosphorIcon(
                      PhosphorIconsBold.eye,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View Results',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.95, 0.95),
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return 'Done';
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '${m}m ${s}s';
  }
}

// ════════════════════════════════════════════════════════════════════
// Models
// ════════════════════════════════════════════════════════════════════

class PipelineStage {
  final String name;
  final IconData icon;
  StageStatus status;

  PipelineStage({
    required this.name,
    required this.icon,
    required this.status,
  });
}

enum StageStatus { pending, inProgress, completed }
