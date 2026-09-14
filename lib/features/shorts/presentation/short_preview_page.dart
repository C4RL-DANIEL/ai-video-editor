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

  // Real data fields — populated from Appwrite (TODO)
  String _shortTitle = '';
  String _shortDescription = '';
  String? _videoUrl;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadShortData();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadShortData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Fetch short document from Appwrite using widget.shortId
      // For now, derive minimal data from IDs.
      _shortTitle = 'Short ${widget.shortId}';
      _shortDescription = 'Project: ${widget.projectId}';

      // TODO: When a real video URL is available:
      // _videoUrl = 'https://...';
      // _videoController = VideoPlayerController.networkUrl(Uri.parse(_videoUrl!));
      // await _videoController!.initialize();
      // _totalDuration = _videoController!.value.duration;
      // _videoController!.addListener(_videoListener);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load short video';
      });
    }
  }

  void _videoListener() {
    if (!mounted || _videoController == null) return;
    final controller = _videoController!;
    final newPos = controller.value.position;
    final newDuration = controller.value.duration;
    if (newPos != _currentPosition || newDuration != _totalDuration) {
      setState(() {
        _currentPosition = newPos;
        _totalDuration = newDuration;
      });
    }
    // Auto-pause at end
    if (newPos >= newDuration && _isPlaying) {
      setState(() {
        _isPlaying = false;
      });
    }
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
    } else if (_videoUrl == null) {
      // No video available yet — show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No video available to play',
            style: GoogleFonts.inter(),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF141418),
        ),
      );
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
              // TODO: Trigger real export pipeline
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
              final newTitle = controller.text.trim();
              Navigator.of(ctx).pop();
              if (newTitle.isNotEmpty) {
                setState(() {
                  _shortTitle = newTitle;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✏️ Title updated to "$newTitle"', style: GoogleFonts.inter()),
                    backgroundColor: const Color(0xFF141418),
                  ),
                );
                // TODO: Persist title change to Appwrite
              }
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
              // TODO: Delete short from Appwrite
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
                  // Empty state placeholder
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(PhosphorIconsRegular.filmSlate,
                          size: 40, color: Color(0xFF6B7280)),
                      const SizedBox(height: 8),
                      Text('9:16 Preview',
                          style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        _videoUrl == null ? 'No video loaded' : 'Initializing…',
                        style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 10),
                      ),
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
                  if (_videoController != null && _videoController!.value.isInitialized) {
                    _videoController!.seekTo(Duration.zero);
                  } else {
                    setState(() {
                      _currentPosition = Duration.zero;
                    });
                  }
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
                  if (_videoController != null && _videoController!.value.isInitialized) {
                    _videoController!.seekTo(_videoController!.value.duration);
                  } else {
                    setState(() {
                      _currentPosition = _totalDuration;
                    });
                  }
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
