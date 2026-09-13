# Firebase Setup Guide

## Prerequisites
1. A Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Flutter CLI installed
3. Firebase CLI installed (`npm install -g firebase-tools`)

## Step 1: Create Firebase Project
1. Go to Firebase Console → Add Project
2. Enable Google Analytics (optional)
3. Note your project ID

## Step 2: Enable Firebase Services

### Authentication
1. Go to Authentication → Sign-in method
2. Enable **Email/Password**
3. Enable **Google** (add support email)

### Firestore Database
1. Go to Firestore Database → Create Database
2. Start in **test mode** (update rules for production)
3. Choose a location closest to your users

### Storage
1. Go to Storage → Get Started
2. Start in **test mode**

## Step 3: Add Firebase to Flutter

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will:
- Generate `lib/firebase_options.dart`
- Download `google-services.json` (Android)
- Download `GoogleService-Info.plist` (iOS)

## Step 4: Android Setup

1. Ensure `android/app/build.gradle` has:
```gradle
plugins {
    id "com.google.gms.google-services"
}
```

2. Ensure `android/build.gradle` has:
```gradle
dependencies {
    classpath "com.google.gms:google-services:4.4.0"
}
```

## Step 5: iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Drag `GoogleService-Info.plist` into the Runner directory
3. Ensure Bundle Identifier matches your Firebase config

## Step 6: Update main.dart

Replace the TODO in `main.dart` with:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: AiVideoEditorApp()));
}
```

## Step 7: Firestore Security Rules

### Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /projects/{projectId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /projects/{projectId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 8: Environment Variables

1. Copy `.env.example` to `.env`
2. Fill in your Firebase configuration values
3. Never commit `.env` to version control

## Production Checklist
- [ ] Update Firestore rules to restrict by userId
- [ ] Enable App Check for Firestore and Storage
- [ ] Set up Firebase App Distribution for beta testing
- [ ] Configure Cloud Functions for server-side AI processing
- [ ] Set up Firebase Hosting for web (if applicable)
