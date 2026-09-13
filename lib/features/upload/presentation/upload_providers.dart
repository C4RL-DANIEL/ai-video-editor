import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ═══════════════════════════════════════════════════════════════════════
// Domain models
// ═══════════════════════════════════════════════════════════════════════

enum UploadStatus { idle, validating, uploading, processing, completed, failed }

enum MediaType { video, audio, image, unknown }

class UploadTask {
  final String id;
  final String fileName;
  final MediaType mediaType;
  final UploadStatus status;
  final double progress; // 0.0 – 1.0
  final String? sourcePath; // local path
  final String? sourceUrl; // remote URL (link upload)
  final String? remoteUrl; // where it ends up after upload
  final String? errorMessage;
  final DateTime createdAt;

  const UploadTask({
    required this.id,
    required this.fileName,
    this.mediaType = MediaType.unknown,
    this.status = UploadStatus.idle,
    this.progress = 0.0,
    this.sourcePath,
    this.sourceUrl,
    this.remoteUrl,
    this.errorMessage,
    required this.createdAt,
  });

  UploadTask copyWith({
    UploadStatus? status,
    double? progress,
    String? remoteUrl,
    String? errorMessage,
    MediaType? mediaType,
  }) {
    return UploadTask(
      id: id,
      fileName: fileName,
      mediaType: mediaType ?? this.mediaType,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      sourcePath: sourcePath,
      sourceUrl: sourceUrl,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt,
    );
  }

  bool get isCompleted => status == UploadStatus.completed;
  bool get isFailed => status == UploadStatus.failed;
  bool get isUploading =>
      status == UploadStatus.uploading || status == UploadStatus.processing;
}

class FileValidationResult {
  final bool isValid;
  final String? errorMessage;
  final MediaType detectedType;

  const FileValidationResult({
    required this.isValid,
    this.errorMessage,
    this.detectedType = MediaType.unknown,
  });

  factory FileValidationResult.valid(MediaType type) =>
      FileValidationResult(isValid: true, detectedType: type);

  factory FileValidationResult.invalid(String message) =>
      FileValidationResult(isValid: false, errorMessage: message);
}

class LinkValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? resolvedUrl;

  const LinkValidationResult({
    required this.isValid,
    this.errorMessage,
    this.resolvedUrl,
  });

  factory LinkValidationResult.valid(String resolvedUrl) =>
      LinkValidationResult(isValid: true, resolvedUrl: resolvedUrl);

  factory LinkValidationResult.invalid(String message) =>
      LinkValidationResult(isValid: false, errorMessage: message);
}

// ═══════════════════════════════════════════════════════════════════════
// Service abstraction
// ═══════════════════════════════════════════════════════════════════════

abstract class UploadService {
  FileValidationResult validateFile(String path);
  Future<LinkValidationResult> validateLink(String url);
  Stream<double> uploadFile(String taskId, String path);
  Future<String> uploadFromLink(String taskId, String url);
  MediaType detectMediaType(String fileName);
}

class MockUploadService implements UploadService {
  @override
  FileValidationResult validateFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    final validExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'mp3', 'wav', 'm4a', 'jpg', 'jpeg', 'png', 'gif'];
    if (!validExtensions.contains(ext)) {
      return FileValidationResult.invalid('Unsupported file type: .$ext');
    }
    return FileValidationResult.valid(detectMediaType(path));
  }

  @override
  Future<LinkValidationResult> validateLink(String url) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return LinkValidationResult.invalid('Invalid URL format');
    }
    if (!['http', 'https'].contains(uri.scheme)) {
      return LinkValidationResult.invalid('Only HTTP/HTTPS links are supported');
    }
    return LinkValidationResult.valid(url);
  }

  @override
  Stream<double> uploadFile(String taskId, String path) async* {
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield i / 100.0;
    }
  }

  @override
  Future<String> uploadFromLink(String taskId, String url) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://storage.example.com/uploads/$taskId';
  }

  @override
  MediaType detectMediaType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) return MediaType.video;
    if (['mp3', 'wav', 'm4a', 'aac'].contains(ext)) return MediaType.audio;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return MediaType.image;
    return MediaType.unknown;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// State Notifier
// ═══════════════════════════════════════════════════════════════════════

class UploadState {
  final List<UploadTask> tasks;
  final bool isDragOver;

  const UploadState({
    this.tasks = const [],
    this.isDragOver = false,
  });

  UploadState copyWith({
    List<UploadTask>? tasks,
    bool? isDragOver,
  }) {
    return UploadState(
      tasks: tasks ?? this.tasks,
      isDragOver: isDragOver ?? this.isDragOver,
    );
  }

  int get activeCount =>
      tasks.where((t) => t.isUploading).length;

  int get completedCount =>
      tasks.where((t) => t.isCompleted).length;

  int get failedCount =>
      tasks.where((t) => t.isFailed).length;

  double get overallProgress {
    if (tasks.isEmpty) return 0.0;
    return tasks.map((t) => t.progress).reduce((a, b) => a + b) / tasks.length;
  }

  bool get hasActiveUploads => activeCount > 0;
}

class UploadNotifier extends StateNotifier<UploadState> {
  final UploadService _service;

  UploadNotifier(this._service) : super(const UploadState());

  /// Validate a local file and add it as a task if valid.
  FileValidationResult validateAndAddFile(String path) {
    final result = _service.validateFile(path);
    if (result.isValid) {
      final task = UploadTask(
        id: 'upload_${DateTime.now().millisecondsSinceEpoch}',
        fileName: path.split('/').last,
        mediaType: result.detectedType,
        sourcePath: path,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(tasks: [...state.tasks, task]);
    }
    return result;
  }

  /// Validate a URL link and add as a task if valid.
  Future<LinkValidationResult> validateAndAddLink(String url) async {
    final result = await _service.validateLink(url);
    if (result.isValid) {
      final task = UploadTask(
        id: 'upload_${DateTime.now().millisecondsSinceEpoch}',
        fileName: url.split('/').last,
        mediaType: MediaType.video,
        sourceUrl: url,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(tasks: [...state.tasks, task]);
    }
    return result;
  }

  /// Start uploading a specific task.
  Future<void> startUpload(String taskId) async {
    final idx = state.tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final task = state.tasks[idx];
    if (task.sourcePath == null && task.sourceUrl == null) return;

    _updateTask(idx, task.copyWith(status: UploadStatus.uploading, progress: 0.0));

    try {
      if (task.sourcePath != null) {
        await for (final progress in _service.uploadFile(taskId, task.sourcePath!)) {
          _updateTask(idx, state.tasks[idx].copyWith(progress: progress));
        }
      } else {
        _updateTask(idx, state.tasks[idx].copyWith(status: UploadStatus.processing));
        final remoteUrl = await _service.uploadFromLink(taskId, task.sourceUrl!);
        _updateTask(idx, state.tasks[idx].copyWith(
          status: UploadStatus.completed,
          progress: 1.0,
          remoteUrl: remoteUrl,
        ));
      }

      // Ensure completed
      if (!state.tasks[idx].isCompleted) {
        _updateTask(idx, state.tasks[idx].copyWith(
          status: UploadStatus.completed,
          progress: 1.0,
        ));
      }
    } catch (e) {
      _updateTask(idx, state.tasks[idx].copyWith(
        status: UploadStatus.failed,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Retry a failed upload.
  Future<void> retryUpload(String taskId) async {
    final idx = state.tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _updateTask(idx, state.tasks[idx].copyWith(
      status: UploadStatus.idle,
      progress: 0.0,
      errorMessage: null,
    ));
    await startUpload(taskId);
  }

  /// Remove a task from the list.
  void removeTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != taskId).toList(),
    );
  }

  /// Clear all completed tasks.
  void clearCompleted() {
    state = state.copyWith(
      tasks: state.tasks.where((t) => !t.isCompleted).toList(),
    );
  }

  /// Set drag-over state for drop zone UI.
  void setDragOver(bool value) {
    state = state.copyWith(isDragOver: value);
  }

  void _updateTask(int index, UploadTask updated) {
    final newTasks = List<UploadTask>.from(state.tasks);
    newTasks[index] = updated;
    state = state.copyWith(tasks: newTasks);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════════

final uploadServiceProvider = Provider<UploadService>((ref) {
  return MockUploadService();
});

/// Main upload state (task list, drag state, aggregate progress).
final uploadStateProvider =
    StateNotifierProvider<UploadNotifier, UploadState>(
  (ref) => UploadNotifier(ref.read(uploadServiceProvider)),
);

/// Derived: overall progress 0.0–1.0.
final uploadProgressProvider = Provider<double>((ref) {
  return ref.watch(uploadStateProvider).overallProgress;
});

/// Derived: number of active uploads.
final uploadActiveCountProvider = Provider<int>((ref) {
  return ref.watch(uploadStateProvider).activeCount;
});

/// Derived: has any uploads completed.
final uploadHasCompletedProvider = Provider<bool>((ref) {
  return ref.watch(uploadStateProvider).completedCount > 0;
});

/// Derived: has any uploads failed.
final uploadHasFailedProvider = Provider<bool>((ref) {
  return ref.watch(uploadStateProvider).failedCount > 0;
});

// ── Validation helpers ──────────────────────────────────────────────

/// Sync file validation via the upload service.
final fileValidationProvider =
    Provider.family<FileValidationResult, String>((ref, filePath) {
  return ref.read(uploadServiceProvider).validateFile(filePath);
});

/// Async link validation via the upload service.
final linkValidationProvider =
    FutureProvider.family<LinkValidationResult, String>((ref, url) async {
  return ref.read(uploadServiceProvider).validateLink(url);
});
