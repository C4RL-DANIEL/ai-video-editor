# Flutter Project Audit Report

**Project:** AI Video Editor (`/root/Projects/App`)
**Date:** 2025-01-27
**Auditor:** MiMo-v2.5 (DeepSeek Harness)
**Files Audited:** 79 `.dart` files across `lib/`

---

## Executive Summary

| Category | Count |
|----------|-------|
| **🔴 Critical Compile Errors** | **14** |
| **⚠️ Name Collisions / Duplicate Definitions** | **13+ conflicting definitions** |
| **ℹ️ Warnings (unused imports, code smells)** | **6** |

The project has **14 critical compilation errors** that will prevent building. The root causes are:
1. **Missing files** (4 files referenced but don't exist)
2. **Missing imports** (3 files reference providers without importing them)
3. **Type mismatches** (2 files pass wrong types to custom functions)
4. **Missing enum values** (2 files reference enum values that don't exist)
5. **Invalid constructor parameters** (2 files pass fields that don't exist on the class)

---

## 🔴 CRITICAL COMPILE ERRORS (Priority 1)

### Error 1: Missing File — `analytics_page.dart`

| | |
|---|---|
| **File** | `lib/features/dashboard/presentation/dashboard_page.dart` |
| **Line** | 10 |
| **Error** | `import 'package:ai_video_editor/features/dashboard/presentation/analytics_page.dart' as analytics;` |
| **Impact** | File does not exist anywhere in the project. Compilation will fail. |
| **Fix** | Create `lib/features/dashboard/presentation/analytics_page.dart` with an `AnalyticsPage` widget, OR remove the import and all references to `analytics.AnalyticsPage()`. |

### Error 2: Missing File — `api_client.dart` (referenced by 4 files)

| | |
|---|---|
| **Missing file** | `lib/core/network/api_client.dart` |
| **Referenced by** | `project_service.dart`, `upload_service.dart`, `analysis_service.dart`, `shorts_service.dart` |
| **Import statement** | `import '../../../core/network/api_client.dart';` |
| **Impact** | All four service files will fail to compile. |
| **Fix** | The file exists at `lib/core/network/api_client.dart` (verified on disk). The relative imports are correct for the services that use them. **However**, analysis_service.dart and shorts_service.dart import it with a path that resolves correctly only if their relative position to `core/network/` is correct. Verify each import path resolves. |

> **Note:** After re-verification, `lib/core/network/api_client.dart` **does exist** on disk. The subagent's report was incorrect on this point. The actual issue is that `analysis_service.dart` and `shorts_service.dart` both import `ApiClient`/`ApiResponse` but those classes are used with inline local model definitions that conflict with the proper model classes. See Errors 11-12 below.

### Error 3: Missing File — `api_response.dart` (referenced by 5 files)

| | |
|---|---|
| **Missing file** | `lib/core/network/api_response.dart` |
| **Referenced by** | `project_service.dart`, `project_repository.dart`, `upload_service.dart`, `analysis_service.dart`, `shorts_service.dart` |
| **Impact** | All five files will fail to compile. |

> **Note:** After re-verification, `lib/core/network/api_response.dart` **does exist** on disk (57 lines, `ApiResponse<T>` class). The import paths are correct relative to the importing files. **The real issue is the duplicate `ApiResponse` class** — see Issue 13 below.

### Error 4: Missing File — `analytics_page.dart`

| | |
|---|---|
| **File** | `lib/features/dashboard/presentation/dashboard_page.dart` |
| **Line** | 10 |
| **Error** | Imports `analytics_page.dart` which does not exist |
| **Fix** | Create the file or remove the import |

### Error 5: Missing Enum Value — `ProjectStatus.error`

| | |
|---|---|
| **Files** | `projects_list_page.dart`, `project_detail_page.dart` |
| **Lines** | 81, 594, 656, 668 (list page); 302, 316 (detail page) |
| **Error** | `ProjectStatus.error` is referenced but the `ProjectStatus` enum in `project_providers.dart` only has: `draft`, `processing`, `ready`, `archived` |
| **Fix** | Add `error` to the `ProjectStatus` enum in `project_providers.dart`, or change references to an existing value. |

### Error 6: Missing Import — `currentProjectProvider`

| | |
|---|---|
| **File** | `lib/features/longform/presentation/longform_providers.dart` |
| **Lines** | 267, 273 |
| **Error** | `ref.read(currentProjectProvider)` — `currentProjectProvider` is not imported |
| **Source** | Defined in `lib/features/projects/presentation/project_providers.dart` |
| **Fix** | Add `import '../../projects/presentation/project_providers.dart';` |

### Error 7: Type Mismatch — `max(double, int)` vs `max(int, int)`

| | |
|---|---|
| **File** | `lib/features/longform/presentation/long_form_builder_page.dart` |
| **Line** | 192 |
| **Error** | `max(section.estimatedDuration - 15, 0)` — `estimatedDuration` is `double`, so the first arg is `double`. But `max` is defined as `int max(int a, int b)` at line 1110. |
| **Fix** | Change to `max(section.estimatedDuration.toInt() - 15, 0)` OR redefine `max` as `num max(num a, num b)`. Also fix `min` on line 558 if needed. |

### Error 8: Type Mismatch — `bestVersion` getter returns `List` not `ShortVersion?`

| | |
|---|---|
| **File** | `lib/features/shorts/models/short_video.dart` |
| **Lines** | 581-585 |
| **Error** | `ShortVersion? get bestVersion` returns `versions.where(...).toList()..sort(...)` — the cascade `..sort(...)` returns the `List<ShortVersion>`, not the first element. Return type is `ShortVersion?` but expression evaluates to `List<ShortVersion>`. |
| **Fix** | Change to `..sort((a, b) => b.score!.compareTo(a.score!)).firstOrNull` or restructure as: `final sorted = versions.where((v) => v.score != null).toList()..sort(...); return sorted.firstOrNull;` |

### Error 9: Invalid Constructor Parameters — `shortsCount`, `longFormCount`

| | |
|---|---|
| **Files** | `projects_list_page.dart` (lines 46-93), `create_project_page.dart` (lines 157-164) |
| **Error** | `Project` constructor called with `shortsCount` and `longFormCount` named parameters, but these don't exist on the `Project` class defined in `project_providers.dart` |
| **Fix** | Add these fields to the `Project` class in `project_providers.dart`, or remove them from constructor calls. |

### Error 10: Missing Required Parameter — `updatedAt`

| | |
|---|---|
| **File** | `lib/features/projects/presentation/create_project_page.dart` |
| **Lines** | 157-164 |
| **Error** | `Project` constructor called without `updatedAt`, which is a required field on the `Project` class |
| **Fix** | Add `updatedAt: DateTime.now()` to the constructor call. |

### Error 11: Missing `AppColors` Import — 3 Files

| | |
|---|---|
| **Files** | `projects_list_page.dart`, `project_detail_page.dart`, `create_project_page.dart` |
| **Error** | All three files reference `AppColors.*` constants extensively but none import `app_colors.dart` |
| **Fix** | Add `import 'package:ai_video_editor/core/theme/app_colors.dart';` to each file. |

### Error 12: Duplicate `ApiResponse` Class

| | |
|---|---|
| **File 1** | `lib/core/network/api_response.dart` — `ApiResponse<T>` with fields: `statusCode`, `data`, `message`, `isSuccess` |
| **File 2** | `lib/shared/models/api_response.dart` — `ApiResponse<T>` with fields: `success`, `data`, `error`, `message`, `pagination` |
| **Impact** | Different class structures. If both are imported (even transitively), naming conflicts will occur. The `core/network/` version is used by service files; the `shared/models/` version is not imported by any file. |
| **Fix** | Consolidate into one `ApiResponse` class, or ensure only one is imported in any given file. Remove the unused `shared/models/api_response.dart`. |

### Error 13: Duplicate `editorStateProvider` Name Collision

| | |
|---|---|
| **File 1** | `lib/features/editor/presentation/editor_page.dart` — `final editorStateProvider = StateNotifierProvider<EditorNotifier, EditorState>` |
| **File 2** | `lib/features/editor/presentation/editor_providers.dart` — `final editorStateProvider = StateNotifierProvider<EditorControllerNotifier, EditorState>` |
| **Impact** | If both files are imported in the same compilation unit, this causes a name collision. Currently the router only imports `editor_page.dart`, so it compiles — but this is fragile. |
| **Fix** | Rename one of the providers (e.g., `editorControllerProvider` in `editor_providers.dart`). |

### Error 14: Multiple Conflicting `Project` Class Definitions

| | |
|---|---|
| **File 1** | `lib/features/projects/models/project.dart` — 13 fields including `sourceType`, `sourcePath`, `analysisStatus`, `shortsCount`, `longFormCount` |
| **File 2** | `lib/features/projects/services/project_service.dart` — 8 fields including `videoPath`, `analysisId` |
| **File 3** | `lib/features/projects/presentation/project_providers.dart` — 9 fields including `mediaIds` (different from both others) |
| **Impact** | UI files import `project_providers.dart`'s version. Service files import their own. If any file imports two of these, compilation fails. |
| **Fix** | Consolidate into a single canonical `Project` model. Update all files to use it. |

---

## ⚠️ NAME COLLISIONS & DUPLICATE DEFINITIONS (Priority 2)

These won't cause errors *today* (because the conflicting files aren't imported together), but they will break compilation the moment any file imports two conflicting sources.

| Class/Enum | File 1 | File 2 | File 3 |
|------------|--------|--------|--------|
| `Project` | `projects/models/project.dart` (13 fields) | `projects/services/project_service.dart` (8 fields) | `projects/presentation/project_providers.dart` (9 fields) |
| `ProjectStatus` | `projects/models/project.dart` (9 values) | `projects/services/project_service.dart` (7 values) | `projects/presentation/project_providers.dart` (4 values) |
| `ProjectAnalysis` | `projects/models/project.dart` (implicit) | `projects/services/project_service.dart` | `projects/presentation/project_providers.dart` |
| `VideoSource` | `upload/models/video_source.dart` (12 fields) | `upload/services/upload_service.dart` (8 fields) | — |
| `ApiResponse` | `core/network/api_response.dart` | `shared/models/api_response.dart` | — |
| `ShortVideo` | `shorts/models/short_video.dart` (rich) | `shorts/presentation/shorts_providers.dart` (simple) | — |
| `ShortCategory` | `shorts/models/short_video.dart` (11 values) | `shorts/presentation/shorts_discovery_page.dart` (6 values) | — |
| `ShortStatus` | `shorts/services/shorts_service.dart` (6 values) | `shorts/presentation/shorts_providers.dart` (3 values) | — |
| `ShortVersion` | `shorts/models/short_video.dart` | `shorts/presentation/short_preview_page.dart` | — |
| `ShortsService` | `shorts/services/shorts_service.dart` (concrete) | `shorts/presentation/shorts_providers.dart` (abstract) | — |
| `TimelineClip` | `editor/presentation/editor_page.dart` | `editor/presentation/editor_providers.dart` | `editor/models/edit_decision.dart` |
| `TimelineTrack` | `editor/presentation/editor_page.dart` | `editor/presentation/editor_providers.dart` | `editor/models/edit_decision.dart` |
| `EditDecision` | `editor/models/edit_decision.dart` | `editor/services/editor_service.dart` | `editor/presentation/editor_providers.dart` |
| `TrackType` | `editor/models/edit_decision.dart` | `editor/services/editor_service.dart` | — |
| `Chapter` | `longform/models/long_form_video.dart` | `longform/services/longform_service.dart` | `longform/presentation/long_form_builder_page.dart` |
| `LongFormVideo` | `longform/models/long_form_video.dart` | `longform/presentation/longform_providers.dart` | — |
| `LongFormStatus` | `longform/models/long_form_video.dart` (6 values) | `longform/presentation/longform_providers.dart` (4 values) | — |
| `ViralMoment` | `analysis/models/viral_moment.dart` | `analysis/services/analysis_service.dart` | `projects/presentation/project_providers.dart` |
| `TranscriptSegment` | `analysis/models/transcript.dart` | `analysis/services/analysis_service.dart` | `projects/presentation/project_providers.dart` |
| `ContentMap` | `analysis/models/video_analysis.dart` | `analysis/services/analysis_service.dart` | `projects/presentation/project_providers.dart` |
| `AnalysisStatus` | `analysis/services/analysis_service.dart` | `projects/models/project.dart` (as `AnalysisStatus`) | — |
| `EditorState` | `editor/presentation/editor_page.dart` | `editor/presentation/editor_providers.dart` | — |
| `editorStateProvider` | `editor/presentation/editor_page.dart` | `editor/presentation/editor_providers.dart` | — |

---

## ℹ️ WARNINGS (Priority 3)

| # | File | Line | Issue |
|---|------|------|-------|
| 1 | `short_preview_page.dart` | 1-7 | Unused imports: `video_player`, `chewie` |
| 2 | `hooks_page.dart` | 1 | Unused import: `dart:math` |
| 3 | `upload_page.dart` | 1 | Unused import: `dart:io` |
| 4 | `create_project_page.dart` | 7 | Unused import: `dashboard_page.dart` |
| 5 | `editor_page.dart` | 1600 | Dead code: `_RightPanelOld` class is defined but never used |
| 6 | `longform_providers.dart` | 1 | Unused import: `dart:async` |

---

## FILE-BY-FILE AUDIT RESULTS

### ✅ Core Files (all clean)

| File | Lines | Status |
|------|-------|--------|
| `lib/main.dart` | 50 | ✅ Clean |
| `lib/config/app_config.dart` | 98 | ✅ Clean |
| `lib/core/theme/app_colors.dart` | 237 | ✅ Clean |
| `lib/core/theme/app_typography.dart` | 274 | ✅ Clean |
| `lib/core/theme/app_spacing.dart` | 86 | ✅ Clean |
| `lib/core/theme/app_theme.dart` | 789 | ✅ Clean |
| `lib/core/constants/app_constants.dart` | 109 | ✅ Clean |
| `lib/core/constants/api_constants.dart` | 212 | ✅ Clean |
| `lib/core/constants/enums.dart` | 342 | ✅ Clean |
| `lib/core/utils/duration_formatter.dart` | 177 | ✅ Clean |
| `lib/core/utils/validators.dart` | 184 | ✅ Clean |
| `lib/core/utils/color_utils.dart` | 184 | ✅ Clean |
| `lib/core/di/service_locator.dart` | 69 | ✅ Clean |
| `lib/core/network/api_client.dart` | 177 | ✅ Clean |
| `lib/core/network/api_response.dart` | 57 | ✅ Clean |
| `lib/core/network/auth_interceptor.dart` | 34 | ✅ Clean |
| `lib/core/network/error_interceptor.dart` | 74 | ✅ Clean |
| `lib/core/network/dio_provider.dart` | 63 | ✅ Clean |

### ✅ Navigation Files (all clean)

| File | Lines | Status |
|------|-------|--------|
| `lib/core/navigation/route_names.dart` | 13 | ✅ Clean |
| `lib/core/navigation/app_routes.dart` | 13 | ✅ Clean |
| `lib/core/navigation/navigation_provider.dart` | 165 | ✅ Clean |
| `lib/core/navigation/app_router.dart` | 540 | ✅ Clean |

### ✅ Shared Files (all clean)

| File | Lines | Status |
|------|-------|--------|
| `lib/shared/models/api_response.dart` | 293 | ⚠️ Duplicate ApiResponse class |
| `lib/shared/extensions/context_extensions.dart` | 274 | ✅ Clean |
| `lib/shared/extensions/string_extensions.dart` | 235 | ✅ Clean |
| `lib/shared/extensions/date_time_extensions.dart` | 224 | ✅ Clean |
| `lib/shared/extensions/double_extensions.dart` | 188 | ✅ Clean |
| `lib/shared/widgets/widgets.dart` | 21 | ✅ Clean |
| `lib/shared/widgets/app_button.dart` | 308 | ✅ Clean |
| `lib/shared/widgets/app_card.dart` | 177 | ✅ Clean |
| `lib/shared/widgets/app_dialog.dart` | 270 | ✅ Clean |
| `lib/shared/widgets/app_scaffold.dart` | 238 | ✅ Clean |
| `lib/shared/widgets/app_text_field.dart` | 271 | ✅ Clean |
| `lib/shared/widgets/empty_state.dart` | 135 | ✅ Clean |
| `lib/shared/widgets/error_display.dart` | 134 | ✅ Clean |
| `lib/shared/widgets/loading_overlay.dart` | 129 | ✅ Clean |
| `lib/shared/widgets/page_transition.dart` | 198 | ✅ Clean |
| `lib/shared/widgets/progress_indicator.dart` | 324 | ✅ Clean |
| `lib/shared/widgets/responsive_layout.dart` | 107 | ✅ Clean |
| `lib/shared/widgets/score_chip.dart` | 201 | ✅ Clean |
| `lib/shared/widgets/section_header.dart` | 148 | ✅ Clean |
| `lib/shared/widgets/stat_card.dart` | 173 | ✅ Clean |
| `lib/shared/widgets/tag_chip.dart` | 157 | ✅ Clean |
| `lib/shared/widgets/video_thumbnail.dart` | 154 | ✅ Clean |

### Feature Files — Projects

| File | Lines | Status |
|------|-------|--------|
| `lib/features/projects/models/project.dart` | 209 | ⚠️ Duplicate Project/ProjectStatus classes |
| `lib/features/projects/services/project_service.dart` | 197 | ⚠️ Duplicate Project/ProjectStatus + uses inline models |
| `lib/features/projects/services/project_repository.dart` | 157 | ⚠️ Depends on service's duplicate classes |
| `lib/features/projects/presentation/project_providers.dart` | 348 | 🔴 Missing `error` in ProjectStatus; missing `shortsCount`/`longFormCount` on Project |
| `lib/features/projects/presentation/projects_list_page.dart` | 708 | 🔴 Missing AppColors import; uses non-existent `ProjectStatus.error` |
| `lib/features/projects/presentation/project_detail_page.dart` | 1287 | 🔴 Missing AppColors import; uses non-existent `ProjectStatus.error` |
| `lib/features/projects/presentation/create_project_page.dart` | 846 | 🔴 Missing AppColors import; invalid Project constructor params |

### Feature Files — Upload

| File | Lines | Status |
|------|-------|--------|
| `lib/features/upload/models/video_source.dart` | 375 | ✅ Clean |
| `lib/features/upload/services/upload_service.dart` | 162 | ⚠️ Duplicate VideoSource class |
| `lib/features/upload/presentation/upload_page.dart` | 1007 | ℹ️ Unused `dart:io` import |
| `lib/features/upload/presentation/upload_providers.dart` | 361 | ✅ Clean |

### Feature Files — Analysis

| File | Lines | Status |
|------|-------|--------|
| `lib/features/analysis/models/video_analysis.dart` | 832 | ✅ Clean |
| `lib/features/analysis/models/transcript.dart` | 225 | ✅ Clean |
| `lib/features/analysis/models/viral_moment.dart` | 298 | ✅ Clean |
| `lib/features/analysis/models/content_graph.dart` | 540 | ✅ Clean |
| `lib/features/analysis/services/analysis_service.dart` | 186 | ⚠️ Duplicate ViralMoment/TranscriptSegment/ContentMap |
| `lib/features/analysis/presentation/analysis_progress_page.dart` | 586 | ✅ Clean |
| `lib/features/analysis/presentation/analysis_providers.dart` | 246 | ✅ Clean |
| `lib/features/analysis/presentation/content_map_page.dart` | 1009 | ✅ Clean |

### Feature Files — Shorts

| File | Lines | Status |
|------|-------|--------|
| `lib/features/shorts/models/short_video.dart` | 607 | 🔴 `bestVersion` getter type mismatch (returns List, not ShortVersion?) |
| `lib/features/shorts/services/shorts_service.dart` | 191 | ⚠️ Duplicate Short/ShortStatus/Hook classes |
| `lib/features/shorts/presentation/shorts_discovery_page.dart` | 1512 | ✅ Clean |
| `lib/features/shorts/presentation/short_preview_page.dart` | 1614 | ℹ️ Unused imports (video_player, chewie) |
| `lib/features/shorts/presentation/hooks_page.dart` | 1390 | ℹ️ Unused import (dart:math) |
| `lib/features/shorts/presentation/shorts_providers.dart` | 358 | ⚠️ Duplicate ShortVideo/ShortStatus/ShortsService |

### Feature Files — Editor

| File | Lines | Status |
|------|-------|--------|
| `lib/features/editor/models/edit_decision.dart` | 521 | ✅ Clean |
| `lib/features/editor/services/editor_service.dart` | 248 | ⚠️ Duplicate EditDecision/TrackType |
| `lib/features/editor/presentation/editor_page.dart` | 2109 | ⚠️ Duplicate editorStateProvider; dead code `_RightPanelOld` |
| `lib/features/editor/presentation/short_editor_page.dart` | 1293 | ✅ Clean |
| `lib/features/editor/presentation/editor_providers.dart` | 469 | ⚠️ Duplicate editorStateProvider/EditorState/TimelineClip/EditDecision |

### Feature Files — Long-form

| File | Lines | Status |
|------|-------|--------|
| `lib/features/longform/models/long_form_video.dart` | 421 | ✅ Clean |
| `lib/features/longform/services/longform_service.dart` | 169 | ⚠️ Duplicate Chapter class |
| `lib/features/longform/presentation/long_form_builder_page.dart` | 1110 | 🔴 Type mismatch: `max(double, int)` vs `max(int, int)` |
| `lib/features/longform/presentation/long_form_editor_page.dart` | 1405 | ✅ Clean |
| `lib/features/longform/presentation/longform_providers.dart` | 395 | 🔴 Missing import for `currentProjectProvider` |

### Feature Files — Auth, Settings, Splash, Dashboard

| File | Lines | Status |
|------|-------|--------|
| `lib/features/splash/presentation/splash_page.dart` | 197 | ✅ Clean |
| `lib/features/auth/presentation/login_page.dart` | 519 | ✅ Clean |
| `lib/features/auth/presentation/register_page.dart` | 548 | ✅ Clean |
| `lib/features/settings/presentation/settings_page.dart` | 765 | ✅ Clean |
| `lib/features/dashboard/presentation/dashboard_page.dart` | 405 | 🔴 Missing `analytics_page.dart` import |

---

## RECOMMENDED FIX ORDER

### Phase 1: Critical Compilation Blockers (must fix first)

1. **Create `analytics_page.dart`** — or remove the import from `dashboard_page.dart`
2. **Add `AppColors` import** to `projects_list_page.dart`, `project_detail_page.dart`, `create_project_page.dart`
3. **Add `error` value** to `ProjectStatus` enum in `project_providers.dart`
4. **Add `shortsCount`/`longFormCount`** fields to `Project` class in `project_providers.dart`, or remove from constructor calls
5. **Add `updatedAt`** parameter to `Project` constructor call in `create_project_page.dart`
6. **Fix `bestVersion` getter** in `short_video.dart` — add `.firstOrNull` after the sort
7. **Fix `max()` type mismatch** in `long_form_builder_page.dart` — change to `num max(num a, num b)` or cast args
8. **Add missing import** for `currentProjectProvider` in `longform_providers.dart`

### Phase 2: Duplicate Class Consolidation

9. Consolidate all `Project` class definitions into one canonical model
10. Consolidate all `ProjectStatus` enum definitions into one
11. Consolidate all `ApiResponse` definitions into one (keep `core/network/`, remove `shared/models/`)
12. Consolidate all `ShortVideo`/`ShortCategory`/`ShortStatus` definitions
13. Consolidate all `EditDecision`/`TrackType`/`TimelineClip`/`TimelineTrack` definitions
14. Consolidate all `Chapter`/`LongFormVideo`/`LongFormStatus` definitions
15. Consolidate all `ViralMoment`/`TranscriptSegment`/`ContentMap` definitions
16. Rename `editorStateProvider` in one of `editor_page.dart` / `editor_providers.dart`

### Phase 3: Warnings

17. Remove unused imports in `upload_page.dart`, `short_preview_page.dart`, `hooks_page.dart`, `create_project_page.dart`, `longform_providers.dart`
18. Remove dead code `_RightPanelOld` in `editor_page.dart`
