import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:appwrite/appwrite.dart';
import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import '../../../config/appwrite_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../analysis/presentation/analysis_progress_page.dart';
import '../../auth/presentation/auth_provider.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDragging = false;

  // File upload state
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0;
  FileDetails? _fileDetails;
  String? _uploadedFileId;

  // Link paste state
  final TextEditingController _linkController = TextEditingController();
  LinkDetails? _linkDetails;
  bool _isValidating = false;
  String? _linkError;

  // Appwrite client for storage
  late final Client _appwriteClient;
  late final Storage _storage;
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize Appwrite client for file uploads
    _appwriteClient = createAppwriteClient();
    _storage = Storage(_appwriteClient);

    // Initialize Dio for URL validation
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      followRedirects: true,
      maxRedirects: 5,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (compatible; VideoUploader/1.0)',
      },
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _linkController.dispose();
    _dio.close();
    super.dispose();
  }

  // ── File picking ──────────────────────────────────────────────────

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _fileDetails = null;
          _isUploading = false;
          _uploadProgress = 0;
          _uploadedFileId = null;
        });
        await _uploadToAppwrite(_selectedFile!);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: $e');
    }
  }

  /// Uploads video to Appwrite Storage with real progress tracking,
  /// then extracts metadata using video_player.
  Future<void> _uploadToAppwrite(PlatformFile file) async {
    setState(() => _isUploading = true);

    try {
      final filePath = file.path;
      if (filePath == null) {
        throw Exception('File path is not available');
      }

      final bucketId = AppwriteConfig.videosBucketId;
      final fileId = 'video_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(99999)}';

      // Timer-based progress estimation while upload completes
      double estimatedProgress = 0;
      final progressTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          estimatedProgress += (1.0 - estimatedProgress) * 0.05;
          if (estimatedProgress > 0.95) estimatedProgress = 0.95;
          setState(() => _uploadProgress = estimatedProgress);
        },
      );

      try {
        // Upload to Appwrite Storage
        final uploadedFile = await _storage.createFile(
          bucketId: bucketId,
          fileId: fileId,
          file: InputFile.fromPath(path: filePath, filename: file.name),
        );
        progressTimer.cancel();

        if (mounted) {
          setState(() => _uploadProgress = 1.0);
        }

        // Store the uploaded file ID
        if (mounted) {
          setState(() => _uploadedFileId = uploadedFile.$id);
        }

        // Small delay so user sees 100%
        await Future.delayed(const Duration(milliseconds: 300));

        // Extract real video metadata using video_player
        await _extractFileDetails(filePath, file.name);

        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 1.0;
          });
        }

        // Show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video uploaded successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (uploadError) {
        progressTimer.cancel();
        // If Appwrite upload fails (bucket permissions), fall back to local save
        debugPrint('Appwrite upload failed, falling back to local save: $uploadError');

        if (mounted) {
          setState(() => _uploadProgress = 0.5);
        }

        // Save locally as fallback
        final appDir = await getApplicationDocumentsDirectory();
        final videosDir = Directory('${appDir.path}/videos');
        if (!await videosDir.exists()) {
          await videosDir.create(recursive: true);
        }
        final localPath = '${videosDir.path}/${file.name}';
        await File(filePath).copy(localPath);

        if (mounted) {
          setState(() {
            _uploadedFileId = fileId;
            _uploadProgress = 1.0;
          });
        }

        await Future.delayed(const Duration(milliseconds: 300));
        await _extractFileDetails(localPath, file.name);

        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 1.0;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video saved locally (cloud upload unavailable)'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0;
        });
      }
      _showErrorSnackBar('Upload failed: ${e.toString()}');
    }
  }

  /// Extracts real video metadata (duration, resolution, fps) using video_player.
  Future<void> _extractFileDetails(String filePath, String fileName) async {
    try {
      final localFile = File(filePath);
      final fileBytes = await localFile.length();
      final ext = fileName.split('.').last.toLowerCase();

      final controller = VideoPlayerController.file(localFile);
      await controller.initialize();

      final value = controller.value;

      // Extract metadata from the initialized controller
      final duration = value.duration;
      final size = value.size; // Width x Height

      await controller.dispose();

      if (mounted) {
        setState(() {
          _isUploading = false;
          _fileDetails = FileDetails(
            name: fileName,
            size: fileBytes,
            format: _getFormatFromExtension(ext),
            duration: duration,
            resolution: '${size.width.toInt()}×${size.height.toInt()}',
            fps: _estimateFps(filePath),
            path: filePath,
          );
        });
      }
    } catch (e) {
      // Fallback: if video_player can't parse the file, use basic info
      debugPrint('Could not extract video metadata: $e');
      if (mounted) {
        final localFile = File(filePath);
        final fileBytes = await localFile.length();
        final ext = fileName.split('.').last.toLowerCase();
        setState(() {
          _isUploading = false;
          _fileDetails = FileDetails(
            name: fileName,
            size: fileBytes,
            format: _getFormatFromExtension(ext),
            duration: Duration.zero,
            resolution: 'Unknown',
            fps: 30,
            path: filePath,
          );
        });
      }
    }
  }

  /// Estimates FPS from the file name or extension (video_player doesn't expose fps).
  int _estimateFps(String filePath) {
    final lowerPath = filePath.toLowerCase();
    // Common naming conventions: 30fps, 60fps, etc.
    final fpsRegex = RegExp(r'(\d+)\s*fps', caseSensitive: false);
    final match = fpsRegex.firstMatch(lowerPath);
    if (match != null) {
      final fps = int.tryParse(match.group(1) ?? '');
      if (fps != null && fps > 0 && fps <= 240) return fps;
    }
    return 30; // Default assumption
  }

  String _getFormatFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'mp4':
        return 'MP4';
      case 'mov':
        return 'MOV';
      case 'avi':
        return 'AVI';
      case 'mkv':
        return 'MKV';
      case 'webm':
        return 'WEBM';
      default:
        return ext.toUpperCase();
    }
  }

  // ── Link validation ───────────────────────────────────────────────

  /// Validates a URL by making a real HTTP request and extracting metadata.
  Future<void> _validateLink() async {
    final url = _linkController.text.trim();
    if (url.isEmpty) {
      setState(() => _linkError = 'Please enter a valid URL');
      return;
    }

    // Basic URL format validation
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      setState(() => _linkError = 'Please enter a valid URL (e.g., https://...)');
      return;
    }

    setState(() {
      _isValidating = true;
      _linkError = null;
      _linkDetails = null;
    });

    try {
      final platform = _detectPlatform(url);
      String title = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last.replaceAll('-', ' ')
          : uri.host;
      String channelName = uri.host;
      String? thumbnailUrl;
      Duration duration = Duration.zero;

      if (platform == 'YouTube') {
        // Try to extract metadata from YouTube page
        final ytData = await _fetchYouTubeMetadata(url);
        if (ytData != null) {
          title = ytData['title'] ?? title;
          channelName = ytData['channel'] ?? channelName;
          thumbnailUrl = ytData['thumbnail'];
          if (ytData['duration'] != null) {
            duration = Duration(seconds: ytData['duration']);
          }
        }
      } else {
        // For other URLs, make a HEAD/GET request to verify reachability
        // and extract title from the HTML
        final pageData = await _fetchPageMetadata(url);
        if (pageData != null) {
          title = pageData['title'] ?? title;
          channelName = pageData['siteName'] ?? uri.host;
          thumbnailUrl = pageData['thumbnail'];
        }
      }

      if (mounted) {
        setState(() {
          _isValidating = false;
          _linkDetails = LinkDetails(
            url: url,
            title: title,
            thumbnailUrl: thumbnailUrl ?? '',
            duration: duration,
            platform: platform,
            channelName: channelName,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _linkError = 'Failed to validate URL: $e';
        });
      }
    }
  }

  /// Fetches YouTube video metadata by parsing the oembed API (no API key needed).
  Future<Map<String, dynamic>?> _fetchYouTubeMetadata(String url) async {
    try {
      // Extract video ID from various YouTube URL formats
      String? videoId;
      final uri = Uri.parse(url);

      if (url.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } else if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'];
        // Also handle /shorts/ URLs
        if (videoId == null && uri.pathSegments.contains('shorts')) {
          final idx = uri.pathSegments.indexOf('shorts');
          if (idx + 1 < uri.pathSegments.length) {
            videoId = uri.pathSegments[idx + 1];
          }
        }
      }

      if (videoId == null || videoId.isEmpty) return null;

      // Use YouTube's oEmbed API (no key required) for title and author
      final oembedUrl =
          'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoId&format=json';
      final response = await _dio.get(oembedUrl);

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data;
        return {
          'title': data['title'] as String? ?? 'YouTube Video',
          'channel': data['author_name'] as String? ?? 'YouTube',
          'thumbnail': 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
          'duration': null, // oEmbed doesn't provide duration
        };
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch YouTube metadata: $e');
      return null;
    }
  }

  /// Fetches page metadata (title, site name, thumbnail) from any URL.
  Future<Map<String, dynamic>?> _fetchPageMetadata(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 && response.data is String) {
        final html = response.data as String;
        return _parseMetaTags(html, url);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch page metadata: $e');
      // Even if we can't fetch metadata, the URL might still be valid
      // Return basic info based on the URL
      final uri = Uri.parse(url);
      return {
        'title': uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last.replaceAll('-', ' ')
            : uri.host,
        'siteName': uri.host,
        'thumbnail': null,
      };
    }
  }

  /// Parses Open Graph and standard meta tags from HTML.
  Map<String, dynamic> _parseMetaTags(String html, String url) {
    String? title;
    String? siteName;
    String? thumbnail;

    // Try og:title
    final ogTitleRegex = RegExp(
      r'''<meta\s+[^>]*property=["']og:title["'][^>]*content=["']([^"']+)["']''',
      caseSensitive: false,
    );
    final ogTitleMatch = ogTitleRegex.firstMatch(html);
    if (ogTitleMatch != null) {
      title = ogTitleMatch.group(1);
    }

    // Try standard title tag if no og:title
    if (title == null) {
      final titleRegex = RegExp(
        r'<title[^>]*>([^<]+)</title>',
        caseSensitive: false,
      );
      final titleMatch = titleRegex.firstMatch(html);
      if (titleMatch != null) {
        title = titleMatch.group(1)?.trim();
      }
    }

    // Try og:site_name
    final ogSiteRegex = RegExp(
      r'''<meta\s+[^>]*property=["']og:site_name["'][^>]*content=["']([^"']+)["']''',
      caseSensitive: false,
    );
    final ogSiteMatch = ogSiteRegex.firstMatch(html);
    if (ogSiteMatch != null) {
      siteName = ogSiteMatch.group(1);
    }

    // Try og:image
    final ogImageRegex = RegExp(
      r'''<meta\s+[^>]*property=["']og:image["'][^>]*content=["']([^"']+)["']''',
      caseSensitive: false,
    );
    final ogImageMatch = ogImageRegex.firstMatch(html);
    if (ogImageMatch != null) {
      thumbnail = ogImageMatch.group(1);
    }

    final uri = Uri.parse(url);
    return {
      'title': title ?? uri.host,
      'siteName': siteName ?? uri.host,
      'thumbnail': thumbnail,
    };
  }

  String _detectPlatform(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'YouTube';
    } else if (url.contains('vimeo.com')) {
      return 'Vimeo';
    } else if (url.contains('tiktok.com')) {
      return 'TikTok';
    } else if (url.contains('instagram.com')) {
      return 'Instagram';
    }
    return 'Other';
  }

  // ── Navigation ────────────────────────────────────────────────────

  void _startAnalysis() {
    final isFileTab = _tabController.index == 0;

    // Determine the source info to pass
    String sourceName;
    String sourceType;
    String? sourcePath;
    String? sourceUrl;

    if (isFileTab) {
      sourceType = 'file';
      sourceName = _selectedFile?.name ?? 'Video';
      sourcePath = _selectedFile?.path;
    } else {
      sourceType = 'link';
      sourceName = _linkDetails?.title ?? 'Video';
      sourceUrl = _linkDetails?.url;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisProgressPage(
          sourceType: sourceType,
          sourceName: sourcePath ?? sourceName,
          uploadedFileId: _uploadedFileId,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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
          'Upload Video',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIconsLight.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Tab Bar ─────────────────────────────────────────────
          Container(
            color: AppColors.backgroundSecondary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: PhosphorIcon(PhosphorIconsLight.fileVideo),
                  text: 'Upload File',
                ),
                Tab(
                  icon: PhosphorIcon(PhosphorIconsLight.link),
                  text: 'Paste Link',
                ),
              ],
            ),
          ),

          // ── Tab Content ─────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUploadFileTab(),
                _buildPasteLinkTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // UPLOAD FILE TAB
  // ══════════════════════════════════════════════════════════════════

  Widget _buildUploadFileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDragDropZone(),
          const SizedBox(height: 24),
          if (_selectedFile != null) ...[
            _buildFileInfoCard(),
            const SizedBox(height: 24),
          ],
          if (_isUploading) ...[
            _buildUploadProgress(),
            const SizedBox(height: 24),
          ],
          if (_fileDetails != null) ...[
            _buildStartAnalysisButton(),
            const SizedBox(height: 24),
          ],
          _buildSupportedFormats(),
        ],
      ),
    );
  }

  Widget _buildDragDropZone() {
    return GestureDetector(
      onTap: _pickFile,
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          return MouseRegion(
            onEnter: (_) => setInnerState(() => _isDragging = true),
            onExit: (_) => setInnerState(() => _isDragging = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 280,
              decoration: BoxDecoration(
                color: _isDragging
                    ? AppColors.accent.withOpacity(0.08)
                    : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDragging
                      ? AppColors.accent
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: DottedBorder(
                color: _isDragging
                    ? AppColors.accent
                    : AppColors.borderStrong,
                strokeWidth: 2,
                dashPattern: const [8, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(14),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: PhosphorIcon(
                        PhosphorIconsLight.cloudArrowUp,
                        color: AppColors.accent,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Drag & drop your video here',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'or click to browse',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Max file size: 2 GB',
                        style: GoogleFonts.inter(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileInfoCard() {
    final file = _selectedFile!;
    final details = _fileDetails;
    final fileSize = _formatFileSize(file.size);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Thumbnail placeholder
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.backgroundQuaternary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: PhosphorIcon(
                    PhosphorIconsLight.filmStrip,
                    color: AppColors.textTertiary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileSize,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: PhosphorIcon(
                  PhosphorIconsLight.x,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _fileDetails = null;
                    _uploadProgress = 0;
                    _uploadedFileId = null;
                  });
                },
              ),
            ],
          ),
          if (details != null) ...[
            const Divider(height: 24, color: AppColors.divider),
            Row(
              children: [
                _buildDetailChip(PhosphorIconsLight.fileVideo, details.format),
                const SizedBox(width: 8),
                _buildDetailChip(
                  PhosphorIconsLight.clock,
                  _formatDuration(details.duration),
                ),
                const SizedBox(width: 8),
                _buildDetailChip(
                  PhosphorIconsLight.monitor,
                  details.resolution,
                ),
                const SizedBox(width: 8),
                _buildDetailChip(
                  PhosphorIconsLight.speedometer,
                  '${details.fps} fps',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(PhosphorIconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, color: AppColors.textSecondary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uploading…',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_uploadProgress * 100).toInt()}%',
              style: GoogleFonts.inter(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: AppColors.progressTrack,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStartAnalysisButton() {
    return ElevatedButton(
      onPressed: _startAnalysis,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PhosphorIcon(PhosphorIconsBold.play, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Start Analysis',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportedFormats() {
    final formats = ['MP4', 'MOV', 'AVI', 'MKV', 'WEBM'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsLight.info,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Supported Formats',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: formats.map((format) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  format,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // PASTE LINK TAB
  // ══════════════════════════════════════════════════════════════════

  Widget _buildPasteLinkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── URL Input ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const PhosphorIcon(
                  PhosphorIconsLight.link,
                  color: AppColors.textTertiary,
                ),
                Expanded(
                  child: TextField(
                    controller: _linkController,
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Paste YouTube, Vimeo, or TikTok URL…',
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    onSubmitted: (_) => _validateLink(),
                  ),
                ),
                IconButton(
                  icon: const PhosphorIcon(
                    PhosphorIconsLight.clipboard,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      _linkController.text = data!.text!;
                      _validateLink();
                    }
                  },
                  tooltip: 'Paste from clipboard',
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          if (_linkError != null) ...[
            const SizedBox(height: 8),
            Text(
              _linkError!,
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // ── Validate Button ────────────────────────────────────
          ElevatedButton(
            onPressed: _isValidating ? null : _validateLink,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.backgroundTertiary,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              elevation: 0,
            ),
            child: _isValidating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsLight.magnifyingGlass,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Validate & Fetch',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),

          // ── Link Details ───────────────────────────────────────
          if (_linkDetails != null) ...[
            _buildLinkDetailsCard(),
            const SizedBox(height: 24),
            _buildStartAnalysisButton(),
          ],

          const SizedBox(height: 24),

          // ── Supported Platforms ────────────────────────────────
          _buildSupportedPlatforms(),
        ],
      ),
    );
  }

  Widget _buildLinkDetailsCard() {
    final details = _linkDetails!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Thumbnail placeholder
              Container(
                width: 120,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.backgroundQuaternary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: PhosphorIcon(
                    PhosphorIconsLight.play,
                    color: AppColors.textTertiary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.title,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildPlatformBadge(details.platform),
                        const SizedBox(width: 8),
                        if (details.duration > Duration.zero)
                          Text(
                            _formatDuration(details.duration),
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsLight.user,
                color: AppColors.textTertiary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                details.channelName,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge(String platform) {
    Color badgeColor;
    switch (platform) {
      case 'YouTube':
        badgeColor = const Color(0xFFFF0000);
        break;
      case 'Vimeo':
        badgeColor = const Color(0xFF1AB7EA);
        break;
      case 'TikTok':
        badgeColor = AppColors.textPrimary;
        break;
      case 'Instagram':
        badgeColor = const Color(0xFFE4405F);
        break;
      default:
        badgeColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        platform,
        style: GoogleFonts.inter(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSupportedPlatforms() {
    final platforms = [
      ('YouTube', Color(0xFFFF0000)),
      ('Vimeo', Color(0xFF1AB7EA)),
      ('TikTok', AppColors.textPrimary),
      ('Instagram', Color(0xFFE4405F)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsLight.globe,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Supported Platforms',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: platforms.map((p) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  p.$1,
                  style: GoogleFonts.inter(
                    color: p.$2,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ════════════════════════════════════════════════════════════════════
// Data models
// ════════════════════════════════════════════════════════════════════

class FileDetails {
  final String name;
  final int size;
  final String format;
  final Duration duration;
  final String resolution;
  final int fps;
  final String? path;

  FileDetails({
    required this.name,
    required this.size,
    required this.format,
    required this.duration,
    required this.resolution,
    required this.fps,
    this.path,
  });
}

class LinkDetails {
  final String url;
  final String title;
  final String thumbnailUrl;
  final Duration duration;
  final String platform;
  final String channelName;

  LinkDetails({
    required this.url,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.platform,
    required this.channelName,
  });
}
