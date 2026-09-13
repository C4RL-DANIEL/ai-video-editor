# AI Video Editor & Content Repurposing Platform

A production-ready Flutter application for AI-powered video editing and content repurposing.

## Features

### Core Capabilities
- **Video Upload & Link Ingestion** — Upload files or paste video links
- **Full Video Understanding** — Visual, audio, and semantic analysis
- **Viral Moment Detection** — AI scores and ranks content moments
- **Shorts Generation** — Automatically create YouTube Shorts
- **Long-Form Video Builder** — Construct coherent YouTube videos
- **Professional Editor** — Multi-track timeline editor
- **AI Commentary** — Original commentary generation
- **Dynamic Captions** — Word-level animated captions
- **Hook Lab** — Generate and A/B test hook variations
- **Reference Style** — Learn from reference editing styles
- **Quality Control** — Automated QC with self-critique
- **Watermark-Free Export** — No app branding on exports

### Editing Styles
- High-Energy Commentary (default)
- Clean Professional
- Dramatic Cinematic
- Storytelling
- Maximum Retention

### Export Formats
- YouTube Shorts (9:16)
- YouTube Long-Form (16:9)
- TikTok
- Instagram Reels
- Custom

## Architecture

```
lib/
├── core/
│   ├── constants/        # App constants, enums
│   ├── di/               # Dependency injection
│   ├── navigation/       # GoRouter routing
│   ├── network/          # Dio API client
│   ├── theme/            # Design system
│   └── utils/            # Utility functions
├── config/
│   └── app_config.dart   # App configuration
├── features/
│   ├── splash/           # Splash screen
│   ├── auth/             # Login/Register
│   ├── dashboard/        # Main dashboard shell
│   ├── projects/         # Project management
│   ├── upload/           # File/link upload
│   ├── analysis/         # Video analysis & content map
│   ├── shorts/           # Shorts discovery & preview
│   ├── editor/           # Professional editor
│   ├── longform/         # Long-form builder
│   └── settings/         # App settings
├── shared/
│   ├── models/           # Shared data models
│   ├── widgets/          # Reusable UI components
│   └── extensions/       # Dart extensions
└── main.dart             # App entry point
```

## Tech Stack
- **Flutter** 3.x
- **Riverpod** for state management
- **GoRouter** for navigation
- **Dio** for networking
- **Phosphor Icons** for iconography
- **Google Fonts** (Inter) for typography

## Design System
- Dark theme primary (#0D0D0F background)
- Accent blue (#3B82F6)
- Premium professional creative tool aesthetic
- Responsive layouts for phone, tablet, and desktop

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Run the app
flutter run

# Build for release
flutter build apk
flutter build ios
```

## Project Structure
This follows a feature-based architecture with clean separation:
- **models/** — Data classes
- **presentation/** — UI screens and widgets
- **services/** — API calls and business logic
- **providers/** — Riverpod state management

## Pipeline Stages
1. Upload → Validate → Ingest
2. Transcribe → Vision Analysis → Audio Analysis
3. Semantic Analysis → Content Map → Score Moments
4. Discover Shorts → Short Edit Plans
5. Long-Form Story Builder
6. Commentary → Captions → Sound Design
7. Edit → Render → Quality Control
8. Auto-Fix → Re-render → Export
