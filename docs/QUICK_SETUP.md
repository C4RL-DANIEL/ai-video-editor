# Quick Setup Checklist

## Appwrite (Free, No Credit Card)

### ☐ Step 1: Create Account
- [ ] Go to https://cloud.appwrite.io
- [ ] Sign up (email or Google)
- [ ] Create project "AI Video Editor"
- [ ] Copy **Project ID**

### ☐ Step 2: Create Database
- [ ] Databases → Create Database
- [ ] Name: `ai_video_editor`
- [ ] Database ID: `ai_video_editor_db`

### ☐ Step 3: Create Collections (one by one)

For each collection:
1. Click **Create Collection**
2. Enter the **Collection ID** exactly as shown
3. Click **Attributes** tab → add the fields
4. Click **Settings** tab → Permissions → All "Any"

#### Collections to create:

**projects** (Collection ID: `projects`)
- [ ] name (String, required)
- [ ] description (String)
- [ ] status (String, required)
- [ ] sourceType (String, required)
- [ ] sourcePath (String)
- [ ] sourceUrl (String)
- [ ] shortsCount (Integer)
- [ ] longFormCount (Integer)
- [ ] createdAt (String, required)
- [ ] updatedAt (String, required)

**shorts** (Collection ID: `shorts`)
- [ ] projectId (String, required)
- [ ] title (String, required)
- [ ] sourceStartTime (Float, required)
- [ ] sourceEndTime (Float, required)
- [ ] hookText (String)
- [ ] viralScore (Integer)
- [ ] status (String, required)
- [ ] createdAt (String, required)

**long_forms** (Collection ID: `long_forms`)
- [ ] projectId (String, required)
- [ ] title (String, required)
- [ ] targetDuration (Float)
- [ ] actualDuration (Float)
- [ ] status (String, required)
- [ ] createdAt (String, required)

**analysis** (Collection ID: `analysis`)
- [ ] projectId (String, required)
- [ ] status (String, required)
- [ ] transcriptText (String)
- [ ] completedAt (String)

**moments** (Collection ID: `moments`)
- [ ] projectId (String, required)
- [ ] startTime (Float, required)
- [ ] endTime (Float, required)
- [ ] type (String, required)
- [ ] score (Integer)
- [ ] reasoning (String)

**transcripts** (Collection ID: `transcripts`)
- [ ] projectId (String, required)
- [ ] fullText (String)
- [ ] language (String)
- [ ] segmentCount (Integer)
- [ ] wordCount (Integer)

### ☐ Step 4: Create Storage Buckets

- [ ] Bucket ID: `videos` (Max: 2048MB, Permissions: Any)
- [ ] Bucket ID: `thumbnails` (Max: 5MB, Permissions: Any)
- [ ] Bucket ID: `exports` (Max: 2048MB, Permissions: Any)

### ☐ Step 5: Configure Flutter

Update `lib/config/appwrite_config.dart`:
```dart
static const String projectId = 'YOUR_PROJECT_ID_HERE';
static const String databaseId = 'ai_video_editor_db';
```

### ☐ Step 6: Run the App
```bash
flutter pub get
flutter run
```

---

## ✅ Done! You should be able to:
- Sign up / Sign in
- Create projects
- Upload videos
- See projects in Appwrite Console
