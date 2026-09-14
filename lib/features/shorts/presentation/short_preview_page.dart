import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';

/// Preview page for a single short video.
class ShortPreviewPage extends StatefulWidget {
  const ShortPreviewPage({
    super.key,
    required this.projectId,
    required this.shortId,
  });

  final String projectId;
  final String shortId;

  @override
  State<ShortPreviewPage> createState() => _ShortPreviewPageState();
}

class _ShortPreviewPageState extends State<ShortPreviewPage> {
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPlaying = false;

  // Simulated short data (in a real app this would come from an API/provider)
  String get _shortTitle => 'Short ${widget.shortId}';
  String get _shortDescription => 'Project: ${widget.projectId}';
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(seconds: 45);

  @override
  void initState() {
    super.initState();
    _loadShortData();
  }

  Future<void> _loadShortData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate loading delay (in production, fetch actual video URL from shortId)
      await Future.delayed(const Duration(milliseconds: 500));

      // Since we don't have a real video URL, we set up a placeholder state
      // In production: _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      // await _videoController!.initialize();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load short video';
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _isPlaying = false;
        } else {
          _videoController!.play();
          _isPlaying = true;
        }
      });
    } else {
      // No video loaded — show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPlaying ? '⏸ Paused' : '▶ Playing preview',
            style: GoogleFonts.inter(),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF141418),
        ),
      );
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1F),
        title: Text(
          'Export Short',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Export "$_shortTitle" to your device?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📤 Export started…', style: GoogleFonts.inter()),
                  backgroundColor: const Color(0xFF141418),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            child: Text('Export', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final controller = TextEditingController(text: _shortTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1F),
        title: Text(
          'Edit Short',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Short title...',
            hintStyle: GoogleFonts.inter(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF222228)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✏️ Title updated', style: GoogleFonts.inter()),
                  backgroundColor: const Color(0xFF141418),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            child: Text('Save', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteShort() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1F),
        title: Text(
          'Delete Short',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFEF4444),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$_shortTitle"? This cannot be undone.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑 Short deleted', style: GoogleFonts.inter()),
                  backgroundColor: const Color(0xFF141418),
                ),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141418),
        elevation: 0,
        leading: IconButton(
          icon: const PhosphorIcon(PhosphorIconsLight.caretLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Short Preview',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 18),
            color: Colors.white54,
            tooltip: 'Edit',
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.export, size: 18),
            color: Colors.white54,
            tooltip: 'Export',
            onPressed: _showExportDialog,
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.trash, size: 18),
            color: const Color(0xFFEF4444),
            tooltip: 'Delete',
            onPressed: _deleteShort,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  SizedBox(height: 16),
                  Text('Loading short…',
                      style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsRegular.warningCircle,
                          size: 48, color: Color(0xFFEF4444)),
                      const SizedBox(height: 12),
                      Text(_errorMessage!,
                          style: GoogleFonts.inter(color: Colors.white70)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadShortData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : isDesktop
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left: Video preview
        Expanded(
          flex: 5,
          child: _buildVideoPreview(),
        ),
        // Right: Info + controls
        Expanded(
          flex: 4,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF141418),
              border: Border(left: BorderSide(color: Color(0xFF222228))),
            ),
            child: _buildInfoPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Video preview
        Expanded(
          flex: 3,
          child: _buildVideoPreview(),
        ),
        // Info + controls
        Expanded(
          flex: 2,
          child: _buildInfoPanel(),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          width: 270,
          height: 480,
          decoration: BoxDecoration(
            color: const Color(0xFF111115),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF222228)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Video player or placeholder
                if (_videoController != null && _videoController!.value.isInitialized)
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                else ...[
                  // Placeholder
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.filmSlate,
                          size: 40, color: Color(0xFF6B7280)),
                      SizedBox(height: 8),
                      Text('9:16 Preview',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                    ],
                  ),

                  // Play/pause indicator
                  Positioned(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying
                              ? PhosphorIconsRegular.pause
                              : PhosphorIconsRegular.play,
                          size: 28,
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                    ),
                  ),
                ],

                // Hook overlay text
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'WAIT FOR IT... 😱',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _shortTitle,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _shortDescription,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _totalDuration.inSeconds > 0
                      ? _currentPosition.inSeconds / _totalDuration.inSeconds
                      : 0,
                  backgroundColor: const Color(0xFF222228),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: GoogleFonts.inter(
                        color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    _formatDuration(_totalDuration),
                    style: GoogleFonts.inter(
                        color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.skipBack, size: 20),
                color: Colors.white54,
                onPressed: () {
                  setState(() {
                    _currentPosition = Duration.zero;
                  });
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? PhosphorIconsRegular.pause : PhosphorIconsRegular.play,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.skipForward, size: 20),
                color: Colors.white54,
                onPressed: () {
                  setState(() {
                    _currentPosition = _totalDuration;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: PhosphorIconsRegular.shareFat,
                  label: 'Share',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📤 Share coming soon',
                            style: GoogleFonts.inter()),
                        backgroundColor: const Color(0xFF141418),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: PhosphorIconsRegular.pencilSimple,
                  label: 'Edit',
                  onTap: _showEditDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: PhosphorIconsRegular.trash,
                  label: 'Delete',
                  color: const Color(0xFFEF4444),
                  onTap: _deleteShort,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF9CA3AF);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: c.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withAlpha(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
