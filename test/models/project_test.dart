import 'package:flutter_test/flutter_test.dart';
import 'package:ai_video_editor/features/projects/models/project.dart';

void main() {
  group('ProjectSourceType', () {
    test('fromString returns correct enum value', () {
      expect(ProjectSourceType.fromString('file'), ProjectSourceType.file);
      expect(ProjectSourceType.fromString('link'), ProjectSourceType.link);
    });

    test('fromString returns file for unknown value', () {
      expect(ProjectSourceType.fromString('unknown'), ProjectSourceType.file);
    });

    test('toJson returns name', () {
      expect(ProjectSourceType.file.toJson(), 'file');
      expect(ProjectSourceType.link.toJson(), 'link');
    });
  });

  group('ProjectStatus', () {
    test('fromString returns correct enum value', () {
      expect(ProjectStatus.fromString('draft'), ProjectStatus.draft);
      expect(ProjectStatus.fromString('uploading'), ProjectStatus.uploading);
      expect(ProjectStatus.fromString('processing'), ProjectStatus.processing);
      expect(ProjectStatus.fromString('analyzing'), ProjectStatus.analyzing);
      expect(ProjectStatus.fromString('ready'), ProjectStatus.ready);
      expect(ProjectStatus.fromString('editing'), ProjectStatus.editing);
      expect(ProjectStatus.fromString('exporting'), ProjectStatus.exporting);
      expect(ProjectStatus.fromString('completed'), ProjectStatus.completed);
      expect(ProjectStatus.fromString('failed'), ProjectStatus.failed);
    });

    test('fromString returns draft for unknown value', () {
      expect(ProjectStatus.fromString('unknown'), ProjectStatus.draft);
    });

    test('isActive returns true for active statuses', () {
      expect(ProjectStatus.uploading.isActive, true);
      expect(ProjectStatus.processing.isActive, true);
      expect(ProjectStatus.analyzing.isActive, true);
      expect(ProjectStatus.editing.isActive, true);
      expect(ProjectStatus.exporting.isActive, true);
    });

    test('isActive returns false for non-active statuses', () {
      expect(ProjectStatus.draft.isActive, false);
      expect(ProjectStatus.ready.isActive, false);
      expect(ProjectStatus.completed.isActive, false);
      expect(ProjectStatus.failed.isActive, false);
    });

    test('isTerminal returns true for terminal statuses', () {
      expect(ProjectStatus.completed.isTerminal, true);
      expect(ProjectStatus.failed.isTerminal, true);
    });

    test('isTerminal returns false for non-terminal statuses', () {
      expect(ProjectStatus.draft.isTerminal, false);
      expect(ProjectStatus.uploading.isTerminal, false);
      expect(ProjectStatus.processing.isTerminal, false);
      expect(ProjectStatus.ready.isTerminal, false);
      expect(ProjectStatus.editing.isTerminal, false);
    });
  });

  group('AnalysisStatus', () {
    test('fromString returns correct enum value', () {
      expect(AnalysisStatus.fromString('pending'), AnalysisStatus.pending);
      expect(AnalysisStatus.fromString('inProgress'), AnalysisStatus.inProgress);
      expect(AnalysisStatus.fromString('completed'), AnalysisStatus.completed);
      expect(AnalysisStatus.fromString('failed'), AnalysisStatus.failed);
    });

    test('fromString returns pending for unknown value', () {
      expect(AnalysisStatus.fromString('unknown'), AnalysisStatus.pending);
    });
  });

  group('Project', () {
    // Shared test data
    final now = DateTime(2024, 1, 15, 10, 30, 0);
    final later = DateTime(2024, 1, 15, 11, 0, 0);

    Project createTestProject({
      String id = 'test-id',
      String name = 'Test Project',
      ProjectSourceType sourceType = ProjectSourceType.file,
      String? sourcePath = '/path/to/video.mp4',
      String? sourceUrl,
      ProjectStatus status = ProjectStatus.draft,
      AnalysisStatus analysisStatus = AnalysisStatus.pending,
      int shortsCount = 3,
      int longFormCount = 1,
      DateTime? createdAt,
      DateTime? updatedAt,
      Map<String, dynamic> metadata = const {},
      String? thumbnailUrl,
    }) {
      return Project(
        id: id,
        name: name,
        sourceType: sourceType,
        sourcePath: sourcePath,
        sourceUrl: sourceUrl,
        status: status,
        analysisStatus: analysisStatus,
        shortsCount: shortsCount,
        longFormCount: longFormCount,
        createdAt: createdAt ?? now,
        updatedAt: updatedAt ?? later,
        metadata: metadata,
        thumbnailUrl: thumbnailUrl,
      );
    }

    group('construction', () {
      test('creates project with required parameters', () {
        final project = Project(
          id: '1',
          name: 'My Project',
          sourceType: ProjectSourceType.file,
          status: ProjectStatus.draft,
          analysisStatus: AnalysisStatus.pending,
          createdAt: now,
          updatedAt: later,
        );

        expect(project.id, '1');
        expect(project.name, 'My Project');
        expect(project.sourceType, ProjectSourceType.file);
        expect(project.sourcePath, null);
        expect(project.sourceUrl, null);
        expect(project.status, ProjectStatus.draft);
        expect(project.analysisStatus, AnalysisStatus.pending);
        expect(project.shortsCount, 0);
        expect(project.longFormCount, 0);
        expect(project.createdAt, now);
        expect(project.updatedAt, later);
        expect(project.metadata, isEmpty);
        expect(project.thumbnailUrl, null);
      });

      test('creates project with all parameters', () {
        final metadata = {'key': 'value', 'count': 42};
        final project = createTestProject(
          sourceUrl: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          metadata: metadata,
        );

        expect(project.sourceUrl, 'https://example.com/video.mp4');
        expect(project.thumbnailUrl, 'https://example.com/thumb.jpg');
        expect(project.metadata, metadata);
      });

      test('uses const empty map for default metadata', () {
        final p1 = createTestProject();
        final p2 = createTestProject();
        // Both use the same const empty map instance
        expect(identical(p1.metadata, p2.metadata), true);
      });
    });

    group('fromJson / toJson serialization', () {
      test('round-trip preserves all fields', () {
        final original = createTestProject(
          sourceUrl: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          metadata: {'theme': 'dark'},
        );

        final json = original.toJson();
        final restored = Project.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.sourceType, original.sourceType);
        expect(restored.sourcePath, original.sourcePath);
        expect(restored.sourceUrl, original.sourceUrl);
        expect(restored.status, original.status);
        expect(restored.analysisStatus, original.analysisStatus);
        expect(restored.shortsCount, original.shortsCount);
        expect(restored.longFormCount, original.longFormCount);
        expect(restored.createdAt, original.createdAt);
        expect(restored.updatedAt, original.updatedAt);
        expect(restored.metadata, original.metadata);
        expect(restored.thumbnailUrl, original.thumbnailUrl);
      });

      test('fromJson handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final project = Project.fromJson(json);

        expect(project.id, '');
        expect(project.name, '');
        expect(project.sourceType, ProjectSourceType.file);
        expect(project.status, ProjectStatus.draft);
        expect(project.analysisStatus, AnalysisStatus.pending);
        expect(project.shortsCount, 0);
        expect(project.longFormCount, 0);
        expect(project.createdAt, isA<DateTime>());
        expect(project.updatedAt, isA<DateTime>());
        expect(project.metadata, isEmpty);
      });

      test('fromJson handles all source types', () {
        for (final type in ProjectSourceType.values) {
          final json = {
            'id': '1',
            'sourceType': type.name,
          };
          final project = Project.fromJson(json);
          expect(project.sourceType, type);
        }
      });

      test('fromJson handles all project statuses', () {
        for (final status in ProjectStatus.values) {
          final json = {
            'id': '1',
            'status': status.name,
          };
          final project = Project.fromJson(json);
          expect(project.status, status);
        }
      });

      test('fromJson handles all analysis statuses', () {
        for (final status in AnalysisStatus.values) {
          final json = {
            'id': '1',
            'analysisStatus': status.name,
          };
          final project = Project.fromJson(json);
          expect(project.analysisStatus, status);
        }
      });

      test('toJson produces correct structure', () {
        final project = createTestProject();
        final json = project.toJson();

        expect(json['id'], project.id);
        expect(json['name'], project.name);
        expect(json['sourceType'], project.sourceType.name);
        expect(json['status'], project.status.name);
        expect(json['analysisStatus'], project.analysisStatus.name);
        expect(json['shortsCount'], project.shortsCount);
        expect(json['longFormCount'], project.longFormCount);
        expect(json['createdAt'], project.createdAt.toIso8601String());
        expect(json['updatedAt'], project.updatedAt.toIso8601String());
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        final original = createTestProject();
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.status, original.status);
      });

      test('copies with id updated', () {
        final original = createTestProject();
        final copy = original.copyWith(id: 'new-id');
        expect(copy.id, 'new-id');
        expect(original.id, 'test-id');
      });

      test('copies with name updated', () {
        final original = createTestProject();
        final copy = original.copyWith(name: 'New Name');
        expect(copy.name, 'New Name');
      });

      test('copies with sourceType updated', () {
        final original = createTestProject();
        final copy = original.copyWith(sourceType: ProjectSourceType.link);
        expect(copy.sourceType, ProjectSourceType.link);
      });

      test('copies with status updated', () {
        final original = createTestProject();
        final copy = original.copyWith(status: ProjectStatus.processing);
        expect(copy.status, ProjectStatus.processing);
      });

      test('copies with analysisStatus updated', () {
        final original = createTestProject();
        final copy =
            original.copyWith(analysisStatus: AnalysisStatus.completed);
        expect(copy.analysisStatus, AnalysisStatus.completed);
      });

      test('copies with shortsCount updated', () {
        final original = createTestProject();
        final copy = original.copyWith(shortsCount: 10);
        expect(copy.shortsCount, 10);
      });

      test('copies with longFormCount updated', () {
        final original = createTestProject();
        final copy = original.copyWith(longFormCount: 5);
        expect(copy.longFormCount, 5);
      });

      test('copies with createdAt updated', () {
        final newDate = DateTime(2025, 6, 1);
        final original = createTestProject();
        final copy = original.copyWith(createdAt: newDate);
        expect(copy.createdAt, newDate);
      });

      test('copies with updatedAt updated', () {
        final newDate = DateTime(2025, 6, 1);
        final original = createTestProject();
        final copy = original.copyWith(updatedAt: newDate);
        expect(copy.updatedAt, newDate);
      });

      test('copies with metadata updated', () {
        final original = createTestProject();
        final copy = original.copyWith(metadata: {'new': 'data'});
        expect(copy.metadata, {'new': 'data'});
      });

      test('copies with sourcePath cleared', () {
        final original = createTestProject(sourcePath: '/path/to/video.mp4');
        final copy = original.copyWith(clearSourcePath: true);
        expect(copy.sourcePath, null);
      });

      test('copies with sourceUrl cleared', () {
        final original =
            createTestProject(sourceUrl: 'https://example.com/video.mp4');
        final copy = original.copyWith(clearSourceUrl: true);
        expect(copy.sourceUrl, null);
      });

      test('copies with thumbnailUrl cleared', () {
        final original =
            createTestProject(thumbnailUrl: 'https://example.com/thumb.jpg');
        final copy = original.copyWith(clearThumbnailUrl: true);
        expect(copy.thumbnailUrl, null);
      });
    });

    group('getters', () {
      test('isAnalyzed returns true when analysis completed', () {
        final project =
            createTestProject(analysisStatus: AnalysisStatus.completed);
        expect(project.isAnalyzed, true);
      });

      test('isAnalyzed returns false when analysis pending', () {
        final project =
            createTestProject(analysisStatus: AnalysisStatus.pending);
        expect(project.isAnalyzed, false);
      });

      test('hasLocalSource returns true when sourcePath is non-empty', () {
        final project = createTestProject(sourcePath: '/path/to/video.mp4');
        expect(project.hasLocalSource, true);
      });

      test('hasLocalSource returns false when sourcePath is null', () {
        final project = createTestProject(sourcePath: null);
        expect(project.hasLocalSource, false);
      });

      test('hasLocalSource returns false when sourcePath is empty', () {
        final project = createTestProject(sourcePath: '');
        expect(project.hasLocalSource, false);
      });

      test('hasRemoteSource returns true when sourceUrl is non-empty', () {
        final project =
            createTestProject(sourceUrl: 'https://example.com/video.mp4');
        expect(project.hasRemoteSource, true);
      });

      test('hasRemoteSource returns false when sourceUrl is null', () {
        final project = createTestProject(sourceUrl: null);
        expect(project.hasRemoteSource, false);
      });

      test('hasRemoteSource returns false when sourceUrl is empty', () {
        final project = createTestProject(sourceUrl: '');
        expect(project.hasRemoteSource, false);
      });

      test('totalVideos sums shortsCount and longFormCount', () {
        final project =
            createTestProject(shortsCount: 5, longFormCount: 2);
        expect(project.totalVideos, 7);
      });

      test('totalVideos returns zero when both counts are zero', () {
        final project =
            createTestProject(shortsCount: 0, longFormCount: 0);
        expect(project.totalVideos, 0);
      });
    });

    group('equality', () {
      test('equal projects with same id are equal', () {
        final p1 = createTestProject(id: 'same-id', name: 'Name 1');
        final p2 = createTestProject(id: 'same-id', name: 'Name 2');
        expect(p1 == p2, true);
        expect(p1.hashCode, p2.hashCode);
      });

      test('projects with different ids are not equal', () {
        final p1 = createTestProject(id: 'id-1');
        final p2 = createTestProject(id: 'id-2');
        expect(p1 == p2, false);
      });

      test('project is equal to itself', () {
        final p = createTestProject();
        expect(p == p, true);
      });

      test('project is not equal to non-Project object', () {
        final p = createTestProject();
        expect(p == 'not a project', false);
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final project = createTestProject(id: 'p1', name: 'Test');
        final str = project.toString();
        expect(str, contains('p1'));
        expect(str, contains('Test'));
        expect(str, contains('draft'));
      });
    });
  });
}
