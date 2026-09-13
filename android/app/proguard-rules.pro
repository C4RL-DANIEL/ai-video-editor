# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Appwrite
-keep class io.appwrite.** { *; }
-dontwarn io.appwrite.**

# Keep annotation
-keepattributes *Annotation*
