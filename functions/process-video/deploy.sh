#!/bin/bash

# Deployment script for video processing function
set -e

echo "🚀 Deploying video processing function to Appwrite..."

# Check if Appwrite CLI is installed
if ! command -v appwrite &> /dev/null; then
    echo "❌ Appwrite CLI not found. Installing..."
    npm install -g appwrite-cli
fi

# Check if we're logged in
echo "🔐 Checking Appwrite authentication..."
if ! appwrite whoami &> /dev/null; then
    echo "❌ Not logged in to Appwrite. Please run: appwrite login"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install --omit=dev

# Push the function
echo "📤 Pushing function to Appwrite..."
appwrite push function --function-id process-video --force

echo ""
echo "✅ Function deployed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Set the APPWRITE_API_KEY in your Appwrite console"
echo "2. The function will be triggered on storage file creation/update"
echo "3. Test with: curl -X POST <YOUR_ENDPOINT>/functions/process-video/executions \\"
echo "   -H 'Content-Type: application/json' \\"
echo "   -d '{\"fileId\": \"YOUR_FILE_ID\", \"action\": \"analyze\"}'"
echo ""
echo "📚 See README.md for full API documentation"