# Appwrite Setup Guide (Free — No Credit Card Required)

## Why Appwrite?
- **Free tier**: 75,000 monthly active users, 10GB storage, 50GB bandwidth
- **No credit card** required
- **Open source** — self-host if you want
- Built-in auth, database, storage, functions
- REST API + Flutter SDK

---

## Step 1: Create Appwrite Account

1. Go to [cloud.appwrite.io](https://cloud.appwrite.io)
2. Sign up (free, no credit card)
3. Click **Create Project**
4. Name it `AI Video Editor`
5. Copy your **Project ID** (looks like `64a1b2c3d4e5f...`)

---

## Step 2: Create Database

1. Left sidebar → **Databases**
2. Click **Create Database**
3. Name: `ai_video_editor`
4. **Database ID**: Click "Generate" or type `ai_video_editor_db`
5. Click **Create**

### Step 2a: Create Each Collection

For EACH collection below, do this:

1. Inside your database → click **Create Collection**
2. Enter the **Collection ID** (exact name from the table)
3. Enter the **Name** (human-readable)
4. Click **Create**
5. Click the **Attributes** tab → add each field from the table
6. Click the **Settings** tab → set Permissions

#### Collection 1: `projects`

| Attribute Name | Type | Required | Default |
|---------------|------|----------|---------|
| name | String | ✅ | — |
| description | String | ❌ | `""` |
| status | String | ✅ | `"draft"` |
| sourceType | String | ✅ | `"file"` |
| sourcePath | String | ❌ | `""` |
| sourceUrl | String | ❌ | `""` |
| shortsCount | Integer | ❌ | `0` |
| longFormCount | Integer | ❌ | `0` |
| createdAt | String | ✅ | — |
| updatedAt | String | ✅ | — |

**Permissions:**
- Read: `any`
- Create: `any`
- Update: `any`
- Delete: `any`

#### Collection 2: `shorts`

| Attribute Name | Type | Required | Default |
|---------------|------|----------|---------|
| projectId | String | ✅ | — |
| title | String | ✅ | — |
| sourceStartTime | Float | ✅ | — |
| sourceEndTime | Float | ✅ | — |
| hookText | String | ❌ | `""` |
| viralScore | Integer | ❌ | `0` |
| hookScore | Integer | ❌ | `0` |
| category | String | ❌ | `"general"` |
| status | String | ✅ | `"draft"` |
| duration | Float | ❌ | `0` |
| createdAt | String | ✅ | — |

**Permissions:**
- Read: `any`
- Create: `any`
- Update: `any`
- Delete: `any`

#### Collection 3: `long_forms`

| Attribute Name | Type | Required | Default |
|---------------|------|----------|---------|
| projectId | String | ✅ | — |
| title | String | ✅ | — |
| targetDuration | Float | ❌ | `600` |
| actualDuration | Float | ❌ | `0` |
| status | String | ✅ | `"draft"` |
| chapterCount | Integer | ❌ | `0` |
| createdAt | String | ✅ | — |

**Permissions:**
- Read: `any`
- Create: `any`
- Update: `any`
- Delete: `any`

#### Collection 4: `analysis`

| Attribute Name | Type | Required | Default |
|---------------|------|----------|---------|
| projectId | String | ✅ | — |
| status | String | ✅ | `"pending"` |
| transcriptText | String | ❌ | `""` |
| sceneCount | Integer | ❌ | `0` |
| speakerCount | Integer | ❌ | `0` |
| duration | Float | ❌ | `0` |
| completedAt | String | ❌ | `""` |

**Permissions:**
- Read: `any`
- Create: `any`
- Update: `any`
- Delete: `any`

#### Collection 5: `moments`

| Attribute Name | Type | Required | Default |
|---------------|------|----------|---------|
| projectId | String | ✅ | — |
| analysisId | String | ❌ | `""` |
| startTime | Float | ✅ | — |
| endTime | Float | ✅ | — |
| type | String | ✅ | `"general"` |
| score | Integer | ❌ | `0` |
| hookScore | Integer | ❌ | `0` |
| reasoning | String | ❌ | `""` |
| createdAt | String | ✅ | — |

**Permissions:**
- Read: `any`
- Create: `any`
- Update: `any`
- Delete: `any`

#### Collection 6: `transcripts`

| Attribute Name | Type | Required | Default |
|---------------|------|----------|---------|
| projectId | String | ✅ | — |
| fullText | String | ❌ | `""` |
| language | String | ❌ | `"en"` |
| segmentCount | Integer | ❌ | `0` |
| wordCount | Integer | ❌ | `0` |

**Permissions:**
- Read: `any`
- Create: `any`
- Update: `any`
- Delete: `any`

---

## Step 3: Create Storage Buckets

1. Left sidebar → **Storage**
2. For each bucket below, click **Create Bucket**

| Bucket Name | Bucket ID | Max File Size | Permissions |
|------------|-----------|---------------|-------------|
| Videos | `videos` | 2048 MB (2GB) | Any read, Any write |
| Thumbnails | `thumbnails` | 5 MB | Any read, Any write |
| Exports | `exports` | 2048 MB (2GB) | Any read, Any write |

For each bucket:
1. Enter the **Bucket ID** exactly as shown
2. Set **Maximum File Size** to the value shown
3. **Permissions** → Set all to **Any** (for MVP/development)
4. Click **Create**

---

## Step 4: Configure Flutter

Open `lib/config/appwrite_config.dart` and update:

```dart
static const String endpoint = 'https://cloud.appwrite.io/v1';
static const String projectId = 'PASTE_YOUR_PROJECT_ID_HERE';
static const String databaseId = 'ai_video_editor_db';
```

---

## Step 5: Update main.dart

Open `lib/main.dart` and replace with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';

import 'config/appwrite_config.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Appwrite client
  final client = createAppwriteClient();

  runApp(const ProviderScope(child: AiVideoEditorApp()));
}

class AiVideoEditorApp extends ConsumerWidget {
  const AiVideoEditorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'AI Video Editor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
```

---

## Step 6: Test the Connection

Add this to `main.dart` temporarily to verify Appwrite is connected:

```dart
// Test Appwrite connection
try {
  final client = createAppwriteClient();
  final account = Account(client);
  print('Appwrite connected! Endpoint: ${AppwriteConfig.endpoint}');
} catch (e) {
  print('Appwrite connection failed: $e');
}
```

---

## Troubleshooting

### "Collection not found"
- Make sure you created the collection inside the correct database
- Check the Collection ID matches exactly (case-sensitive)

### "Permission denied"
- Go to the collection → Settings → Permissions
- Make sure all permissions are set to "Any" for development

### "Document limit exceeded"
- Free tier allows unlimited documents per collection
- Check if you hit the 10GB storage limit

### "Invalid endpoint"
- Make sure endpoint is `https://cloud.appwrite.io/v1` (with /v1)
- For self-hosted: `http://YOUR_SERVER:80/v1`

---

## Quick Visual Guide

```
Appwrite Console
├── Project: AI Video Editor
│   ├── Databases
│   │   └── Database: ai_video_editor_db
│   │       ├── Collection: projects
│   │       ├── Collection: shorts
│   │       ├── Collection: long_forms
│   │       ├── Collection: analysis
│   │       ├── Collection: moments
│   │       └── Collection: transcripts
│   ├── Storage
│   │   ├── Bucket: videos (2GB)
│   │   ├── Bucket: thumbnails (5MB)
│   │   └── Bucket: exports (2GB)
│   └── Auth
│       └── Enable: Email/Password
```

---

## Free Tier Limits
- ✅ 75,000 monthly active users
- ✅ 10GB database storage
- ✅ 10GB file storage
- ✅ 50GB bandwidth
- ✅ Unlimited API calls
- ✅ Unlimited databases
- ✅ Unlimited collections

---

## Next Steps After Setup

1. Push code to GitHub
2. Run `flutter pub get`
3. Run `flutter run`
4. Create a test project in the app
5. Verify it appears in Appwrite Console → Database → projects

Need help? Check the [Appwrite Docs](https://appwrite.io/docs) or [Community Discord](https://appwrite.io/discord)
