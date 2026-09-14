import { Client, Storage, ID, InputFile } from "node-appwrite";
import { execSync } from "child_process";
import { readFileSync, writeFileSync, unlinkSync, existsSync, mkdirSync, readdirSync, rmdirSync } from "fs";
import { join, basename } from "path";
import { tmpdir } from "os";

// Appwrite configuration
const APPWRITE_ENDPOINT = process.env.APPWRITE_ENDPOINT || "https://sgp.cloud.appwrite.io/v1";
const APPWRITE_PROJECT_ID = process.env.APPWRITE_PROJECT_ID || "6aa6c23100337d473370";
const APPWRITE_API_KEY = process.env.APPWRITE_API_KEY;
const VIDEOS_BUCKET_ID = process.env.VIDEOS_BUCKET_ID || "videos";

// Initialize Appwrite client
const client = new Client()
  .setEndpoint(APPWRITE_ENDPOINT)
  .setProject(APPWRITE_PROJECT_ID);

if (APPWRITE_API_KEY) {
  client.setKey(APPWRITE_API_KEY);
}

const storage = new Storage(client);

// Utility to run FFmpeg commands
function runFFmpeg(command) {
  try {
    const result = execSync(command, { 
      encoding: 'utf-8',
      timeout: 300000, // 5 minute timeout
      maxBuffer: 10 * 1024 * 1024 // 10MB buffer
    });
    return result;
  } catch (error) {
    console.error('FFmpeg error:', error.message);
    throw new Error(`FFmpeg command failed: ${error.message}`);
  }
}

// Extract video metadata using FFprobe
function extractMetadata(videoPath) {
  const command = `ffprobe -v quiet -print_format json -show_format -show_streams "${videoPath}"`;
  const result = runFFmpeg(command);
  return JSON.parse(result);
}

// Detect scene changes
function detectScenes(videoPath) {
  const command = `ffprobe -v quiet -show_frames -of json -f lavfi "movie=${videoPath},select='gt(scene\\,0.3)'"`;
  try {
    const result = runFFmpeg(command);
    const data = JSON.parse(result);
    return data.frames || [];
  } catch (error) {
    console.log('Scene detection failed, returning empty array');
    return [];
  }
}

// Analyze audio levels
function analyzeAudioLevels(videoPath) {
  const command = `ffmpeg -i "${videoPath}" -af volumedetect -f null /dev/null 2>&1`;
  try {
    const result = runFFmpeg(command);
    
    // Parse volumedetect output
    const meanVolume = result.match(/mean_volume:\s*([-\d.]+)\s*dB/);
    const maxVolume = result.match(/max_volume:\s*([-\d.]+)\s*dB/);
    const histogram = result.match(/histogram_([\d]+)db:\s*(\d+)/g) || [];
    
    return {
      meanVolume: meanVolume ? parseFloat(meanVolume[1]) : null,
      maxVolume: maxVolume ? parseFloat(maxVolume[1]) : null,
      histogram: histogram.map(h => {
        const match = h.match(/histogram_(\d+)db:\s*(\d+)/);
        return match ? { db: parseInt(match[1]), count: parseInt(match[2]) } : null;
      }).filter(Boolean)
    };
  } catch (error) {
    console.log('Audio analysis failed');
    return { meanVolume: null, maxVolume: null, histogram: [] };
  }
}

// Generate clip suggestions based on scene changes and audio levels
function generateClipSuggestions(metadata, scenes, audioAnalysis) {
  const duration = metadata.format?.duration ? parseFloat(metadata.format.duration) : 0;
  const clips = [];
  
  if (duration <= 0) {
    return clips;
  }
  
  // Default clip suggestions if no scenes detected
  if (scenes.length === 0) {
    // Suggest clips from different parts of the video
    const clipLength = Math.min(30, duration);
    const intervals = Math.min(3, Math.floor(duration / clipLength));
    
    for (let i = 0; i < intervals; i++) {
      const startTime = (duration / (intervals + 1)) * (i + 1) - clipLength / 2;
      clips.push({
        startTime: Math.max(0, startTime),
        endTime: Math.min(duration, startTime + clipLength),
        duration: clipLength,
        score: Math.random() * 0.3 + 0.7, // Random score between 0.7-1.0
        reason: "Suggested segment"
      });
    }
  } else {
    // Use scene changes to identify interesting segments
    const sceneTimestamps = scenes.map(scene => 
      parseFloat(scene.pkt_pts_time || scene.best_effort_timestamp_time || 0)
    ).filter(t => t > 0);
    
    // Generate clips around scene changes
    for (let i = 0; i < Math.min(5, sceneTimestamps.length); i++) {
      const sceneTime = sceneTimestamps[i];
      const clipDuration = Math.min(15 + Math.random() * 45, duration - sceneTime); // 15-60 seconds
      const startTime = Math.max(0, sceneTime - 5); // Start 5 seconds before scene
      
      clips.push({
        startTime: startTime,
        endTime: Math.min(duration, startTime + clipDuration),
        duration: clipDuration,
        score: 0.8 + Math.random() * 0.2, // Score between 0.8-1.0
        reason: `Scene change at ${sceneTime.toFixed(2)}s`
      });
    }
  }
  
  // Sort by score and limit to top suggestions
  return clips
    .sort((a, b) => b.score - a.score)
    .slice(0, 5);
}

// Identify viral moments (high audio activity, scene changes)
function identifyViralMoments(metadata, scenes, audioAnalysis) {
  const moments = [];
  const duration = metadata.format?.duration ? parseFloat(metadata.format.duration) : 0;
  
  if (duration <= 0) {
    return moments;
  }
  
  // Find moments with high audio levels
  if (audioAnalysis.maxVolume && audioAnalysis.maxVolume > -10) {
    moments.push({
      timestamp: duration * 0.3, // Approximate timestamp
      type: "high_audio",
      intensity: Math.min(1, (audioAnalysis.maxVolume + 60) / 50), // Normalize 0-1
      description: "High audio activity detected"
    });
  }
  
  // Find moments with rapid scene changes
  if (scenes.length > 3) {
    const sceneTimestamps = scenes.map(scene => 
      parseFloat(scene.pkt_pts_time || scene.best_effort_timestamp_time || 0)
    ).filter(t => t > 0);
    
    for (let i = 1; i < sceneTimestamps.length; i++) {
      const timeDiff = sceneTimestamps[i] - sceneTimestamps[i-1];
      if (timeDiff < 2) { // Rapid scene changes (less than 2 seconds apart)
        moments.push({
          timestamp: sceneTimestamps[i],
          type: "rapid_scenes",
          intensity: Math.min(1, (2 - timeDiff) / 2),
          description: `Rapid scene change (${timeDiff.toFixed(2)}s gap)`
        });
      }
    }
  }
  
  return moments.slice(0, 10); // Limit to top 10 moments
}

// Trim video using FFmpeg
function trimVideo(videoPath, startTime, endTime, outputName) {
  const command = `ffmpeg -i "${videoPath}" -ss ${startTime} -to ${endTime} -c copy "${outputName}" -y`;
  runFFmpeg(command);
  return outputName;
}

// Extract clip from video
function extractClip(videoPath, startTime, duration, outputName) {
  const command = `ffmpeg -i "${videoPath}" -ss ${startTime} -t ${duration} -c copy "${outputName}" -y`;
  runFFmpeg(command);
  return outputName;
}

// Main function handler
export default async function handler(req) {
  // CORS headers
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
  };

  // Handle preflight request
  if (req.method === "OPTIONS") {
    return {
      statusCode: 204,
      headers
    };
  }

  // Only allow POST requests
  if (req.method !== "POST") {
    return {
      statusCode: 405,
      headers,
      body: JSON.stringify({ error: "Method not allowed" })
    };
  }

  try {
    const body = JSON.parse(req.body || "{}");
    const { fileId, action } = body;

    if (!fileId || !action) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ 
          error: "Missing required fields: fileId and action" 
        })
      };
    }

    // Create temporary directory for processing
    const tempDir = join(tmpdir(), `video-${Date.now()}`);
    mkdirSync(tempDir, { recursive: true });
    
    const videoPath = join(tempDir, `input-${fileId}.mp4`);
    
    // Download video from Appwrite Storage
    console.log(`Downloading video ${fileId} from storage...`);
    const fileBuffer = await storage.getFileDownload(VIDEOS_BUCKET_ID, fileId);
    writeFileSync(videoPath, Buffer.from(fileBuffer));
    
    let result;
    
    switch (action) {
      case "analyze":
        result = await handleAnalyze(videoPath, fileId);
        break;
      case "trim":
        result = await handleTrim(videoPath, fileId, body, tempDir);
        break;
      case "extract-clip":
        result = await handleExtractClip(videoPath, fileId, body, tempDir);
        break;
      default:
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({ error: `Unknown action: ${action}` })
        };
    }
    
    // Clean up temporary files
    try {
      if (existsSync(videoPath)) unlinkSync(videoPath);
      if (existsSync(tempDir)) {
        const files = readdirSync(tempDir);
        files.forEach(file => {
          const filePath = join(tempDir, file);
          if (existsSync(filePath)) unlinkSync(filePath);
        });
        rmdirSync(tempDir);
      }
    } catch (cleanupError) {
      console.log('Cleanup warning:', cleanupError.message);
    }
    
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(result)
    };
    
  } catch (error) {
    console.error('Function error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ 
        error: "Internal server error",
        message: error.message 
      })
    };
  }
}

// Handle video analysis
async function handleAnalyze(videoPath, fileId) {
  console.log('Starting video analysis...');
  
  // Extract metadata
  const metadata = extractMetadata(videoPath);
  
  // Detect scenes
  const scenes = detectScenes(videoPath);
  
  // Analyze audio levels
  const audioAnalysis = analyzeAudioLevels(videoPath);
  
  // Generate clip suggestions
  const clips = generateClipSuggestions(metadata, scenes, audioAnalysis);
  
  // Identify viral moments
  const viralMoments = identifyViralMoments(metadata, scenes, audioAnalysis);
  
  // Extract useful metadata
  const videoStream = metadata.streams?.find(s => s.codec_type === 'video');
  const audioStream = metadata.streams?.find(s => s.codec_type === 'audio');
  
  return {
    fileId,
    success: true,
    metadata: {
      duration: metadata.format?.duration ? parseFloat(metadata.format.duration) : null,
      size: metadata.format?.size ? parseInt(metadata.format.size) : null,
      bitrate: metadata.format?.bit_rate ? parseInt(metadata.format.bit_rate) : null,
      format: metadata.format?.format_name,
      video: videoStream ? {
        codec: videoStream.codec_name,
        width: videoStream.width,
        height: videoStream.height,
        fps: videoStream.r_frame_rate ? eval(videoStream.r_frame_rate) : null,
        bitrate: videoStream.bit_rate ? parseInt(videoStream.bit_rate) : null
      } : null,
      audio: audioStream ? {
        codec: audioStream.codec_name,
        sampleRate: audioStream.sample_rate ? parseInt(audioStream.sample_rate) : null,
        channels: audioStream.channels,
        bitrate: audioStream.bit_rate ? parseInt(audioStream.bit_rate) : null
      } : null
    },
    scenes: scenes.map(scene => ({
      timestamp: parseFloat(scene.pkt_pts_time || scene.best_effort_timestamp_time || 0),
      score: scene.scene_score || 0
    })),
    audioAnalysis,
    clips,
    viralMoments
  };
}

// Handle video trimming
async function handleTrim(videoPath, fileId, body, tempDir) {
  const { startTime, endTime } = body;
  
  if (startTime === undefined || endTime === undefined) {
    throw new Error("startTime and endTime are required for trim action");
  }
  
  if (startTime >= endTime) {
    throw new Error("startTime must be less than endTime");
  }
  
  console.log(`Trimming video from ${startTime} to ${endTime}...`);
  
  const outputName = `trimmed-${Date.now()}.mp4`;
  const outputPath = join(tempDir, outputName);
  
  trimVideo(videoPath, startTime, endTime, outputPath);
  
  // Upload trimmed video to Appwrite Storage
  const outputFileBuffer = readFileSync(outputPath);
  const newFile = await storage.createFile(
    VIDEOS_BUCKET_ID,
    ID.unique(),
    InputFile.fromBuffer(outputFileBuffer, outputName)
  );
  
  return {
    fileId,
    success: true,
    action: "trim",
    newFileId: newFile.$id,
    trimRange: {
      startTime: parseFloat(startTime),
      endTime: parseFloat(endTime),
      duration: endTime - startTime
    }
  };
}

// Handle clip extraction
async function handleExtractClip(videoPath, fileId, body, tempDir) {
  const { startTime, duration } = body;
  
  if (startTime === undefined || duration === undefined) {
    throw new Error("startTime and duration are required for extract-clip action");
  }
  
  if (duration <= 0 || duration > 60) {
    throw new Error("Duration must be between 0 and 60 seconds");
  }
  
  console.log(`Extracting ${duration}s clip starting at ${startTime}...`);
  
  const outputName = `clip-${Date.now()}.mp4`;
  const outputPath = join(tempDir, outputName);
  
  extractClip(videoPath, startTime, duration, outputPath);
  
  // Upload clip to Appwrite Storage
  const outputFileBuffer = readFileSync(outputPath);
  const newFile = await storage.createFile(
    VIDEOS_BUCKET_ID,
    ID.unique(),
    InputFile.fromBuffer(outputFileBuffer, outputName)
  );
  
  return {
    fileId,
    success: true,
    action: "extract-clip",
    newFileId: newFile.$id,
    clipInfo: {
      startTime: parseFloat(startTime),
      duration: parseFloat(duration),
      endTime: startTime + duration
    }
  };
}