#!/bin/bash

# Appwrite CLI Setup Script for AI Video Editor
# Creates all database collections and attributes automatically

set -e

echo "🎬 AI Video Editor - Appwrite Setup"
echo "==================================="
echo ""

# Check if Appwrite CLI is installed
if ! command -v appwrite &> /dev/null; then
    echo "❌ Appwrite CLI not found. Installing..."
    npm install -g appwrite-cli
    echo "✅ Appwrite CLI installed"
fi

# Prompt for configuration
echo "📝 Please enter your Appwrite configuration:"
read -p "Project ID: " PROJECT_ID
read -p "Database ID (default: ai_video_editor_db): " DATABASE_ID
DATABASE_ID=${DATABASE_ID:-ai_video_editor_db}

echo ""
echo "🔐 Logging in to Appwrite..."
appwrite login

echo ""
echo "📦 Setting project..."
appwrite client --projectId "$PROJECT_ID"

echo ""
echo "🗄️  Creating database: $DATABASE_ID"
appwrite databases create \
    --databaseId "$DATABASE_ID" \
    --name "AI Video Editor Database"

# ═══════════════════════════════════════════════════════════════════
# Create Collections
# ═══════════════════════════════════════════════════════════════════

echo ""
echo "📋 Creating collections..."

# ── Collection: projects ──────────────────────────────────────────
echo "  Creating: projects"
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --name "Projects" \
    --permission "any" \
    --permission "any" \
    --permission "any" \
    --permission "any"

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "name" \
    --size 255 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "description" \
    --size 1000 \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "status" \
    --size 50 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "sourceType" \
    --size 20 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "sourcePath" \
    --size 500 \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "sourceUrl" \
    --size 2000 \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "shortsCount" \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "longFormCount" \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "createdAt" \
    --size 50 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "projects" \
    --key "updatedAt" \
    --size 50 \
    --required true

# ── Collection: shorts ───────────────────────────────────────────
echo "  Creating: shorts"
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --name "Shorts" \
    --permission "any" \
    --permission "any" \
    --permission "any" \
    --permission "any"

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "projectId" \
    --size 50 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "title" \
    --size 255 \
    --required true

appwrite databases createFloatAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "sourceStartTime" \
    --required true

appwrite databases createFloatAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "sourceEndTime" \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "hookText" \
    --size 2000 \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "viralScore" \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "hookScore" \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "category" \
    --size 50 \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "status" \
    --size 50 \
    --required true

appwrite databases createFloatAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "duration" \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "shorts" \
    --key "createdAt" \
    --size 50 \
    --required true

# ── Collection: long_forms ───────────────────────────────────────
echo "  Creating: long_forms"
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "long_forms" \
    --name "Long Forms" \
    --permission "any" \
    --permission "any" \
    --permission "any" \
    --permission "any"

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "long_forms" \
    --key "projectId" \
    --size 50 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "long_forms" \
    --key "title" \
    --size 255 \
    --required true

appwrite databases createFloatAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "long_forms" \
    --key "targetDuration" \
    --required false

appwrite databases createFloatAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "long_forms" \
    --key "actualDuration" \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "long_forms" \
    --key "status" \
    --size 50 \
    --required true

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "long_forms" \
    --key "chapterCount" \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "long_forms" \
    --key "createdAt" \
    --size 50 \
    --required true

# ── Collection: analysis ─────────────────────────────────────────
echo "  Creating: analysis"
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "analysis" \
    --name "Analysis" \
    --permission "any" \
    --permission "any" \
    --permission "any" \
    --permission "any"

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "analysis" \
    --key "projectId" \
    --size 50 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "analysis" \
    --key "status" \
    --size 50 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "analysis" \
    --key "transcriptText" \
    --size 50000 \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "analysis" \
    --key "sceneCount" \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "analysis" \
    --key "speakerCount" \
    --required false

appwrite databases createFloatAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "analysis" \
    --key "duration" \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "analysis" \
    --key "completedAt" \
    --size 50 \
    --required false

# ── Collection: moments ──────────────────────────────────────────
echo "  Creating: moments"
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --name "Moments" \
    --permission "any" \
    --permission "any" \
    --permission "any" \
    --permission "any"

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --key "projectId" \
    --size 50 \
    --required true

appwrite databases createFloatAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --key "startTime" \
    --required true

appwrite databases createFloatAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --key "endTime" \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --key "type" \
    --size 50 \
    --required true

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --key "score" \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --key "hookScore" \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --key "reasoning" \
    --size 2000 \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "moments" \
    --key "createdAt" \
    --size 50 \
    --required true

# ── Collection: transcripts ──────────────────────────────────────
echo "  Creating: transcripts"
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "transcripts" \
    --name "Transcripts" \
    --permission "any" \
    --permission "any" \
    --permission "any" \
    --permission "any"

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "transcripts" \
    --key "projectId" \
    --size 50 \
    --required true

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "transcripts" \
    --key "fullText" \
    --size 100000 \
    --required false

appwrite databases createStringAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "transcripts" \
    --key "language" \
    --size 10 \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "transcripts" \
    --key "segmentCount" \
    --required false

appwrite databases createIntegerAttribute \
    --databaseId "$DATABASE_ID" \
    --collectionId "transcripts" \
    --key "wordCount" \
    --required false

# ═══════════════════════════════════════════════════════════════════
# Create Storage Buckets
# ═══════════════════════════════════════════════════════════════════

echo ""
echo "📦 Creating storage buckets..."

appwrite storage createBucket \
    --bucketId "videos" \
    --name "Videos" \
    --permissions "any" \
    --permissions "any" \
    --permissions "any" \
    --permissions "any" \
    --maximumFileSize 2097152

appwrite storage createBucket \
    --bucketId "thumbnails" \
    --name "Thumbnails" \
    --permissions "any" \
    --permissions "any" \
    --permissions "any" \
    --permissions "any" \
    --maximumFileSize 5242880

appwrite storage createBucket \
    --bucketId "exports" \
    --name "Exports" \
    --permissions "any" \
    --permissions "any" \
    --permissions "any" \
    --permissions "any" \
    --maximumFileSize 2097152

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Update lib/config/appwrite_config.dart with your Project ID"
echo "   2. Run: flutter pub get"
echo "   3. Run: flutter run"
echo ""
echo "🔗 Appwrite Console: https://cloud.appwrite.io"
