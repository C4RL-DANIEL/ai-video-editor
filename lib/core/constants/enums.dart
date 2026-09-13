// ---------------------------------------------------------------------------
// Project & Video Enums
// ---------------------------------------------------------------------------

/// Lifecycle status of a video project from draft through export.
enum ProjectStatus {
  draft,
  inProgress,
  rendering,
  exported,
  shared,
  archived,
  failed,
}

/// Container & codec formats for video output.
enum VideoFormat {
  mp4H264,
  mp4H265,
  movProRes,
  movHevc,
  webmVP9,
  aviMPEG,
  mkvH264,
  gifAnimated,
  mp4AV1,
}

/// Aspect ratio presets common in professional video editors.
enum VideoAspectRatio {
  landscape16x9,
  portrait9x16,
  square1x1,
  cinema21x9,
  vertical4x5,
  standard4x3,
  custom,
}

/// Resolution presets.
enum VideoResolution {
  r480p,
  r720p,
  r1080p,
  r1440p,
  r2k,
  r4k,
  r8k,
  custom,
}

// ---------------------------------------------------------------------------
// AI Pipeline Enums
// ---------------------------------------------------------------------------

/// Processing job status across the AI pipeline.
enum JobStatus {
  queued,
  initializing,
  processing,
  finalizing,
  completed,
  failed,
  cancelled,
  retrying,
}

/// Granular stage inside the AI analysis / processing pipeline.
enum AnalysisStage {
  uploading,
  analyzing,
  sceneDetection,
  transcription,
  momentDetection,
  contentAnalysis,
  smartCuts,
  brollSuggestion,
  colorGrading,
  audioEnhancement,
  captionGeneration,
  styleTransfer,
  musicGeneration,
  qualityCheck,
  packaging,
}

// ---------------------------------------------------------------------------
// Creative / Content Enums
// ---------------------------------------------------------------------------

/// Short-form content creation styles (TikTok / Reels / Shorts).
enum ShortStyle {
  viralHook,
  tutorial,
  storytelling,
  reactionDuet,
  beforeAfter,
  montage,
  talkingHead,
  textOverlay,
  behindTheScenes,
  productShowcase,
  listicle,
  podcastClip,
  asmr,
  transition,
  greenScreen,
}

/// Intensity of AI-assisted editing suggestions.
enum EditIntensity {
  minimal,     // lightest touch — only essential cuts
  subtle,      // smooth transitions, gentle color correction
  moderate,    // balanced AI intervention
  aggressive,  // heavy AI editing, bold transitions
  cinematic,   // cinematic grade — dramatic pacing & grading
}

// ---------------------------------------------------------------------------
// Export & Encoding Enums
// ---------------------------------------------------------------------------

/// Target export format, broader than raw codec selection.
enum ExportFormat {
  // Social presets
  tiktok,
  youtubeLandscape,
  youtubeShorts,
  instagramReels,
  instagramFeed,
  instagramStory,
  facebookFeed,
  facebookStory,
  twitterFeed,
  linkedinFeed,
  pinterestPin,

  // Professional
  broadcastHd,
  broadcastUhd,
  cinemaDcp,
  proRes422,
  proRes4444,

  // Web
  webMp4,
  webMWebm,
  hlsStreaming,

  // Archive
  masterLossless,
  proxyEdit,
}

/// Export quality / resolution preset.
enum ExportQuality {
  draft,       // fast, low-res preview
  standard,    // 1080p, balanced
  high,        // 4K, higher bitrate
  ultra,       // maximum quality, large file
  custom,
}

// ---------------------------------------------------------------------------
// Content Analysis Enums
// ---------------------------------------------------------------------------

/// Category of content detected by AI analysis.
enum ContentCategory {
  // People & Faces
  faceDetected,
  multipleFaces,
  interview,
  talkingHead,
  crowd,

  // Scenes & Environments
  indoor,
  outdoor,
  urban,
  nature,
  studio,
  stage,

  // Objects
  product,
  food,
  animal,
  vehicle,
  text,
  graphic,

  // Activities
  action,
  sports,
  cooking,
  travel,
  dance,
  performance,

  // Mood / Atmosphere
  dramatic,
  cheerful,
  calm,
  energetic,
  dark,
  bright,

  // Technical
  transition,
  titleCard,
  blackFrame,
  staticNoise,
  glitch,
}

/// Type of a detected highlight moment within video content.
enum MomentType {
  highlight,
  hook,
  climax,
  transition,
  funny,
  emotional,
  informative,
  boring,       // potential cut candidate
  silence,      // dead air / pause
  musicDrop,    // beat drop alignment point
  speechStart,
  speechEnd,
  sceneChange,
  objectEntry,
  textAppears,
  faceCloseup,
}

// ---------------------------------------------------------------------------
// Audio Enums
// ---------------------------------------------------------------------------

/// Type of audio track within the timeline.
enum AudioTrackType {
  original,       // source audio from video clip
  voiceover,      // recorded or AI-generated narration
  backgroundMusic,
  soundEffect,
  ambient,        // background / room tone
  aiGenerated,    // fully AI-created audio
  podcast,
  podcastHost,
  podcastGuest,
  podcastIntro,
}

/// Audio quality presets.
enum AudioQuality {
  low,       // 128 kbps, 44.1 kHz
  standard,  // 192 kbps, 48 kHz
  high,      // 320 kbps, 48 kHz
  lossless,  // PCM / FLAC
}

/// Voice for text-to-speech generation.
enum TTSVoice {
  maleDeep,
  maleWarm,
  maleYoung,
  femaleCrisp,
  femaleWarm,
  femaleYoung,
  neutral,
  narrator,
  news,
  custom,
}

// ---------------------------------------------------------------------------
// Caption & Subtitle Enums
// ---------------------------------------------------------------------------

/// Visual style of burned-in captions / subtitles.
enum CaptionStyle {
  defaultClean,
  boldHighlight,     // karaoke-style word highlighting
  minimal,
  modern,            // subtle background pill
  bold,              // large bold text, centered
  outlined,          // stroke outline text
  neon,              // glowing neon effect
  typewriter,        // letter-by-letter animation
  wordByWord,        // each word appears on beat
  twoLine,           // max two lines at bottom
  topThird,          // upper third placement
  centered,
  custom,
}

/// Supported subtitle export format.
enum SubtitleFormat {
  srt,
  vtt,
  ass,
  ssa,
  ttml,
  burnIn,  // hardcoded into video frames
}

// ---------------------------------------------------------------------------
// UI / Processing State Enums
// ---------------------------------------------------------------------------

/// Generic processing state for async UI widgets.
enum ProcessingState {
  idle,
  loading,
  processing,
  uploading,
  downloading,
  success,
  error,
  cancelled,
}

// ---------------------------------------------------------------------------
// User & Subscription Enums
// ---------------------------------------------------------------------------

/// Subscription tier.
enum SubscriptionTier {
  free,
  pro,
  studio,
  enterprise,
}

/// User role within a collaborative project.
enum ProjectRole {
  owner,
  editor,
  viewer,
  commenter,
}
