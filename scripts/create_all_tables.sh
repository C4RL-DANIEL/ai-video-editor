#!/bin/bash
# Continue on errors (tables may already exist)

DB="6aa6c27e000c9c9ccc71"

echo "🎬 AI Video Editor — Creating Appwrite Tables"
echo "Database: $DB"
echo ""

# ═══════════════════════════════════════════════════════════════════
# TABLE: projects
# ═══════════════════════════════════════════════════════════════════
echo "📋 Creating table: projects"
appwrite tablesdb create-table --database-id "$DB" --table-id "projects" --name "Projects" --enabled --row-security --force 2>&1

appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "projects" --key "name" --size 255 --required --force 2>&1
appwrite tablesdb create-longtext-column --database-id "$DB" --table-id "projects" --key "description" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "projects" --key "status" --size 50 --required --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "projects" --key "sourceType" --size 20 --required --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "projects" --key "sourcePath" --size 500 --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "projects" --key "sourceUrl" --size 2000 --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "projects" --key "shortsCount" --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "projects" --key "longFormCount" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "projects" --key "createdAt" --size 50 --required --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "projects" --key "updatedAt" --size 50 --required --force 2>&1
echo "✅ projects done"

# ═══════════════════════════════════════════════════════════════════
# TABLE: shorts
# ═══════════════════════════════════════════════════════════════════
echo "📋 Creating table: shorts"
appwrite tablesdb create-table --database-id "$DB" --table-id "shorts" --name "Shorts" --enabled --row-security --force 2>&1

appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "shorts" --key "projectId" --size 50 --required --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "shorts" --key "title" --size 255 --required --force 2>&1
appwrite tablesdb create-float-column --database-id "$DB" --table-id "shorts" --key "sourceStartTime" --required --force 2>&1
appwrite tablesdb create-float-column --database-id "$DB" --table-id "shorts" --key "sourceEndTime" --required --force 2>&1
appwrite tablesdb create-longtext-column --database-id "$DB" --table-id "shorts" --key "hookText" --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "shorts" --key "viralScore" --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "shorts" --key "hookScore" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "shorts" --key "category" --size 50 --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "shorts" --key "status" --size 50 --required --force 2>&1
appwrite tablesdb create-float-column --database-id "$DB" --table-id "shorts" --key "duration" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "shorts" --key "createdAt" --size 50 --required --force 2>&1
echo "✅ shorts done"

# ═══════════════════════════════════════════════════════════════════
# TABLE: long_forms
# ═══════════════════════════════════════════════════════════════════
echo "📋 Creating table: long_forms"
appwrite tablesdb create-table --database-id "$DB" --table-id "long_forms" --name "Long Forms" --enabled --row-security --force 2>&1

appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "long_forms" --key "projectId" --size 50 --required --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "long_forms" --key "title" --size 255 --required --force 2>&1
appwrite tablesdb create-float-column --database-id "$DB" --table-id "long_forms" --key "targetDuration" --required=false --force 2>&1
appwrite tablesdb create-float-column --database-id "$DB" --table-id "long_forms" --key "actualDuration" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "long_forms" --key "status" --size 50 --required --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "long_forms" --key "chapterCount" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "long_forms" --key "createdAt" --size 50 --required --force 2>&1
echo "✅ long_forms done"

# ═══════════════════════════════════════════════════════════════════
# TABLE: analysis
# ═══════════════════════════════════════════════════════════════════
echo "📋 Creating table: analysis"
appwrite tablesdb create-table --database-id "$DB" --table-id "analysis" --name "Analysis" --enabled --row-security --force 2>&1

appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "analysis" --key "projectId" --size 50 --required --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "analysis" --key "status" --size 50 --required --force 2>&1
appwrite tablesdb create-longtext-column --database-id "$DB" --table-id "analysis" --key "transcriptText" --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "analysis" --key "sceneCount" --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "analysis" --key "speakerCount" --required=false --force 2>&1
appwrite tablesdb create-float-column --database-id "$DB" --table-id "analysis" --key "duration" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "analysis" --key "completedAt" --size 50 --required=false --force 2>&1
echo "✅ analysis done"

# ═══════════════════════════════════════════════════════════════════
# TABLE: moments
# ═══════════════════════════════════════════════════════════════════
echo "📋 Creating table: moments"
appwrite tablesdb create-table --database-id "$DB" --table-id "moments" --name "Moments" --enabled --row-security --force 2>&1

appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "moments" --key "projectId" --size 50 --required --force 2>&1
appwrite tablesdb create-float-column --database-id "$DB" --table-id "moments" --key "startTime" --required --force 2>&1
appwrite tablesdb create-float-column --database-id "$DB" --table-id "moments" --key "endTime" --required --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "moments" --key "type" --size 50 --required --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "moments" --key "score" --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "moments" --key "hookScore" --required=false --force 2>&1
appwrite tablesdb create-longtext-column --database-id "$DB" --table-id "moments" --key "reasoning" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "moments" --key "createdAt" --size 50 --required --force 2>&1
echo "✅ moments done"

# ═══════════════════════════════════════════════════════════════════
# TABLE: transcripts
# ═══════════════════════════════════════════════════════════════════
echo "📋 Creating table: transcripts"
appwrite tablesdb create-table --database-id "$DB" --table-id "transcripts" --name "Transcripts" --enabled --row-security --force 2>&1

appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "transcripts" --key "projectId" --size 50 --required --force 2>&1
appwrite tablesdb create-longtext-column --database-id "$DB" --table-id "transcripts" --key "fullText" --required=false --force 2>&1
appwrite tablesdb create-varchar-column --database-id "$DB" --table-id "transcripts" --key "language" --size 10 --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "transcripts" --key "segmentCount" --required=false --force 2>&1
appwrite tablesdb create-integer-column --database-id "$DB" --table-id "transcripts" --key "wordCount" --required=false --force 2>&1
echo "✅ transcripts done"

# ═══════════════════════════════════════════════════════════════════
# STORAGE BUCKETS
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "📦 Creating storage buckets..."

echo "  Creating: videos (20MB limit)"
appwrite storage create-bucket --bucket-id "videos" --name "Videos" --enabled --maximum-file-size 20971520 --force 2>&1

echo "  Creating: thumbnails (5MB limit)"
appwrite storage create-bucket --bucket-id "thumbnails" --name "Thumbnails" --enabled --maximum-file-size 5242880 --force 2>&1

echo "  Creating: exports (20MB limit)"
appwrite storage create-bucket --bucket-id "exports" --name "Exports" --enabled --maximum-file-size 20971520 --force 2>&1

echo ""
echo "✅ ALL DONE!"
echo ""
echo "📊 Tables:"
appwrite tablesdb list-tables --database-id "$DB" --json 2>&1
echo ""
echo "📦 Buckets:"
appwrite storage list-buckets --json 2>&1
