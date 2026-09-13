import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ═══════════════════════════════════════════════════════════════════════
// Domain models
// ═══════════════════════════════════════════════════════════════════════

enum EditorTool { select, trim, split, text, sticker, transition, audio }

enum TimelineZoomLevel { fitAll, normal, zoomed }

class TimelineClip {
  final String id;
  final String sourceId;
  final String? label;
  final double startTime; // position on timeline (seconds)
  final double duration; // clip duration (seconds)
  final double sourceInPoint; // in-point in source media
  final double sourceOutPoint; // out-point in source media
  final double volume; // 0.0 – 1.0
  final bool isMuted;
  final int trackIndex; // which track (0 = main)

  const TimelineClip({
    required this.id,
    required this.sourceId,
    this.label,
    required this.startTime,
    required this.duration,
    required this.sourceInPoint,
    required this.sourceOutPoint,
    this.volume = 1.0,
    this.isMuted = false,
    this.trackIndex = 0,
  });

  TimelineClip copyWith({
    String? label,
    double? startTime,
    double? duration,
    double? sourceInPoint,
    double? sourceOutPoint,
    double? volume,
    bool? isMuted,
    int? trackIndex,
  }) {
    return TimelineClip(
      id: id,
      sourceId: sourceId,
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      sourceInPoint: sourceInPoint ?? this.sourceInPoint,
      sourceOutPoint: sourceOutPoint ?? this.sourceOutPoint,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      trackIndex: trackIndex ?? this.trackIndex,
    );
  }
}

class EditDecision {
  final String id;
  final String type; // "trim", "split", "move", "delete", "volume", etc.
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
  final DateTime timestamp;

  const EditDecision({
    required this.id,
    required this.type,
    required this.before,
    required this.after,
    required this.timestamp,
  });
}

class TextOverlay {
  final String id;
  final String text;
  final double startTime;
  final double duration;
  final double x;
  final double y;
  final double fontSize;
  final String fontFamily;
  final int color; // ARGB
  final bool isBold;
  final bool isItalic;

  const TextOverlay({
    required this.id,
    required this.text,
    required this.startTime,
    required this.duration,
    this.x = 0.5,
    this.y = 0.5,
    this.fontSize = 24,
    this.fontFamily = 'Inter',
    this.color = 0xFFFFFFFF,
    this.isBold = false,
    this.isItalic = false,
  });
}

// ═══════════════════════════════════════════════════════════════════════
// Timeline state
// ═══════════════════════════════════════════════════════════════════════

class TimelineState {
  final List<TimelineClip> clips;
  final double playheadPosition; // current playhead in seconds
  final bool isPlaying;
  final TimelineZoomLevel zoomLevel;
  final double? totalDuration; // auto-calculated from clips

  const TimelineState({
    this.clips = const [],
    this.playheadPosition = 0,
    this.isPlaying = false,
    this.zoomLevel = TimelineZoomLevel.fitAll,
    this.totalDuration,
  });

  TimelineState copyWith({
    List<TimelineClip>? clips,
    double? playheadPosition,
    bool? isPlaying,
    TimelineZoomLevel? zoomLevel,
    double? totalDuration,
  }) {
    return TimelineState(
      clips: clips ?? this.clips,
      playheadPosition: playheadPosition ?? this.playheadPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  /// Computed total duration based on the latest clip end.
  double get computedDuration {
    if (clips.isEmpty) return 0;
    double maxEnd = 0;
    for (final clip in clips) {
      final end = clip.startTime + clip.duration;
      if (end > maxEnd) maxEnd = end;
    }
    return maxEnd;
  }

  /// Get clip at a given playhead position.
  TimelineClip? clipAtPosition(double position) {
    for (final clip in clips) {
      if (position >= clip.startTime && position < clip.startTime + clip.duration) {
        return clip;
      }
    }
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Editor state (top-level)
// ═══════════════════════════════════════════════════════════════════════

class EditorState {
  final EditorTool activeTool;
  final String? selectedClipId;
  final bool isDirty; // has unsaved changes
  final bool isSaving;
  final String? error;

  const EditorState({
    this.activeTool = EditorTool.select,
    this.selectedClipId,
    this.isDirty = false,
    this.isSaving = false,
    this.error,
  });

  EditorState copyWith({
    EditorTool? activeTool,
    String? selectedClipId,
    bool? isDirty,
    bool? isSaving,
    String? error,
  }) {
    return EditorState(
      activeTool: activeTool ?? this.activeTool,
      selectedClipId: selectedClipId ?? this.selectedClipId,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Undo / Redo
// ═══════════════════════════════════════════════════════════════════════

class UndoRedoState {
  final List<EditDecision> _undoStack;
  final List<EditDecision> _redoStack;

  UndoRedoState({
    List<EditDecision>? undoStack,
    List<EditDecision>? redoStack,
  })  : _undoStack = undoStack ?? [],
        _redoStack = redoStack ?? [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get undoCount => _undoStack.length;
  int get redoCount => _redoStack.length;
  List<EditDecision> get undoStack => List.unmodifiable(_undoStack);
  List<EditDecision> get redoStack => List.unmodifiable(_redoStack);

  UndoRedoState copyWith({
    List<EditDecision>? undoStack,
    List<EditDecision>? redoStack,
  }) {
    return UndoRedoState(
      undoStack: undoStack ?? _undoStack,
      redoStack: redoStack ?? _redoStack,
    );
  }
}

class UndoRedoNotifier extends StateNotifier<UndoRedoState> {
  UndoRedoNotifier() : super(UndoRedoState());

  void push(EditDecision decision) {
    state = state.copyWith(
      undoStack: [...state._undoStack, decision],
      redoStack: [], // new action clears redo
    );
  }

  EditDecision? undo() {
    if (!state.canUndo) return null;
    final decision = state._undoStack.last;
    state = state.copyWith(
      undoStack: state._undoStack.sublist(0, state._undoStack.length - 1),
      redoStack: [...state._redoStack, decision],
    );
    return decision;
  }

  EditDecision? redo() {
    if (!state.canRedo) return null;
    final decision = state._redoStack.last;
    state = state.copyWith(
      redoStack: state._redoStack.sublist(0, state._redoStack.length - 1),
      undoStack: [...state._undoStack, decision],
    );
    return decision;
  }

  void clear() {
    state = UndoRedoState();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Timeline Notifier
// ═══════════════════════════════════════════════════════════════════════

class TimelineNotifier extends StateNotifier<TimelineState> {
  final UndoRedoNotifier _undoRedo;

  TimelineNotifier(this._undoRedo) : super(const TimelineState());

  void addClip(TimelineClip clip) {
    _recordAction('add_clip', {}, clip.toJson());
    state = state.copyWith(
      clips: [...state.clips, clip],
    );
  }

  void removeClip(String clipId) {
    final clip = state.clips.firstWhere((c) => c.id == clipId);
    _recordAction('remove_clip', clip.toJson(), {});
    state = state.copyWith(
      clips: state.clips.where((c) => c.id != clipId).toList(),
    );
  }

  void moveClip(String clipId, double newStartTime) {
    final idx = state.clips.indexWhere((c) => c.id == clipId);
    if (idx == -1) return;
    final oldClip = state.clips[idx];
    final updated = oldClip.copyWith(startTime: newStartTime);
    _recordAction('move_clip', oldClip.toJson(), updated.toJson());
    final newClips = List<TimelineClip>.from(state.clips);
    newClips[idx] = updated;
    state = state.copyWith(clips: newClips);
  }

  void trimClip(String clipId, double newDuration) {
    final idx = state.clips.indexWhere((c) => c.id == clipId);
    if (idx == -1) return;
    final oldClip = state.clips[idx];
    final updated = oldClip.copyWith(duration: newDuration);
    _recordAction('trim_clip', oldClip.toJson(), updated.toJson());
    final newClips = List<TimelineClip>.from(state.clips);
    newClips[idx] = updated;
    state = state.copyWith(clips: newClips);
  }

  void splitClip(String clipId, double splitPoint) {
    final idx = state.clips.indexWhere((c) => c.id == clipId);
    if (idx == -1) return;
    final clip = state.clips[idx];
    final relativePoint = splitPoint - clip.startTime;
    if (relativePoint <= 0 || relativePoint >= clip.duration) return;

    final left = clip.copyWith(
      duration: relativePoint,
      sourceOutPoint: clip.sourceInPoint + relativePoint,
    );
    final right = TimelineClip(
      id: '${clip.id}_split_${DateTime.now().millisecondsSinceEpoch}',
      sourceId: clip.sourceId,
      label: clip.label,
      startTime: clip.startTime + relativePoint,
      duration: clip.duration - relativePoint,
      sourceInPoint: clip.sourceInPoint + relativePoint,
      sourceOutPoint: clip.sourceOutPoint,
      volume: clip.volume,
      isMuted: clip.isMuted,
      trackIndex: clip.trackIndex,
    );

    _recordAction('split_clip', clip.toJson(), {
      'left': left.toJson(),
      'right': right.toJson(),
    });

    final newClips = List<TimelineClip>.from(state.clips);
    newClips.removeAt(idx);
    newClips.insertAll(idx, [left, right]);
    state = state.copyWith(clips: newClips);
  }

  void setClipVolume(String clipId, double volume) {
    final idx = state.clips.indexWhere((c) => c.id == clipId);
    if (idx == -1) return;
    final newClips = List<TimelineClip>.from(state.clips);
    newClips[idx] = newClips[idx].copyWith(volume: volume);
    state = state.copyWith(clips: newClips);
  }

  void toggleClipMute(String clipId) {
    final idx = state.clips.indexWhere((c) => c.id == clipId);
    if (idx == -1) return;
    final newClips = List<TimelineClip>.from(state.clips);
    newClips[idx] = newClips[idx].copyWith(isMuted: !newClips[idx].isMuted);
    state = state.copyWith(clips: newClips);
  }

  void setPlayhead(double position) {
    state = state.copyWith(playheadPosition: position);
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void setZoom(TimelineZoomLevel zoom) {
    state = state.copyWith(zoomLevel: zoom);
  }

  void _recordAction(String type, Map<String, dynamic> before, Map<String, dynamic> after) {
    _undoRedo.push(EditDecision(
      id: 'edit_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      before: before,
      after: after,
      timestamp: DateTime.now(),
    ));
  }
}

// ── Extension for JSON serialization (stub) ─────────────────────────
extension _TimelineClipJson on TimelineClip {
  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'label': label,
        'startTime': startTime,
        'duration': duration,
        'sourceInPoint': sourceInPoint,
        'sourceOutPoint': sourceOutPoint,
        'volume': volume,
        'isMuted': isMuted,
        'trackIndex': trackIndex,
      };
}

// ═══════════════════════════════════════════════════════════════════════
// Editor Notifier (top-level tools, selection, save)
// ═══════════════════════════════════════════════════════════════════════

class EditorControllerNotifier extends StateNotifier<EditorState> {
  EditorControllerNotifier() : super(const EditorState());

  void selectTool(EditorTool tool) {
    state = state.copyWith(activeTool: tool);
  }

  void selectClip(String? clipId) {
    state = state.copyWith(selectedClipId: clipId);
  }

  void markDirty() => state = state.copyWith(isDirty: true);
  void markClean() => state = state.copyWith(isDirty: false);

  Future<void> save() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      // TODO: persist to backend
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isSaving: false, isDirty: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════════

/// Top-level editor state (tool, selection, dirty, save).
final editorStateProvider =
    StateNotifierProvider<EditorControllerNotifier, EditorState>(
  (ref) => EditorControllerNotifier(),
);

/// Undo/redo stack.
final undoRedoProvider =
    StateNotifierProvider<UndoRedoNotifier, UndoRedoState>(
  (ref) => UndoRedoNotifier(),
);

/// Timeline state (clips, playhead, zoom).
final timelineProvider =
    StateNotifierProvider<TimelineNotifier, TimelineState>(
  (ref) => TimelineNotifier(ref.read(undoRedoProvider.notifier)),
);

/// Derived: currently selected clip object.
final selectedClipProvider = Provider<TimelineClip?>((ref) {
  final editor = ref.watch(editorStateProvider);
  final timeline = ref.watch(timelineProvider);
  if (editor.selectedClipId == null) return null;
  try {
    return timeline.clips.firstWhere((c) => c.id == editor.selectedClipId);
  } catch (_) {
    return null;
  }
});

/// Derived: total duration of the timeline.
final timelineDurationProvider = Provider<double>((ref) {
  return ref.watch(timelineProvider).computedDuration;
});

/// Derived: clip count.
final clipCountProvider = Provider<int>((ref) {
  return ref.watch(timelineProvider).clips.length;
});
