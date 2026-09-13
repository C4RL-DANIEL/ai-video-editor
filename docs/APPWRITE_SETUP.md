# Appwrite Setup Guide (Free — No Credit Card Required)

## Why Appwrite?
- **Free tier**: 75,000 monthly active users, 10GB storage, 50GB bandwidth
- **No credit card** required
- **Open source** — self-host if you want
- Built-in auth, database, storage, functions
- REST API + Flutter SDK

## Step 1: Create Appwrite Account
1. Go to [cloud.appwrite.io](https://cloud.appwrite.io)
2. Sign up (free, no credit card)
3. Create a new project → note the **Project ID**

## Step 2: Create Database
1. Go to **Databases** → Create Database
2. Name it `ai_video_editor`
3. Note the **Database ID**

### Create Collections

| Collection | Fields |
|------------|--------|
| `projects` | name, description, status, sourceType, sourcePath, sourceUrl, shortsCount, longFormCount, createdAt, updatedAt |
| `shorts` | projectId, title, sourceStartTime, sourceEndTime, hookText, viralScore, status, createdAt |
| `long_forms` | projectId, title, targetDuration, actualDuration, status, createdAt |
| `analysis` | projectId, transcript, scenes, speakers, moments, completedAt |
| `moments` | projectId, startTime, endTime, type, score, reasoning |
| `transcripts` | projectId, segments, fullText, language |

### Set Permissions
For each collection, set:
- **Read**: `any`
- **Write**: `any`

(For production, restrict to authenticated users)

## Step 3: Create Storage Buckets

| Bucket | Permission | Max Size |
|--------|-----------|----------|
| `videos` | any read/write | 2GB |
| `thumbnails` | any read/write | 5MB |
| `exports` | any read/write | 2GB |

## Step 4: Configure Flutter

Update `lib/config/appwrite_config.dart`:
```dart
static const String endpoint = 'https://cloud.appwrite.io/v1';
static const String projectId = 'YOUR_PROJECT_ID';
static const String databaseId = 'YOUR_DATABASE_ID';
```

## Step 5: Update main.dart

```dart
import 'package:appwrite/appwrite.dart';
import 'config/appwrite_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final client = createAppwriteClient();
  // Services are initialized via providers
  
  runApp(const ProviderScope(child: AiVideoEditorApp()));
}
```

## Free Tier Limits
- 75,000 monthly active users
- 10GB storage
- 50GB bandwidth
- Unlimited databases
- Unlimited API calls

## Self-Hosted Option
```bash
docker run -it --rm \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  appwrite/appwrite sh -c "install"
```
Then point `endpoint` to your server.
