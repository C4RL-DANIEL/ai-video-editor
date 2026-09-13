import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class ContentMapPage extends StatefulWidget {
  const ContentMapPage({super.key});

  @override
  State<ContentMapPage> createState() => _ContentMapPageState();
}

class _ContentMapPageState extends State<ContentMapPage> {
  late ScrollController _timelineScrollController;
  late ScrollController _transcriptScrollController;
  int? _selectedSegmentIndex;
  bool _showSpeakerView = false;

  // ── Sample data ───────────────────────────────────────────────────

  final List<TimelineSegment> _segments = [
    TimelineSegment(
      start: Duration.zero,
      end: const Duration(seconds: 45),
      type: SegmentType.talking,
      speaker: 'Speaker 1',
      speakerColor: AppColors.accent,
      transcript:
          'Welcome to today\'s video where we\'ll be exploring the latest features and updates in Flutter development.',
      viralScore: 0.2,
    ),
    TimelineSegment(
      start: const Duration(seconds: 45),
      end: const Duration(minutes: 1, seconds: 30),
      type: SegmentType.action,
      speaker: 'Speaker 1',
      speakerColor: AppColors.accent,
      transcript:
          'Let me show you how to set up your development environment from scratch. First, we need to install the SDK and configure our IDE…',
      viralScore: 0.3,
    ),
    TimelineSegment(
      start: const Duration(minutes: 1, seconds: 30),
      end: const Duration(minutes: 2, seconds: 15),
      type: SegmentType.reaction,
      speaker: 'Speaker 2',
      speakerColor: AppColors.purple500,
      transcript:
          'Wow, that\'s amazing! I didn\'t know you could do that with just a few lines of code.',
      viralScore: 0.85,
    ),
    TimelineSegment(
      start: const Duration(minutes: 2, seconds: 15),
      end: const Duration(minutes: 3, seconds: 0),
      type: SegmentType.silence,
      speaker: null,
      speakerColor: null,
      transcript: '[Silence — B-roll footage of code compilation]',
      viralScore: 0.1,
    ),
    TimelineSegment(
      start: const Duration(minutes: 3, seconds: 0),
      end: const Duration(minutes: 4, seconds: 30),
      type: SegmentType.talking,
      speaker: 'Speaker 1',
      speakerColor: AppColors.accent,
      transcript:
          'Now let\'s dive into the core concepts. The widget tree is fundamental to understanding how Flutter works under the hood.',
      viralScore: 0.4,
    ),
    TimelineSegment(
      start: const Duration(minutes: 4, seconds: 30),
      end: const Duration(minutes: 5, seconds: 45),
      type: SegmentType.action,
      speaker: 'Speaker 1',
      speakerColor: AppColors.accent,
      transcript:
          'Watch as I build this entire UI in real-time. We\'ll use a combination of widgets and custom painters to create something incredible.',
      viralScore: 0.6,
    ),
    TimelineSegment(
      start: const Duration(minutes: 5, seconds: 45),
      end: const Duration(minutes: 7, seconds: 0),
      type: SegmentType.reaction,
      speaker: 'Speaker 2',
      speakerColor: AppColors.purple500,
      transcript:
          'This is incredible! The performance is so much better than I expected. Can we see more examples of this technique?',
      viralScore: 0.92,
    ),
    TimelineSegment(
      start: const Duration(minutes: 7, seconds: 0),
      end: const Duration(minutes: 8, seconds: 15),
      type: SegmentType.talking,
      speaker: 'Speaker 1',
      speakerColor: AppColors.accent,
      transcript:
          'Absolutely! Let me show you some advanced techniques that will take your apps to the next level.',
      viralScore: 0.5,
    ),
    TimelineSegment(
      start: const Duration(minutes: 8, seconds: 15),
      end: const Duration(minutes: 9, seconds: 30),
      type: SegmentType.action,
      speaker: 'Speaker 1',
      speakerColor: AppColors.accent,
      transcript:
          'Here\'s where it gets really interesting. We can optimize our animations using this technique to achieve buttery smooth 60fps.',
      viralScore: 0.7,
    ),
    TimelineSegment(
      start: const Duration(minutes: 9, seconds: 30),
      end: const Duration(minutes: 10, seconds: 45),
      type: SegmentType.reaction,
      speaker: 'Speaker 2',
      speakerColor: AppColors.purple500,
      transcript:
          'Mind blown! 🤯 That\'s the coolest thing I\'ve seen in Flutter. This is going to change how I build apps forever.',
      viralScore: 0.95,
    ),
    TimelineSegment(
      start: const Duration(minutes: 10, seconds: 45),
      end: const Duration(minutes: 12, seconds: 0),
      type: SegmentType.talking,
      speaker: 'Speaker 1',
      speakerColor: AppColors.accent,
      transcript:
          'Thanks for watching! If you found this helpful, don\'t forget to like and subscribe for more content like this.',
      viralScore: 0.3,
    ),
  ];

  List<TimelineSegment> get _viralMoments {
    final moments =
        _segments.where((s) => s.viralScore >= 0.8).toList();
    moments.sort((a, b) => b.viralScore.compareTo(a.viralScore));
    return moments;
  }

  @override
  void initState() {
    super.initState();
    _timelineScrollController = ScrollController();
    _transcriptScrollController = ScrollController();
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    _transcriptScrollController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────

  void _scrollToViralMoment(TimelineSegment moment) {
    final index = _segments.indexOf(moment);
    final scrollPosition = index * 128.0;

    _timelineScrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    setState(() => _selectedSegmentIndex = index);
  }

  void _scrollToHighestViralMoments() {
    if (_viralMoments.isNotEmpty) {
      _scrollToViralMoment(_viralMoments.first);
    }
  }

  void _exportTimeline() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Timeline exported to clipboard!',
          style: GoogleFonts.inter(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          'Content Map',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const PhosphorIcon(
            PhosphorIconsLight.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Find Best Moments
          IconButton(
            icon: const PhosphorIcon(
              PhosphorIconsLight.fire,
              color: AppColors.warning,
            ),
            onPressed: _scrollToHighestViralMoments,
            tooltip: 'Find Best Moments',
          ),
          // Speaker toggle
          IconButton(
            icon: PhosphorIcon(
              _showSpeakerView
                  ? PhosphorIconsLight.users
                  : PhosphorIconsLight.user,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() => _showSpeakerView = !_showSpeakerView);
            },
            tooltip: 'Speaker Diarization',
          ),
          // Export
          IconButton(
            icon: const PhosphorIcon(
              PhosphorIconsLight.shareFat,
              color: AppColors.textSecondary,
            ),
            onPressed: _exportTimeline,
            tooltip: 'Export Timeline',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildViralMomentsBanner(),
          _buildTimelineHeader(),
          _buildTimeline(),
          if (_showSpeakerView) _buildSpeakerView(),
          Expanded(child: _buildTranscript()),
          if (_selectedSegmentIndex != null) _buildSegmentDetails(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // VIRAL MOMENTS BANNER
  // ══════════════════════════════════════════════════════════════════

  Widget _buildViralMomentsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppColors.backgroundSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsLight.fire,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Viral Moments Found',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_viralMoments.length}',
                  style: GoogleFonts.inter(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _viralMoments.length,
              itemBuilder: (context, index) {
                return _buildViralMomentCard(_viralMoments[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViralMomentCard(TimelineSegment moment) {
    return GestureDetector(
      onTap: () => _scrollToViralMoment(moment),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.warning.withOpacity(0.45),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(moment.viralScore * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      color: AppColors.gray950,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _fmt(moment.start),
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                moment.transcript,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration.zero)
        .slideX(begin: 0.08);
  }

  // ══════════════════════════════════════════════════════════════════
  // TIMELINE
  // ══════════════════════════════════════════════════════════════════

  Widget _buildTimelineHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      color: AppColors.backgroundPrimary,
      child: Row(
        children: [
          const PhosphorIcon(
            PhosphorIconsLight.clock,
            color: AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Timeline',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          _legend('Talking', AppColors.accent),
          const SizedBox(width: 10),
          _legend('Action', AppColors.success),
          const SizedBox(width: 10),
          _legend('Reaction', AppColors.purple500),
          const SizedBox(width: 10),
          _legend('Silence', AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Container(
      height: 100,
      color: AppColors.backgroundSecondary,
      child: SingleChildScrollView(
        controller: _timelineScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: List.generate(_segments.length, (index) {
            final segment = _segments[index];
            final isSelected = _selectedSegmentIndex == index;
            final isViral = segment.viralScore >= 0.8;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSegmentIndex = isSelected ? null : index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 120,
                height: 68,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: _segmentColor(segment.type)
                      .withOpacity(isSelected ? 0.75 : 0.45),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.white
                        : isViral
                            ? AppColors.warning
                            : Colors.transparent,
                    width: isSelected ? 2 : isViral ? 1.5 : 0,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_fmt(segment.start)}–${_fmt(segment.end)}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            segment.type.name.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isViral)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(segment.viralScore * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              color: AppColors.gray950,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SPEAKER DIARIZATION
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSpeakerView() {
    final speakers = <String>{};
    for (final s in _segments) {
      if (s.speaker != null) speakers.add(s.speaker!);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppColors.backgroundSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsLight.users,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Speaker Diarization',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final speaker in speakers) _buildSpeakerTrack(speaker),
        ],
      ),
    );
  }

  Widget _buildSpeakerTrack(String speaker) {
    final speakerSegs =
        _segments.where((s) => s.speaker == speaker).toList();
    final color = speakerSegs.first.speakerColor ?? AppColors.accent;
    final totalDuration = _segments.last.end.inSeconds.toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                speaker,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${speakerSegs.length} segments',
                style: GoogleFonts.inter(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: speakerSegs.map((seg) {
                final startPct =
                    seg.start.inSeconds.toDouble() / totalDuration;
                final widthPct =
                    (seg.end.inSeconds - seg.start.inSeconds).toDouble() /
                        totalDuration;
                final flex =
                    (widthPct * 1000).toInt().clamp(1, 1000);
                final pad =
                    (startPct * 1000).toInt().clamp(0, 100);

                return Expanded(
                  flex: flex,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TRANSCRIPT
  // ══════════════════════════════════════════════════════════════════

  Widget _buildTranscript() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsLight.textAlignLeft,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transcript',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: ListView.builder(
              controller: _transcriptScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _segments.length,
              itemBuilder: (context, index) {
                final seg = _segments[index];
                final isSelected = _selectedSegmentIndex == index;
                return _buildTranscriptItem(seg, index, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptItem(
      TimelineSegment segment, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegmentIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.08)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Timestamp chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _segmentColor(segment.type).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_fmt(segment.start)}–${_fmt(segment.end)}',
                    style: GoogleFonts.inter(
                      color: _segmentColor(segment.type),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Speaker
                if (segment.speaker != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: segment.speakerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    segment.speaker!,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],

                const Spacer(),

                // Viral score
                if (segment.viralScore >= 0.5)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _viralColor(segment.viralScore)
                          .withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          PhosphorIconsLight.fire,
                          color: _viralColor(segment.viralScore),
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(segment.viralScore * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            color: _viralColor(segment.viralScore),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              segment.transcript,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SEGMENT DETAILS (bottom bar)
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSegmentDetails() {
    final segment = _segments[_selectedSegmentIndex!];

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundSecondary,
      child: Row(
        children: [
          // Type icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _segmentColor(segment.type).withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: PhosphorIcon(
                _segmentIcon(segment.type),
                color: _segmentColor(segment.type),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${segment.type.name.toUpperCase()} — ${_fmt(segment.start)}–${_fmt(segment.end)}',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  segment.speaker ?? 'No speaker detected',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Viral score
          if (segment.viralScore > 0)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Viral Score',
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${(segment.viralScore * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    color: _viralColor(segment.viralScore),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          const SizedBox(width: 12),

          // Play
          IconButton(
            icon: const PhosphorIcon(
              PhosphorIconsBold.play,
              color: AppColors.accent,
            ),
            onPressed: () {
              // TODO: play from this timestamp
            },
            tooltip: 'Play from here',
          ),

          // Trim
          IconButton(
            icon: const PhosphorIcon(
              PhosphorIconsLight.scissors,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              // TODO: trim / cut segment
            },
            tooltip: 'Trim segment',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════

  Color _segmentColor(SegmentType type) {
    switch (type) {
      case SegmentType.talking:
        return AppColors.accent;
      case SegmentType.action:
        return AppColors.success;
      case SegmentType.reaction:
        return AppColors.purple500;
      case SegmentType.silence:
        return AppColors.textTertiary;
    }
  }

  IconData _segmentIcon(SegmentType type) {
    switch (type) {
      case SegmentType.talking:
        return PhosphorIconsLight.microphone;
      case SegmentType.action:
        return PhosphorIconsLight.lightning;
      case SegmentType.reaction:
        return PhosphorIconsLight.heart;
      case SegmentType.silence:
        return PhosphorIconsLight.speakerSlash;
    }
  }

  Color _viralColor(double score) {
    if (score >= 0.9) return AppColors.warning;
    if (score >= 0.7) return const Color(0xFFF97316);
    if (score >= 0.5) return const Color(0xFFEAB308);
    return AppColors.textSecondary;
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ════════════════════════════════════════════════════════════════════
// Models
// ════════════════════════════════════════════════════════════════════

class TimelineSegment {
  final Duration start;
  final Duration end;
  final SegmentType type;
  final String? speaker;
  final Color? speakerColor;
  final String transcript;
  final double viralScore;

  TimelineSegment({
    required this.start,
    required this.end,
    required this.type,
    this.speaker,
    this.speakerColor,
    required this.transcript,
    required this.viralScore,
  });
}

enum SegmentType { talking, action, reaction, silence }
