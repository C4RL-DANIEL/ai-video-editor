#!/bin/bash

# Example usage of the video processing function
# Replace these values with your actual Appwrite endpoint and file ID

ENDPOINT="https://sgp.cloud.appwrite.io/v1"
PROJECT_ID="6aa6c23100337d473370"
FUNCTION_ID="process-video"
FILE_ID="YOUR_VIDEO_FILE_ID"

echo "🎬 Video Processing Function Examples"
echo "======================================"

# Example 1: Analyze a video
echo ""
echo "1️⃣  Analyzing video..."
curl -X POST "$ENDPOINT/functions/$FUNCTION_ID/executions" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: $PROJECT_ID" \
  -d "{
    \"fileId\": \"$FILE_ID\",
    \"action\": \"analyze\"
  }" | jq .

# Example 2: Trim a video (from 10s to 30s)
echo ""
echo "2️⃣  Trimming video (10s to 30s)..."
curl -X POST "$ENDPOINT/functions/$FUNCTION_ID/executions" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: $PROJECT_ID" \
  -d "{
    \"fileId\": \"$FILE_ID\",
    \"action\": \"trim\",
    \"startTime\": 10,
    \"endTime\": 30
  }" | jq .

# Example 3: Extract a 30-second clip starting at 25s
echo ""
echo "3️⃣  Extracting 30s clip starting at 25s..."
curl -X POST "$ENDPOINT/functions/$FUNCTION_ID/executions" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: $PROJECT_ID" \
  -d "{
    \"fileId\": \"$FILE_ID\",
    \"action\": \"extract-clip\",
    \"startTime\": 25,
    \"duration\": 30
  }" | jq .

echo ""
echo "✅ Examples completed!"
echo ""
echo "📝 Notes:"
echo "- Replace YOUR_VIDEO_FILE_ID with an actual file ID from your 'videos' bucket"
echo "- Install jq for pretty JSON output: apt-get install jq"
echo "- You need an Appwrite API key with storage permissions"