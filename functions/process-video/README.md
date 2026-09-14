# Video Processing Function

This Appwrite Function provides comprehensive video analysis and processing capabilities for the AI Video Editor application.

## Features

1. **Video Analysis** - Extracts metadata, detects scenes, analyzes audio, and generates clip suggestions
2. **Video Trimming** - Trim videos to specific time ranges
3. **Clip Extraction** - Extract short clips (15-60 seconds) from videos

## API Usage

### Analyze Video

```bash
curl -X POST https://YOUR_APPWRITE_ENDPOINT/functions/process-video/executions \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: YOUR_PROJECT_ID" \
  -d '{
    "fileId": "VIDEO_FILE_ID",
    "action": "analyze"
  }'
```

**Response:**
```json
{
  "fileId": "VIDEO_FILE_ID",
  "success": true,
  "metadata": {
    "duration": 120.5,
    "size": 52428800,
    "bitrate": 3500000,
    "format": "mov,mp4,m4a,3gp,3g2,mj2",
    "video": {
      "codec": "h264",
      "width": 1920,
      "height": 1080,
      "fps": 30.0,
      "bitrate": 3000000
    },
    "audio": {
      "codec": "aac",
      "sampleRate": 44100,
      "channels": 2,
      "bitrate": 128000
    }
  },
  "scenes": [
    {
      "timestamp": 15.2,
      "score": 0.85
    }
  ],
  "audioAnalysis": {
    "meanVolume": -23.5,
    "maxVolume": -8.2,
    "histogram": []
  },
  "clips": [
    {
      "startTime": 10.0,
      "endTime": 45.0,
      "duration": 35.0,
      "score": 0.92,
      "reason": "Scene change at 15.20s"
    }
  ],
  "viralMoments": [
    {
      "timestamp": 35.5,
      "type": "high_audio",
      "intensity": 0.85,
      "description": "High audio activity detected"
    }
  ]
}
```

### Trim Video

```bash
curl -X POST https://YOUR_APPWRITE_ENDPOINT/functions/process-video/executions \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: YOUR_PROJECT_ID" \
  -d '{
    "fileId": "VIDEO_FILE_ID",
    "action": "trim",
    "startTime": 10.5,
    "endTime": 30.2
  }'
```

**Response:**
```json
{
  "fileId": "VIDEO_FILE_ID",
  "success": true,
  "action": "trim",
  "newFileId": "NEW_VIDEO_FILE_ID",
  "trimRange": {
    "startTime": 10.5,
    "endTime": 30.2,
    "duration": 19.7
  }
}
```

### Extract Clip

```bash
curl -X POST https://YOUR_APPWRITE_ENDPOINT/functions/process-video/executions \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: YOUR_PROJECT_ID" \
  -d '{
    "fileId": "VIDEO_FILE_ID",
    "action": "extract-clip",
    "startTime": 25.0,
    "duration": 30
  }'
```

**Response:**
```json
{
  "fileId": "VIDEO_FILE_ID",
  "success": true,
  "action": "extract-clip",
  "newFileId": "NEW_CLIP_FILE_ID",
  "clipInfo": {
    "startTime": 25.0,
    "duration": 30,
    "endTime": 55.0
  }
}
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `APPWRITE_ENDPOINT` | Appwrite API endpoint | `https://sgp.cloud.appwrite.io/v1` |
| `APPWRITE_PROJECT_ID` | Appwrite project ID | `6aa6c23100337d473370` |
| `APPWRITE_API_KEY` | Appwrite API key with storage permissions | Required |
| `VIDEOS_BUCKET_ID` | Storage bucket ID for videos | `videos` |

## Deployment

1. Install Appwrite CLI globally: `npm install -g appwrite-cli`
2. Login to Appwrite: `appwrite login`
3. Push the function: `appwrite push function --force`
4. Set environment variables in Appwrite console
5. Activate the function

## Error Handling

The function includes comprehensive error handling for:
- Invalid request parameters
- File not found in storage
- FFmpeg processing errors
- Storage upload/download failures

All errors return structured JSON with error messages for debugging.

## Technical Details

- Uses FFmpeg and FFprobe for video/audio processing
- Scene detection uses FFmpeg's scene change filter with threshold 0.3
- Audio analysis uses FFmpeg's volumedetect filter
- Clip suggestions are algorithmically generated based on scene changes and audio levels
- Viral moments are identified by high audio activity and rapid scene changes
- Temporary files are automatically cleaned up after processing
- Supports videos up to 5 minutes (300 second timeout)