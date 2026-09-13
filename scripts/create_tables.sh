#!/bin/bash
set -e

DB_ID="6aa6c27e000c9c9ccc71"

echo "🎬 Creating Appwrite Tables..."
echo "Database: $DB_ID"
echo ""

# ── Table: projects ──────────────────────────────────────────────
echo "📋 Creating: projects"
appwrite tablesdb create-table \
  --database-id "$DB_ID" \
  --table-id "projects" \
  --name "Projects" \
  --enabled \
  --row-security \
  --columns '[{"key":"name","type":"varchar","size":255,"required":true},{"key":"description","type":"longtext","required":false},{"key":"status","type":"varchar","size":50,"required":true},{"key":"sourceType","type":"varchar","size":20,"required":true},{"key":"sourcePath","type":"varchar","size":500,"required":false},{"key":"sourceUrl","type":"varchar","size":2000,"required":false},{"key":"shortsCount","type":"integer","required":false},{"key":"longFormCount","type":"integer","required":false},{"key":"createdAt","type":"varchar","size":50,"required":true},{"key":"updatedAt","type":"varchar","size":50,"required":true}]' \
  --force

# ── Table: shorts ───────────────────────────────────────────────
echo "📋 Creating: shorts"
appwrite tablesdb create-table \
  --database-id "$DB_ID" \
  --table-id "shorts" \
  --name "Shorts" \
  --enabled \
  --row-security \
  --columns '[{"key":"projectId","type":"varchar","size":50,"required":true},{"key":"title","type":"varchar","size":255,"required":true},{"key":"sourceStartTime","type":"float","required":true},{"key":"sourceEndTime","type":"float","required":true},{"key":"hookText","type":"longtext","required":false},{"key":"viralScore","type":"integer","required":false},{"key":"hookScore","type":"integer","required":false},{"key":"category","type":"varchar","size":50,"required":false},{"key":"status","type":"varchar","size":50,"required":true},{"key":"duration","type":"float","required":false},{"key":"createdAt","type":"varchar","size":50,"required":true}]' \
  --force

# ── Table: long_forms ───────────────────────────────────────────
echo "📋 Creating: long_forms"
appwrite tablesdb create-table \
  --database-id "$DB_ID" \
  --table-id "long_forms" \
  --name "Long Forms" \
  --enabled \
  --row-security \
  --columns '[{"key":"projectId","type":"varchar","size":50,"required":true},{"key":"title","type":"varchar","size":255,"required":true},{"key":"targetDuration","type":"float","required":false},{"key":"actualDuration","type":"float","required":false},{"key":"status","type":"varchar","size":50,"required":true},{"key":"chapterCount","type":"integer","required":false},{"key":"createdAt","type":"varchar","size":50,"required":true}]' \
  --force

# ── Table: analysis ─────────────────────────────────────────────
echo "📋 Creating: analysis"
appwrite tablesdb create-table \
  --database-id "$DB_ID" \
  --table-id "analysis" \
  --name "Analysis" \
  --enabled \
  --row-security \
  --columns '[{"key":"projectId","type":"varchar","size":50,"required":true},{"key":"status","type":"varchar","size":50,"required":true},{"key":"transcriptText","type":"longtext","required":false},{"key":"sceneCount","type":"integer","required":false},{"key":"speakerCount","type":"integer","required":false},{"key":"duration","type":"float","required":false},{"key":"completedAt","type":"varchar","size":50,"required":false}]' \
  --force

# ── Table: moments ──────────────────────────────────────────────
echo "📋 Creating: moments"
appwrite tablesdb create-table \
  --database-id "$DB_ID" \
  --table-id "moments" \
  --name "Moments" \
  --enabled \
  --row-security \
  --columns '[{"key":"projectId","type":"varchar","size":50,"required":true},{"key":"startTime","type":"float","required":true},{"key":"endTime","type":"float","required":true},{"key":"type","type":"varchar","size":50,"required":true},{"key":"score","type":"integer","required":false},{"key":"hookScore","type":"integer","required":false},{"key":"reasoning","type":"longtext","required":false},{"key":"createdAt","type":"varchar","size":50,"required":true}]' \
  --force

# ── Table: transcripts ──────────────────────────────────────────
echo "📋 Creating: transcripts"
appwrite tablesdb create-table \
  --database-id "$DB_ID" \
  --table-id "transcripts" \
  --name "Transcripts" \
  --enabled \
  --row-security \
  --columns '[{"key":"projectId","type":"varchar","size":50,"required":true},{"key":"fullText","type":"longtext","required":false},{"key":"language","type":"varchar","size":10,"required":false},{"key":"segmentCount","type":"integer","required":false},{"key":"wordCount","type":"integer","required":false}]' \
  --force

# ═══════════════════════════════════════════════════════════════════
# Storage Buckets
# ═══════════════════════════════════════════════════════════════════

echo ""
echo "📦 Creating storage buckets..."

echo "  Creating: videos"
appwrite storage create-bucket \
  --bucket-id "videos" \
  --name "Videos" \
  --enabled \
  --maximum-file-size 20971520 \
  --allowed-extensions '["mp4","mov","avi","mkv","webm"]' \
  --permissions '["read(any)","write(any)"]' \
  --force

echo "  Creating: thumbnails"
appwrite storage create-bucket \
  --bucket-id "thumbnails" \
  --name "Thumbnails" \
  --enabled \
  --maximum-file-size 5242880 \
  --allowed-extensions '["jpg","jpeg","png","webp"]' \
  --permissions '["read(any)","write(any)"]' \
  --force

echo "  Creating: exports"
appwrite storage create-bucket \
  --bucket-id "exports" \
  --name "Exports" \
  --enabled \
  --maximum-file-size 20971520 \
  --allowed-extensions '["mp4","mov","avi","mkv","webm"]' \
  --permissions '["read(any)","write(any)"]' \
  --force

echo ""
echo "✅ All tables and buckets created!"
echo ""
appwrite tablesdb list-tables --database-id "$DB_ID" --json 2>&1
echo ""
appwrite storage list-buckets --json 2>&1
